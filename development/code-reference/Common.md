# Code Reference — Common
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Shared utilities: briefing, arsenal, players/groups, markers, bootstrap. One entry per source file in `Code/functions/Common/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_CheckCampDistance  —  `Code/functions/Common/fn_CheckCampDistance.sqf`  ·  _status: documented_
- **Purpose:** Tests whether a candidate position is far enough from already-placed camps (ComCenters, MotorPools, AmmoDepots, or all cleared positions) so new structures/extraction zones aren't stacked on top of each other.
- **Inputs:** `_this select 0` = `_pos` (position); `_this select 1` = `_dis` (distance threshold, default 100); `_this select 2` = `_checkAgainst` (`"all"|"com"|"motorpool"|"ammo"`, default "All"). Reads globals `A3E_Var_ClearedPositions`, `a3e_var_Escape_communicationCenterPositions`, `a3e_var_Escape_MotorPoolPositions`, `a3e_var_Escape_AmmoDepotPositions`.
- **Outputs:** Returns `true` if position is clear (far enough), `false` if too close. No globals written. Side effect: `diag_log` on missing position.
- **Calls:** none (leaf function).
- **Called by:** `Code/functions/Server/fn_SelectExtractionZone.sqf:16` (`[_pos,250,"all"] call A3E_fnc_CheckCampDistance`). Per _xref.md Common section.
- **Processing:** Reads params, lowercases `_checkAgainst`; selects the relevant positions array via a `switch`; iterates positions and sets `_check=false` on first within `_dis`; returns `_check`.
- **Theory of operation:** Simple spacing constraint to keep procedurally-placed camps and the extraction zone spread out across the map.
- **Whys & questions:** Default-value guards use `isNil("_pos")` on already-assigned locals; `_dis`/`_checkAgainst` defaults are effectively dead because `_this select 1/2` throws or assigns before the isNil check (params are positional and required by callers). Only caller passes all three args, so defaults never exercised.
- **Unresolved issues:** BUG/typo candidate: line 23 assigns `_checkagainst` (lowercase g) instead of `_checkAgainst`, so the default branch would not set the intended variable — harmless only because callers always pass arg 2. The `switch` has no `default` case; an unknown `_checkAgainst` yields `nil` `_positions` and the `foreach` over nil silently does nothing (returns `true`). Casing inconsistency: `A3E_Var_ClearedPositions` vs `a3e_var_Escape_*`.
- **Reforger port notes:** TBD — position-spacing concept ports directly; replace global position lists with an Enfusion registry of placed camp locations.

### a3e_fnc_CompileGroupVar  —  `Code/functions/Common/fn_CompileGroupVar.sqf`  ·  _status: documented_
- **Purpose:** Assigns a stable, unique global variable name to a group (e.g. `a3e_Groupvar7`) and publishes the group under that name in missionNamespace — a debugging/reference helper for addressing groups by name.
- **Inputs:** `params ["_group"]` (group). Reads/writes group var `a3e_GroupNumber`; reads/increments global `a3e_var_GrpNumber`.
- **Outputs:** Returns the variable name string `_varname`. Side effects: `missionNamespace setVariable [_varname,_group]`; `a3e_var_GrpNumber` incremented; group var `a3e_GroupNumber` set; `player sidechat` warning if name already compiled.
- **Calls:** none (leaf function; uses only engine commands).
- **Called by:** _no `fnc_` references found_ in _xref.md — appears to be dead code or a manual/debug helper. Not registered in functions.hpp appendices as an entry point. Verify before removal.
- **Processing:** Get/assign group number; format `_varname`; if that mission var isNil publish the group, else warn via sidechat.
- **Theory of operation:** Gives groups human-readable global handles for debug tracking (compare Debug/TrackGroup).
- **Whys & questions:** Uses `player sidechat` — only meaningful on a client with a player; on a dedicated server `player` is null. Likely a dev-only tool.
- **Unresolved issues:** Suspected dead code (no callers). `a3e_var_GrpNumber` must be initialized elsewhere or first call errors on `+1` (nil). Casing: `a3e_var_GrpNumber` vs `a3e_GroupNumber` group var.
- **Reforger port notes:** TBD — debug-only; likely not ported.

### a3e_fnc_FireSmokeFX  —  `Code/functions/Common/fn_FireSmokeFX.sqf`  ·  _status: documented_
- **Purpose:** Spawns fire/smoke particle effects (and optional light source) at a position — used to make crash sites and destruction look burning.
- **Inputs:** `params ["_pos","_effect"]`; `_effect` is one of `FIRE_SMALL/MEDIUM/BIG`, `SMOKE_SMALL/MEDIUM/BIG`. No globals read.
- **Outputs:** No return value used. Side effects: creates local `#particlesource` objects (`createVehicleLocal`) for fire and smoke, and for big/medium fire creates a global `#lightpoint` and configures its light. Runs where invoked (remoteExec'd to all).
- **Calls:** none (leaf function; engine particle/light commands only).
- **Called by:** `Code/functions/Templates/fn_CrashSite.sqf:40` via `_fx remoteExec ["A3E_fnc_FireSmokeFX",0,true]` (JIP, all machines). Per _xref.md.
- **Processing:** Switch on `_effect` sets fire/smoke class names and light params; creates local particle sources; for FIRE_BIG/FIRE_MEDIUM creates and configures a light point 1m above position.
- **Theory of operation:** Runs locally on each client (via remoteExec 0) so particle effects are visible everywhere without networking each particle; light created globally (`createVehicle`) for medium/big fires.
- **Whys & questions:** Locals `_brightness/_intensity/_attenuation` are only set for MEDIUM/BIG fire; for other effects they stay nil but are only read inside the `_effect in [...]` guard, so fine. Light uses `createVehicle` (global) inside a function that is itself remoteExec'd to all — potential for duplicate lights across clients (see below).
- **Unresolved issues:** Possible DUPLICATION bug: since the whole function is remoteExec'd to every client and the light is created with `createVehicle` (global entity), each client could create its own global light → multiple lights. Not verified. Casing: function called with mixed case elsewhere.
- **Reforger port notes:** TBD — Enfusion uses particle emitters and light entities; concept maps but API differs entirely.

### a3e_fnc_GetEnemyCount  —  `Code/functions/Common/fn_GetEnemyCount.sqf`  ·  _status: documented_
- **Purpose:** Returns a `[min,max]` enemy-count range for a spawn point, scaled by mission enemy-frequency parameter and an optional multiplier — used to size dynamically spawned enemy groups.
- **Inputs:** `params [["_modifier",1,[0]]]` (scalar multiplier, default 1). Reads global `A3E_Param_EnemyFrequency`.
- **Outputs:** Returns array `[_minEnemies,_maxEnemies]`. No globals written; no side effects.
- **Calls:** none (leaf function).
- **Called by:** _no `fnc_` references found_ in _xref.md — flagged as possible dead code/entry point. Verify; the naming suggests intended use by spawning code but no active caller was indexed.
- **Processing:** Default min/max 8/12; `switch (_enemyFrequency)`: case 1 → 2/4, case 2 → 4/6, default → 6/8; multiply both by `_modifier`; return pair.
- **Theory of operation:** Central place to translate the difficulty/player-count parameter into a group-size band.
- **Whys & questions:** The pre-switch defaults (8/12) are always overwritten by the switch (which has a `default`), so 8/12 is dead initialization. Why unused by any caller? Possibly superseded by `Spawning/fn_getDynamicSquadsize` or `GetEnemyCount` duplicated logic elsewhere — worth checking.
- **Unresolved issues:** Suspected dead code (no callers indexed). Dead default assignment of 8/12. Duplication risk with dynamic-squad-size logic in Spawning.
- **Reforger port notes:** TBD — trivial numeric mapping; port directly if the frequency parameter survives.

### a3e_fnc_GetPlayers  —  `Code/functions/Common/fn_GetPlayers.sqf`  ·  _status: documented_
- **Purpose:** Returns the list of all alive players in the mission — the single most-used player-enumeration helper in the codebase.
- **Inputs:** none (ignores `_this`). No globals read.
- **Outputs:** Returns array of alive player units (`allPlayers`/`BIS_fnc_listPlayers` filtered by `alive`). No side effects.
- **Calls:** `BIS_fnc_listPlayers` (leaf otherwise).
- **Called by:** Very widely used (~40 call sites in _xref.md), e.g. `AI/fn_Patrol.sqf:41`, `Server/fn_initServer.sqf:209/587/644/668`, `Server/fn_RunExtraction*.sqf` loops, `Spawning/fn_AmbientPatrols.sqf:7`, `SearchLeader.sqf`, and internally by `fn_getPlayerGroup.sqf:10` and `fn_getRandomPlayer.sqf:1`. Called with many casings (`GetPlayers`/`getPlayers`/`Fnc_GetPlayers`).
- **Processing:** `([] call BIS_fnc_listPlayers) select {alive _x}`; returns filtered list.
- **Theory of operation:** Wraps `BIS_fnc_listPlayers` (which excludes headless clients/AI) and adds an alive filter so callers get a clean live-player list without repeating the idiom.
- **Whys & questions:** `BIS_fnc_listPlayers` excludes HC and disconnected units; chosen over `allPlayers` presumably to exclude headless clients. Extremely hot function — called inside tight `while`/`count` loops (e.g. RunExtraction) which recompute the full list repeatedly.
- **Unresolved issues:** Performance: repeated calls in extraction `while` loops (`count(...)!=count(...)`) recompute twice per iteration. Casing inconsistency across call sites (not a functional bug — SQF function names are case-insensitive).
- **Reforger port notes:** TBD — Enfusion has its own player manager (`GetGame().GetPlayerManager()`); this becomes a wrapper over that.

### a3e_fnc_InitVillageMarkers  —  `Code/functions/Common/fn_InitVillageMarkers.sqf`  ·  _status: documented_
- **Purpose:** Creates local map markers for each village defined in the island's `a3e_villageMarkers` config, used both for debug visualization and as internal position references.
- **Inputs:** Ignores its argument (`[true]` passed but unused). Reads globals `a3e_villageMarkers` (island config array of `[pos,dir,shape,size]`), `A3E_Debug`.
- **Outputs:** No return value. Side effects: creates local markers `drn_villageMarkerN`, sets alpha 0 when not in debug; sets global `a3e_var_villageMarkersInitialized = true`. Calls `BIS_fnc_error` if config missing.
- **Calls:** `BIS_fnc_error` (on missing config). Otherwise leaf (engine marker commands).
- **Called by:** `Code/functions/Server/fn_initServer.sqf:205` (`[true] call A3E_fnc_InitVillageMarkers`). Per _xref.md.
- **Processing:** Guard on missing `a3e_villageMarkers`; loop each entry, build marker name from index, create local marker, hide (alpha 0) unless `A3E_Debug`, set shape/dir/size; set initialized flag.
- **Theory of operation:** Villages are named after the DRN legacy library (`drn_villageMarker*`); markers are local (created per client if called there) and only visible with debug on.
- **Whys & questions:** Called only on server (initServer) with `createMarkerLocal` — local markers on the server aren't seen by clients, so debug visualization may only appear if run client-side. The `[true]` argument is ignored (function reads `A3E_Debug` instead). Naming still uses `drn_` prefix.
- **Unresolved issues:** Possible mismatch: `createMarkerLocal` on server won't show to clients — verify whether debug village markers are actually visible. Casing: `A3E_Debug` vs `a3e_var_villageMarkersInitialized`.
- **Reforger port notes:** TBD — map markers exist in Enfusion but API differs; village data likely moves to a world config resource.

### a3e_fnc_KeyDown  —  `Code/functions/Common/fn_KeyDown.sqf`  ·  _status: documented_
- **Purpose:** KeyDown display event handler that disables the map self-centering button (icon 1202) when the player opens the map — prevents auto-centering the map on the player (anti-cheat/immersion, hides player position).
- **Inputs:** `params ["_ctrl","_dikCode","_shift","_ctrlKey","_alt"]` (standard displayEH args). Reads `actionKeys "ShowMap"`.
- **Outputs:** Returns `_handled` (false — lets engine process key). Side effects: sets map control 1202 icon/enable/tooltip via `finddisplay 12`.
- **Calls:** none (leaf function; localize + UI commands).
- **Called by:** Registered in `Code/functions/Common/fn_initLocalPlayer.sqf:83` via `(findDisplay 46) displayAddEventHandler ["keyDown","_this call a3e_fnc_KeyDown"]`. Invoked by the engine display event handler (indirect). Per _xref.md.
- **Processing:** If no modifier keys and the pressed DIK is the ShowMap key, replace the map-center button icon with a disabled one, disable the control, set a localized tooltip; return false.
- **Theory of operation:** When the map opens via the ShowMap key, this disables the "center on player" control so players cannot trivially locate themselves — reinforcing the mission's fog-of-war.
- **Whys & questions:** Relies on hard-coded display id 12 (map) and control id 1202 (center button). Only fires for the ShowMap keypress, not if the map is opened another way. Commented-out `ctrlShow false` alternative present.
- **Unresolved issues:** Fragile hard-coded control ids (engine-version dependent). Returns `_handled=false` always — fine, but means it never suppresses the key.
- **Reforger port notes:** TBD — Reforger map UI and input system are completely different; this behavior would be reimplemented in the map UI layer if needed.

### a3e_fnc_RandomPatrolPos  —  `Code/functions/Common/fn_RandomPatrolPos.sqf`  ·  _status: documented_
- **Purpose:** Picks a random non-water position within `_maxSpawnDistance` of a random reference unit — used to generate patrol waypoints/destinations.
- **Inputs:** `_this select 0` = `_referenceUnits` (array of units); `_this select 1` = `_maxSpawnDistance`. No globals read.
- **Outputs:** Returns a position `[x,y,0]` (or `[0,0,0]` if no reference units). No side effects. `diag_log` on nil input.
- **Calls:** none (leaf function).
- **Called by:** `Code/functions/AI/fn_Patrol.sqf:42` and `:49` (`[_players,_searchRange] call a3e_fnc_RandomPatrolPos`). Per _xref.md.
- **Processing:** Validate; if there are reference units, select one at random, then loop: random direction 0-360 and random distance 0.._maxSpawnDistance, compute x/y offset, reject if on water; return first valid pos.
- **Theory of operation:** Gives patrol groups a plausible on-land destination roughly within range of players/reference units, so patrols wander toward player areas without going into the sea.
- **Whys & questions:** Distance is `random(_maxSpawnDistance)` (0..max, no minimum) so destinations can be right on top of the reference unit. Nearly identical to `RandomSpawnPos` but with no min-distance and no per-unit separation check.
- **Unresolved issues:** DUPLICATION: strongly overlaps `fn_RandomSpawnPos.sqf` (copy-paste; both share leftover unused `_minSpawnDistance` in the `private` list). Infinite-loop risk if all reachable positions are water (rare). Leftover `_minSpawnDistance` declared but unused.
- **Reforger port notes:** TBD — random-point-on-land is straightforward; replace `surfaceIsWater` with Enfusion terrain/water query.

### a3e_fnc_RandomSpawnPos  —  `Code/functions/Common/fn_RandomSpawnPos.sqf`  ·  _status: documented_
- **Purpose:** Picks a random spawn position in an annulus (`_minSpawnDistance.._maxSpawnDistance`) around a random reference unit, avoiding water and staying at least `_minSpawnDistance` from every reference unit.
- **Inputs:** `_this select 0` = `_referenceUnits`; `_this select 1` = `_minSpawnDistance`; `_this select 2` = `_maxSpawnDistance`. No globals read.
- **Outputs:** Returns position `[x,y,0]`. No side effects.
- **Calls:** none (leaf function).
- **Called by:** `Code/functions/DRN/fn_AmbientInfantry.sqf:111` (`[units _referenceGroup,_minDistance,_maxSpawnDistance]`) and `Code/functions/Server/fn_updateTraps.sqf:30`. Per _xref.md.
- **Processing:** Select random reference unit; loop: random dir + distance in `[min,max]`, compute pos; then check every reference unit — invalid if on water or within `_minSpawnDistance` of any; retry until valid; return.
- **Theory of operation:** Ensures spawned units appear at a controlled distance band from players (not too close, not too far) and not clustered on any single unit — used for ambient/trap spawns.
- **Whys & questions:** Nested check over all `_referenceUnits` each attempt; can loop for a while if constraints are tight (e.g. narrow land strip). Uses `vehicle _x` for distance so mounted units counted correctly.
- **Unresolved issues:** DUPLICATION with `fn_RandomPatrolPos.sqf`. No max-iteration guard → theoretical infinite loop if no valid position exists.
- **Reforger port notes:** TBD — same as RandomPatrolPos.

### a3e_fnc_RotatePosition  —  `Code/functions/Common/fn_RotatePosition.sqf`  ·  _status: documented_
- **Purpose:** Rotates a 2D position around a center by a given angle — the core geometry helper for placing template objects (prisons, com centers, depots, motor pools) relative to a rotated template center.
- **Inputs:** `params ["_centerPos","_pos","_dir"]`; `_pos` params to `[_px,_py,[_pz,0]]`; `_centerPos` to `[_mpx,_mpy]`. No globals.
- **Outputs:** Returns rotated position `[_rpx,_rpy,_pz]`. No side effects.
- **Calls:** none (leaf function).
- **Called by:** Extremely widely used by Templates (`fn_AmmoDepot2..5`, `fn_BuildComCenter*`, `fn_BuildPrison*`, `fn_BuildMotorPool*`, `fn_Roadblock*`, etc.) — hundreds of call sites in _xref.md.
- **Processing:** Standard 2D rotation matrix around center; preserves `_pz`.
- **Theory of operation:** Template files store object offsets relative to a canonical (unrotated) center; this rotates each offset by the template's spawn direction so the whole structure can be placed at any orientation.
- **Whys & questions:** Header credits "Engima modified by NeoArmageddon cleaned up by kuroneko." Note some callers pass a **4th argument** (e.g. `fn_AmmoDepot_VN_US1.sqf:53` `...,89.9946`); this function only reads three params, so the 4th is silently ignored — verify whether an older signature took a per-object extra rotation.
- **Unresolved issues:** Signature mismatch (extra 4th arg passed by some AmmoDepot_VN_US callers is ignored). Possible casing `A3E_fnc_rotatePosition` vs `a3e_fnc_RotateP...` — case-insensitive so harmless.
- **Reforger port notes:** TBD — pure math; trivially portable (or replaced by Enfusion transform/quaternion math).

### a3e_fnc_WriteParamBriefing  —  `Code/functions/Common/fn_WriteParamBriefing.sqf`  ·  _status: documented_
- **Purpose:** Adds a "Settings" diary record to the player's briefing containing the mission parameter summary string, so players can see the chosen parameters in the map diary.
- **Inputs:** `params [["_settings","Error - No params received"]]` (a formatted settings string). Preconditions: not dedicated; waits for player.
- **Outputs:** No return value. Side effect: `player createDiaryRecord ["Diary",["Settings",_settings]]`.
- **Calls:** none (leaf function).
- **Called by:** `Code/functions/Server/fn_parameterInit.sqf:65` via `_paramsBriefing remoteExec ["A3E_fnc_WriteParamBriefing",0,true]` (all clients, JIP). Also a commented-out call in `fn_initPlayer.sqf:10`. Per _xref.md.
- **Processing:** If not dedicated, wait for `!isNull player`, then create the diary record.
- **Theory of operation:** RemoteExec'd to every client so each player gets the settings written to their own local diary (diary is local UI state).
- **Whys & questions:** Uses default `"Error - No params received"` string if called with no args — a visible fallback. Guarded by `!isDedicated` so the dedicated server (no player) skips.
- **Unresolved issues:** None obvious. Minor: relies on caller-formatted string; no structure.
- **Reforger port notes:** TBD — Reforger has no diary system; parameter display would move to a UI/notification.

### a3e_fnc_addUserActions  —  `Code/functions/Common/fn_addUserActions.sqf`  ·  _status: documented_
- **Purpose:** Adds the player's context "Hack Terminal" and "Heal at building" scroll-menu actions, with condition helper functions that check proximity/target type.
- **Inputs:** none (uses `player`). Reads `cursorObject`, object vars `A3E_isTerminal`, `A3E_Terminal_Hacked`; localized strings.
- **Outputs:** No return. Side effects: defines global code vars `at_fnc_checkTerminalHack`, `at_fnc_checkHealAtBuilding`; adds two actions; stores their ids in `A3E_localvar_HackAction`, `A3E_localvar_HealAction`; sets player var `A3E_CurrentTerminal`.
- **Calls:** The added actions call `A3E_fnc_Hijack` and `A3E_fnc_HealAtBuilding` (when triggered). Condition code calls `at_fnc_checkTerminalHack` / `at_fnc_checkHealAtBuilding` (defined here). `player reveal`, `addAction` engine.
- **Called by:** `Code/functions/Common/fn_initLocalPlayer.sqf:21` (`[] call A3E_fnc_addUserActions`). Per _xref.md.
- **Processing:** Define two check-functions (proximity ≤3m + terminal/building-type checks, storing current terminal in a player var); add two `addAction`s (hack yellow, heal red) gated by those check-functions.
- **Theory of operation:** Uses `addAction` condition code re-evaluated each frame near the cursor; the check functions stash the current terminal on the player so `fn_hijack` can read it (workaround for cursorTarget instability, see comments).
- **Whys & questions:** `player reveal _target` is described as an "engine optimization workaround" to force reveal for cursorObject to work. Heal action only for `Land_Medevac_House_V1_F` (single classname — mod/DLC dependent). Hack heal building type is hard-coded.
- **Unresolved issues:** Hard-coded building classname `Land_Medevac_House_V1_F` (won't match modded medical buildings). `player setVariable ["A3E_CurrentTerminal", nil]` used to clear — fine. Mixed namespace `at_fnc_*` vs `A3E_fnc_*`.
- **Reforger port notes:** TBD — Reforger uses the action/UserAction component system; both actions reimplemented as `ScriptedUserAction` classes.

### a3e_fnc_bootstrapEscape  —  `Code/functions/Common/fn_bootstrapEscape.sqf`  ·  _status: documented_
- **Purpose:** Top-level mission bootstrap: loads runtime config and island config files, validates them, then launches server-side flow/init and client-side local-player init. Primary postInit entry point.
- **Inputs:** none meaningful (`["postInit"]` from engine). Reads/creates many globals via the compiled config files; checks `A3E_WorldName`, `a3e_villageMarkers`, `a3e_communicationCenterMarkers`, `isServer`, `hasInterface`.
- **Outputs:** No return. Side effects: compiles `config.sqf`, `Island\WorldConfig.sqf`, `Island\VillageMarkers.sqf`, `Island\CommunicationCenterMarkers.sqf`; throws on missing config; spawns `a3e_fnc_missionFlow` and `a3e_fnc_initServer` (server); spawns local-player init with title screen (client).
- **Calls:** `call compile preprocessFileLineNumbers` on config + island files; `A3E_fnc_log` (error logging); spawns `a3e_fnc_missionFlow`, `a3e_fnc_initServer`; calls `a3e_fnc_initLocalPlayer`; `titleText`/`titleFadeOut`.
- **Called by:** **[engine/scheduler]** — registered in `Code/include/functions.hpp:7` class `BootstrapEscape` with `postInit = 1`. Runs automatically at mission start after objects init. (No `fnc_` caller in _xref.md as expected for an entry point.)
- **Processing:** Log; compile config.sqf; compile the three island config scripts; validate presence of `A3E_WorldName`/village/comcenter markers (throw if missing); on server spawn missionFlow + initServer; on interface show loading title and run initLocalPlayer.
- **Theory of operation:** Single deterministic entry that guarantees config is loaded/validated before any server or client subsystem starts; splits into server (spawn) and client (interface) branches.
- **Whys & questions:** Commented-out `Island\WorldConfig.sqf` line 4 (superseded by `_configPath` variant). Why `throw` rather than graceful abort? Throw propagates out of postInit — verify it's caught / that mission fails visibly.
- **Unresolved issues:** Uncaught `throw` behavior in postInit unclear. Dead commented line 4.
- **Reforger port notes:** TBD — becomes the mission/game-mode init entry (`SCR_BaseGameMode` OnGameStart / init methods); config loading replaced by Enfusion config resources.

### a3e_fnc_briefing  —  `Code/functions/Common/fn_briefing.sqf`  ·  _status: documented_
- **Purpose:** Builds the entire player briefing: creates the map diary tasks (Escape prison, Find map, Locate/Hack comcenter, Exfiltrate) with their completion/failure triggers, and writes all the lore/help/hints diary records. Also sets the prison alarm and HSC-exit triggers.
- **Inputs:** none meaningful. Reads/uses globals `A3E_PrisonLoudspeakerObject`, `A3E_WorldName`, `a3e_var_Escape_AllPlayersDead`, `a3e_var_Escape_MissionComplete`, various `A3E_Task_*_Complete/_Failed` flags, `player`.
- **Outputs:** No return. Side effects: creates simple tasks `A3E_Task_Prison/Map/LocateComcenter/ComCenter/Exfil`; many triggers driving task states + alarm sound + HSC exit; initializes `A3E_Task_*_Complete/_Failed` mission vars (public); defines global `A3E_FNC_FailTasks`; sets `A3E_WorldName` fallback; writes many `createDiaryRecord` entries.
- **Calls:** none via `call` to a3e_fnc (all engine: `createTrigger`, `createSimpleTask`, `createDiaryRecord`, trigger statements reference `ATHSC_fnc_exit`). Trigger statements call `ATHSC_fnc_exit` at runtime.
- **Called by:** `Code/functions/Common/fn_initLocalPlayer.sqf:7` (`call A3E_FNC_Briefing`). Per _xref.md.
- **Processing:** Create alarm trigger (moves to loudspeaker, plays AlarmSfx); create HSC-exit trigger on all-dead/complete; for each of 5 tasks: createSimpleTask + description + CREATED state + init Complete/Failed vars + two triggers (Succeeded/Failed); define FailTasks; write ~10 diary records (help, credits, hints, mission text, situation, background).
- **Theory of operation:** Runs client-side (each player builds their own local diary/tasks); triggers watch public mission vars set by server subsystems and update local task states. `{* ISLANDNAME *}` placeholders in text are substituted by the engine from the world.
- **Whys & questions:** Very long, mixes UI text and trigger logic. Task/trigger public vars are initialized here defensively (`isNil` guards) — but if server sets them first there could be ordering concerns. Alarm trigger references `A3E_PrisonLoudspeakerObject` which must exist (commented waituntil at line 4).
- **Unresolved issues:** Large monolith mixing 5 tasks, 3 special triggers, and ~10 diary records — maintenance burden. `A3E_FNC_FailTasks` doesn't fail `A3E_Task_Map`? (it does handle Map). Potential null `A3E_PrisonLoudspeakerObject` if not yet spawned (waituntil commented out).
- **Reforger port notes:** TBD — Reforger task system (`SCR_BaseTask`) and no diary; briefing text moves to UI. Triggers → scripted event listeners.

### a3e_fnc_callRandomFunction  —  `Code/functions/Common/fn_callRandomFunction.sqf`  ·  _status: documented_
- **Purpose:** Selects a random function name from a list and calls it with the given params — the dispatcher used to pick one of several interchangeable template builders (com center / ammo depot / mortar / motor pool variants).
- **Inputs:** `params ["_params","_functions",["_spawn",false]]`; `_functions` = array of function-name strings; `_params` = args to pass. Reads `missionNamespace getVariable _function`.
- **Outputs:** Returns whatever the chosen function returns. Side effects: whatever the chosen function does.
- **Calls:** dynamically calls the selected function via `_params call (missionNamespace getvariable _function)` (indirect — resolves to a3e_fnc_* template builders passed by caller).
- **Called by:** `Code/functions/Server/fn_createAmmoDepots.sqf:89`, `fn_createComCenters.sqf:46`, `fn_createMortarSites.sqf:95`, `fn_createMotorPools.sqf:83`. Per _xref.md.
- **Processing:** `selectRandom _functions`; resolve to code via missionNamespace; `call` with `_params`.
- **Theory of operation:** Lets the placement code pass a list of template variant function names (from island/mod config) and pick one at random, decoupling "which layout" from "how to place it."
- **Whys & questions:** `_spawn` param is declared but never used — despite the name suggesting an optional `spawn` vs `call` mode. Assumes every name resolves to defined code (no isNil guard) — a bad name would error.
- **Unresolved issues:** Dead `_spawn` parameter (unused). No validation that `_function` resolves to code (nil → error). 
- **Reforger port notes:** TBD — random dispatch maps to selecting a prefab/config from an array; function-by-name resolution replaced by typed references.

### a3e_fnc_checkUnitClasses  —  `Code/functions/Common/fn_checkUnitClasses.sqf`  ·  _status: documented_
- **Purpose:** Developer/validation tool: loads all unit-class arrays for a mod/config and logs any vehicle/weapon/magazine/CfgPatch classnames that don't exist or have non-public scope — used to catch typos and missing-mod-content class references.
- **Inputs:** none (self-contained; sets `A3E_Param_*` flags at top). Reads the many `a3e_arr_*` class arrays (populated by the compiled `Units\UnitClasses.sqf` and `fn_loadLocalClasses`). Reads `configFile`.
- **Outputs:** No return. Side effect: `diag_log` for each nonexistent/non-public class. Sets `A3E_Param_UseDLCApex/Laws/NoNightvision/SearchChopper` globals.
- **Calls:** `call compile preprocessFileLineNumbers "Units\UnitClasses.sqf"` and `"functions\Common\fn_loadLocalClasses.sqf"`; recursive local `_fnc_selectFromSet`. No a3e_fnc calls.
- **Called by:** _no `fnc_` references found_ in _xref.md. Header line 1 shows the intended manual invocation (`call compile preprocessFileLineNumbers "functions\Common\fn_checkUnitClasses.sqf"`). Dev-only tool, run manually from console. Not an automatic entry point.
- **Processing:** Force DLC flags; load unit classes; flatten nested vehicle-class arrays; log vehicles with scope < 1; collect weapon/magazine classes from several array shapes; log weapons/magazines with scope < 2; log missing CfgPatches for the additional arsenal box.
- **Theory of operation:** Static validation harness to verify a mod's class arrays against the loaded config before shipping a build.
- **Whys & questions:** Forces `A3E_Param_UseDLCApex/Laws=1` etc. so all conditional classes load for the check. `arrayIntersect` with itself is used to dedupe. Purely a lint/QA tool.
- **Unresolved issues:** Not wired anywhere (intentional — manual tool). Overwrites `A3E_Param_*` globals as a side effect (would corrupt a live mission if run at runtime). Casing across `a3e_arr_*`.
- **Reforger port notes:** TBD — becomes a build-time config validator; not runtime.

### a3e_fnc_cleanupTerrain  —  `Code/functions/Common/fn_cleanupTerrain.sqf`  ·  _status: documented_
- **Purpose:** Hides all natural/structural terrain objects (buildings, trees, rocks, walls, etc.) within a radius of a position on all clients — clears ground so procedurally-built camps/prisons/depots don't clip into map objects.
- **Inputs:** `params [["_position",[],[[]],3],["_radius",0,[0]]]`. No globals.
- **Outputs:** No return. Side effect: for each matched terrain object, `[_x,true] remoteExec ["hideObjectGlobal",0,true]` (JIP, all machines).
- **Calls:** `hideObjectGlobal` via remoteExec; `nearestTerrainObjects` engine. No a3e_fnc calls.
- **Called by:** All template builders — `Templates/fn_AmmoDepot*`, `fn_BuildComCenter*`, `fn_BuildMotorPool*`, `fn_BuildPrison*`, `fn_Roadblock*` (30+ call sites, radius 25/40/50). Per _xref.md.
- **Processing:** Hard-coded list of ~35 terrain-object type strings (BUILDING, TREE, ROCK, WALL, ...); `nearestTerrainObjects` within radius matching the list; `hideObjectGlobal true` each via remoteExec to all + JIP.
- **Theory of operation:** Creates one JIP remoteExec per object so late-joiners also see cleared terrain; noted in header as "a touch expensive."
- **Whys & questions:** Several types commented out deliberately (FOREST BORDER/SQUARE/TRIANGLE, HIDE, RAILWAY) to preserve special roads/pillars/rails. Generates many JIP messages (one per object) — potential network/JIP-queue bloat for dense areas.
- **Unresolved issues:** Performance/JIP-queue concern: 30+ camps × many objects each × persistent JIP remoteExec could accumulate. No batching. `hideObjectGlobal` objects never restored (permanent for session).
- **Reforger port notes:** TBD — Enfusion world editing/streaming differs; would use world-object queries + disabling/hiding entities, likely without per-object JIP.

### a3e_fnc_expandProbabilities  —  `Code/functions/Common/fn_expandProbabilities.sqf`  ·  _status: documented_
- **Purpose:** Expands a compact "probability" array (strings interleaved with repeat-count scalars and nested arrays) into a flat weighted list, so a later `selectRandom` yields the intended distribution.
- **Inputs:** `_this` = the probability array (mix of STRING, ARRAY, SCALAR). No globals.
- **Outputs:** Returns the expanded flat array `_out`. Side effect: `a3e_fnc_debugmsg` on unknown type.
- **Calls:** recurses into `A3E_fnc_expandProbabilities` for nested arrays; `a3e_fnc_debugmsg` for unknown element types.
- **Called by:** `Code/functions/Server/fn_getRndEntryFromFaction.sqf:5` (`_entry call a3e_fnc_expandProbabilities`). Per _xref.md.
- **Processing:** For each element: STRING → append; ARRAY → append recursive expansion; SCALAR → repeat the previous entry `_x-1` extra times (weighting); else debug-msg unknown type.
- **Theory of operation:** Author writes e.g. `["rifleman", 3, "officer"]` meaning rifleman×3; the scalar multiplies the preceding element to encode weights compactly, expanded once to a flat list for uniform `selectRandom`.
- **Whys & questions:** SCALAR meaning depends on preceding element existing (`count _out > 0` guard); a leading scalar is ignored. Recursion appends the nested expanded array as-is. Loop `for [{_i=1},{_i<_x},...]` adds `_x-1` copies (since the original element is already appended once).
- **Unresolved issues:** Fragile positional semantics (scalar must follow an element). Nested arrays are appended flat, which may or may not be intended for weighting. Deep recursion untested for large configs.
- **Reforger port notes:** TBD — weighted random selection is a common Enfusion need; reimplement as a weighted-list builder.

### a3e_fnc_findControl  —  `Code/functions/Common/fn_findControl.sqf`  ·  _status: documented_
- **Purpose:** Debug utility to locate a UI control by its text: brute-force scans displays 0-2999 × controls 0-2999 and hints the display/control ids whose text matches the given string.
- **Inputs:** `_this select 0` = `_text` (string to find). No globals.
- **Outputs:** No return. Side effects: `hint` on match; `player sidechat "Nope: ..."` on every non-match (extremely spammy).
- **Calls:** none (leaf; UI + sidechat).
- **Called by:** _no `fnc_` references found_ in _xref.md — dev-only console helper, dead in production. Verify/remove.
- **Processing:** Nested loop 0..2999 over display ids and control ids; compare `ctrltext` to `_text`; hint on match, sidechat on miss.
- **Theory of operation:** Quick-and-dirty way to discover the display/control ids backing a piece of on-screen text during development.
- **Whys & questions:** 3000×3000 = 9,000,000 iterations with a `sidechat` on nearly every miss — would freeze the client and flood chat. Almost certainly never meant to be run as-is; likely leftover debug scaffolding.
- **Unresolved issues:** BUG/dead code: the `else` branch sidechats on every non-match (9M sidechats) — catastrophically slow; clearly not production code. No callers. Should be deleted or gated.
- **Reforger port notes:** TBD — not portable; debug scaffolding, drop it.

### a3e_fnc_findFlatArea  —  `Code/functions/Common/fn_findFlatArea.sqf`  ·  _status: documented_
- **Purpose:** Finds a flat, empty, road-/building-/water-free area somewhere on the map by repeatedly picking random map points and delegating a local search to `findFlatAreaNear`. Used to place ammo depots, crash sites, mortar sites, and the mission start position.
- **Inputs:** `params [["_flat_area_radius",3],["_offset_radius",200],["_gradient",0.1],["_max_tries_within_grid",1000],["_max_num_search_areas",0]]`. Reads map objects `SouthWest`/`NorthEast` (editor markers/objects for map corners).
- **Outputs:** Returns a 2D position `[x,y,0]`, or `[]` if none found. No side effects.
- **Calls:** `A3E_fnc_findFlatAreaNear` (per search area). Optional commented `A3E_fnc_debugLog`.
- **Called by:** `Server/fn_createAmmoDepots.sqf:22`, `Server/fn_CreateCrashSites.sqf:3`, `Server/fn_createMortarSites.sqf:29`, `Server/fn_initServer.sqf:190/192/434`. Per _xref.md.
- **Processing:** Compute map bounds inset by `_offset_radius` from SouthWest/NorthEast; loop: pick random map point, call `findFlatAreaNear`; on non-empty result, stop; convert to `[x,y,0]` and return.
- **Theory of operation:** Two-stage random search — global (random map point) then local (`findFlatAreaNear`) — to find open ground suitable for placing a base without clipping roads/houses/water.
- **Whys & questions:** Return logic is odd: `_retval` is only set when `_max_num_search_areas_excceded` is true, and with the default `_max_num_search_areas=0` that flag is set after the first iteration (`_ii(1) > 0`) — so it works, but the naming implies the opposite (it returns the found pos only because the "exceeded" flag happens to be true). This looks accidental.
- **Unresolved issues:** BUG-candidate: `_max_num_search_areas_excceded` (typo, double-c) gates the return; with default 0 it always becomes true so the found position is returned — but the intent ("exceeded" = failure) is inverted vs. the returned success value. If a caller passed a large `_max_num_search_areas`, `_retval` might stay `[]` even when a position was found until the counter is exceeded. Needs review. Typo in identifier.
- **Reforger port notes:** TBD — flat-area finding maps to Enfusion terrain/spawn-point queries; `SouthWest`/`NorthEast` corner objects replaced by world bounds.

### a3e_fnc_findFlatAreaNear  —  `Code/functions/Common/fn_findFlatAreaNear.sqf`  ·  _status: documented_
- **Purpose:** Finds a flat, empty position within a search radius of a given center — validates flatness, no roads, no water, no nearby buildings. The local worker behind `findFlatArea`.
- **Inputs:** `params ["_center_pos",["_max_offset_radius",1000],["_flat_area_radius",3],["_gradient",0.1],["_max_tries",0]]`. No globals.
- **Outputs:** Returns the `isFlatEmpty` result position array, or `[]` if not found within `_max_tries`. No side effects.
- **Calls:** none a3e_fnc (engine `isFlatEmpty`, `nearRoads`, `nearObjects`, `surfaceIsWater`). Commented `A3E_fnc_debugLog`.
- **Called by:** `Code/functions/Common/fn_findFlatArea.sqf:56` (`_arg_vector call A3E_fnc_findFlatAreaNear`). Per _xref.md.
- **Processing:** Loop: random offset within `_max_offset_radius`; `isFlatEmpty` check; ensure no roads within 30m, not water, no objects within 30m, and no "House" within 50m of the result; stop when found or `_max_tries` exceeded (0 = infinite).
- **Theory of operation:** Combines engine flatness test with clearance checks to guarantee a spawnable, unobstructed area for base placement.
- **Whys & questions:** `_max_tries=0` means infinite loop until found — relies on the map having a valid area (safe for real terrains). `call {count _result > 0}` wrapping is redundant.
- **Unresolved issues:** Potential infinite loop if no valid area exists and `_max_tries=0` (as called by `findFlatArea`, which passes `_max_tries_within_grid=1000` → not infinite). Redundant `call {}` wrapper. `nearObjects 30` (count==0) is strict — may reject otherwise-fine spots near clutter.
- **Reforger port notes:** TBD — same as findFlatArea.

### a3e_fnc_getAssocArrayEntry  —  `Code/functions/Common/fn_getAssocArrayEntry.sqf`  ·  _status: documented_
- **Purpose:** Looks up a value by key in a two-array "associative array" of the form `[[keys],[values]]` — used to read faction config fields (e.g. FactionName) and to pull class arrays by key.
- **Inputs:** `params ["_arr","_key"]`; `_arr` must be `[keysArray, valuesArray]`. No globals.
- **Outputs:** Returns the matching value, or `[]` on error (bad array shape or missing key). Side effect: `a3e_fnc_debugmsg` / `a3e_fnc_log` on error.
- **Calls:** `a3e_fnc_debugmsg` (bad array), `a3e_fnc_log` (key not found).
- **Called by:** `Code/functions/Server/fn_getRndEntryFromFaction.sqf:12`, `Code/functions/Server/fn_selectFaction.sqf:69`. Per _xref.md.
- **Processing:** Validate `_arr` is an array of length 2; `find` the key in keys; if -1 log error and return []; else return the value at that index.
- **Theory of operation:** Lightweight parallel-array map (predates/avoids HashMap) for faction/config structures loaded from island configs.
- **Whys & questions:** Returns `[]` as the "not found" sentinel — ambiguous if a real value is `[]`. Uses parallel arrays instead of `createHashMap` (SQF added HashMaps later; some code, e.g. loadLocalClasses, does use HashMaps — inconsistency).
- **Unresolved issues:** `[]` sentinel ambiguity. Inconsistent data-structure choice vs. HashMap usage elsewhere. Error path returns `_return` (which is []) — callers may not check.
- **Reforger port notes:** TBD — replace with a real map/`ref` config lookup in Enfusion.

### a3e_fnc_getPlayerGroup  —  `Code/functions/Common/fn_getPlayerGroup.sqf`  ·  _status: documented_
- **Purpose:** Returns a single "reference" player group for the mission — the group of the first player found (MP) or the local player's group (SP). Used as a spawn/reference anchor by many server subsystems.
- **Inputs:** none. Reads `isMultiplayer`, `player`. Calls `A3E_fnc_GetPlayers`.
- **Outputs:** Returns a group (or `grpNull` if no player found in MP). No side effects.
- **Calls:** `A3E_fnc_GetPlayers`.
- **Called by:** `Server/fn_createComCenters.sqf:71`, `Server/fn_createMotorPools.sqf:78`, `Server/fn_FindSpawnRoad.sqf:1`, `Server/fn_firedNearExtraction.sqf:35`, `Server/fn_initServer.sqf:211/258`, `Spawning/fn_initPatrolZone.sqf:47`, `Zones/fn_initZone.sqf:47`, `Scripts/Escape/EscapeSurprises.sqf:350`, `Scripts/Escape/SearchLeader.sqf:116`. Per _xref.md.
- **Processing:** MP → loop players, return `group` of first `isPlayer`, default `grpNull`; SP → `group player`.
- **Theory of operation:** Since all players start in one squad, the "first player's group" is a good stand-in for "the player group" used as a distance/reference anchor for spawning and zone logic.
- **Whys & questions:** Assumes players share one group (true for Escape). On dedicated server with no player yet returns `grpNull` — callers in initServer wait for players first. `isPlayer` loop returns first found, order not guaranteed.
- **Unresolved issues:** Returns `grpNull` if called before any player connects — callers must guard (some do via `waituntil count GetPlayers > 0`). Commented-out `_modifier` param leftover.
- **Reforger port notes:** TBD — "player faction/group" concept exists in Reforger; reimplement over player manager.

### a3e_fnc_getRandomPlayer  —  `Code/functions/Common/fn_getRandomPlayer.sqf`  ·  _status: documented_
- **Purpose:** Returns one randomly-selected alive player — used to pick a target/reference player for drones and spawn-road selection.
- **Inputs:** none. Calls `A3E_FNC_GetPlayers`.
- **Outputs:** Returns a player unit (or nil/`objNull`-like if no players). No side effects.
- **Calls:** `A3E_FNC_GetPlayers`; `selectRandom`.
- **Called by:** `Code/functions/AI/fn_LeafletDrone.sqf:91` (`getpos ([] call A3E_fnc_GetRandomPlayer)`), `Code/functions/Server/fn_FindSpawnRoad.sqf:7` (`vehicle (call A3E_fnc_getRandomPlayer)`). Per _xref.md.
- **Processing:** Get alive players; `selectRandom`; return.
- **Theory of operation:** Simple randomizer so behaviors (drone target, spawn road) don't always key off the same player.
- **Whys & questions:** No empty-list guard — `selectRandom []` returns nil; callers doing `getpos nil`/`vehicle nil` could misbehave if called with zero players.
- **Unresolved issues:** No guard against empty player list (nil return). 
- **Reforger port notes:** TBD — trivial; port over player manager.

### a3e_fnc_getSideColor  —  `Code/functions/Common/fn_getSideColor.sqf`  ·  _status: documented_
- **Purpose:** Maps an Arma side to a standard marker color name (civilian→white, west→blue, east→red, resistance→green, else black) for map markers.
- **Inputs:** `[_this,0] call bis_fnc_param` = `_side`. No globals.
- **Outputs:** Returns a color string like `"ColorBlue"`. No side effects.
- **Calls:** `BIS_fnc_param` (leaf otherwise).
- **Called by:** `Code/functions/Debug/fn_TrackGroup.sqf:13` (`[side leader _group] call a3e_fnc_getSideColor`); commented use in `Debug/fn_TrackGroup_Update.sqf:57`. Per _xref.md.
- **Processing:** `switch(_side)` over civilian/west/east/resistance with a black default; return color.
- **Theory of operation:** Standard side→color convention for debug/track markers.
- **Whys & questions:** DUPLICATION: an identical `getSideColor` exists in `Code/functions/Helper/` (flagged in assignment). The two are byte-for-byte equivalent side→color maps — one should be canonical.
- **Unresolved issues:** DUPLICATION with `Helper/fn_getSideColor.sqf` — consolidate. Only used by Debug (near-dead outside debug).
- **Reforger port notes:** TBD — side/faction→color mapping trivially reimplemented.

### a3e_fnc_groupChat  —  `Code/functions/Common/fn_groupChat.sqf`  ·  _status: documented_
- **Purpose:** Sends a side-chat "HQ" message on a given side channel — a helper for radio-style HQ messages.
- **Inputs:** `[_this,0,"Empty message",[""]] call BIS_fnc_param` = `_msg`; `[_this,1,A3E_VAR_Side_Blufor,[sideUnknown]] call BIS_fnc_param` = `_side`. Reads global `A3E_VAR_Side_Blufor`.
- **Outputs:** No return. Side effect: `[_side,"HQ"] SideChat _msg`.
- **Calls:** `BIS_fnc_param` (leaf otherwise).
- **Called by:** _no `fnc_` references found_ in _xref.md — possibly dead or superseded by `groupChat`/`sideChat` inline usage elsewhere. Verify.
- **Processing:** Read msg/side with defaults; emit sidechat as a virtual "HQ" unit on `_side`.
- **Theory of operation:** Wraps `sideChat` with a fixed "HQ" sender so HQ messages have consistent formatting.
- **Whys & questions:** Named `groupChat` but actually uses `sideChat`. No callers found — possibly replaced by direct sidechat calls or a Common/systemChat path. `A3E_VAR_Side_Blufor` must be defined before default is evaluated.
- **Unresolved issues:** Suspected dead code (no callers). Misleading name (groupChat vs sideChat).
- **Reforger port notes:** TBD — Reforger uses notification/radio systems, not sideChat.

### a3e_fnc_handleRating  —  `Code/functions/Common/fn_handleRating.sqf`  ·  _status: documented_
- **Purpose:** HandleRating event handler that prevents a unit's rating from going further negative once it's already ≤0 — stops rating penalties (e.g. friendly-fire on civilians) from stacking below zero.
- **Inputs:** `params ["_unit","_rating"]` (EH args: unit and rating delta). Reads `rating _unit`.
- **Outputs:** Returns the (possibly zeroed) `_rating` used by the HandleRating EH to override the change. Side effect: `diag_log` when nulled.
- **Calls:** none (leaf function).
- **Called by:** Registered in `Code/functions/Common/fn_initLocalPlayer.sqf:39` via `player addeventhandler ["HandleRating","_this call A3E_FNC_handleRating;"]`. Invoked by engine HandleRating EH (indirect). Per _xref.md.
- **Processing:** If current rating ≤0 and the incoming `_rating` delta is negative, set `_rating=0` (log); return `_rating`.
- **Theory of operation:** The HandleRating EH lets script override rating changes; this clamps negative rating so players don't accumulate unbounded penalties (which affect AI hostility).
- **Whys & questions:** Only clamps when already ≤0; a single large negative when rating >0 still applies. `diag_log` mislabels — logs `_rating` (now 0) not the original.
- **Unresolved issues:** Log message uses post-nulled value (`_rating` already 0) — misleading log. Minor.
- **Reforger port notes:** TBD — Reforger has no rating system; reputation/hostility handled by its faction/AI systems.

### a3e_fnc_handleScore  —  `Code/functions/Common/fn_handleScore.sqf`  ·  _status: documented_
- **Purpose:** HandleScore event handler that suppresses negative score changes for civilian kills (when civilian reporting is active) or when a unit's score is already ≤0 — prevents score going negative from unintended events.
- **Inputs:** `params ["_unit","_object","_score"]` (EH args). Reads `side _object`, global `a3e_var_Escape_SearchLeader_civilianReporting`, `score _unit`.
- **Outputs:** Returns boolean — `false` to block the score change, `true` to allow it. Side effect: `diag_log` when nulled.
- **Calls:** none (leaf function).
- **Called by:** Registered in `Code/functions/Server/fn_initPlayer.sqf:14` via `_player addeventhandler ["HandleScore","_this call A3E_FNC_handleScore;"]`. Invoked by engine HandleScore EH (indirect). Per _xref.md.
- **Processing:** If (killed object is civilian AND civilianReporting active AND score<0) OR (unit score ≤0 AND score<0) → return false (block); else true.
- **Theory of operation:** HandleScore EH returning false vetoes the score change; used to keep the scoreboard from penalizing players for civilian casualties under certain conditions and to floor at zero.
- **Whys & questions:** Relies on `!isNil "a3e_var_Escape_SearchLeader_civilianReporting"` as a proxy for "civilian reporting active" — presence of the var, not its value. Registered per-player on server (initPlayer) whereas handleRating is client (initLocalPlayer) — asymmetry.
- **Unresolved issues:** Uses `!isNil(var)` rather than the var's boolean value — may misfire if the var is set to false but defined. Asymmetric registration site vs handleRating.
- **Reforger port notes:** TBD — Reforger scoring differs; reimplement in its scoring subsystem.

### a3e_fnc_healAtBuilding  —  `Code/functions/Common/fn_healAtBuilding.sqf`  ·  _status: documented_
- **Purpose:** Action handler that fully heals the player and plays a medic animation — the effect of the "Heal at building" scroll action added by addUserActions.
- **Inputs:** `params ["_obj","_unit","_id"]` (addAction args: target object, caller unit, action id). No globals.
- **Outputs:** No return. Side effects: `_unit setDamage 0.0`; `_unit playActionNow "Medic"`.
- **Calls:** none (leaf function).
- **Called by:** The action added in `Code/functions/Common/fn_addUserActions.sqf:52` (`"_this call A3E_fnc_HealAtBuilding;"`). Invoked when the player uses the heal action (indirect). Per _xref.md.
- **Processing:** Set unit damage 0 (full heal); play medic animation.
- **Theory of operation:** Simple heal-at-medical-building reward — action's condition (in addUserActions) gates it to being near a `Land_Medevac_House_V1_F`.
- **Whys & questions:** Full heal (setDamage 0) ignores ACE medical state — likely bypasses ACE wounds. No cooldown/limit. `playActionNow` runs locally where action fires.
- **Unresolved issues:** setDamage 0 may not integrate with ACE Medical (which tracks wounds separately) — potential inconsistency under ACE. No limit/cooldown.
- **Reforger port notes:** TBD — heal-at-location reimplemented via Reforger damage/health component reset.

### a3e_fnc_hijack  —  `Code/functions/Common/fn_hijack.sqf`  ·  _status: documented_
- **Purpose:** The com-center terminal hacking action: runs the timed hack sequence on the terminal, animates it, and on success requests an extraction zone from the server. Core mission-progression action.
- **Inputs:** `params ["_target","_unit","_id"]` (addAction args). Reads player var `A3E_CurrentTerminal` (set by addUserActions check fn), terminal var `A3E_Terminal_Hacked`, unit engineer config, unit var `AT_Revive_isUnconscious`.
- **Outputs:** No return. Side effects: sets terminal `A3E_Terminal_Hacked` (public); animates/colors terminal (`BIS_fnc_DataTerminalColor/Animate`); `cutText` progress UI; on success `remoteExec ["A3E_fnc_SelectExtractionZone",2]` to server; `diag_log`.
- **Calls:** `BIS_fnc_DataTerminalColor`, `BIS_fnc_DataTerminalAnimate`, `BIS_fnc_returnConfigEntry`; `A3E_fnc_SelectExtractionZone` via remoteExec to server (2).
- **Called by:** The hack action added in `Code/functions/Common/fn_addUserActions.sqf:41` (`"_this call A3E_fnc_Hijack;"`). Invoked when player uses hack action (indirect). Per _xref.md.
- **Processing:** Read current terminal; abort if already hacked; mark hacked + color red; base count 36 ticks (12 if engineer); animate at 3 progress states; loop 1s ticks while near terminal and conscious, showing "Hacking N"; on abort (unconscious/too far) revert hacked flag + green; on completion (count==0) remoteExec SelectExtractionZone to server.
- **Theory of operation:** Client-side timed interaction with server hand-off (extraction selection is authoritative on server via remoteExec 2). Engineer hacks 3× faster (12 vs 36s). Terminal color signals state to all (green=available, red=in-progress/done).
- **Whys & questions:** Comment notes change from `cursorTarget` to player var `A3E_CurrentTerminal` (reliability). Sets `A3E_Terminal_Hacked=true` at start (to lock others out) then reverts on failure — brief window where a failed hack shows "hacked". Uses `AT_Revive_isUnconscious` only (not ACE) to detect downed — under ACE the abort-on-unconscious check may not trigger.
- **Unresolved issues:** ACE incompatibility: downed detection uses `AT_Revive_isUnconscious` only, not `ACE_Revive_isUnconscious` — hack may continue while ACE-unconscious. Early-set hacked flag could confuse concurrent hackers. Variable named `_generatorTrailer` (legacy) for the terminal.
- **Reforger port notes:** TBD — reimplement as a timed `ScriptedUserAction` with server RPC for extraction; terminal animation via prefab states.

### a3e_fnc_initArsenal  —  `Code/functions/Common/fn_initArsenal.sqf`  ·  _status: documented_
- **Purpose:** Configures a supply box as a BIS virtual arsenal stocked with the weapons/magazines from the mod's "additional weapon box" CfgPatches — used to fill certain ammo-depot arsenal crates.
- **Inputs:** `params ["_box"]` (object). Reads globals `a3e_additional_weapon_box_arsenal_cfgPatches`, `a3e_additional_weapon_box_arsenal_weapons`; reads `configFile`.
- **Outputs:** No return. Side effects: initializes arsenal on box (`BIS_fnc_arsenal "AmmoboxInit"`); adds virtual weapon/magazine cargo.
- **Calls:** `BIS_fnc_arsenal`, `BIS_fnc_addVirtualWeaponCargo`, `BIS_fnc_addVirtualMagazineCargo`.
- **Called by:** `Code/functions/Templates/fn_AmmoDepot*.sqf` (many: fn_AmmoDepot, 2, 3, 4, 5, _spe1/2/3, _VN_nva1, _VN_US1; two calls each, ~20 sites). Per _xref.md.
- **Processing:** Exit if no cfgPatches configured; gather all public-scope weapons whose source addon is in the configured patches (via `configClasses`), collect their magazines; append explicit extra weapons + their magazines; dedupe magazines; init arsenal and add virtual weapon/magazine cargo.
- **Theory of operation:** Lets each mod expose a curated arsenal (by addon patches + explicit list) that gets dynamically populated into arsenal crates without hard-listing every class.
- **Whys & questions:** Silent exit if `a3e_additional_weapon_box_arsenal_cfgPatches` is nil (no arsenal). Uses `configSourceAddonList` / `configClasses` — heavy config iteration per box (called ~2× per depot). Scope==2 (public) filter.
- **Unresolved issues:** Performance: full CfgWeapons scan per box call. Depends on mod-config globals being set (loadLocalClasses). 
- **Reforger port notes:** TBD — Reforger has no BIS arsenal; supply/loadout systems differ entirely (SCR_ArsenalComponent).

### a3e_fnc_initLocalPlayer  —  `Code/functions/Common/fn_initLocalPlayer.sqf`  ·  _status: documented_
- **Purpose:** Client-side per-player initialization: builds briefing, strips starting gear, registers actions/event handlers/keybinds, sets up revive (ATR or ACE), grass/terrain, magrepack, and readiness handshake with the server. The main client bootstrap body.
- **Inputs:** `_this` (logged). Reads/writes many globals: `A3E_DEBUG`, `A3E_Param_ReviveView/Grass/Magrepack`, `A3E_ParamsParsed`, `A3E_WorldName`, `A3E_Task_Prison_Complete`, `A3E_EscapeHasStarted`, ACE config presence, `CBA_fnc_addKeybind`.
- **Outputs:** No return. Side effects: creates diary (via Briefing); removes all player gear; adds actions/EHs; sets player vars `A3E_PlayerInitializedLocal`; various UI/title; remoteExec `a3e_fnc_initPlayer` to server; keybind registration; execVM magrepack.
- **Calls:** `A3E_FNC_Briefing`, `A3E_fnc_addUserActions`, `A3E_FNC_handleRating` (EH), `A3E_FNC_collectIntel` (EH), `a3e_fnc_KeyDown` (EH), `a3e_fnc_toggleEarplugs` (keybind), `ATR_FNC_ReviveInit`; `a3e_fnc_initPlayer` via remoteExec to server (2); `drn_fnc_Escape_DisableLeaderSetWaypoints` (defined here); `BIS_fnc_infoText`; execVM `MagRepack_init_sv.sqf`; compile `dronehack_init.sqf`.
- **Called by:** `Code/functions/Common/fn_bootstrapEscape.sqf:42` (`[] call a3e_fnc_initLocalPlayer`). Runs inside the client `hasInterface` spawn. Per _xref.md.
- **Processing:** Guard non-interface; wait for player; briefing; remoteExec initPlayer to server; set ATR revive defaults; addUserActions; strip all gear; debug allowdamage/map; register HandleRating + InventoryClosed EHs; disable MP "move-to waypoint" cheat; wait params; set revive camera; init ACE or ATR revive; dronehack; terrain grid; magrepack; register KeyDown EH; set local-init flag; wait for server-init flag; spawn ACE/mission-start/exfil watchers; register earplugs keybind.
- **Theory of operation:** Establishes the whole client-side player state and the two-way readiness handshake (`A3E_PlayerInitializedLocal` ↔ `A3E_PlayerInitializedServer`) so server and client agree the player is ready before the mission proceeds.
- **Whys & questions:** Branches heavily on ACE presence (`CfgPatches>>ACE_Medical`). Commented-out KeyDown waypoint-disable line 56 (uses MouseButtonDown instead). Multiple nested spawns for staged waits. `A3E_DEBUG` grants god mode + map + teleport.
- **Unresolved issues:** Long monolithic init with many implicit ordering dependencies (waituntil on several globals). ACE-vs-ATR branching duplicated across the codebase. Debug teleport (`onMapSingleClick setpos`) must never ship enabled.
- **Reforger port notes:** TBD — becomes the player-controller/component init; gear stripping, actions, keybinds, revive all map to Reforger component systems.

### a3e_fnc_loadLocalClasses  —  `Code/functions/Common/fn_loadLocalClasses.sqf`  ·  _status: documented_
- **Purpose:** Merges player-profile-defined custom class arrays (from `profileNamespace "A3E_Classes"`) into the mission's `a3e_arr_*` class globals, filtered to an allow-list and to the current mod — lets server admins override/extend unit/weapon class lists without editing the mission.
- **Inputs:** none. Reads `profileNamespace getVariable "A3E_Classes"` (nested `[[modKey,[[arrayName,arrayValue],...]],...]`), `getMissionConfigValue "EscapeMod"`. Writes many `a3e_arr_*` mission globals.
- **Outputs:** No return. Side effects: for allowed array names, sets/append the mission-namespace class arrays; `a3e_fnc_rptLog` diagnostics.
- **Calls:** `a3e_fnc_rptLog`; `createHashMapFromArray` engine.
- **Called by:** `Code/functions/Server/fn_initServer.sqf:65` (`call a3e_fnc_loadLocalClasses`); also compiled directly by `fn_checkUnitClasses.sqf:8` (dev tool). Per _xref.md.
- **Processing:** Exit if no profile classes; build allow-list of array names (lowercased); read `EscapeMod`; make HashMap of profile classes; for each of `["global", _mod]`, for each `[arrayName,arrayValue]`, skip if not in allow-list (log "bad array"), else set (if nil) or append to the mission global.
- **Theory of operation:** Server-side extensibility hook: admins put custom class arrays in their Arma profile; this safely merges the whitelisted, mod-matching subset so per-server class customization is possible without recompiling.
- **Whys & questions:** Allow-list is a security/safety measure (only known array names accepted). Uses modern HashMap here while other code uses assoc arrays — inconsistency. `getMissionConfigValue "EscapeMod"` drives which mod-section merges.
- **Unresolved issues:** Data-structure inconsistency (HashMap here vs assoc arrays in getAssocArrayEntry). Relies on admin-provided profile data format being correct (partial `params`/`isNil` guards). 
- **Reforger port notes:** TBD — profile-based overrides map to Reforger config/mod loadout data; whitelist concept still useful.

### a3e_fnc_systemChat  —  `Code/functions/Common/fn_systemChat.sqf`  ·  _status: documented_
- **Purpose:** Conditional systemChat wrapper — prints a system-chat message only when the global debug/system-log flag `A3E_SystemLog` is enabled. Used for gated debug output.
- **Inputs:** `_this select 0` = message. Reads global `A3E_SystemLog`.
- **Outputs:** No return. Side effect: `systemchat` when enabled.
- **Calls:** none (leaf function).
- **Called by:** _no direct `fnc_` references listed in the Common section of _xref.md_ (not indexed there). Likely used via `A3E_fnc_systemChat` at scattered debug sites or dead; verify. (Distinct from engine `systemChat` used directly elsewhere.)
- **Processing:** If `A3E_SystemLog` defined and true, `systemchat` the first element.
- **Theory of operation:** Central on/off switch for developer system-chat spam, controlled by one global.
- **Whys & questions:** Nested `if(!isNil) if(...)` rather than a single guard. Only reads element 0 (no formatting). No callers indexed — may be effectively dead or invoked dynamically.
- **Unresolved issues:** Possible dead code (no indexed callers). Redundant with direct `systemChat` usage elsewhere (which is not gated).
- **Reforger port notes:** TBD — debug log gating maps to Reforger `Print`/log-level system.

### a3e_fnc_toggleEarplugs  —  `Code/functions/Common/fn_toggleEarplugs.sqf`  ·  _status: documented_
- **Purpose:** Toggles "earplugs" — lowers game sound volume and shows an on-screen earplug indicator; toggling again restores volume and removes the indicator. Bound to a CBA keybind.
- **Inputs:** none meaningful. Reads/writes player vars `EarplugsActivated`, `EarplugsImage`, `EarplugsText`.
- **Outputs:** Returns `true`. Side effects: `fadeSound` (0.4 in / 1.0 out); creates/deletes RscText + RscPicture controls on display 46; sets player vars.
- **Calls:** none a3e_fnc (engine UI/sound + `localize`).
- **Called by:** Registered in `Code/functions/Common/fn_initLocalPlayer.sqf:115` via `CBA_fnc_addKeybind` (`"toggle_earplugs_key"`, `{_this call A3E_fnc_toggleEarplugs}`). Invoked on keypress (indirect). Per _xref.md.
- **Processing:** Read current state; if on → restore sound, clear vars, delete UI controls; else → fade sound to 0.4, create earplug text + image controls (uiNamespace), store control handles on player, set state true; return true.
- **Theory of operation:** Standard earplugs QoL feature (reduce loud gunfire/engine noise), with a persistent on-screen indicator while active. Returns true to satisfy CBA keybind handled-flag.
- **Whys & questions:** `_activated` is not declared `private` (line 1) — leaks to caller scope. Fixed fade level 0.4 (not configurable). Stores UI control handles on the player object.
- **Unresolved issues:** Missing `private _activated`. UI positions hard-coded (1.5,0.55 etc.) — may not fit all resolutions. 
- **Reforger port notes:** TBD — Reforger audio system + UI overlay reimplementation; keybind via its input action system.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-06-30 | Claude | Documented all entries |
