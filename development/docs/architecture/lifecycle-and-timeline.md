# Architecture — Lifecycle & Timeline

_Last updated: 2026-07-02 (local)_ · _Status: active (integration — draft)_

> The **end-to-end sequence** of a co10_Escape session: engine load → PreInit → PostInit bootstrap →
> server world-build + client init → player placement → escape start → runtime steady-state → mission
> end. This is a **synthesis** of the per-file [code-reference](../../code-reference/README.md) into one
> ordered, cross-machine picture — the "wiring diagram" the per-file docs feed.
>
> Companion integration docs: **[state-and-data-flow.md](state-and-data-flow.md)** (the globals as
> producer→consumer maps) and **[runtime-loops.md](runtime-loops.md)** (the recurring loops). The prison
> escape/alarm state machine lives in [application.md](application.md#control-flow); this doc places it in
> the wider timeline.

## How to read this

- **Machines/lanes.** Arma is locality-sensitive. Three lanes run this mission: **[S] server**
  (authoritative world), **[C] client** (each player's machine, `hasInterface`), and **[JIP]** (a client
  that joins after the world is already built). A dedicated server has no `[C]` lane.
- **Phase markers** (`P0`…`P6`) are the coarse stages; steps inside a phase are ordered but some run
  concurrently (called out explicitly).
- **Handshake variables.** Cross-lane synchronization is done entirely through `missionNamespace`
  globals used as latches (`waitUntil {!isNil …}` / `waitUntil {… getVariable …}`). The load-bearing ones
  are named at each step and collected in [§ Synchronization latches](#synchronization-latches).
- `file:line` citations point at the legacy Arma 3 source; verify there when porting.

---

## P0 — Engine load & parse `[S]``[C]`

The engine reads **[`Code/description.ext`](../../Code/description.ext)** at mission load and, through its
`#include`s, registers everything that must exist before any script runs:

1. `#include include\defines.hpp` — build-identity macros (the `{* … *}` tokens the compiler stamped) +
   UI style constants.
2. `Header` / metadata / respawn (`INSTANT`, 5 s) / `disabledAI=1` / debriefing (End1–End4) / remoteExec
   whitelist / `RscTitles` (revive cam) / allowed-HTML URIs.
3. Register the CBA PreInit hook: `Extended_PreInit_EventHandlers` class `a3e` → runs `XEH_preInit.sqf`
   (`description.ext:28-32`).
4. `#include include\params.hpp` — the lobby `Params` tree.
5. `#include include\functions.hpp` — **`CfgFunctions`**: every `a3e_fnc_*` / `drn_fnc_*` / `ace_fnc_*`
   name is compiled and bound; the two auto-run flags are set here — `Common::BootstrapEscape`
   `postInit=1` and `Chronos::Chronos_Init` `postInit=1`.

**Output of P0:** every function callable by name; two functions armed to self-start at postInit; CBA
armed to run `XEH_preInit` at preInit. No gameplay state yet.

## P1 — PreInit: settings materialize `[S]``[C]`

CBA fires the `Extended_PreInit_EventHandlers` → **[`Code/XEH_preInit.sqf`](../../Code/XEH_preInit.sqf)**
runs on every machine, before objects init. It walks `missionConfigFile >> "Params"` and registers one
**CBA setting** per param (`CBA_fnc_addSetting`, category `"co10 Escape"`), remapping
`A3E_Param_Loadparams` → the `A3E_UseCBASettings` checkbox.

**Output of P1:** CBA settings exist; the `A3E_Param_*` surface is defined. (Whether a lobby param or its
CBA setting wins when they disagree is **Q-019**; the values are finally resolved into `A3E_Param_*`
globals by `a3e_fnc_parameterInit` early in P3a, which also sets the `A3E_ParamsParsed` latch.)

## P2 — PostInit bootstrap `[S]``[C]`

Objects now exist. Two `postInit=1` functions fire on every machine:

- **`Chronos::Chronos_Init`** → [`fn_Chronos_Init.sqf`](../../Code/functions/Chronos/fn_Chronos_Init.sqf):
  on the **server only** (`isServer` guard) it initializes the scheduler globals and creates the 5 s
  heartbeat trigger. The scheduler is now *ticking* but has **no registered jobs yet** — those are added
  at the very end of P3a. See [runtime-loops.md](runtime-loops.md).
- **`Common::BootstrapEscape`** →
  [`fn_bootstrapEscape.sqf`](../../Code/functions/Common/fn_bootstrapEscape.sqf), the real fork point:
  1. `call compile preprocessFileLineNumbers "config.sqf"` — defines the `a3e_var_*` tuning globals.
  2. Compile the three per-island files: `Island\WorldConfig.sqf`, `Island\VillageMarkers.sqf`,
     `Island\CommunicationCenterMarkers.sqf`.
  3. Guard-check `A3E_WorldName` / `a3e_villageMarkers` / `a3e_communicationCenterMarkers` — **`throw`**
     (abort init loudly) if any island global is `nil`.
  4. **Fork by locality:**
     - `if (isServer)` → `spawn a3e_fnc_missionFlow` **and** `spawn a3e_fnc_initServer` (parallel; **P3a**).
     - `if (hasInterface)` → black-screen title thread → `call a3e_fnc_initLocalPlayer` (**P3b**) →
       2 s → fade out.

> ⚠ **Ordering hazard (Q-020):** `missionFlow` and `initServer` are spawned in parallel with no ordering
> guarantee. `missionFlow` immediately creates its win/lose triggers (P6) whose conditions read globals
> `initServer` publishes later — harmless because triggers only *evaluate*, but note the two are racing.

## P3a — Server world-build `[S]`

**[`fn_initServer.sqf`](../../Code/functions/Server/fn_initServer.sqf)** is the authoritative build
sequence. Detailed per-section notes are in [Server.md](../../code-reference/Server.md); the timeline-
relevant ordering and its two **blocking waits**:

1. `isServer` guard; load CommonLib; **`a3e_fnc_parameterInit`** → resolves `A3E_Param_*`, sets the
   **`A3E_ParamsParsed`** latch.
2. Load Escape `Functions.sqf` / `AIskills.sqf`; resolve `A3E_Debug`; ACE revive EH + broadcast
   **`ACE_MedicalServer`**.
3. Load statistics; **`a3e_fnc_loadLocalClasses`** (unit pools) + **`a3e_fnc_loadTemplates`**
   (`A3E_*Templates` selection arrays); publish flag path.
4. Create com-centers group container; set faction relations (war-torn branch); weather; compute & set
   date / time-of-day / time-multiplier (`a3e_var_Escape_hoursSkipped`).
5. Reset game-control vars; map `A3E_Param_EnemySkill` → `enemyMin/MaxSkill`; compute search-chopper
   timers; gather exclusion zones.
6. Pick **`A3E_StartPos`** (retry until outside exclusion zones) → **`a3e_fnc_createStartpos`** builds the
   prison and sets the **`A3E_FenceIsCreated`** latch.
7. `a3e_fnc_InitVillageMarkers`.
8. **🚧 BLOCKING WAIT #1 — wait for players** (`fn_initServer.sqf:~209`): dynamic content is not spawned
   until players are present.
9. Spawn dynamic sites: **`CreateComCenters` / `CreateMotorPools` / `CreateAmmoDepots` /
   `createMortarSites` / `createCrashSites`** (the latter fills `a3e_var_artillery_units`).
10. `SearchleaderInit` + `PlayerDetection`; `initVillages`; *(legacy DRN ambient block at `:251-441` is
    dead — wrapped in `if(false)`; RD-018/RD-025)*; `startStatistics`.
11. **🚧 BLOCKING WAIT #2 — search chopper** (`:~452`): `waitUntil {scriptDone _scriptHandle}` on the
    `CreateSearchChopper` execVM serializes the rest of init behind chopper creation (intentional? Q-020).
12. `InitTraps` (registers `A3E_fnc_updateTraps` with Chronos).
13. **Prison guard / backpack / alarm / escape-detection block** (`:589-655`): defines
    `A3E_fnc_revealPlayers` + `A3E_fnc_soundAlarm`, spawns the guard groups, and creates the **three
    escape-detection triggers + the alarm triggers** that publish `A3E_EscapeHasStarted` /
    `A3E_SoundPrisonAlarm` (see [P4](#p4--escape-start) and
    [application.md](application.md#control-flow)).
14. **Register Chronos jobs** (`:679-683`): `RoadBlocks`, `AmbientPatrols`, `MilitaryTraffic`,
    `CivilianCommuters`, `TrackGroup_Update`. *Now* the P2 heartbeat has work → runtime loops begin (P5).
15. Spawn the war-crime score-decay loop (`:688-697`, a raw `while / sleep 60`; RD — "move to chronos").

**Output of P3a:** the world exists, the escape triggers are armed, the ambient loops are running.

## P3b — Client init `[C]`

**[`fn_initLocalPlayer.sqf`](../../Code/functions/Common/fn_initLocalPlayer.sqf)** runs on each interface
machine (concurrent with P3a):

1. `waitUntil {!isNull player}`; `call A3E_FNC_Briefing`; `sleep 0.5`.
2. **`[player] remoteExec ["a3e_fnc_initPlayer", 2]`** — ask the **server** to place me (→ P3c server side).
3. **Strip all gear** — `removeAllWeapons` / `removeAllItems` / `removeBackpack` / vest / headgear / NVG
   (`:23-33`). *(Runs concurrently with the server placement it just requested — see the BUG-031 hazard
   in [P3c](#p3c--player-placement-handshake).)*
4. Add `HandleRating` + `InventoryClosed`(→collectIntel) EHs; disable leader "move-to" waypoint cheat in
   MP.
5. `waitUntil {!isNil "A3E_ParamsParsed"}`; set revive-cam; **revive init** — ACE branch sets
   `ACE_Revive_isUnconscious=false`, else `ATR_FNC_ReviveInit`.
6. Compile drone-hack init; set terrain grid; optional mag-repack; add keydown handler.
7. Set the **`A3E_PlayerInitializedLocal`** latch (`:85`).
8. **🚧 WAIT — `waitUntil {player getVariable "A3E_PlayerInitializedServer"}`** (`:88`): block until the
   server reports this player placed (set in P3c).
9. Post-ready threads: on `A3E_EscapeHasStarted` un-captive (rejoin) + ACE/server compat chat; on
   `A3E_Task_Prison_Complete` show the "somewhere on <world>" info text; register the earplugs keybind.

## P3c — Player placement handshake `[S]`↔`[C]`

The remoteExec'd **[`fn_initPlayer.sqf`](../../Code/functions/Server/fn_initPlayer.sqf)** runs **on the
server** (target `2`) for each player. This is the two-way handshake that gets a body into the prison:

1. `params ["_player"]`; add `HandleScore` EH; **`setCaptive true`** on the player.
2. **🚧 WAIT** — `waitUntil {!isNil A3E_FenceIsCreated && !isNil A3E_StartPos && !isNil A3E_ParamsParsed}`
   (`:20`): don't place anyone until the prison exists and params are resolved (P3a steps 1 & 6).
3. **Placement branch:**
   - **If `A3E_EscapeHasStarted` is _defined_** (`!isNil`, i.e. the mission is already underway → this is
     effectively the **[JIP]** path): teleport the player next to a random already-placed player
     (`moveInAny` if they're in a vehicle with a free seat, else `setPos` within a few metres) (`:24-51`).
   - **Else / if placement failed:** `setPos` at **`A3E_StartPos`** ± a few metres (the prison) with a
     random facing (`:52-56`).
4. Set the **`A3E_PlayerInitializedServer`** latch on the player (`:61`) → unblocks P3b step 8.
5. `waitUntil {!isNil A3E_EscapeHasStarted}` → **`setCaptive false`** (`:63-65`): the player is released
   from captivity only once the escape is defined.

> ⚠ **BUG-031 (spawn/init race → premature escape).** The server's placement (P3c) waits only on the
> *world* latches (`A3E_FenceIsCreated` / `A3E_StartPos` / `A3E_ParamsParsed`), **not** on the client's
> gear-strip (P3b step 3). So the server can place the body and set `A3E_PlayerInitializedServer` while
> the client still holds starting weapons. Escape-trigger #2 is `count weapons _player > 0`
> ([P4](#p4--escape-start)) — evaluated server-side on players flagged
> `A3E_PlayerInitializedServer` — so a not-yet-stripped player can **start the escape at spawn**. This is
> the "spawn at map corner → lose gear → teleport" sequence players observe. Tracked as **BUG-031**;
> tested by **TS-007**. The `setPos` to `[0,0,0]`-ish corner before placement is the un-placed initial
> body position.

**Output of P3:** every player is captive, stripped, and standing in the prison (or teleported to the
group if JIP); both `A3E_PlayerInitialized{Local,Server}` latches are set.

## P4 — Escape start `[S]`

The three detection triggers armed in P3a step 13 publish **`A3E_EscapeHasStarted`** when, for any
`A3E_PlayerInitializedServer` player, **any of**:

1. player is **15–100 m** from `A3E_StartPos` (`fn_initServer.sqf:613`);
2. player **holds a weapon** — `count weapons > 0` (`:617-618`);
3. the **gate/door animates open** — `animationPhase > 0.5` (`:647-655`).

Guard awareness (`knowsAbout > 2.5`) is **not** a start trigger; it only sounds the alarm *after* escape
begins. **`A3E_SoundPrisonAlarm`** (one-shot ~30 s siren + reveal-all) fires on guard-awareness-post-start
**or** gate-open. Full state machine + the arming-vs-alarm distinction:
[application.md § Control flow](application.md#control-flow).

**Consequences of `A3E_EscapeHasStarted` being set** (fan-out — a key data path, see
[state-and-data-flow.md](state-and-data-flow.md)):
- P3c step 5 releases captives (`setCaptive false`); P3b step 9 un-captives rejoiners.
- The mission-flow prison/MIA/all-dead triggers (P6) start meaningfully evaluating (they are all gated on
  `A3E_EscapeHasStarted`).
- The prison task completes once a player is >50 m out → `A3E_Task_Prison_Complete`.

## P5 — Runtime steady-state `[S]``[C]`

The mission now runs its recurring loops until an end condition trips. Detailed in
**[runtime-loops.md](runtime-loops.md)**; in brief:

- **Chronos heartbeat (5 s)** dispatches the registered jobs: `RoadBlocks`, `AmbientPatrols`,
  `MilitaryTraffic`, `CivilianCommuters`, `TrackGroup_Update`, `updateTraps`.
- **SearchLeader** escalation: player weapon-fire detection → "known position" reports → dispatch idle
  patrols → reinforcements/artillery/CAS the longer contact holds.
- **EscapeSurprises** (`Scripts/Escape/`) reinforcement scheduler.
- **AI waypoint self-respawn**: behaviors reuse waypoint index 1 with self-re-queuing oncomplete strings
  (Q-013).
- **War-crime score decay** loop (P3a step 15).
- Objective progress: reaching a com-center hacks intel; finding the map sets `A3E_Task_Map_Complete`;
  reaching extraction sets `a3e_var_Escape_MissionComplete`.

## P6 — Mission end `[S]`

**[`fn_missionFlow.sqf`](../../Code/functions/Server/fn_missionFlow.sqf)** created seven `EmptyDetector`
polling triggers back in P2 (2 s interval). Their conditions decide the ending; each calls
`"endN" call A3E_fnc_endMissionServer`:

| Trigger | Condition (abridged) | Result |
|---------|----------------------|--------|
| **end2** (WIN) | `MissionComplete && !SearchLeader_civilianReporting && !AllPlayersDead` | Clean win |
| **end4** (WIN, tainted) | `MissionComplete && A3E_Warcrime_Score > 1000 && !AllPlayersDead` | Win, war-crimes |
| **end3** (FAIL) | `MissionFailed_LeftBehind && !AllPlayersDead` | MIA / left behind |
| **end1** (FAIL) | `AllPlayersDead` | Everyone dead |

Two **feeder** triggers (not endings themselves) also created here, gated on `A3E_EscapeHasStarted`:

- **All-players-unconscious** → sets `a3e_var_Escape_AllPlayersDead = true` + `A3E_FNC_FailTasks`
  (feeds end1). Uses the inline `A3E_fnc_InlineEverybodyUnconscious` (AT **or** ACE unconscious check).
- **Prison-escaped** (`any player >50 m from A3E_StartPos`) → `A3E_Task_Prison_Complete`.
- **Map-found** (`any player has ItemMap`) → `A3E_Task_Map_Complete`.

> Note the win latch `a3e_var_Escape_MissionComplete` is set elsewhere (extraction logic), and
> `MissionFailed_LeftBehind` by the extraction-leaves-without-everyone path — those producers are mapped
> in [state-and-data-flow.md](state-and-data-flow.md).

---

## Synchronization latches

The whole boot is coordinated by these `missionNamespace` globals used as one-way latches. Producer →
the waiters that block on it:

| Latch | Set by | Waited on by | Meaning |
|-------|--------|--------------|---------|
| `A3E_ParamsParsed` | `parameterInit` (P3a #1) | initPlayer (P3c #2), initLocalPlayer (P3b #5) | params resolved |
| `A3E_FenceIsCreated` | `createStartpos` (P3a #6) | initPlayer (P3c #2) | prison built |
| `A3E_StartPos` | initServer (P3a #6) | initPlayer (P3c #2) | prison location known |
| `A3E_PlayerInitializedLocal` | initLocalPlayer (P3b #7) | *(informational)* | client done its setup |
| `A3E_PlayerInitializedServer` | initPlayer (P3c #4) | initLocalPlayer (P3b #8); escape triggers gate on it | body placed |
| `A3E_EscapeHasStarted` | escape triggers (P4) | initPlayer (P3c #5), initLocalPlayer (P3b #9), all P6 gates | escape underway |
| `ACE_MedicalServer` | initServer (P3a #2) | initLocalPlayer compat-chat (P3b #9) | server ACE state |
| `A3E_Task_Prison_Complete` | missionFlow feeder (P6) | initLocalPlayer info-text (P3b #9) | first player clear of prison |

## Cross-machine swimlane (condensed)

```
        SERVER [S]                          CLIENT [C]                     JIP [JIP]
P0/P1   parse ext, CfgFunctions, CBA settings  ── same on every machine ──
P2      Chronos_Init (server)              bootstrap: black screen
        bootstrap: spawn missionFlow+initServer   spawn initLocalPlayer
P3a     parameterInit→A3E_ParamsParsed
        createStartpos→A3E_FenceIsCreated/StartPos
        [wait for players] ───────────────┐
        spawn sites, guards, escape triggers│
        register Chronos jobs               │
P3b/3c                                      ├─ initLocalPlayer: briefing
        initPlayer (remoteExec'd) ◄─────────┘   remoteExec initPlayer(2)
          setCaptive true                       strip gear  ⚠BUG-031 race
          [wait fence/startpos/params]          [wait A3E_PlayerInitializedServer]
          place at prison  ───────────────►     (unblocks) ready              place-near-group
          A3E_PlayerInitializedServer=true
P4      escape triggers → A3E_EscapeHasStarted (fan-out: uncaptive, tasks, P6 gates)
P5      Chronos loops, SearchLeader, surprises, war-crime decay  ── steady state ──
P6      missionFlow triggers → endMissionServer(end1..end4)
```

## Concurrency & ordering hazards (index)

- **Bootstrap parallel spawn** — `missionFlow || initServer`, no ordering guarantee (**Q-020**).
- **Search-chopper serialization** — init blocks on the chopper execVM (`:452`) (**Q-020**).
- **Spawn/init gear race** — server places & flags a player before the client strips weapons → premature
  escape via trigger #2 (**BUG-031**, **TS-007**).
- **JIP placement gate** — `!isNil A3E_EscapeHasStarted` (variable *defined*, not its value) is the
  "mission already underway" signal that routes a joiner to the group instead of the prison (P3c #3).

## Reforger port notes

The Arma 3 boot is a chain of `postInit` spawns + `waitUntil` latch polling. In Enfusion this becomes an
explicit **server game-mode state machine** (e.g. an `SCR_BaseGameMode` subclass) with init *phases* and
events rather than latch-polling:

- P0/P1 (parse + settings) → world/game-mode config attributes + a settings component.
- P2 fork → authority checks (`Replication.IsServer()`), not `isServer` spawns.
- P3a ordered build → an init state machine (LoadConfig → BuildPrison → WaitForPlayers → SpawnSites →
  ArmTriggers → StartLoops), each phase an event/state, replacing the two `waitUntil` blocking waits.
- P3b/P3c placement handshake → a player-spawn/`SCR_SpawnPoint` flow + player-controller component;
  **fix BUG-031 by ordering** loadout-strip *before* marking the player spawn-complete.
- P4 escape triggers → a trigger/area component or a tick check on a server system.
- P5 Chronos → a periodic system update (`CallLater(..., repeat)` / a scheduler system).
- P6 mission-flow triggers → end-condition checks in the game-mode's tick + `EndGameMode`.

See open questions **Q-001/Q-002/Q-004/Q-006/Q-020** and the placement bug **BUG-031**.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-07-02 | Claude | Initial integration timeline (P0–P6, latches, swimlane, hazards) synthesized from code-reference + source (bootstrap, initServer, initPlayer, initLocalPlayer, missionFlow, Chronos) |
