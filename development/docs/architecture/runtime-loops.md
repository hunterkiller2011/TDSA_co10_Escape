# Architecture — Runtime Loops

_Last updated: 2026-07-02 (local)_ · _Status: active (integration — draft)_

> The **recurring control loops** that run co10_Escape after boot: the Chronos scheduler and its jobs, the
> SearchLeader escalation clock, the detection triggers, the mission-flow poll triggers, the client task
> triggers, the war-crime decay, the per-group AI waypoint loop, and the EscapeSurprises scheduler. This
> is the "function logic loops" half of the integration set.
>
> Companions: **[lifecycle-and-timeline.md](lifecycle-and-timeline.md)** (when each loop starts — mostly
> phase [P5](lifecycle-and-timeline.md#p5--runtime-steady-state)) and
> **[state-and-data-flow.md](state-and-data-flow.md)** (the signals they read/write). Per-file detail is
> in the [code-reference](../../code-reference/README.md).

## The recurring theme: triggers-as-timers

Almost every loop here is built on **Arma `EmptyDetector` triggers used as clocks**, not `while` loops.
A trigger with a zero area, an interval, and a condition string is the mission's idiomatic periodic timer:
the engine evaluates the condition every interval and runs the activation statement. Three variants recur:

- **Poll trigger** — condition tests mission state; activation acts once when it flips (mission-flow ends,
  task states).
- **Sensor trigger** — condition tests world/AI state; activation spawns a handler (player detection).
- **Self-resetting tick** — a boolean flag toggled between activation/deactivation makes a trigger
  re-fire forever at a fixed cadence (Chronos heartbeat, SearchLeader tick).

There are only **two real `while` loops** (war-crime decay; the Chronos arming `while(isNil …)` blocks in
initServer), plus `spawn`+`sleep` threads. **Porting note up front:** every one of these becomes a
periodic *system update* / `CallLater(..., repeat)` in Enfusion — the trigger-as-timer hack goes away.

---

## L1 — Chronos heartbeat & jobs `[S]`

The mission's general-purpose scheduler (per-file: [Chronos.md](../../code-reference/Chronos.md)).

- **Clock:** one `EmptyDetector` trigger created by `fn_Chronos_Init.sqf` (postInit, server-only), interval
  **`A3E_CronTime` = 5 s**; its statement is `"A3E_CronTick=false; [] call a3e_fnc_chronos_run;"`.
- **Body:** `chronos_run` walks `A3E_CronProcesses`; for each process whose `lastCall + interval` has
  elapsed it calls `chronos_dispatch`, which `call`/`spawn`s the registered function (by name via
  `call compile format` for STRING entries) and either reschedules (stamp `lastCall`) or removes it
  (one-shot timeout).
- **Registered jobs** (`fn_initServer.sqf:679-683`, all default `spawn` / re-eval each tick; +traps):

  | Job | Registered at | Purpose |
  |-----|---------------|---------|
  | `A3E_FNC_RoadBlocks` | initServer:679 | maintain up to `MaxNumberOfRoadblocks` roadblocks |
  | `A3E_FNC_AmbientPatrols` | initServer:680 | spawn/refresh ambient foot patrols |
  | `A3E_FNC_MilitaryTraffic` | initServer:681 | military vehicle traffic |
  | `A3E_FNC_CivilianCommuters` | initServer:682 | civilian vehicle/commuter traffic |
  | `A3E_FNC_TrackGroup_Update` | initServer:683 | group bookkeeping/cleanup tracking |
  | `A3E_fnc_updateTraps` | initTraps:3 (`call`, 5 s) | update player traps |
  | ~~`AmbientAISpawn`~~ | initServer:678 (commented) | — disabled |

- **Overrun guard:** spawn-type jobs are re-dispatched only when their previous script handle
  `scriptDone`; a still-running job logs an overrun and is skipped. **Call-type jobs have no guard** — a
  slow `call` blocks the whole tick.
- **Hazards:** `chronos_dispatch` `deleteAt`s finished one-shots **while `chronos_run` iterates by index**
  → possible index-skew if multiple timeouts fire in one tick (Chronos.md). `A3E_CronTimer` is set but
  never read (vestigial). `call compile format` on names is a static-analysis blind spot (the jobs look
  "uncalled").

## L2 — SearchLeader escalation tick `[S]`

The search "brain" clock (per-file: [SearchLeader.md](../../code-reference/SearchLeader.md); pipeline:
[state-and-data-flow.md §6](state-and-data-flow.md#6-detection--known-positions--search-dispatch)).

- **Clock:** self-resetting tick trigger from `fn_SearchLeaderInit.sqf` (interval =
  `A3E_var_SearchleaderInterval/2`, default → **~30 s effective**); `A3E_var_SearchLeaderTick` toggles to
  re-fire. Seeds `A3E_var_LastArtilleryStrike = now + 300` (5-min strike grace).
- **Body (`fn_SearchLeader.sqf`), each tick:**
  1. No `A3E_KnownPositions` → order all `"SAD"` groups back to `Patrol`, delete legacy marker, log.
  2. Else → dispatch the nearest IDLE patrol within `A3E_var_MaxInvestigationRange` (1300) to a random
     known position via `Search` (group `A3E_TaskState → "SAD"`); move the legacy search marker to the
     most-recently-updated position.
  3. **Escalation:** past `a3e_var_artillery_cooldown` and for contacts observed ≥
     `a3e_var_artilleryTimeThreshold` and updated within 60 s → **80 % artillery / 20 % CAS**
     (`FireArtillery` / `CallCAS`), reset the strike timer.
- **Reads/writes:** reads `A3E_KnownPositions`, per-group `A3E_TaskState`/`a3e_homeMarker`; writes patrol
  orders, the legacy marker, `A3E_var_LastArtilleryStrike`, `A3E_StatusOfPatrols` (currently **write-only**
  — its only reader is a dead block).
- **Hazards:** half-interval + flag-toggle makes cadence non-obvious; large dead "lost contact" block;
  magic constants (1300/200/300, 80/20).

## L3 — Player-detection sensors `[S]`

- **Clock:** two full-map `EmptyDetector` sensor triggers (OPFOR, IND) from `fn_PlayerDetection.sqf`,
  interval **5 s**, activation = *Blufor present, detected by enemy side*.
- **Body:** on fire → `["<side>"] spawn A3E_FNC_ReportToHQ` **iff** `A3E_var_PlayerCanBeDetected`; the
  report latches that global false, so the two triggers are mutually exclusive (one report at a time,
  Q-017). Re-armed after a report resolves (`recordSighting` +60 s / `ReportToHQ`).
- **Feeds** the detection pipeline in [§6](state-and-data-flow.md#6-detection--known-positions--search-dispatch).
- **Hazards:** single shared latch serializes OPFOR vs IND; whole-map area + 5 s are hardcoded.

## L4 — Mission-flow poll triggers `[S]`

- **Clock:** seven `EmptyDetector` poll triggers from `fn_missionFlow.sqf` ([P6](lifecycle-and-timeline.md#p6--mission-end)),
  interval **2 s**, with `setTriggerTimeout` debounces (2–3 s).
- **Bodies:** four **ending** triggers (`end1`…`end4` → `A3E_fnc_endMissionServer`) and three **feeders**
  (all-unconscious → `AllPlayersDead` + `FailTasks`; prison-clear → `A3E_Task_Prison_Complete`; map-found →
  `A3E_Task_Map_Complete`). All feeders + the unconscious ending are gated on `A3E_EscapeHasStarted`.
- **Reads:** the outcome latches ([§2](state-and-data-flow.md#2-mission-outcome-chain)), `A3E_Warcrime_Score`
  (end4), player positions/items, `A3E_fnc_InlineEverybodyUnconscious`.
- **Note:** these are created **in parallel with `initServer`** (bootstrap race, Q-020) but only
  *evaluate* until their globals exist, so the race is benign.

## L5 — Client task-state triggers `[C]`

- **Clock:** per-task client triggers from `fn_briefing.sqf` (one `_Complete`, one `_Failed` per task).
- **Body:** when the broadcast bool flips, `setTaskState "Succeeded"/"Failed"` on the client's simple task
  — the visual half of the [task data path](state-and-data-flow.md#3-task-state-server--client-tasks--stats).
  These are **reactive** (they only mirror server signals), not autonomous loops.

## L6 — War-crime score decay `[S]`

- **Clock:** a raw `while true / sleep 60` thread (`fn_initServer.sqf:688-697`) — the mission's one true
  polling loop, flagged `//Move to chronos`.
- **Body:** if `A3E_Warcrime_Score > 500`, subtract 50 (floor 500). **Not broadcast** (minor RD; see
  [§5](state-and-data-flow.md#5-war-crime-score)). Counterpart to the +500 civilian-death raise.

## L7 — Per-group AI waypoint loop `[S]`

- **Mechanism:** not a trigger — behaviors (`Patrol`/`Search`/`Guard`/`Extraction`) reuse **waypoint
  index 1** and embed **self-respawn recursion** in the waypoint's `oncomplete` statement string, so a
  group re-queues its own next move on arrival. This is the per-unit steady-state motion loop.
- **Hazards (Q-013):** fragile if extra waypoints exist; `Guard`/`Search` set `setWaypointTimeout [0,20,6]`
  (max < mid — looks like a min/mid/max typo). A key rework point for the port (different waypoint API).

## L8 — EscapeSurprises reinforcement scheduler `[S]`

- **Clock/body:** `Code/Scripts/Escape/EscapeSurprises.sqf` — the live surprise/reinforcement scheduler
  (per-file: [Scripts-Escape.md](../../code-reference/Scripts-Escape.md)). Runs on its own cadence keyed to
  enemy-frequency, spawning periodic pressure (search parties, motorized elements).
- **Hazard:** BUG-033 — the motorized-search branch (`:137`) can re-fire immediately at max frequency;
  RD-032 notes unbounded reinforcement bookkeeping.

## L9 — Known-position watchdog `[S]`

- **Mechanism:** each `createKnownPosition` `spawn`s `A3E_fnc_watchKnownPosition` for the new record — a
  per-record lifecycle thread that expires stale `A3E_KnownPositions` entries, feeding L2's "no reports"
  branch. (Per-record, not a single global loop.)

---

## Clocks summary

| Loop | Mechanism | Cadence | Scope |
|------|-----------|---------|-------|
| L1 Chronos | self-resetting tick trigger | 5 s | server |
| L2 SearchLeader | self-resetting tick trigger | ~30 s | server |
| L3 Player detection | sensor triggers ×2 | 5 s | server |
| L4 Mission-flow | poll triggers ×7 | 2 s (+debounce) | server |
| L5 Task states | reactive client triggers | on signal | each client |
| L6 War-crime decay | `while / sleep` | 60 s | server |
| L7 AI waypoints | waypoint self-respawn recursion | per-arrival | server |
| L8 EscapeSurprises | script scheduler | freq-keyed | server |
| L9 Known-pos watchdog | per-record `spawn` | per-record | server |

## Hazards index

- **Chronos index-skew** on multi-timeout ticks; **no overrun guard for call-type jobs** (L1).
- **`A3E_CronTimer` / `A3E_StatusOfPatrols`** — set-but-unread / write-only dead data (L1/L2).
- **Single detection latch** serializes OPFOR vs IND reports (L3, Q-017).
- **Bootstrap race** `missionFlow ‖ initServer` (L4, Q-020) — benign but noted.
- **Waypoint-timeout typo** `[0,20,6]` and index-1 reuse fragility (L7, Q-013).
- **EscapeSurprises immediate re-fire** at max frequency (L8, BUG-033).
- **War-crime decay not broadcast** (L6; minor).

## Reforger port notes

Collapse the trigger-as-timer zoo into a small number of **periodic server systems**:

- L1 Chronos → a single scheduler system (`CallLater(cb, period, repeat)` or a task-list update); jobs
  become typed method references (no `call compile format`), with real overrun/dedup handling.
- L2/L3 detection+search → a **perception/search manager system** that queries AI target knowledge each
  tick, maintains a known-positions data list, dispatches groups, and escalates — replacing the two
  detection triggers, the `PlayerCanBeDetected` latch, the SearchLeader tick, and `watchKnownPosition`.
- L4 mission-flow → end-condition checks in the game-mode's `EOnFrame`/tick + `EndGameMode`.
- L5 tasks → server-updated, replicated objective components (no client task triggers).
- L6 decay, L8 surprises → scheduled system updates.
- L7 AI waypoints → the Enfusion waypoint/`AIWaypoint` API with an explicit patrol behavior loop; fix the
  timeout typo and the index-1 assumption.

See Q-013 / Q-017 / Q-020, BUG-033, and RD-032 for the specific rework points.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-07-02 | Claude | Initial integration runtime-loops map (L1–L9, clocks summary, hazards index) synthesized from code-reference + source |
