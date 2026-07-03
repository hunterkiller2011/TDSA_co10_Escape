# Architecture — State & Data Flow

_Last updated: 2026-07-02 (local)_ · _Status: active (integration — draft)_

> The **load-bearing global state** of co10_Escape and its **producer → consumer** data paths: who writes
> each signal, who reads it, and how it crosses the server/client boundary. This is the "data paths" half
> of the integration set — a synthesis of the per-file [code-reference](../../code-reference/README.md)
> into the flows that actually drive mission logic.
>
> Companions: **[lifecycle-and-timeline.md](lifecycle-and-timeline.md)** (when these signals fire in the
> boot sequence) and **[runtime-loops.md](runtime-loops.md)** (the loops that poll/emit them). Citations
> are `file:line` in the legacy Arma 3 source.

## How state is stored

The mission has **no central store** — state is loose globals in `missionNamespace`, plus per-entity
`setVariable`. Five storage idioms, each with different locality:

| Idiom | Example | Locality |
|-------|---------|----------|
| Bare global assignment | `A3E_EscapeHasStarted = true` | local to the machine that ran it |
| `publicVariable "x"` after assign | `A3E_EscapeHasStarted` + `publicVariable` | **broadcast** to all machines (+ JIP if re-sent) |
| `missionNamespace setVariable [n,v,true]` | `A3E_Warcrime_Score` (+500 path) | broadcast (3rd arg `true`) |
| `object setVariable [n,v,true]` | guard `A3E_TaskState`, known-position `A3E_LastUpdated` | replicated with the object |
| helper-object records | `A3E_KnownPositions` = spawned `Land_HelipadEmpty_F` carrying vars | server-side data-as-entities |

> ⚠ **Locality is manual and inconsistent.** A value is only on other machines if *explicitly* broadcast.
> Several producers broadcast, their paired consumers read locally, and at least one writer forgets the
> broadcast flag (war-crime **decay**, `initServer:693`, omits `true` while the **+500** path at
> `onCivilianSpawn:35` broadcasts) — usually harmless only because the consumer runs server-side. This
> manual locality is the single biggest thing the Reforger port replaces (replicated component vars).

---

## 1. Escape & alarm signals

The prison state machine's two signals (full machine: [application.md § Control flow](application.md#control-flow); timeline phase [P4](lifecycle-and-timeline.md#p4--escape-start)).

**`A3E_EscapeHasStarted`** (broadcast) — the central "mission is underway" signal.
- **Produced by** the three escape-detection triggers in `fn_initServer.sqf:614 / :619 / :651` (distance / weapon / gate-open).
- **Consumed by** (wide fan-out):
  - `initPlayer.sqf:24` — placement branch (JIP-vs-prison; uses `!isNil`, i.e. *defined*, not value); `:63` — release from captivity (`setCaptive false`).
  - `initLocalPlayer.sqf:94` — client un-captive + ACE compat chat.
  - `missionFlow.sqf:57 / :64 / :71` — **gates every end/feeder trigger** (all-dead, prison-clear, map-found).
  - `initServer.sqf:608 / :636 / :650 / :663 / :665` — the escape/alarm/uncaptive `while(isNil …)` arming loops.

**`A3E_SoundPrisonAlarm`** (broadcast, one-shot) — the ~30 s siren + reveal-all.
- **Produced by** `fn_initServer.sqf:592` (set true) / `:598` (reset false after the one-shot window).
- **Consumed by** `fn_briefing.sqf:9` — a client trigger that repositions `A3E_PrisonLoudspeakerObject` (the audible siren source), and `A3E_fnc_soundAlarm` / `A3E_fnc_revealPlayers`.

## 2. Mission-outcome chain

Four boolean latches decide the ending; the seven `fn_missionFlow.sqf` triggers ([P6](lifecycle-and-timeline.md#p6--mission-end)) read them.

| Signal (broadcast) | Set **false** (init) | Set **true** by | Read by (ending) |
|--------------------|----------------------|-----------------|------------------|
| `a3e_var_Escape_MissionComplete` | initServer:136, missionFlow:5 | **extraction reached** — `RunExtraction*.sqf` (`:131/:137/:127/:131`) | end2, end4; `briefing:20` (HSC exit) |
| `a3e_var_Escape_MissionFailed_LeftBehind` | missionFlow:6 | **extraction left w/o everyone** — `RunExtraction*.sqf` (`:134/:140/:130/:134`) | end3 |
| `a3e_var_Escape_AllPlayersDead` | initServer:135, missionFlow:3 | **all players unconscious** — missionFlow:57 feeder | end1 + gates end2/end3/end4; `briefing:20` |
| `a3e_var_Escape_SearchLeader_civilianReporting` | missionFlow:4 | **(never, in live code)** — see below | end2 gate `!civilianReporting` |

There are five extraction variants (`fn_RunExtraction{,Boat,Car,Heli}.sqf` + the selector); each sets
`MissionComplete=true` on a successful pickup or `MissionFailed_LeftBehind=true` if it departs without the
full group. So the **win/lose latch is produced by the extraction subsystem and the all-unconscious
feeder**, and consumed only by the missionFlow poll triggers.

> ⚠ **Finding — `civilianReporting` is a dead win-gate (RD-035).** `a3e_var_Escape_SearchLeader_civilianReporting`
> is **only ever assigned `false`** in live code (`missionFlow:4`); the sole `= true` site is the
> deprecated `Code/Scripts/Escape/SearchLeader.sqf:30` (RD-019, not loaded). So end2's `!civilianReporting`
> term is **always true** — the "you shot civilians, no clean win" mechanic it implies is inert. That
> penalty now lives in the **war-crime score** path (§5 → end4). `fn_handleScore.sqf:3` only checks the
> var's *presence* (`!isNil`), not its value, so it doesn't revive the mechanic. Verify in-game, then
> either wire it or delete it in the port.

## 3. Task state (server → client tasks + stats)

Player-facing tasks are **client** simple-tasks created in `fn_briefing.sqf`, driven by **broadcast
boolean** `A3E_Task_<X>_Complete` / `_Failed` pairs. `briefing.sqf` also creates a per-task client
trigger that flips the task's visual state when its bool goes true (`:49/:56/:81/...`). Producers are
server-side:

| Task | `_Complete` set by | Notes |
|------|--------------------|-------|
| Prison | `missionFlow:64` — any player >50 m from `A3E_StartPos` | gated on `A3E_EscapeHasStarted` |
| Map | `missionFlow:71` — any player carries `ItemMap` | |
| LocateComcenter | `fn_UpdateLocationMarker.sqf:25` | com-center revealed |
| ComCenter ("Hack") | `fn_SelectExtractionZone.sqf:119` | **completes when the extraction zone is chosen**, not at the terminal hack — trace this |
| Exfil | `RunExtraction*.sqf:126 / :132 / :122 / :126` | on pickup |

- **`_Failed`** vars are set by the `A3E_FNC_FailTasks` block (`briefing.sqf:190-200`: any task not
  complete → its `_Failed=true`), spawned from the all-unconscious feeder (`missionFlow:57`).
- **Consumers:** the client task-state triggers in `briefing.sqf`; `initLocalPlayer.sqf:108` waits on
  `A3E_Task_Prison_Complete` (info-text); `fn_SaveStatistics.sqf:16` logs all `_Complete` flags to the
  external stats API.

## 4. Faction / unit selection data (mostly static)

Per-mod `Mods/{Mod}/UnitClasses.sqf` defines the spawn pools; `initServer` loads them (P3a). This is
data, not signal flow — summarized here, detailed in the
[code-reference Coverage table](../../code-reference/README.md#coverage--gaps):

- **Side setup:** `A3E_VAR_Side_{Opfor,Ind,Blufor}` (+ `_Str`, + `A3E_VAR_Flag_Ind`) — set at init, read by
  the detection triggers (§6), faction-relations, and spawners.
- **Unit pools:** `a3e_arr_*` probability-weighted classname arrays → the `A3E_*Templates` selection
  arrays (`fn_loadTemplates`) → consumed by the Spawning + Templates families via `callRandomFunction`.
- The `Factions/` abstraction that *looks* like it feeds this is **dead** (Q-018/RD-030) — the live path
  is `UnitClasses` → templates.

## 5. War-crime score

A single scalar, `A3E_Warcrime_Score` (default 0), is the civilian-harm accumulator.

- **Raised** by the `Killed` event handler attached to every civilian in `fn_onCivilianSpawn.sqf:26-40`:
  a player-caused civilian death does `A3E_Warcrime_Score += 500` (**broadcast**), plus a systemChat
  callout, `addScore -5`, `addRating 1000`.
- **Decayed** by the loop in `fn_initServer.sqf:688-697` (`while true / sleep 60`): if score >500, subtract
  50 each minute (**floor 500**, and **not broadcast** — `:693` omits the `true` flag; minor RD).
- **Read by:**
  - `missionFlow:26` — **end4** (tainted win) when `>1000` at extraction.
  - `fn_onEnemyDetected.sqf:9-10` and `fn_onCivilianGroupSpawn.sqf:10-11` — compare to
    `A3E_Warcrime_Score_CivilianFear` (default 1000): high war-crimes make civilians fearful/less
    cooperative.
- Related civilian behavior: `onCivilianSpawn` also attaches a `FiredNear` handler (`:43-103`) → the
  scared/flee-to-building behavior (independent of the score, via `A3E_IsScared`).

This is the mechanic that **replaced** the inert `civilianReporting` gate (§2).

## 6. Detection → known-positions → search dispatch

The SearchLeader subsystem is a multi-stage pipeline (per-file detail in
[SearchLeader.md](../../code-reference/SearchLeader.md)); as a data path:

```
[sensor]   PlayerDetection full-map triggers (OPFOR + IND, 5s)   ── gated by A3E_var_PlayerCanBeDetected
              │  enemy knowsAbout player > threshold
              ▼
[report]   ReportToHQ (radio window; reporter must survive)      ── latches A3E_var_PlayerCanBeDetected = false
              │  success
              ▼
[record]   recordSighting  ◄── also fed by fn_onEnemyDetected (AI direct) + fn_onCivilianGroupSpawn (informant)
              │  targetKnowledge → [pos, accuracy]
              ▼
[data]     createKnownPosition → merges/updates A3E_KnownPositions (helper-object records:
              │  A3E_FirstSight / A3E_LastUpdated / A3E_Accuracy / A3E_NumOfReports)
              │  watchKnownPosition expires stale records
              ▼
[dispatch] SearchLeader tick (~30s) reads A3E_KnownPositions →
              ├─ A3E_fnc_Search  (send nearest IDLE patrol; sets group A3E_TaskState "SAD")
              ├─ A3E_fnc_Patrol  (return SAD groups home when no reports)
              └─ FireArtillery / CallCAS  (persistent contact + cooldown; a3e_var_artillery_*)
```

Key shared state:
- **`A3E_var_PlayerCanBeDetected`** (latch) — one global for **both** side triggers, so only one
  side reports at a time (Q-017). Re-armed after each report (`recordSighting` +60 s; `ReportToHQ`).
- **`A3E_KnownPositions`** — the pipeline's output and the dispatcher's input.
- **`a3e_var_artillery_units`** — filled by the mortar-site template at spawn (P3a #9),
  consumed by `FireArtillery`. Cooldowns/thresholds from `config.sqf` (`a3e_var_artillery_*`).

## 7. AI group state (side + task-state dispatch)

AI groups carry their role in **group `setVariable`**, queried by `side` + state rather than tracked in a
list (per CLAUDE.md conventions):

- **`A3E_TaskState`** — `"IDLE"` / `"PATROL"` / `"SAD"` (search-and-destroy). Producers: `Patrol`,
  `Search`, `AquaticPatrol` (note: boats also tag `"PATROL"`, Q-014). Consumers: `SearchLeader` dispatch
  (counts SAD groups, finds IDLE patrols), `OrderSearch` / `SeekShelter`.
- **`a3e_homeMarker`** — a patrol's home zone, read by `SearchLeader` to send groups back.
- The `move` waypoint convention (index 1 + self-respawn recursion) is the per-group control loop
  (Q-013) — see [runtime-loops.md](runtime-loops.md).

## 8. Config & tuning inputs

`config.sqf` seeds the `a3e_var_*` tuning globals at postInit (before `initServer`); the `A3E_Param_*`
surface comes from the lobby/CBA params via `parameterInit`. These are **read-mostly inputs** to the
subsystems above (search range, investigation chance, artillery timing, roadblock counts, spawn
distances). Full list + per-value notes: [_init-and-includes.md → config.sqf / params.hpp](../../code-reference/_init-and-includes.md).

## 9. Scheduler state

The Chronos globals (`A3E_CronProcesses`, `A3E_CronTime`, `A3E_CronTick`, `A3E_CronTimer`,
`A3E_CronTrigger`) hold the registered-job list and heartbeat. Written by `Chronos_Register` /
`Chronos_Init` / `Chronos_Dispatch`; read by `Chronos_Run`. Data detail in
[Chronos.md](../../code-reference/Chronos.md); loop behavior in
[runtime-loops.md](runtime-loops.md).

---

## Signal summary (quick index)

| Signal | Kind | Producer(s) | Key consumer(s) |
|--------|------|-------------|-----------------|
| `A3E_EscapeHasStarted` | broadcast latch | escape triggers (initServer) | initPlayer, initLocalPlayer, missionFlow, arming loops |
| `A3E_SoundPrisonAlarm` | broadcast one-shot | initServer:592/598 | briefing loudspeaker, soundAlarm/revealPlayers |
| `a3e_var_Escape_MissionComplete` | broadcast latch | extraction functions | missionFlow end2/end4 |
| `a3e_var_Escape_MissionFailed_LeftBehind` | broadcast latch | extraction functions | missionFlow end3 |
| `a3e_var_Escape_AllPlayersDead` | broadcast latch | missionFlow:57 feeder | missionFlow end1 + gates |
| `A3E_Task_*_Complete` | broadcast latch | missionFlow / UpdateLocationMarker / SelectExtractionZone / extraction | briefing tasks, SaveStatistics, initLocalPlayer |
| `A3E_Warcrime_Score` | broadcast scalar | civilian Killed EH (+500), decay loop (−50/min) | missionFlow end4, civilian-fear checks |
| `A3E_var_PlayerCanBeDetected` | server latch | PlayerDetection / ReportToHQ / recordSighting | detection triggers |
| `A3E_KnownPositions` | server list (entities) | createKnownPosition | SearchLeader dispatch, watchKnownPosition |
| `A3E_TaskState` (group) | replicated group var | Patrol / Search / AquaticPatrol | SearchLeader, OrderSearch, SeekShelter |

## Reforger port notes

- Replace loose broadcast globals with **replicated component variables** (`[RplProp]`) on the relevant
  manager components — the manual `publicVariable`/`setVariable true` locality (and its inconsistencies,
  e.g. the non-broadcast war-crime decay) disappears into the replication system.
- The **mission-outcome latches** → fields on the game-mode with server-authoritative end checks; drop
  the dead `civilianReporting` gate (RD-035) and keep the war-crime scalar.
- **Tasks** → Reforger's task/objective system, updated server-side and replicated to clients (no
  per-client `createSimpleTask` + trigger pattern).
- **Known positions as spawned helper entities** → a plain server-side data record/struct list in a
  search manager (position, firstSeen, lastUpdated, reportCount, accuracy); merge/expire as list ops.
- **Group `A3E_TaskState`** → a typed state enum on an AI-group component; dispatch queries become
  component/system lookups.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-07-02 | Claude | Initial integration data-flow map (storage idioms; escape/outcome/task/war-crime/detection/AI-state paths; signal index). Surfaced RD-035 (dead civilianReporting win-gate) |
