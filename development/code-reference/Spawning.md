# Code Reference — Spawning
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Dynamic unit/vehicle spawning and zone population. One entry per source file in `Code/functions/Spawning/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_AmbientPatrols  —  `Code/functions/Spawning/fn_AmbientPatrols.sqf`  ·  _status: documented_
- **Purpose:** One Chronos tick that maintains a pool of roaming ambient enemy/independent infantry patrols around the players: cleans up empty/too-far groups and spawns a new one if under the cap.
- **Inputs:** No params. Reads globals `A3E_AmbientAIGroups`, `A3E_MaxAmbientAIGroups` (default 15), `A3E_MinSpawnCircleDistance`/`A3E_MaxSpawnCircleDistance` (800/1500), `A3E_UnitRemovalDistance` (2000), sides `A3E_VAR_Side_Opfor`/`A3E_VAR_Side_Ind`. Precondition: server, mission running.
- **Outputs:** Writes back `A3E_AmbientAIGroups`. Side effects: deletes far/empty groups, their units and vehicles; spawns one new patrol group with units; starts `A3E_fnc_Patrol` and `A3E_fnc_TrackGroup_Add` threads; logs.
- **Calls:** `A3E_fnc_GetPlayers`, `A3E_fnc_Log`, `A3E_fnc_NearestObjectDis`, `A3E_fnc_GetCircularSpawnPos`, `a3e_fnc_getDynamicSquadSize`, `A3E_FNC_SpawnPatrol`; spawns `A3E_fnc_Patrol`, `A3E_fnc_TrackGroup_Add`.
- **Called by:** Chronos-registered — `Code/functions/Server/fn_initServer.sqf:680` `["A3E_FNC_AmbientPatrols"] call A3E_FNC_Chronos_Register;` (invoked periodically by the Chronos scheduler; see Chronos appendix).
- **Processing:** Halves spawn radius in first 10 s. Iterates group list: deletes empty groups; for others, if nearest player > removal distance, deletes crew/vehicles and the group, nulls the slot. Compacts out nulls. If under cap, gets a circular spawn pos and spawns a patrol (random Opfor/Ind, dynamic squad size).
- **Theory of operation:** Keeps a bounded population of ambient patrols cycling in/out of a ring around the player group, so the world feels alive without unbounded unit count.
- **Whys & questions:** Random side list `[Opfor,Ind,Ind,Ind]` weights independent 3:1. Why half radius for first 10 s? Likely to populate quickly at mission start before players move.
- **Unresolved issues:** Cleanup/spawn logic is duplicated near-verbatim in `fn_CivilianCommuters` and `fn_MilitaryTraffic` (log tag "AmbientAI" is even reused in all three empty-group branches). `_leader`, `_group` written as global (no `private`).
- **Reforger port notes:** TBD — Reforger has its own AI group/spawn manager and streaming; the distance-based cull + circular spawn pattern maps to a spawn-manager but the exact tuning would be re-derived.

### a3e_fnc_CivilianCommuters  —  `Code/functions/Spawning/fn_CivilianCommuters.sqf`  ·  _status: documented_
- **Purpose:** Chronos tick maintaining a pool of ambient civilian vehicles ("commuters") driving on roads around the players; cleanup + capped spawn, same pattern as AmbientPatrols/MilitaryTraffic.
- **Inputs:** No params. Reads `A3E_MaxCivilianCommutersGroups` (default 4), spawn-circle distances (800/1500), `A3E_UnitRemovalDistance` (2000), `A3E_CivilianCommuterGroups`, and `a3e_arr_Escape_MilitaryTraffic_CivilianVehicleClasses`. Precondition: server.
- **Outputs:** Writes `A3E_CivilianCommuterGroups`. Side effects: deletes far/empty groups + vehicles; spawns a civilian vehicle group; starts `A3E_fnc_CivilianCommuter` and `A3E_fnc_TrackGroup_Add`; logs. Exits early if no civilian vehicle classes configured (`fn_CivilianCommuters.sqf:50`).
- **Calls:** `A3E_fnc_GetPlayers`, `A3E_fnc_Log`, `A3E_fnc_NearestObjectDis`, `A3E_fnc_GetCircularSpawnPos` (with "ROAD"), `A3E_fnc_SpawnCivilianVehicle`; spawns `A3E_fnc_CivilianCommuter`, `A3E_fnc_TrackGroup_Add`.
- **Called by:** Chronos-registered — `Code/functions/Server/fn_initServer.sqf:682` `["A3E_FNC_CivilianCommuters"] call A3E_FNC_Chronos_Register;`.
- **Processing:** Identical cleanup loop to AmbientPatrols. Then requests a road spawn pos and, if valid, spawns a civilian commuter vehicle group.
- **Theory of operation:** Populates roads with civilian traffic near players to add atmosphere and warcrime/collateral tension; bounded and self-cleaning.
- **Whys & questions:** Uses "ROAD" filter in GetCircularSpawnPos so vehicles spawn on roads. Log line at :60 says "Military Traffic created" — copy-paste from MilitaryTraffic.
- **Unresolved issues:** Duplicated cleanup/spawn boilerplate (see AmbientPatrols). Empty-group log tag still "AmbientAI" (:20). Mislabeled log string "Military Traffic created" for civilians. `_leader`/`_group` not `private`.
- **Reforger port notes:** TBD — civilian traffic could use Reforger's ambient/traffic systems; class-list gating and road spawn logic reusable conceptually.

### a3e_fnc_MilitaryTraffic  —  `Code/functions/Spawning/fn_MilitaryTraffic.sqf`  ·  _status: documented_
- **Purpose:** Chronos tick maintaining a pool of ambient enemy military vehicle patrols on roads around the players; cleanup + capped spawn, same pattern as the other two.
- **Inputs:** No params. Reads `A3E_MaxMilitaryTrafficGroups` (default 3), spawn-circle distances (800/1500), `A3E_UnitRemovalDistance` (2000), `A3E_MilitaryTrafficGroups`, sides `A3E_VAR_Side_Opfor`/`A3E_VAR_Side_Ind`. Precondition: server.
- **Outputs:** Writes `A3E_MilitaryTrafficGroups`. Side effects: deletes far/empty groups + vehicles; spawns a military vehicle group; starts `A3E_fnc_MilitaryTrafficPatrol` and `A3E_fnc_TrackGroup_Add`; logs.
- **Calls:** `A3E_fnc_GetPlayers`, `A3E_fnc_Log`, `A3E_fnc_NearestObjectDis`, `A3E_fnc_GetCircularSpawnPos` ("ROAD"), `A3E_fnc_SpawnMilitaryVehicle`; spawns `A3E_fnc_MilitaryTrafficPatrol`, `A3E_fnc_TrackGroup_Add`.
- **Called by:** Chronos-registered — `Code/functions/Server/fn_initServer.sqf:681` `["A3E_FNC_MilitaryTraffic"] call A3E_FNC_Chronos_Register;`. Note: initServer.sqf:399-400 also `spawn drn_fnc_...` a *different* MilitaryTraffic (DRN legacy), not this A3E function.
- **Processing:** Identical cleanup loop; then road spawn pos → spawns an enemy vehicle group (random Opfor/Ind, 3:1 toward Ind).
- **Theory of operation:** Keeps a bounded set of enemy vehicle patrols roaming roads near players, providing motorized threat that persists as players move.
- **Whys & questions:** Squad size is fixed by the vehicle crew (no dynamic size here, unlike foot patrols). Empty-group log tag "AmbientAI" reused (:20).
- **Unresolved issues:** Duplicated cleanup/spawn boilerplate (see AmbientPatrols/CivilianCommuters). Overlaps conceptually with the DRN `drn_fnc_...MilitaryTraffic` still spawned in initServer — potential duplicate systems. `_leader` not `private`.
- **Reforger port notes:** TBD — maps to a road-based motorized spawn manager; reconcile with the DRN traffic system before porting.

### a3e_fnc_SpawnCivilianVehicle  —  `Code/functions/Spawning/fn_SpawnCivilianVehicle.sqf`  ·  _status: documented_
- **Purpose:** Spawns a single random civilian vehicle (with crew group) at a position, aligned to the road direction, runs the standard spawn callbacks, and randomly stocks its cargo (weapon/FAK/smoke/chemlight).
- **Inputs:** `params["_pos"]`. Reads `a3e_arr_Escape_MilitaryTraffic_CivilianVehicleClasses`, `a3e_arr_CivilianCarWeapons`. Precondition: at least one civilian vehicle class defined (exits with log otherwise).
- **Outputs:** Returns the crew `_group`. Side effects: creates a vehicle + crew via `BIS_fnc_spawnVehicle`; clears then randomly re-stocks cargo; runs vehicle/civilian spawn callbacks; logs.
- **Calls:** `BIS_fnc_spawnVehicle`; `a3e_fnc_onVehicleSpawn`, `A3E_fnc_onCivilianGroupSpawn`, `A3E_fnc_onCivilianSpawn` (per unit), `a3e_fnc_log`.
- **Called by:** `Code/functions/Spawning/fn_CivilianCommuters.sqf:59` `[_spawnpos] call A3E_fnc_SpawnCivilianVehicle;`.
- **Processing:** Picks random class; gets direction from `roadAt _pos`; spawns vehicle; wires callbacks; clears all cargo; 20% chance to add a random civilian car weapon+mag, 80% each for 3 FAKs / 2 red smokes / 5 green chemlights.
- **Theory of operation:** Central factory for civilian traffic vehicles so commuters carry the loot/FAK the escape mechanic relies on (players can scavenge civilian cars).
- **Whys & questions:** Loot chances are hard-coded (20/80/80/80). Why FAKs in civilian cars? Supports the mission's survival loop (players start with nothing).
- **Unresolved issues:** `clearitemcargoglobal`/`clearWeaponCargoGlobal`/`clearMagazineCargoGlobal` casing inconsistent but valid. No handling if `BIS_fnc_spawnVehicle` fails (assumes `_result` populated).
- **Reforger port notes:** TBD — Reforger uses prefab-based vehicle spawning and inventory; cargo stocking would be reimplemented via storage components.

### a3e_fnc_SpawnMilitaryVehicle  —  `Code/functions/Spawning/fn_SpawnMilitaryVehicle.sqf`  ·  _status: documented_
- **Purpose:** Spawns a single random enemy military vehicle (with crew group) for the given side at a position, road-aligned, and runs the enemy spawn callbacks.
- **Inputs:** `params["_pos","_side"]`. Reads `a3e_arr_Escape_MilitaryTraffic_EnemyVehicleClasses` (Opfor) / `..._Ind` (Ind), sides `A3E_VAR_Side_Opfor`/`A3E_VAR_Side_Ind`.
- **Outputs:** Returns crew `_group`. Side effects: creates vehicle+crew via `BIS_fnc_spawnVehicle`; runs vehicle + enemy-group + per-soldier spawn callbacks; logs.
- **Calls:** `BIS_fnc_spawnVehicle`; `a3e_fnc_onVehicleSpawn`, `A3E_fnc_onEnemyGroupSpawn`, `A3E_fnc_onEnemySoldierSpawn` (per unit), `a3e_fnc_log`.
- **Called by:** `Code/functions/Spawning/fn_MilitaryTraffic.sqf:56` `[_spawnpos,selectRandom [...]] call A3E_fnc_SpawnMilitaryVehicle;`.
- **Processing:** Selects vehicle class list by side; gets road direction; spawns vehicle; wires callbacks (vehicle lock, enemy group tracking, per-soldier loadout scrubbing).
- **Theory of operation:** Factory for the enemy motorized traffic pool so crews get the standard AI-skill/loadout treatment and tracking.
- **Whys & questions:** No civilian-side branch (mirror of SpawnCivilianVehicle for enemies). If `_side` is neither Opfor nor Ind, `_possibleVehicles` stays empty → `selectRandom []` returns nil → likely spawn failure.
- **Unresolved issues:** Empty-list guard missing (unlike SpawnCivilianVehicle which checks). No failure handling for `BIS_fnc_spawnVehicle`.
- **Reforger port notes:** TBD — prefab-based vehicle + crew spawn; side/class selection maps to faction catalogs.

### a3e_fnc_activatePatrolZone  —  `Code/functions/Spawning/fn_activatePatrolZone.sqf`  ·  _status: documented_
- **Purpose:** Trigger activation handler for a patrol zone: when players enter, spawn (first time) or respawn (subsequent) that zone's foot patrols, set marker to yellow.
- **Inputs:** `_this select 0` = zone index. Reads `a3e_patrolZones` (array of hashmaps with active/initialized/marker/side/patrols/zoneArea), `A3E_Param_VillageSpawnCount`, `A3E_Debug`.
- **Outputs:** Mutates the zone hashmap (active/initialized/patrols). Side effects: spawns patrol groups + units; assigns `A3E_PatrolZone_Index` per group; starts `A3E_fnc_Patrol` and `A3E_fnc_TrackGroup`; recolors marker; in debug adds a text marker.
- **Calls:** `a3e_fnc_debugmsg`, `BIS_fnc_getFromPairs`/`setToPairs`, `BIS_fnc_randomPosTrigger`, `a3e_fnc_getDynamicSquadSize`, `A3E_FNC_spawnPatrol`, `A3E_fnc_Patrol`; spawns `A3E_fnc_TrackGroup`.
- **Called by:** Wired as trigger activation statement in `Code/functions/Spawning/fn_initPatrolZone.sqf:56`.
- **Processing:** If not active: if never initialized, compute `_patrolCount` from area × player-scaled density + edge factor, spawn that many patrols at random trigger positions, store them and mark initialized; else re-spawn from saved `[pos,count]` pairs. Set active true.
- **Theory of operation:** Lazy, on-demand population — patrols only exist while players are near, saving performance across 70+ maps. State is persisted in the hashmap so despawn/respawn preserves counts and positions.
- **Whys & questions:** `default` case in the density switch is commented "6-8 players" but falls back to 0.01 (same as case 1) — likely copy-paste. Uses `BIS_fnc_getFromPairs` on what initPatrolZone builds as a hashmap (`createHashMapFromArray`) — pairs helpers still work on hashmaps here.
- **Unresolved issues:** Density `default` comment wrong (BUG-ish/cosmetic). This zone system (`a3e_patrolZones`, pairs API) is distinct from the `A3E_Zones` hashmap system used by populateLocationZone/populateVillageZone — two parallel zone frameworks.
- **Reforger port notes:** TBD — maps to trigger/area-based spawn activation; Reforger streaming may already gate spawns by player proximity.

### a3e_fnc_deactivatePatrolZone  —  `Code/functions/Spawning/fn_deactivatePatrolZone.sqf`  ·  _status: documented_
- **Purpose:** Trigger deactivation handler: when players leave a patrol zone, despawn its living patrols (saving their position+count for later respawn), recolor marker red, and delete the zone entirely if fully cleared.
- **Inputs:** `params["_zoneIndex"]`. Reads `a3e_patrolZones`, `A3E_Debug`, `A3E_StatusOfPatrols` (SearchLeader tracking list).
- **Outputs:** Mutates zone hashmap (active=false, patrols=saved pairs). Side effects: deletes units and groups; sets a despawn flag on matching SearchLeader entries; recolors marker; if zone empty, deletes the trigger and whitens marker.
- **Calls:** `BIS_fnc_getFromPairs`/`setToPairs`, `a3e_fnc_debugmsg`.
- **Called by:** Wired as trigger deactivation statement in `Code/functions/Spawning/fn_initPatrolZone.sqf:57`.
- **Processing:** Only if active&initialized. For each patrol group, count living units; if >0, record `[leaderPos,count]`, delete its units, set the SearchLeader despawn flag (`_x set [3,true]`) so search logic doesn't treat the group as "lost", delete the group. Save the pair list back; if none survived, delete trigger + mark cleared.
- **Theory of operation:** Complements activatePatrolZone: preserves the zone's patrol footprint (positions+sizes) when unloaded, and permanently retires zones the players have cleared.
- **Whys & questions:** The `set [3,true]` despawn flag couples this to SearchLeader's `A3E_StatusOfPatrols` layout (index 3 = despawn). Groups with 0 living units are silently dropped (not re-saved) — correct, they're dead.
- **Unresolved issues:** Reads `_trigger` from the hashmap but the "deactivationtrigger" (initPatrolZone:77) is never deleted here — only the activation "trigger" is deleted on clear, leaving the larger deactivation trigger orphaned (possible leak). Verify.
- **Reforger port notes:** TBD — despawn-on-leave + state persistence maps to a streaming/save pattern.

### a3e_fnc_findSpawnPosBuilding  —  `Code/functions/Spawning/fn_findSpawnPosBuilding.sqf`  ·  _status: documented_
- **Purpose:** Returns a list of hand-authored garrison positions (relative-to-building world positions + facing) for a set of supported Arma vanilla military buildings (cargo HQ/tower/patrol, barracks), so a building can be manned with sentries.
- **Inputs:** `_this select 0` = building object. Uses a large hard-coded lookup keyed by `typeOf _building` with `[relDir,dist,elev,dir]` tuples per position.
- **Outputs:** Returns `_return` = array of `[x,y,z,dir]` world positions. Side effects: sets `_building setVariable ["occupied", TRUE]` so it isn't garrisoned twice; returns empty `[]` if already occupied or building type unsupported.
- **Calls:** `BIS_fnc_relPos`, `BIS_fnc_removeIndex` (thinning), `BIS_fnc_relativeDirTo`/`BIS_fnc_distance2D` (only inside the unused `BIS_getRelPos` helper it defines).
- **Called by:** `Code/functions/AI/fn_spawnGarisson.sqf:7` `_positions = [_building] call a3e_fnc_findSpawnPosBuilding;`.
- **Processing:** Guard on `occupied`; look up param array by building type; thin to `_finalCnt` (here `_coef=1` so no thinning); for each entry compute a world position via `BIS_fnc_relPos` and adjusted Z, push `[x,y,z,dir]` into `_return`.
- **Theory of operation:** Precomputed firing/observation posts per building model let garrison AI stand at windows/balconies rather than random `buildingPos`, giving deliberate defensive placement.
- **Whys & questions:** Why hard-coded per model? `buildingPos` positions are generic; these are curated for good sightlines. `_coef=1` makes the thinning loop and `_finalCnt` machinery effectively dead.
- **Unresolved issues:** Large blocks of dead/commented code (the original unit-creation path). Lines 156/141 reference `_site` and `_newGrp` which are never defined in this scope — if `_finalCnt>0` and that `_site setVariable` line ran it would error; it currently sits after the `forEach` that only builds `_return`, so it executes and likely throws (BUG — verify whether `_site` errors are swallowed). `BIS_getRelPos` defined but unused. Some tower tuples have 5 elements (extra comma-number, e.g. `-271,3285`) breaking the `[dir,dist,elev,dir]` shape.
- **Reforger port notes:** TBD — per-prefab garrison waypoints would be re-authored against Reforger building prefabs (different models/coordinates).

### a3e_fnc_getDynamicSquadsize  —  `Code/functions/Spawning/fn_getDynamicSquadsize.sqf`  ·  _status: documented_
- **Purpose:** Computes a randomized enemy group size, optionally scaled by live player count, clamped to a min/max — the standard "how many soldiers in this patrol" helper.
- **Inputs:** `params[["_overWriteBase",-1],["_overWriteMod",-1],["_min",2],["_max",12]]`. Reads `A3E_Param_EnemyGroupSize` (default 5) and `A3E_Param_DynamicGroupSizeMultiplier` (default 1).
- **Outputs:** Returns an integer unit count. No side effects.
- **Calls:** `A3E_fnc_GetPlayers` (leaf otherwise).
- **Called by:** `Code/functions/DRN/fn_AmbientInfantry.sqf:124`, `Code/functions/DRN/fn_InitGuardedLocations.sqf:78`, `Code/functions/Server/fn_initServer.sqf:466` (`[-1,-1,3,8]`), and Spawning callers `fn_activatePatrolZone.sqf:53`, `fn_AmbientPatrols.sqf:55`, `fn_populateLocationZone.sqf:51`, `fn_populateVillageZone.sqf:44`.
- **Processing:** Base = param override or `A3E_Param_EnemyGroupSize`. If base < 0, treat as player-scaling code: -1 → round(players×0.5), -2 → ×1, -3 → ×1.5. Add a weighted random jitter `selectRandom [-1..3]`, then clamp to `[_min,_max]`.
- **Theory of operation:** Central knob so group sizes scale with player count and difficulty, with jitter so patrols aren't uniform. Negative base codes are a compact way to request player-relative sizing.
- **Whys & questions:** The `_mod`/`A3E_Param_DynamicGroupSizeMultiplier` is read but never actually applied to `_unitsPerGroup` — multiplier appears to be dead. Jitter table is biased toward +1.
- **Unresolved issues:** CASING: file is `fn_getDynamicSquadsize.sqf` (lowercase s) but every call site uses `a3e_fnc_getDynamicSquadSize` (uppercase S) — works because SQF is case-insensitive, but inconsistent. `_mod` multiplier unused (BUG/dead). May overlap Common `GetEnemyCount` — confirm which is authoritative.
- **Reforger port notes:** TBD — straightforward numeric helper; port as a group-size utility using Reforger's player count API.

### a3e_fnc_initPatrolZone  —  `Code/functions/Spawning/fn_initPatrolZone.sqf`  ·  _status: documented_
- **Purpose:** Registers one patrol zone: allocates a zone index, creates its map marker plus activation and (larger) deactivation triggers wired to activate/deactivatePatrolZone, and stores the zone as a hashmap in `a3e_patrolZones`.
- **Inputs:** `params["_shape","_onInit",["_type","Default"]]` where `_shape = [pos,dir,shape,[sizeX,sizeY]]`. Reads/initializes globals `a3e_patrolZoneIndex`, `a3e_patrolZones`, `A3E_Param_EnemySpawnDistance` (800), `A3E_Debug`, `A3E_VAR_Side_Ind`/`_Opfor`. Uses player group (`a3e_fnc_getPlayerGroup`) for trigger attachment.
- **Outputs:** Writes/extends `a3e_patrolZones` (and increments `a3e_patrolZoneIndex`). Side effects: creates a marker and two triggers (activation + deactivation).
- **Calls:** `a3e_fnc_getPlayerGroup`; engine `createMarker`/`createTrigger`; `createHashMapFromArray`. Note `_onInit` param is captured but never used here (the triggers hard-call activate/deactivatePatrolZone by name).
- **Called by:** _No `fnc_` references found in xref (initPatrolZone:1231-1232 — "entry point or dead code; verify")._ Likely invoked from island/prison setup code by name or is legacy.
- **Processing:** Bootstrap index/array; derive side from area (>5000 m² → Opfor, else Ind); create blue marker (alpha 0, or 0.2 in debug); create activation trigger sized `sizeXY+spawnDistance` attached to a player vehicle with MEMBER/PRESENT; create a second trigger 50 m larger for deactivation; assemble zone hashmap with trigger/marker/area/flags/patrols and store at index.
- **Theory of operation:** Sets up the proximity machinery so patrols spawn/despawn as players approach/leave; the 50 m hysteresis between the two triggers prevents spawn/despawn oscillation at the boundary.
- **Whys & questions:** `_side` computed here (line 25-28) but activate/deactivate read side from the hashmap — consistent. `_type` and `_onInit` params seem unused; suggests a generalized signature that this specialization doesn't fully use. Uses `_x` at lines 31-34 (marker setup from `_x`) though loop variable `_x` isn't defined in scope — reads the last-iterated `_x` or errors (see issues).
- **Unresolved issues:** Lines 31-34 reference `_x select 0/1/2/3` but `_x` is undefined in this scope (should be `_shape`) — BUG, marker dir/shape/size likely fail unless `_x` leaks from a caller. `_onInit`/`_type` unused. No `fnc_` callers found — verify it's still wired in.
- **Reforger port notes:** TBD — trigger+hysteresis proximity model maps to Reforger trigger entities or a proximity manager.

### a3e_fnc_initVillages  —  `Code/functions/Spawning/fn_initVillages.sqf`  ·  _status: documented_
- **Purpose:** Registers every village marker as a proximity zone of type "Village" whose population callback is `A3E_FNC_PopulateVillageZone`.
- **Inputs:** No params. Reads global `a3e_villageMarkers` (array of village marker names/positions).
- **Outputs:** None returned. Side effects: one `A3E_fnc_initZone` call per village (which creates markers/triggers/zone state).
- **Calls:** `A3E_fnc_initZone` (per village) — leaf otherwise.
- **Called by:** `Code/functions/Server/fn_initServer.sqf:248` `[] spawn A3E_fnc_initVillages;`.
- **Processing:** `forEach a3e_villageMarkers`, call `[_zone,"A3E_FNC_PopulateVillageZone","Village"] call A3E_fnc_initZone`.
- **Theory of operation:** Bulk-arms the village zone system so each village lazily populates with patrols + civilian strollers when players approach (via the Zones/initZone framework, distinct from `a3e_patrolZones`).
- **Whys & questions:** Uses the `A3E_fnc_initZone` framework (Zones category) rather than the initPatrolZone framework — confirms two zone systems coexist; villages use the newer `A3E_Zones`/hashmap one.
- **Unresolved issues:** Depends on `a3e_villageMarkers` being populated beforehand (by island config) — no guard if empty (harmless, loop just no-ops).
- **Reforger port notes:** TBD — village population maps to per-location spawn triggers seeded from world config.

### a3e_fnc_onCivilianGroupSpawn  —  `Code/functions/Spawning/fn_onCivilianGroupSpawn.sqf`  ·  _status: documented_
- **Purpose:** Group-level callback for a newly spawned civilian group: registers it for tracking and installs event handlers so scared civilians can radio-report players to HQ (the "civilian fear / snitch" mechanic).
- **Inputs:** `params["_grp"]`. Reads `A3E_Warcrime_Score`, `A3E_Warcrime_Score_CivilianFear` (1000), `A3E_Radio_Reporting` sound list, `A3E_var_ReportTime` (10), per-group `A3E_LastReportedPlayer`.
- **Outputs:** No return. Side effects: `A3E_fnc_TrackGroup_Add`; adds `EnemyDetected` and `KnowsAboutChanged` event handlers to the group; on report, plays radio audio/lip/anim via remoteExec and calls `A3E_fnc_recordSighting`; sets `A3E_LastReportedPlayer`.
- **Calls:** `A3E_fnc_TrackGroup_Add`, `A3E_fnc_onEnemyDetected`, `A3E_fnc_recordSighting`; remoteExec `say3D`/`setRandomLip`/`playmovenow`.
- **Called by:** `Code/functions/Spawning/fn_spawnCivilianStroller.sqf:22`, `Code/functions/Spawning/fn_SpawnCivilianVehicle.sqf:28`.
- **Processing:** On `KnowsAboutChanged`: bail unless knowsAbout rose past ~2.5, warcrime score ≥ fear threshold, target is a player, and ≥300 s since last report. Pick a hidden/standing/distant unit as reporter; play radio audio + listening anim; after `_reportTime` s, if reporter still alive, record the sighting and stamp the group; otherwise reset lip.
- **Theory of operation:** Civilians only start snitching once the players have committed enough warcrimes (fear threshold), creating an escalating consequence system where atrocities make the population hostile-by-information.
- **Whys & questions:** 300 s cooldown per group prevents spam. The knowsAbout gate (>2.5) means only reasonably-confident sightings trigger. Radio anim only if unit on foot.
- **Unresolved issues:** BUG: lines 6 & 8 reference `_group` but the param is `_grp` — `_group` is undefined here, so both `addEventHandler` calls likely attach to a nil/leaked variable (verify whether handlers actually register). Sound list default duplicated inline.
- **Reforger port notes:** TBD — event-handler + remoteExec audio/anim model is Arma-specific; Reforger would use its RPC/replication and audio components.

### a3e_fnc_onCivilianSpawn  —  `Code/functions/Spawning/fn_onCivilianSpawn.sqf`  ·  _status: documented_
- **Purpose:** Per-civilian-unit callback: strips navigation/aid items (so players can't loot maps/GPS off civilians) and installs Killed (warcrime penalty) and FiredNear (flee/hide) behaviors.
- **Inputs:** `params["_unit"]`. Reads `A3E_MapItemsUsedInMission`, `A3E_ItemsToBeRemoved`, `A3E_Warcrime_Score`.
- **Outputs:** No return. Side effects: removes FirstAidKit/map/compass/GPS/binocular and configured items; adds `Killed` EH (+500 warcrime score globally, systemchat, negative score/positive rating to killer) and `FiredNear` EH (run to a building position or flee 500 m, then recover after ~60 s).
- **Calls:** `A3E_fnc_getRndBuildingWithPositions`; engine `BIS_fnc_arrayShuffle`; remoteExec `systemchat`; spawns anonymous flee-recovery threads.
- **Called by:** `Code/functions/Spawning/fn_spawnCivilianStroller.sqf:19`, `Code/functions/Spawning/fn_SpawnCivilianVehicle.sqf:30` (per unit).
- **Processing:** Unlink items. Killed EH: attribute kill to instigator if player, bump warcrime score +500 (global), broadcast chat, penalize killer score / raise rating. FiredNear EH: if not already scared, mark scared; if a nearby building found, doStop and move to a random building position, crouch/prone, recover after a delay; else flee 500 m away from firer, then recover and refollow leader.
- **Theory of operation:** Makes civilians behave realistically under fire (hide or run) and enforces the mission's warcrime economy — shooting civilians is costly, driving the civilian-fear/snitch escalation in onCivilianGroupSpawn.
- **Whys & questions:** Killed EH adds +1000 rating and -5 score to killer — rating up but score down is deliberate (rating avoids team-kill auto-punish while score reflects penalty). The commented switch/playMove block (lines 52-57) is disabled animation experimentation.
- **Unresolved issues:** `params["_group","_building"]` at line 63 re-declares inside the FiredNear EH but `_building` was already computed at 59 and `_group` at 47 — the inner `params` reads from `_this` (the EH args), overwriting `_building` with an EH arg (likely BUG/leftover — verify it doesn't clobber the building ref). `_nighttime` declared, never used.
- **Reforger port notes:** TBD — flee/hide AI and warcrime scoring reimplement as Reforger behaviors + a scoring system; item stripping maps to loadout config.

### a3e_fnc_onEnemyGroupSpawn  —  `Code/functions/Spawning/fn_onEnemyGroupSpawn.sqf`  ·  _status: documented_
- **Purpose:** Group-level callback for a newly spawned enemy group: register it for tracking and wire its EnemyDetected event to the search/HQ reporting system.
- **Inputs:** `params["_grp"]`. No globals read.
- **Outputs:** No return. Side effects: `A3E_fnc_TrackGroup_Add`; adds `EnemyDetected` EH calling `A3E_fnc_onEnemyDetected`.
- **Calls:** `A3E_fnc_TrackGroup_Add`, `A3E_fnc_onEnemyDetected` (leaf otherwise).
- **Called by:** `Code/functions/Server/fn_RoadBlocks.sqf:78` & `:97`, `Code/functions/Spawning/fn_SpawnMilitaryVehicle.sqf:31`, `Code/functions/Spawning/fn_spawnPatrol.sqf:21`.
- **Processing:** Add group to tracker; attach `EnemyDetected` handler forwarding to `A3E_fnc_onEnemyDetected`.
- **Theory of operation:** Single choke point so every enemy group participates in the SearchLeader detection/escalation loop and group tracking, regardless of how it was spawned.
- **Whys & questions:** Minimal by design — the heavy lifting is in TrackGroup and onEnemyDetected. Civilian analog (onCivilianGroupSpawn) adds the fear/report handlers instead.
- **Unresolved issues:** None obvious. (Contrast with onCivilianGroupSpawn which has the `_grp`/`_group` bug — this one correctly uses `_grp`.)
- **Reforger port notes:** TBD — detection wiring maps to Reforger perception/faction awareness events.

### a3e_fnc_onEnemySoldierSpawn  —  `Code/functions/Spawning/fn_onEnemySoldierSpawn.sqf`  ·  _status: documented_
- **Purpose:** Per-enemy-soldier callback: sets AI skill from difficulty, randomizes loadout (scopes/NVG/attachments/bipod), strips navigation gear, optionally adds intel, and tracks kills-by-player.
- **Inputs:** `params["_unit"]`. Reads `A3E_Param_EnemySkill`, `A3E_Param_NoNightvision`, `A3E_Var_AllowVanillaNightVision`, `A3E_arr_Scopes`/`_TWSScopes`/`_NightScopes`, `a3e_arr_Bipods`, `A3E_MapItemsUsedInMission`, `A3E_ItemsToBeRemoved`, `A3E_Param_UseIntel`, `A3E_Kill_Count`; uses `daytime`.
- **Outputs:** No return. Side effects: `setVehicleAmmo`, multiple `setSkill`, weapon-item add/remove, NVG link/unlink, item unlinks; adds `Killed` EH that increments `A3E_Kill_Count` when killer is a player; may call `A3E_fnc_AddIntel`.
- **Calls:** `A3E_fnc_AddIntel` (if intel enabled); engine loadout/config commands (leaf otherwise).
- **Called by:** `Code/functions/Server/fn_RoadBlocks.sqf:80` & `:98`, `Code/functions/Spawning/fn_SpawnMilitaryVehicle.sqf:33`, `Code/functions/Spawning/fn_spawnPatrol.sqf:26`/`:29`, `Code/Scripts/Escape/Functions.sqf:2`.
- **Processing:** Reduce ammo to 0.2-0.6; map difficulty (0-4) to skill 0.1-0.5 and set all skill subvalues; 70% chance to clear+maybe re-add a scope (day/night/TWS pools); night/day-weighted NVG add or removal; 15%/night attachment (flashlight or IR+NVG); 20% bipod; strip map/compass/GPS/binocular/rangefinder probabilistically; add intel if enabled; Killed EH bumps kill count.
- **Theory of operation:** Central enemy "dress + calibrate" pass so every spawned OPFOR/IND soldier gets consistent, difficulty-scaled skill and varied but night-appropriate gear, and contributes to statistics.
- **Whys & questions:** NVG logic is probability-heavy (day: mostly remove; night: mostly keep) to make night fights harder but not universally NV-equipped. Silencer block (85) is a no-op ("//Not yet").
- **Unresolved issues:** `_nighttime` re-derived here (also derived in onCivilianSpawn but unused there). Loop at 100-106 declares `_items` and never uses it, and unlinks `_x` (the item) — works but `_items` is dead. Silencer branch is empty dead code. `setVehicleAmmo` on a soldier affects magazines — intentional?
- **Reforger port notes:** TBD — loadout randomization and skill scaling map to Reforger loadout/AI difficulty configs; NVG/attachment pools re-derive per faction catalog.

### a3e_fnc_onVehicleSpawn  —  `Code/functions/Spawning/fn_onVehicleSpawn.sqf`  ·  _status: documented_
- **Purpose:** Per-vehicle spawn callback applying the vehicle-lock policy from the mission parameter (so players can't just steal every enemy vehicle).
- **Inputs:** `params["_vehicle"]`. Reads `A3E_Param_VehicleLock` (default 0).
- **Outputs:** No return. Side effects: locks vehicle (`lock 3`) depending on policy.
- **Calls:** none (leaf function).
- **Called by:** Many spawn sites — DRN `fn_MilitaryTraffic.sqf:327`, `fn_PopulateAquaticPatrol.sqf:30`; `fn_RoadBlocks.sqf:77`/`:96`; Spawning `fn_SpawnCivilianVehicle.sqf:23`, `fn_SpawnMilitaryVehicle.sqf:26`; and several `Code/Scripts/Escape/*` chopper/search/reinforcement scripts (see xref :1264-1276).
- **Processing:** Switch on lock param: case 1 → lock only if the vehicle has turrets (armed vehicles); case 2 → always lock; default → no lock.
- **Theory of operation:** Single hook every spawned vehicle passes through so lock behavior is configurable mission-wide (e.g. lock armed vehicles only, to preserve balance while allowing transport theft).
- **Whys & questions:** `lock 3` = fully locked. Case 1 (turrets only) keeps armed vehicles out of player hands while leaving trucks/cars stealable.
- **Unresolved issues:** None obvious. Extension point — no callback for e.g. fuel/damage randomization.
- **Reforger port notes:** TBD — maps to setting a lock/access component on the spawned vehicle prefab.

### a3e_fnc_populateLocationZone  —  `Code/functions/Spawning/fn_populateLocationZone.sqf`  ·  _status: documented_
- **Purpose:** Population callback for a "location" objective zone (COM center, mortar, ammo depot, motor pool, roadblock): spawns a type-appropriate number of guard patrols, split between roaming Guard and building-garrison behaviors.
- **Inputs:** `params["_zoneIndex"]`. Reads `A3E_Zones` hashmap (marker/zonearea/side/type), infantry class arrays `a3e_arr_Escape_InfantryTypes[_Ind]`, sides.
- **Outputs:** No return. Side effects: spawns patrol groups, stores them in the zone hashmap `groups`; assigns Guard/GuardBuilding behavior; logs building counts.
- **Calls:** `a3e_fnc_getBuildingsInMarker`, `a3e_fnc_getDynamicSquadSize`, `A3E_FNC_spawnPatrol`, `A3E_fnc_Guard`, `A3E_fnc_GuardBuilding`, `a3e_fnc_log`.
- **Called by:** `Code/functions/Zones/fn_initLocationZone.sqf:4` — registered as the zone's populate callback via `A3E_fnc_initZone`.
- **Processing:** Pick `_patrolCount` by zone type (COMCENTER 6, MOTORPOOL 5, AMMODEPOT 4, MORTAR/ROADBLOCK 2, default 4); pick infantry list by side; spawn that many dynamic-size patrols at random trigger positions; 70% get `A3E_fnc_Guard`, 30% `A3E_fnc_GuardBuilding`; store in `groups`.
- **Theory of operation:** Gives each objective a defensive garrison scaled to its importance, mixing perimeter guards and building defenders, populated lazily via the Zones framework.
- **Whys & questions:** Uses the `A3E_Zones` hashmap system (not `a3e_patrolZones`) — the newer zone framework. `_guardCount`/`_possibleInfantryTypes` computed but the building-garrison count path (`_guardCount`) isn't actually used to spawn separate garrison units — only the `_patrolCount` loop runs.
- **Unresolved issues:** BUG line 32: `[_x] call a3e_fnc_getBuildingsInMarker` — `_x` is undefined in this scope (should be `_marker`), so building lookup likely fails/returns wrong data (and `_buildingsPositions`/`_guardCount` are then unreliable). `_guardCount` computed (36) but never used to spawn. Dead commented lines throughout.
- **Reforger port notes:** TBD — objective garrison scaling maps to per-location spawn tables in world config.

### a3e_fnc_populateVillageZone  —  `Code/functions/Spawning/fn_populateVillageZone.sqf`  ·  _status: documented_
- **Purpose:** Population callback for a village zone: spawns a player-count-scaled number of patrols plus a handful of ambient civilian strollers, all wandering the village marker area.
- **Inputs:** `params["_zoneIndex"]`. Reads `A3E_Zones` hashmap (marker/zonearea), `A3E_Param_VillageSpawnCount`, sides.
- **Outputs:** No return. Side effects: spawns patrol groups and civilian stroller groups; stores all in the zone `groups`; assigns Patrol/Stroll behavior and tracking; `systemchat` debug of patrol count.
- **Calls:** `getMarkerSize`, `BIS_fnc_randomPosTrigger`, `a3e_fnc_getDynamicSquadSize`, `A3E_FNC_spawnPatrol`, `A3E_fnc_Patrol`, `A3E_fnc_TrackGroup_Add`, `A3E_FNC_spawnCivilianStroller`, `A3E_fnc_Stroll`.
- **Called by:** `Code/functions/Spawning/fn_initVillages.sqf:3` — registered as the village zone populate callback via `A3E_fnc_initZone`.
- **Processing:** Density `_patrolsPerSqmSqrt` from `A3E_Param_VillageSpawnCount` (0.01/0.018/0.029); `_patrolCount = ceil(density*sqrt(area)) + round(edgeAvg/100)`; spawn that many patrols (side selectRandom from an Ind-weighted list, +Opfor if large); if `_patrolCount>2`, spawn a jittered count of civilian strollers.
- **Theory of operation:** Fills villages with a mix of light military presence and civilians, scaled to size and player count, so towns feel inhabited and dangerous to move through.
- **Whys & questions:** Civilian count uses a heavily-negative-weighted jitter (often fewer than patrols). Sides list favors Ind 3:1, matching the "locals hold villages" theme.
- **Unresolved issues:** BUG line 8: `if(_zoneArea > 5000)` references `_zoneArea`, but the variable read from the hashmap is `_area` (line 5) — `_zoneArea` is undefined here, so the Opfor-in-large-village branch likely never fires (or errors). Leftover debug `systemchat str _patrolCount;` (line 37) spams all clients. `default` density comment says "6-8 players" but is 0.01.
- **Reforger port notes:** TBD — village patrol + civilian mix maps to a per-location spawn table; density-by-player-count is reusable.

### a3e_fnc_spawnCivilianStroller  —  `Code/functions/Spawning/fn_spawnCivilianStroller.sqf`  ·  _status: documented_
- **Purpose:** Spawns a small on-foot civilian group ("strollers") at a position, running the per-unit and per-group civilian spawn callbacks.
- **Inputs:** `params["_pos","_count"]`. Reads `A3E_UNITS_civilian_InfantryTypes` (default beggar/casual civ classes).
- **Outputs:** Returns the created `_group`. Side effects: creates a civilian group + `_count` units; runs `A3E_fnc_onCivilianSpawn` per unit and `A3E_fnc_onCivilianGroupSpawn`; logs (and logs an error if the civilian class array is empty).
- **Calls:** `A3E_fnc_onCivilianSpawn` (per unit), `A3E_fnc_onCivilianGroupSpawn`, `a3e_fnc_log`; engine `createGroup`/`createUnit`.
- **Called by:** `Code/functions/Spawning/fn_populateVillageZone.sqf:62` `[_pos,selectRandom[1,1,1,1,1,2]] call A3E_FNC_spawnCivilianStroller;`.
- **Processing:** Resolve civilian class list (warn if empty); create civilian group; loop `_count` times creating units with "FORM" placement and running per-unit callback; run group callback; return group.
- **Theory of operation:** The civilian counterpart to spawnPatrol — a factory that guarantees strollers get the item-stripping, fear/flee, and snitch handlers wired.
- **Whys & questions:** `selectRandom[1,1,1,1,1,2]` at call site biases groups to size 1. Default class list is hard-coded here as a fallback if the mod didn't set `A3E_UNITS_civilian_InfantryTypes`.
- **Unresolved issues:** Empty-array case only logs a warning but still proceeds to the (no-op) loop — group with 0 units may be created and returned. `_unitArray` is just an alias of `_possibleInfantryTypes` (redundant).
- **Reforger port notes:** TBD — civilian group spawn maps to prefab-based unit spawning with the civilian callback logic reimplemented.

### a3e_fnc_spawnPatrol  —  `Code/functions/Spawning/fn_spawnPatrol.sqf`  ·  _status: documented_
- **Purpose:** Core enemy infantry-group factory: creates a group of `_count` soldiers of the given side at a position, running the enemy group + per-soldier spawn callbacks.
- **Inputs:** `params["_pos","_side","_count"]`. Reads `a3e_arr_Escape_InfantryTypes` (Opfor) / `_Ind`, sides `A3E_VAR_Side_Opfor`/`_Ind`.
- **Outputs:** Returns the created `_group`. Side effects: creates group + `_count` units; runs `A3E_fnc_onEnemyGroupSpawn` (before units) and `A3E_fnc_onEnemySoldierSpawn` per unit; logs (error if infantry array empty).
- **Calls:** `A3E_fnc_onEnemyGroupSpawn`, `A3E_fnc_onEnemySoldierSpawn` (per unit), `a3e_fnc_log`; engine `createGroup`/`createUnit`.
- **Called by:** `Code/functions/Spawning/fn_activatePatrolZone.sqf:54`/`:76`, `fn_AmbientPatrols.sqf:55`, `fn_populateLocationZone.sqf:52`, `fn_populateVillageZone.sqf:45`.
- **Processing:** `_count = _count - 1` (leader counted separately); pick infantry list by side (warn if empty); create group; run group callback; create the leader unit + callback; loop remaining `_count` creating units + callback; return group.
- **Theory of operation:** The single entry point every foot patrol goes through, so all enemy soldiers get consistent skill/loadout treatment and every group is tracked and detection-wired.
- **Whys & questions:** Group callback runs on an empty group (line 21) before any units exist — fine since it only adds tracking/EHs. Leader and members draw from the same `_possibleInfantryTypes` (`_leaderArray`/`_unitArray` are identical aliases — no distinct leader class).
- **Unresolved issues:** If `_side` is neither Opfor nor Ind, `_possibleInfantryTypes` stays `[]`; it logs a warning but then `selectRandom []` returns nil → createUnit likely fails (no early exit). `_leaderArray`/`_unitArray` redundant aliases.
- **Reforger port notes:** TBD — group creation maps to Reforger's AI group prefab spawning; side→class selection uses faction catalogs.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-07-01 | Claude | Documented all entries |
