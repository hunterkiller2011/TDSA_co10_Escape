# Code Reference — AI
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Unit behaviors: patrol, search, guard, extraction, drones, combat reactions. One entry per source file in `Code/functions/AI/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_AddStaticGunner  —  `Code/functions/AI/fn_AddStaticGunner.sqf`  ·  _status: documented_
- **Purpose:** Spawns one infantry unit and moves him into the gunner seat of a supplied static weapon (HMG, GMG, AA emplacement, mortar). Used to man the static weapons placed by ammo depots, com centers, motor pools, mortar sites and roadblocks.
- **Inputs:** `_this` via `bis_fnc_param`: `[0]` `_static` (the static weapon object, default objNull), `[1]` `_side` (default `A3E_VAR_Side_Ind`). Globals read: `a3e_arr_Escape_InfantryTypes`, `a3e_arr_Escape_InfantryTypes_Ind`, `A3E_VAR_Side_Opfor`, `A3E_VAR_Side_Ind`. Precondition: unit class arrays and side vars initialized.
- **Outputs:** Returns the created gunner unit (`_unit`), or `objNull` if `_static` was null. Side effects: `createGroup`, `createUnit`, `assignAsGunner`/`moveInGunner`. Note: creates a brand-new group per gunner (no group reuse).
- **Calls:** none (leaf function) — only engine commands.
- **Called by:** Widely spawned (`spawn`, occasionally `call`) from Templates: AmmoDepot* (many), BuildComCenter* (many), BuildMotorPool*, MortarSite*; and `Server/fn_RoadBlocks.sqf:95` (as a `call`). See _xref.md AddStaticGunner (~60 call sites).
- **Processing:** Read params → pick infantry-type array by side (both Opfor and Ind cases actually assign the same base array except Ind) → if static not null, create a random unit at the static's position and seat him as gunner → return unit.
- **Theory of operation:** Static weapons are placed as empty objects by templates; this helper is the single choke-point that mans them, keeping unit-class selection consistent across all template variants.
- **Whys & questions:** Called both as `spawn` (return value discarded) and as `call` (RoadBlocks captures the unit). The default side is `A3E_VAR_Side_Ind` but essentially every caller passes `A3E_VAR_Side_Opfor` — why Ind default? The Opfor `switch` case selects `a3e_arr_Escape_InfantryTypes` (the same as the pre-switch default), so only the Ind case changes anything.
- **Unresolved issues:** Creating a new group per static gunner can bloat the 288-group engine limit when many statics exist. `switch` Opfor case is redundant. No cleanup/`deleteGroup` if the static dies later. Casing consistent here.
- **Reforger port notes:** Static-weapon crewing and `moveInGunner` map to Enfusion turret/compartment APIs; group-per-unit pattern should be reconsidered. TBD.

### a3e_fnc_AquaticPatrol  —  `Code/functions/AI/fn_AquaticPatrol.sqf`  ·  _status: documented_
- **Purpose:** Waterborne (boat) patrol loop: sends a group to a random water position inside its home marker, then re-invokes itself on waypoint completion for a perpetual sea patrol.
- **Inputs:** `_this select 0` `_group`, `_this select 1` `_markerName`. Reads nothing global beyond marker geometry. Precondition: runs server-side only (`if(!isserver) exitwith`).
- **Outputs:** No return. Sets group var `a3e_homeMarker` (the marker). Creates/updates waypoint 1 via `a3e_fnc_move`; sets waypoint timeout `[0,30,60]`. Sets task state `"PATROL"`.
- **Calls:** `a3e_fnc_SetTaskState`, `a3e_fnc_RandomMarkerPos`, `a3e_fnc_move`.
- **Called by:** `DRN/fn_PopulateAquaticPatrol.sqf:37` (`spawn`). Re-spawned by its own `_oncomplete` waypoint statement.
- **Processing:** Server guard → set state PATROL → pick random marker pos, loop up to 50 times until pos is *on water* (`surfaceIsWater`) → build self-respawning `_oncomplete` string → set home marker → create move waypoint (COLUMN/NORMAL/AWARE) with a 30–60s timeout.
- **Theory of operation:** Mirrors `fn_Patrol` but inverts the water test (wants water, not land) so boats keep patrolling water tiles; recursion via waypoint statement gives an endless cycle.
- **Whys & questions:** Task state is `"PATROL"` (same as land patrol) rather than a distinct "AQUATICPATROL" — is that intentional (so OrderSearch/SeekShelter treat boats like foot patrols)?
- **Unresolved issues:** Duplicates the Patrol/Guard/Stroll waypoint-loop structure with only the water predicate flipped — shared logic candidate. 50-iteration cap could yield a land pos on maps with little water. Shares `"PATROL"` state string with foot patrols (possible mis-classification).
- **Reforger port notes:** Water/`surfaceIsWater` sampling and boat waypoint behavior differ in Enfusion. TBD.

### a3e_fnc_CallCAS  —  `Code/functions/AI/fn_CallCAS.sqf`  ·  _status: documented_
- **Purpose:** Calls a scripted close-air-support strike (via BIS CAS module) on a position, and makes nearby Opfor/Ind groups flee the impact zone.
- **Inputs:** `params ["_position"]`. Globals read: `a3e_arr_CASplane`, `a3e_var_artillery_fleeingDistance`, `A3E_VAR_Side_Opfor`, `A3E_VAR_Side_Ind`.
- **Outputs:** Returns `_success` (always `true`). Side effects: creates a `Logic` unit as CAS caller, sets its `vehicle`/`type` vars, spawns a thread that flees nearby friendly AI then runs `BIS_fnc_moduleCAS` and deletes the logic.
- **Calls:** `a3e_fnc_Flee` (per nearby group), `bis_fnc_DirTo`, `BIS_fnc_moduleCAS`.
- **Called by:** `SearchLeader/fn_SearchLeader.sqf:87` and `Scripts/Escape/SearchLeader.sqf:288` (both `call`, capturing `_strikesuccess`).
- **Processing:** Create CAS logic at `_position`, random heading, random plane + random `type` (0/1/2/3 weighted toward 3) → spawn: for each group within `fleeingDistance` that is Opfor/Ind, compute a flee position radially away and `spawn a3e_fnc_Flee` → run `BIS_fnc_moduleCAS` → delete logic → return true.
- **Theory of operation:** Part of the SearchLeader escalation ladder — an air strike option against the players' last known position, with friendly-fire avoidance by scattering own AI first.
- **Whys & questions:** Return value is hard-coded `true` even though the strike may fail — callers can't detect failure. `type` weighting heavily favors value 3 (meaning?). Duplicated flee-loop is essentially identical to the one in `fn_FireArtillery`.
- **Unresolved issues:** Redundant `private["_group","_group",...]` (declared twice). Flee-scatter block is copy-pasted between CallCAS and FireArtillery — extraction candidate. `_success` never reflects real outcome (dead code / misleading contract).
- **Reforger port notes:** BIS_fnc_moduleCAS has no direct Enfusion equivalent; would need a custom CAS behavior. TBD.

### a3e_fnc_CivilianCommuter  —  `Code/functions/AI/fn_CivilianCommuter.sqf`  ·  _status: documented_
- **Purpose:** Drives a civilian vehicle group to a random road position within a spawn ring, re-invoking itself on arrival — creates ambient civilian road traffic.
- **Inputs:** `params [["_group",grpNull]]`. Globals read: `A3E_MaxSpawnCircleDistance` (default 1500). Precondition: `_group` not null (else exits).
- **Outputs:** No return. Sets task state `"COMMUTE"`. Creates move waypoint (COLUMN/NORMAL/AWARE) with timeout `[0,10,30]`; the waypoint statement re-spawns this function.
- **Calls:** `A3E_fnc_GetRandomCirclePosition`, `A3E_fnc_Move`, `a3e_fnc_SetTaskState`; self (`A3E_fnc_CivilianCommuter`).
- **Called by:** `Spawning/fn_CivilianCommuters.sqf:62` (`spawn`). Re-spawned by its own waypoint statement and its own retry block.
- **Processing:** Null-guard → compute a random road position 500–MaxSpawnCircleDistance from leader → if none found, sleep 10s and retry (self-spawn) → create move waypoint with self-respawn statement → set state COMMUTE.
- **Theory of operation:** Same self-recursion pattern as MilitaryTrafficPatrol (its near-twin) but for civilians and with AWARE/NORMAL settings; keeps a pool of civ vehicles perpetually driving between road nodes.
- **Whys & questions:** Sets state COMMUTE only *after* creating the waypoint (order differs from patrol fns). Near-identical to `fn_MilitaryTrafficPatrol` — why two files instead of one parameterized fn?
- **Unresolved issues:** Structural duplicate of MilitaryTrafficPatrol (differs mainly in state string and behaviour mode). No cap on retry recursion depth if roads never resolve.
- **Reforger port notes:** Road-position queries and vehicle waypoints differ in Enfusion; AI driving quality differs. TBD.

### a3e_fnc_EngageReportedGroup  —  `Code/functions/AI/fn_EngageReportedGroup.sqf`  ·  _status: documented_
- **Purpose:** Sends a patrol group to investigate a reported/known enemy position, refining its guess over time using how stale the sighting is, until the sighting ages out or combat starts.
- **Inputs:** `_this select 0` `_group`, `_this select 1` `_lastKnownPosition` (a known-position helper object). Reads object var `A3E_LastUpdated`; global `A3E_Debug`. (Third arg `A3E_Debug` passed by callers but read from global, not param.)
- **Outputs:** No return. Issues moves via `a3e_fnc_move`. In debug, creates/deletes an "Investigate" marker. Loops until stale.
- **Calls:** `a3e_fnc_move`, `A3E_fnc_InCombat`. Debug: marker engine commands.
- **Called by:** `AI/fn_RandomPatrolRoute.sqf:51` and `:66` (both `spawn`, handle awaited via `scriptDone`).
- **Processing:** Compute leader; compute `_lastSeen` age and accuracy (age×2); jitter a target position around the known pos → move there → loop: exit if age>300; if not in combat and age≤200, recompute jittered pos and move again; sleep random 60; delete debug marker on exit.
- **Theory of operation:** Models degrading intel — the longer since the last sighting, the wider the search scatter — so groups sweep an expanding area rather than beelining to a stale point. Feeds the RandomPatrolRoute investigation branch.
- **Whys & questions:** `_lastSeen>300` exit vs `>200` inner exit (two thresholds) — intentional hysteresis? `if(isNil("_group"))` inside the loop can never be true (`_group` was assigned). Debug flag is both a param and a global read.
- **Unresolved issues:** Dead `if(isNil("_group"))` check. Unused declared vars (`_leader` reassigned oddly, `_markername`/`_marker` only in debug). Accuracy grows unbounded with age until the 300s cutoff.
- **Reforger port notes:** Uses SQF known-position helper objects + per-object vars; Enfusion would model this via a perception/target-knowledge system. TBD.

### a3e_fnc_ExtractionBoat  —  `Code/functions/AI/fn_ExtractionBoat.sqf`  ·  _status: documented_
- **Purpose:** State-machine driver for an extraction boat: approach the extraction point, land/beach, wait for players, then evac out along a vector. One of three parallel extraction-vehicle variants.
- **Inputs:** `params ["_boat","_extractPos","_evacVec"]`. Reads vehicle var `State` (external code sets it to `"Init"`/`"Evac"`). Precondition: boat alive.
- **Outputs:** No return. Advances/reads vehicle var `State`; adds waypoints; sets speed modes; ends when `_extract` true or boat dead. Logs via `A3E_fnc_Log`.
- **Calls:** `A3E_fnc_Log`.
- **Called by:** _xref shows no `fnc_` references (entry point / possibly dead). NOTE the naming mismatch: `Server/fn_RunExtractionBoat.sqf:41-42` actually spawns `A3E_fnc_ExtractionCar` (not ExtractionBoat) for its boats. So this file may be effectively unused — verify against extraction runners.
- **Processing:** `while alive && !_extract`: switch on `State` — Init (log, →Approach, add FULL/CARELESS waypoint whose statement sets State=Land), Approach (slow at <100m/<40m), Land (`land "LAND"`, sleep, →WaitForPlayers unless Evac), WaitForPlayers (if airborne→Land), Evac (delay, `land "NONE"`, FULL, add exit waypoint, `_extract=true`); sleep 2 per tick.
- **Theory of operation:** Polling state machine keyed off a shared `State` vehicle var so external runner code (and waypoint statements) can drive transitions; identical skeleton to ExtractionCar/ExtractionChopper.
- **Whys & questions:** Because RunExtractionBoat spawns ExtractionCar instead, is ExtractionBoat orphaned? The three variants are near-identical — why not one parameterized fn?
- **Unresolved issues:** Likely dead code given the runner mismatch (BUG candidate). Heavy duplication with ExtractionCar (nearly line-for-line) and ExtractionChopper (adds fly-in-height). "WaitForPlayers" never sets Evac itself — relies on external code to flip State to "Evac".
- **Reforger port notes:** Boat beaching (`land "LAND"`) and waypoint state machine differ in Enfusion. TBD.

### a3e_fnc_ExtractionCar  —  `Code/functions/AI/fn_ExtractionCar.sqf`  ·  _status: documented_
- **Purpose:** State-machine driver for an extraction ground vehicle (or, per the runner mismatch, boats too): approach, park, wait for players, evac out. Parallel variant of ExtractionBoat.
- **Inputs:** `params ["_car","_extractPos","_evacVec"]`. Reads/writes vehicle var `State`. Precondition: car alive.
- **Outputs:** No return. Manages vehicle var `State`; adds waypoints; sets speed modes; logs via `A3E_fnc_Log`; ends on evac or death.
- **Calls:** `A3E_fnc_Log`.
- **Called by:** `Server/fn_RunExtractionBoat.sqf:41-42` and `Server/fn_RunExtractionCar.sqf:31-32` (all `spawn`). So this variant is used for BOTH the boat-extraction and car-extraction runners.
- **Processing:** Identical structure to ExtractionBoat but Approach slows at <100m/<30m (vs <40m). Init→Approach→Land("LAND"/park)→WaitForPlayers→Evac (exit waypoint, `_extract=true`); sleep 2 per tick.
- **Theory of operation:** Same polling/`State`-var pattern; the small threshold difference (30 vs 40) is the only meaningful divergence from ExtractionBoat.
- **Whys & questions:** Why does the *boat* runner use ExtractionCar? Possibly the two files were consolidated in practice and ExtractionBoat left behind. Naming is now misleading.
- **Unresolved issues:** Near-exact duplicate of ExtractionBoat (only the 40→30 distance differs). Runner naming vs function naming mismatch is a maintenance trap. Log strings say "vehicles" regardless of actual craft.
- **Reforger port notes:** Ground-vehicle parking + waypoint state machine; AI driving/pathing differs in Enfusion. TBD.

### a3e_fnc_ExtractionChopper  —  `Code/functions/AI/fn_ExtractionChopper.sqf`  ·  _status: documented_
- **Purpose:** State-machine driver for an extraction helicopter: fly in, descend, land, wait for players, then lift off and evac. Parallel variant of ExtractionBoat/Car with altitude handling.
- **Inputs:** `params ["_heli","_extractPos","_evacVec"]`. Reads/writes vehicle var `State`. Precondition: heli alive.
- **Outputs:** No return. Manages vehicle var `State`; adds waypoints (first with 30m radius); sets speed mode + `flyInHeight`; logs via `A3E_fnc_Log`; ends on evac/death.
- **Calls:** `A3E_fnc_Log`.
- **Called by:** `Server/fn_RunExtraction.sqf:31-32` and `Server/fn_RunExtractionHeli.sqf:31-32` (all `spawn`).
- **Processing:** Same skeleton; Approach slows and lowers `flyInHeight` (30 at <300m, 20 at <60m); Init waypoint uses radius 30; Land uses `land "LAND"`. Init→Approach→Land→WaitForPlayers→Evac; sleep 2.
- **Theory of operation:** Adds vertical (fly-in-height) control to the shared extraction state machine; otherwise identical to the boat/car variants.
- **Whys & questions:** Three near-identical files differing only in approach thresholds and (for heli) altitude — strong case for a single parameterized extraction fn. Why kept separate?
- **Unresolved issues:** Triplicated state machine (ExtractionBoat/Car/Chopper). Two runners (`RunExtraction` + `RunExtractionHeli`) both feed this — possible redundancy at the runner layer too.
- **Reforger port notes:** Helicopter landing/`flyInHeight`/waypoint radius all differ in Enfusion; heli AI landing is notoriously finicky. TBD.

### a3e_fnc_FireArtillery  —  `Code/functions/AI/fn_FireArtillery.sqf`  ·  _status: documented_
- **Purpose:** Fires available friendly (Opfor/Ind) artillery/mortars at a target position with dispersion, and makes nearby own AI flee the beaten zone. SearchLeader escalation option.
- **Inputs:** `_this` via `bis_fnc_param` `[0]` `_position`. Globals: `a3e_var_artillery_rounds`, `A3E_Param_Artillery`, `a3e_var_artillery_dispersion`, `a3e_var_artillery_fleeingDistance`, `a3e_var_artillery_units`, `a3e_debug_artillery`, `A3E_VAR_Side_Opfor`, `A3E_VAR_Side_Ind`.
- **Outputs:** Returns `_success` (true if a battery was in range and fired). Side effects: `commandArtilleryFire` bursts; spawns flee thread for nearby friendly AI. Debug sidechat when out of range.
- **Calls:** `bis_fnc_DirTo`, `a3e_fnc_Flee`. (`commandArtilleryFire`, `getArtilleryAmmo` engine.)
- **Called by:** `SearchLeader/fn_SearchLeader.sqf:84` (`call`) and `Scripts/Escape/SearchLeader.sqf:285` (`call`; :282 commented out).
- **Processing:** For each artillery unit: if it has ammo, target is in range, and gunner alive → spawn a firing loop (`_artilleryRounds = rounds×Param_Artillery`, each round jittered within dispersion, 3s apart) → spawn flee thread scattering nearby Opfor/Ind → `_success=true`, exit foreach. Else (debug) print out-of-range.
- **Theory of operation:** Reuses the map's actual enemy mortar/artillery statics (registered in `a3e_var_artillery_units`) as an indirect-fire response to detected players, with friendly-fire mitigation.
- **Whys & questions:** `for _i from 0 to _artilleryRounds` fires rounds+1 shells (inclusive loop) — off-by-one intended? Flee-scatter block is duplicated from CallCAS.
- **Unresolved issues:** Duplicate `private["_group","_group",...]`. Copy-pasted flee loop (shared with CallCAS). Inclusive `for` loop over-fires by one. Relies on `a3e_var_artillery_units` being populated elsewhere (implicit dependency).
- **Reforger port notes:** `commandArtilleryFire`/`getArtilleryAmmo`/`inRangeOfArtillery` have no direct Enfusion equivalents; indirect fire would need custom implementation. TBD.

### a3e_fnc_Flee  —  `Code/functions/AI/fn_Flee.sqf`  ·  _status: documented_
- **Purpose:** Makes a group sprint to a given (escape) position in LINE/FULL/AWARE, then resume normal patrol on arrival. Used to clear AI out of artillery/CAS impact zones.
- **Inputs:** `_this select 0` `_group`, `_this select 1` `_targetposition`. Precondition: server-only (`if(!isserver) exitwith`).
- **Outputs:** No return. Sets task state `"FLEE"`. Creates a move waypoint (LINE/FULL/AWARE) with timeout `[0,0,0]`; waypoint statement re-spawns `a3e_fnc_Patrol` on completion.
- **Calls:** `a3e_fnc_SetTaskState`, `a3e_fnc_move`.
- **Called by:** `AI/fn_CallCAS.sqf:25` and `AI/fn_FireArtillery.sqf:40` (both `spawn`).
- **Processing:** Server guard → set state FLEE → build `_oncomplete` = respawn Patrol → create fast LINE move waypoint with immediate (`[0,0,0]`) timeout so it completes as soon as reached.
- **Theory of operation:** Minimal "run away then go back to patrolling" behavior; the zero timeout means the group won't linger at the flee point but transitions straight back to Patrol.
- **Whys & questions:** FULL speed + AWARE (not COMBAT) — chosen to make them run without stopping to fight? On resume it always goes to plain Patrol (loses Guard/Stroll home context except via `a3e_homeMarker`).
- **Unresolved issues:** Shares the waypoint-setup skeleton with Patrol/Search. Resuming to Patrol regardless of the group's prior role may reassign guards/strollers into patrol behavior.
- **Reforger port notes:** Waypoint speed/behavior + self-respawn statement pattern differ in Enfusion. TBD.

### a3e_fnc_GetTaskState  —  `Code/functions/AI/fn_GetTaskState.sqf`  ·  _status: documented_
- **Purpose:** Reads a group's current AI task state string (uppercased), defaulting to `"IDLE"`. Shared helper used across the AI/Zones/Debug subsystems.
- **Inputs:** `_this select 0` `_group`. Reads group var `A3E_TaskState`.
- **Outputs:** Returns `toUpper` of the state (`"PATROL"`, `"GUARD"`, `"SAD"`, etc.), or `"IDLE"` if unset.
- **Calls:** none (leaf function).
- **Called by:** `AI/fn_OrderSearch.sqf:8`, `Debug/fn_TrackGroup.sqf:19`, `Debug/fn_TrackGroup_Update.sqf:29`, `Zones/fn_SerializeZoneGroups.sqf:60` (all `call`).
- **Processing:** Get group → read `A3E_TaskState` var (default "IDLE") → `toUpper` → return.
- **Theory of operation:** Companion to `SetTaskState`; centralizes reading the per-group behavior tag used for search-eligibility and zone (de)serialization.
- **Whys & questions:** Uppercasing on read means callers can store mixed-case but comparisons stay case-insensitive — but SetTaskState stores already-uppercase strings, so the `toUpper` is mostly defensive.
- **Unresolved issues:** None significant. Tiny leaf helper.
- **Reforger port notes:** Maps to a component/state enum on the group/AI in Enfusion. TBD.

### a3e_fnc_Guard  —  `Code/functions/AI/fn_Guard.sqf`  ·  _status: documented_
- **Purpose:** Guard behavior: keeps a group near/inside its home marker in SAFE/LIMITED, occasionally diverting into building garrison, and re-invokes itself for a slow perpetual guard loop.
- **Inputs:** `params ["_group",["_markerName","noMarker"]]`. Reads group var `a3e_homeMarker`. Warns (not exits) if run locally. Precondition ideally server.
- **Outputs:** No return. Sets state `"GUARD"`; sets group var `a3e_homeMarker`; creates move waypoint (COLUMN/LIMITED/SAFE) timeout `[0,20,6]`; may delegate to GuardBuilding or Patrol.
- **Calls:** `A3E_fnc_GuardBuilding`, `a3e_fnc_SetTaskState`, `a3e_fnc_RandomMarkerPos`, `A3E_fnc_Patrol`, `a3e_fnc_move`, `A3E_fnc_Log`.
- **Called by:** `AI/fn_GuardBuilding.sqf:13` (string) & `:38` (`spawn`); `Spawning/fn_populateLocationZone.sqf:56` (`call`).
- **Processing:** Resolve marker (from var if "noMarker") → 35% chance: if houses within 50m, `spawn GuardBuilding` and exit → set state GUARD → if a marker exists, pick a non-water random marker pos (loop ≤50) and set self-respawn `_oncomplete`; else log warning and fall back to Patrol → create slow SAFE waypoint with short timeout.
- **Theory of operation:** Sedentary variant of Patrol — same skeleton but SAFE/LIMITED and biased toward staying by/inside the marker and buildings; forms a Guard↔GuardBuilding cycle.
- **Whys & questions:** Timeout `[0,20,6]` has max(6) < mid(20) — likely a typo (should be `[0,6,20]`?). 35% house-diversion vs Patrol's 25% — tuning.
- **Unresolved issues:** Suspicious waypoint-timeout ordering (min 0, mid 20, max 6). Shares the marker/water-loop skeleton with Patrol/Stroll (dup candidate). Runs-locally case only warns, doesn't exit (unlike Patrol/Search which vary).
- **Reforger port notes:** Waypoint timeouts + self-respawn pattern differ; garrison diversion maps to a defend/garrison behavior. TBD.

### a3e_fnc_GuardBuilding  —  `Code/functions/AI/fn_GuardBuilding.sqf`  ·  _status: documented_
- **Purpose:** Garrisons a guarding group inside a nearby building (occupying a random building position), or falls back to Guard if no building is available.
- **Inputs:** `params ["_group",["_markerName","noMarker"]]`. Reads group var `a3e_homeMarker`. Warns if local.
- **Outputs:** No return. Sets state `"GARRISONED"`; creates a MoveInBuilding or a scatter move waypoint (COLUMN/LIMITED/SAFE) with timeout `[10,30,60]`; `_oncomplete` re-spawns Guard.
- **Calls:** `A3E_fnc_getRndBuildingWithPositions`, `A3E_fnc_MoveInBuilding`, `a3E_fnc_move`, `a3e_fnc_SetTaskState`, `A3E_fnc_Guard`.
- **Called by:** `AI/fn_Guard.sqf:18` (`spawn`); `Spawning/fn_populateLocationZone.sqf:58` (`call`).
- **Processing:** Resolve marker → build `_oncomplete` (respawn Guard) → find a random building with positions near leader → if found: pick a random position; if no man within 1m of it, MoveInBuilding to that index, else move to a nearby scatter pos; set timeout + state GARRISONED → else no building: `spawn Guard`.
- **Theory of operation:** Companion to Guard forming an occupy/patrol oscillation; keeps guards realistically inside structures when present.
- **Whys & questions:** The occupancy check (`nearestObjects Man within 1m`) is coarse — two units could still target the same building position across groups.
- **Unresolved issues:** Nearly identical to `fn_Occupy` (Stroll's building variant) and `fn_PatrolBuildings` — three files share this exact skeleton, differing mainly in formation/state string and the respawn target (Guard vs Stroll vs Patrol). Strong dedup candidate.
- **Reforger port notes:** `buildingPos`/MoveInBuilding garrisoning maps to Enfusion smart-object/waypoint-in-building system. TBD.

### a3e_fnc_InCombat  —  `Code/functions/AI/fn_InCombat.sqf`  ·  _status: documented_
- **Purpose:** Returns whether any unit in a group currently knows about an enemy (a lightweight "is this group engaged?" check).
- **Inputs:** `_this select 0` `_group`. No globals.
- **Outputs:** Returns boolean `_in_combat`.
- **Calls:** `BIS_fnc_enemyDetected` (per unit).
- **Called by:** `AI/fn_EngageReportedGroup.sqf:33` and `AI/fn_RandomPatrolRoute.sqf:35` (both `call`).
- **Processing:** Loop units; if any unit's `BIS_fnc_enemyDetected` is true, set flag and exit loop; return flag.
- **Theory of operation:** Gate used by patrol/investigation loops to stop issuing move orders while a group is actively fighting (so combat behavior isn't overridden).
- **Whys & questions:** `BIS_fnc_enemyDetected` semantics (knowsAbout threshold) determine sensitivity — no explicit threshold here.
- **Unresolved issues:** Leading indentation is a stray tab (cosmetic). Iterates all units even after finding one (uses `exitwith`, so fine). Minor.
- **Reforger port notes:** Maps to querying the AI target/threat knowledge in Enfusion. TBD.

### a3e_fnc_LeafletDrone  —  `Code/functions/AI/fn_LeafletDrone.sqf`  ·  _status: documented_
- **Purpose:** Flies a "leaflet" propaganda helicopter/drone that patrols a search-area marker, drops leaflet bombs near players, then returns to base to refuel and repeats. Adapted from Engima's Search Chopper.
- **Inputs:** `_this select 0..3`: `_chopper`, `_searchAreaMarker`, `_searchTimeMin`, `_refuelTimeMin` (callers also pass A3E_Debug as a 5th arg, unused as param). Globals: `A3E_Debug`, `a3e_var_commonLibInitialized`. Precondition: server-only; chopper must have a `vehicleVarName`.
- **Outputs:** No return. Manages vehicle var `waypointFulfilled`; adds waypoints; fires `"Bomb_Leaflets"`; adds/removes leaflet magazine; refuels. Debug sidechat/smoke.
- **Calls:** `drn_fnc_CL_MarkerExists`, `drn_fnc_CL_GetRandomMarkerPos`, `A3E_fnc_GetPlayers`, `A3E_fnc_GetRandomPlayer`.
- **Called by:** `Scripts/Escape/EscapeSurprises.sqf:314` (`spawn`).
- **Processing:** Guard (server, commonLib initialized, named chopper) → outer state machine READY→MOVING OUT→SEARCHING→RETURNING→LANDING→REFUELING→(READY): climbs, moves to random marker pos; in SEARCHING drops leaflets if a player within 200m and moves toward a random player; RETURNING rebuilds group and flies home; inner loop watches `waypointFulfilled`, death, search-time expiry, and empty leaflet magazine to drive transitions.
- **Theory of operation:** A near-clone of SearchDrone repurposed to drop leaflets instead of doing SAD; the two share the whole state-machine skeleton with different weapon/behavior in the SEARCHING state.
- **Whys & questions:** Uses `player sideChat` for debug — runs server-side, so `player` is questionable on a dedicated server (only fires under A3E_Debug). Hardcoded leaflet class `"1Rnd_Leaflets_Guer_F"` / `"Bomb_Leaflets"`.
- **Unresolved issues:** Large duplication with `fn_SearchDrone` (SEARCHING state and leaflet handling are the main differences). `player sideChat` on server. Depends on legacy DRN CommonLib. Error-branch messages reference "Search chopper" in places.
- **Reforger port notes:** Depends on DRN CommonLib + specific leaflet ammo classes; whole thing needs re-authoring as an Enfusion aerial behavior. TBD.

### a3e_fnc_Loiter  —  `Code/functions/AI/fn_Loiter.sqf`  ·  _status: documented_
- **Purpose:** None — the file is empty (0 bytes). Presumably a placeholder for a planned loiter/idle behavior that was never implemented.
- **Inputs:** None (empty file).
- **Outputs:** None.
- **Calls:** none.
- **Called by:** _xref: no `fnc_` references found. Dead/placeholder file; not registered by any caller.
- **Processing:** N/A (empty).
- **Theory of operation:** N/A.
- **Whys & questions:** Was a distinct loiter behavior intended (vs the loiter-waypoint code commented out in SearchDrone/LeafletDrone)? Safe to delete unless referenced by CfgFunctions.
- **Unresolved issues:** Empty file / dead code — candidate for removal (confirm it isn't declared in `functions.hpp`).
- **Reforger port notes:** N/A.

### a3e_fnc_MilitaryTrafficPatrol  —  `Code/functions/AI/fn_MilitaryTrafficPatrol.sqf`  ·  _status: documented_
- **Purpose:** Drives a military vehicle group to a random road position within a spawn ring in LIMITED/AWARE, re-invoking itself on arrival — ambient military road patrols.
- **Inputs:** `params [["_group",grpNull]]`. Globals: `A3E_MaxSpawnCircleDistance` (default 1500). Precondition: `_group` not null.
- **Outputs:** No return. Sets state `"VEHICLEPATROL"`; creates move waypoint (COLUMN/LIMITED/AWARE) timeout `[0,10,30]` with self-respawn statement.
- **Calls:** `A3E_fnc_GetRandomCirclePosition`, `A3E_fnc_Move`, `a3e_fnc_SetTaskState`; self.
- **Called by:** `Spawning/fn_MilitaryTraffic.sqf:59` (`spawn`). Re-spawned by its own waypoint statement and retry block.
- **Processing:** Null-guard → random road pos 500–MaxSpawnCircleDistance from leader → if none, sleep 10 and retry (self-spawn) → create move waypoint with self-respawn statement → set state VEHICLEPATROL.
- **Theory of operation:** Military twin of `fn_CivilianCommuter` (LIMITED speed, VEHICLEPATROL state) — a self-recursive road-patrol loop for enemy vehicles.
- **Whys & questions:** Differs from CivilianCommuter almost only in state string and speed mode — merge candidate.
- **Unresolved issues:** Structural duplicate of CivilianCommuter. Unbounded retry recursion if roads never resolve.
- **Reforger port notes:** Road queries + vehicle waypoints differ in Enfusion. TBD.

### a3e_fnc_MoveInBuilding  —  `Code/functions/AI/fn_MoveInBuilding.sqf`  ·  _status: documented_
- **Purpose:** Low-level helper that (re)configures a group's waypoint 1 to move to a specific building position and then scatters group members across shuffled building positions once the leader arrives.
- **Inputs:** `_this` via `bis_fnc_param`: `[0]` `_group`, `[1]` `_position`, `[2]` `_house` (object), `[3]` `_housePosition` (index), `[4]` type, `[5]` formation, `[6]` speed, `[7]` combatmode, `[8]` onComplete.
- **Outputs:** Returns the waypoint `[_group,1]`. Side effects: sets waypoint fields (position/house-position/behaviour/speed/formation/type/completion-radius/statements); spawns a thread that `doStop`s and distributes units to `buildingPos`.
- **Calls:** `BIS_fnc_arrayShuffle`; engine waypoint/`doMove`/`buildingPos` commands. (Spawned inner thread only uses engine commands.)
- **Called by:** `AI/fn_GuardBuilding.sqf:28`, `AI/fn_Occupy.sqf:27`, `AI/fn_PatrolBuildings.sqf:27` (all `call`).
- **Processing:** `doFollow` leader → ensure a waypoint 1 exists → set all waypoint attributes incl. house position and completion radius 10 → set onComplete statement → set current waypoint → spawn thread: wait until leader within 30m of target, `doStop` all, shuffle building positions, `doMove` each unit to a distinct position and `doStop` on arrival.
- **Theory of operation:** The shared "occupy this building" primitive under GuardBuilding/Occupy/PatrolBuildings; separates waypoint plumbing from the higher-level behavior selection.
- **Whys & questions:** Commented-out `waypointAttachObject` (line 21) — abandoned approach? Fixed 30m arrival threshold and completion radius 10 are hardcoded.
- **Unresolved issues:** The spawned distribution thread has no timeout guard if the leader never reaches the building (waituntil could hang). Per-unit `spawn`+`waitUntil moveToCompleted` scales poorly for large groups.
- **Reforger port notes:** `setWaypointHousePosition`/`buildingPos`/`doMove` map to Enfusion smart-object garrison waypoints. TBD.

### a3e_fnc_Occupy  —  `Code/functions/AI/fn_Occupy.sqf`  ·  _status: documented_
- **Purpose:** Building-occupy variant used by the Stroll behavior: garrisons a strolling group into a nearby building (LINE formation), else falls back to Stroll.
- **Inputs:** `params ["_group",["_markerName","noMarker"]]`. Reads group var `a3e_homeMarker`. Warns if local.
- **Outputs:** No return. Sets state `"OCCUPY"`; MoveInBuilding or scatter move (LINE/LIMITED/SAFE) timeout `[30,60,300]`; `_oncomplete` re-spawns Stroll.
- **Calls:** `A3E_fnc_getRndBuildingWithPositions`, `A3E_fnc_MoveInBuilding`, `a3E_fnc_move`, `a3e_fnc_SetTaskState`, `A3E_fnc_Stroll`.
- **Called by:** `AI/fn_Stroll.sqf:18` (`spawn`); `Zones/fn_DeserializeZoneGroups.sqf:87` (`call`).
- **Processing:** Resolve marker → build `_oncomplete` (respawn Stroll) → find random building w/ positions near leader → if found, pick random position; if unoccupied MoveInBuilding (LINE), else scatter move; set long timeout + state OCCUPY → else `spawn Stroll`.
- **Theory of operation:** Civilian/ambient counterpart of GuardBuilding — occupies buildings but oscillates back to the relaxed Stroll behavior rather than Guard.
- **Whys & questions:** Longest garrison timeout of the three building variants (`[30,60,300]`) — occupants linger longest. Why LINE (vs COLUMN in Guard/PatrolBuildings)?
- **Unresolved issues:** Near-identical to GuardBuilding and PatrolBuildings (differs in formation, state string, timeout, respawn target). Dedup candidate.
- **Reforger port notes:** Same building-garrison porting concerns as MoveInBuilding. TBD.

### a3e_fnc_OrderSearch  —  `Code/functions/AI/fn_OrderSearch.sqf`  ·  _status: documented_
- **Purpose:** On a fresh known-position report, orders eligible nearby patrolling groups to run a Search (SAD) on that position — the dispatcher that turns a sighting into search sweeps.
- **Inputs:** `_this select 0` `_position` (a known-position helper object). Globals: `a3e_var_maxSearchRange`, `A3E_VAR_Side_Ind`, `A3E_VAR_Side_Opfor`. Reads group state via GetTaskState and group var `a3e_homeMarker`.
- **Outputs:** No return. `spawn`s `a3e_fnc_Search` for chosen groups.
- **Calls:** `a3e_fnc_GetTaskState`, `a3e_fnc_Search`; engine `getMarkerSize`.
- **Called by:** `Scripts/Escape/SearchLeader.sqf:259` (`spawn`); `SearchLeader/fn_createKnownPosition.sqf:18` (commented out).
- **Processing:** For each group in AllGroups: if Ind/Opfor and within `maxSearchRange` of position and state is PATROL or SAD → if it has a home marker, only search when within that marker's radius (limits garrisons); if no marker, 50% chance → `spawn Search`.
- **Theory of operation:** Bridges SearchLeader intel to AI movement: only patrol-type groups near the sighting are pulled in, and marker-bound (garrison) groups won't wander far, keeping searches locally plausible.
- **Whys & questions:** Only PATROL/SAD groups respond (guards/strollers/commuters ignored) — intentional so static defenders stay put? Uses `AllGroups` (O(n)) each call.
- **Unresolved issues:** Iterates every group in the mission per report — could be costly with many groups. `getposATL _position` passed to Search (ATL) while range checks use `distance` (mix of coordinate spaces, usually fine).
- **Reforger port notes:** AllGroups scan + per-group state maps to a query over AI groups; known-position helper objects need an Enfusion equivalent. TBD.

### a3e_fnc_Patrol  —  `Code/functions/AI/fn_Patrol.sqf`  ·  _status: documented_
- **Purpose:** Core foot-patrol behavior: sends a group to a random position (within its home marker, or a large radius around players if markerless), occasionally diverting to building patrol, then re-invokes itself for perpetual patrolling.
- **Inputs:** `params ["_group",["_markerName","noMarker"]]`. Reads group var `a3e_homeMarker`; global player list via GetPlayers. Warns if run locally.
- **Outputs:** No return. Sets state `"PATROL"`; sets `a3e_homeMarker` (when marker given); creates move waypoint (COLUMN/LIMITED/SAFE) timeout `[0,15,30]`; `_oncomplete` re-spawns Patrol.
- **Calls:** `A3E_fnc_PatrolBuildings`, `a3e_fnc_SetTaskState`, `a3e_fnc_RandomMarkerPos`, `A3E_fnc_GetPlayers`, `a3e_fnc_RandomPatrolPos`, `a3e_fnc_move`.
- **Called by:** Very widely (17 sites): `AI/fn_Flee`, `fn_Guard`, `fn_PatrolBuildings`, `fn_Search` (respawn strings/spawns); `DRN/fn_AmbientInfantry`, `PopulateLocation`, `PopulateVillage`; `SearchLeader/fn_SearchLeader:13`; `Server/fn_initServer:578`; `Spawning/fn_activatePatrolZone`, `fn_AmbientPatrols`, `fn_populateVillageZone`; `Zones/fn_DeserializeZoneGroups` (multiple). See _xref.md Patrol.
- **Processing:** Resolve marker → 25% chance divert to PatrolBuildings if houses within 50m → set state PATROL → if marker: pick non-water random marker pos (≤50 tries), self-respawn oncomplete, store home marker; else: pick a RandomPatrolPos within 3000m of players (fallback to leader pos), constrain to ≤1.5× range, markerless self-respawn → create SAFE move waypoint with timeout.
- **Theory of operation:** The canonical patrol loop and template for Guard/Stroll/AquaticPatrol; markerless mode makes ambient patrols orbit the players, marker mode confines them to a zone.
- **Whys & questions:** Two divergent modes (marker vs player-relative) in one fn. `str _destinationPos == "[0,0,0]"` string compare is a fragile null test.
- **Unresolved issues:** Fragile stringified position comparison. Shared marker/water skeleton across Patrol/Guard/Stroll/AquaticPatrol. Local-run only warns (doesn't exit) even though comment says server-only reliance.
- **Reforger port notes:** Waypoint API + self-respawn statements differ; player-relative spawn logic needs re-expression. TBD.

### a3e_fnc_PatrolBuildings  —  `Code/functions/AI/fn_PatrolBuildings.sqf`  ·  _status: documented_
- **Purpose:** Building-patrol variant of Patrol: moves a group into a nearby building position (COLUMN), then oscillates back to Patrol on completion.
- **Inputs:** `params ["_group",["_markerName","noMarker"]]`. Reads group var `a3e_homeMarker`. Warns if local.
- **Outputs:** No return. Sets state `"PATROL BUILDINGS"`; MoveInBuilding or scatter move (COLUMN/LIMITED/SAFE) timeout `[10,20,30]`; `_oncomplete` re-spawns Patrol.
- **Calls:** `A3E_fnc_getRndBuildingWithPositions`, `A3E_fnc_MoveInBuilding`, `a3E_fnc_move`, `a3e_fnc_SetTaskState`, `A3E_fnc_Patrol`.
- **Called by:** `AI/fn_Patrol.sqf:18` (`spawn`).
- **Processing:** Resolve marker → build `_oncomplete` (respawn Patrol) → find random building w/ positions near leader → if found, pick random position; if unoccupied MoveInBuilding, else scatter move; set timeout + state "PATROL BUILDINGS" → else `spawn Patrol`.
- **Theory of operation:** Adds intermittent house-clearing/occupation to patrols so groups aren't always in the open; forms a Patrol↔PatrolBuildings cycle.
- **Whys & questions:** State string contains a space ("PATROL BUILDINGS") unlike the single-token states — matters for any `==` comparisons (none currently key on it). Timeout tuning differs from Guard/Occupy.
- **Unresolved issues:** Near-identical to GuardBuilding/Occupy (formation, state string, timeout, respawn target are the only differences). Dedup candidate.
- **Reforger port notes:** Same garrison-porting concerns as MoveInBuilding. TBD.

### a3e_fnc_RandomPatrolRoute  —  `Code/functions/AI/fn_RandomPatrolRoute.sqf`  ·  _status: documented_
- **Purpose:** A self-contained perpetual patrol loop (per group) that moves to random destinations, and when not in combat and near a reported known position (within investigation chance / city radius) diverts to investigate via EngageReportedGroup; in combat it holds and goes COMBAT/FULL.
- **Inputs:** `_this select 0` `_group`, `_this select 1` `_markerName`. Globals: `A3E_Debug`, `a3e_var_knownPositionHelperObject`, `a3e_var_maxSearchRange`, `a3e_var_investigationChance`. Reads helper object var `A3E_LastUpdated`.
- **Outputs:** No return (infinite loop). Issues moves via `a3e_fnc_move`; sets COMBAT/FULL on units in combat; creates/updates debug markers.
- **Calls:** `A3E_fnc_InCombat`, `a3e_fnc_EngageReportedGroup`, `a3e_fnc_move`. Debug marker engine commands.
- **Called by:** `DRN/fn_PopulateLocation.sqf:62` — commented out. So currently effectively unused (dead / disabled). Verify no dynamic dispatch.
- **Processing:** Optional debug markers → `while true`: recompute leader; if not in combat: find nearest known-position helper within maxSearchRange, pick the most recently updated; with `investigationChance`%, if markerless investigate the freshest (await scriptDone), else only investigate if within city radius; then pick a random non-water destination (marker pos or ±2000m box) and move; sleep ~travel time. If in combat: reposition waypoint to leader, set COMBAT/FULL, sleep 30.
- **Theory of operation:** An alternative all-in-one patrol/investigate loop (predecessor or sibling to the Patrol+OrderSearch split). Uses `nil` `_markerName` branches (via `isNil`) to switch between city-bound and free-roam behavior.
- **Whys & questions:** Uses global (not private) debug markers (`A3E_Debugmarker1/2`) shared across groups — collisions if multiple run. Only reachable via a commented-out call — is it dead?
- **Unresolved issues:** Likely dead code (only caller commented out). Global debug marker vars are not per-group despite per-group names. Contains its own investigate logic overlapping OrderSearch/EngageReportedGroup — architectural duplication.
- **Reforger port notes:** Whole loop would be re-expressed as an Enfusion behavior tree/state; known-position helpers need equivalents. TBD.

### a3e_fnc_Search  —  `Code/functions/AI/fn_Search.sqf`  ·  _status: documented_
- **Purpose:** Sends a group to Search-and-Destroy (SAD) a target position in LINE/FULL/COMBAT, then resume Patrol on completion. The active "go hunt at this position" order.
- **Inputs:** `_this select 0` `_group`, `_this select 1` `_targetposition`. Precondition: server-only (`if(!isserver) exitwith`).
- **Outputs:** No return. Sets state `"SAD"`; creates SAD waypoint (LINE/FULL/COMBAT) timeout `[0,20,6]`; `_oncomplete` re-spawns Patrol.
- **Calls:** `a3e_fnc_SetTaskState`, `a3e_fnc_move`.
- **Called by:** `AI/fn_OrderSearch.sqf:19` & `:23` (`spawn`); `SearchLeader/fn_SearchLeader.sqf:48` & `:107` (`call`).
- **Processing:** Server guard → set state SAD → build `_oncomplete` (respawn Patrol) → create SAD waypoint (aggressive settings) with timeout `[0,20,6]`.
- **Theory of operation:** The offensive counterpart to Patrol — dispatched by SearchLeader/OrderSearch to converge combat-ready AI on the players' last known area, then hand back to Patrol.
- **Whys & questions:** Timeout `[0,20,6]` again has max(6)<mid(20) — same suspicious ordering as Guard (likely typo pattern).
- **Unresolved issues:** Shares waypoint-setup skeleton with Patrol/Flee. Suspicious timeout ordering. Resumes to plain Patrol (drops any guard/stroll role).
- **Reforger port notes:** SAD waypoint type maps to an attack/search behavior in Enfusion. TBD.

### a3e_fnc_SearchDrone  —  `Code/functions/AI/fn_SearchDrone.sqf`  ·  _status: documented_
- **Purpose:** Flies a search helicopter that patrols a search-area marker doing SAD sweeps, then returns to base to refuel and repeats. Engima's Search Chopper, adapted. Sibling of LeafletDrone.
- **Inputs:** `_this select 0..3`: `_chopper`, `_searchAreaMarker`, `_searchTimeMin`, `_refuelTimeMin` (callers pass A3E_Debug 5th, unused). Globals: `A3E_Debug`, `a3e_var_commonLibInitialized`. Precondition: server; named chopper.
- **Outputs:** No return. Manages vehicle var `waypointFulfilled`; adds SAD/MOVE waypoints; refuels. Debug sidechat/smoke.
- **Calls:** `drn_fnc_CL_MarkerExists`, `drn_fnc_CL_GetRandomMarkerPos`.
- **Called by:** `Scripts/Escape/EscapeSurprises.sqf:288` (`spawn`).
- **Processing:** Guards → state machine READY→MOVING OUT (climb, MOVE waypoint to random marker pos)→SEARCHING (SAD/COMBAT/LIMITED waypoint to random marker pos, loops)→RETURNING (rebuild group, fly home)→LANDING→REFUELING (setFuel 1, wait refuel time)→READY; inner loop watches `waypointFulfilled`, death, and search-time expiry.
- **Theory of operation:** Aerial recon that pressures players by conducting SAD over a marked area; LeafletDrone is the same skeleton with leaflet-dropping instead of SAD.
- **Whys & questions:** `player sideChat` for debug on server-side script (only under A3E_Debug). Depends on legacy DRN CommonLib being initialized.
- **Unresolved issues:** Large duplication with `fn_LeafletDrone`. `player sideChat` on server. Legacy CommonLib dependency. Commented-out loiter-waypoint code.
- **Reforger port notes:** DRN CommonLib dependency + helicopter SAD waypoints need re-authoring in Enfusion. TBD.

### a3e_fnc_SeekShelter  —  `Code/functions/AI/fn_SeekShelter.sqf`  ·  _status: documented_
- **Purpose:** None functional — the file is empty (0 bytes). Placeholder for a planned "take cover / seek shelter" behavior; despite being referenced, it does nothing.
- **Inputs:** None (empty file). (Caller passes `[_grp]`.)
- **Outputs:** None.
- **Calls:** none.
- **Called by:** `Zones/fn_DeserializeZoneGroups.sqf:91` (`call A3E_FNC_SeekShelter`) — so it IS invoked on zone deserialization for groups whose saved state was (presumably) a shelter state, but the empty body is a no-op.
- **Processing:** N/A (empty). The `call` returns nil and the group gets no behavior — likely leaving it idle.
- **Theory of operation:** N/A — intended to restore/route groups that were sheltering; currently a silent gap.
- **Whys & questions:** Deserialize routes certain groups here expecting behavior; the empty body means those groups are effectively stranded on load. Was SeekShelter ever implemented and later emptied?
- **Unresolved issues:** BUG candidate: empty function is `call`ed as if it did something — groups deserialized into a "shelter" state receive no orders. Verify what state string maps here in DeserializeZoneGroups.
- **Reforger port notes:** Would need to be authored fresh (take-cover behavior). TBD.

### a3e_fnc_SetTaskState  —  `Code/functions/AI/fn_SetTaskState.sqf`  ·  _status: documented_
- **Purpose:** Stores a group's current AI task-state string in a group variable. Companion setter to GetTaskState; called by every behavior fn to tag what a group is doing.
- **Inputs:** `_this select 0` `_group`, `_this select 1` `_state` (string).
- **Outputs:** No return. Writes group var `A3E_TaskState` (local, non-broadcast). (Commented-out debug chat.)
- **Calls:** none (leaf function).
- **Called by:** All AI behavior fns: AquaticPatrol, CivilianCommuter, Flee, Guard, GuardBuilding, MilitaryTrafficPatrol, Occupy, Patrol, PatrolBuildings, Search, Stroll (see _xref.md SetTaskState).
- **Processing:** Read group + state → `setVariable ["A3E_TaskState",_state,false]`.
- **Theory of operation:** The write side of the group task-state tag used by OrderSearch (eligibility), zone serialization, and debug tracking; central so state strings stay consistent.
- **Whys & questions:** Broadcast flag is `false` (local var) — fine since AI logic runs server-side; but zone serialization must run server-side too (it does).
- **Unresolved issues:** State strings are free-form (mixed single-token and "PATROL BUILDINGS" with a space) — no enum/validation. Minor.
- **Reforger port notes:** Maps to a state field/enum on the AI group in Enfusion. TBD.

### a3e_fnc_Stroll  —  `Code/functions/AI/fn_Stroll.sqf`  ·  _status: documented_
- **Purpose:** Relaxed ambient wander behavior (LINE/LIMITED/SAFE): sends a group to a random position in its home marker, occasionally diverting to Occupy a building, then re-invokes itself. Civilian/ambient counterpart of Patrol.
- **Inputs:** `params ["_group",["_markerName","noMarker"]]`. Reads group var `a3e_homeMarker`. Warns if local.
- **Outputs:** No return. Sets state `"STROLL"`; sets `a3e_homeMarker` (when marker given); creates move waypoint (LINE/LIMITED/SAFE) timeout `[0,30,60]`; `_oncomplete` re-spawns Stroll.
- **Calls:** `A3E_fnc_Occupy`, `a3e_fnc_SetTaskState`, `a3e_fnc_RandomMarkerPos`, `a3e_fnc_move`.
- **Called by:** `AI/fn_Occupy.sqf:13` (string) & `:36` (`spawn`); `Spawning/fn_populateVillageZone.sqf:66` (`call`); `Zones/fn_DeserializeZoneGroups.sqf:83` (`call`).
- **Processing:** Resolve marker → 25% chance divert to Occupy if houses within 50m → set state STROLL → if marker: pick non-water random marker pos (≤50 tries), self-respawn oncomplete, store home marker → create slow SAFE move waypoint with timeout.
- **Theory of operation:** The "civilian villagers / relaxed occupants" behavior; same skeleton as Patrol/Guard but slowest and Occupy-biased.
- **Whys & questions:** If markerless, `_destinationPos` is never set before the waypoint call (unlike Patrol which has a markerless branch) — could reference an undefined variable. Was Stroll only ever meant to be used with a marker?
- **Unresolved issues:** Potential undefined `_destinationPos` when called with no marker and none stored (Patrol handles this case; Stroll does not). Shares marker/water skeleton with Patrol/Guard.
- **Reforger port notes:** Waypoint API + self-respawn statements differ; garrison diversion via Occupy. TBD.

### a3e_fnc_move  —  `Code/functions/AI/fn_move.sqf`  ·  _status: documented_
- **Purpose:** Central low-level waypoint helper: (re)configures a group's waypoint index 1 with the given type/formation/speed/behaviour/oncomplete and returns it. Every AI behavior fn routes its movement through here.
- **Inputs:** `_this` via `bis_fnc_param`: `[0]` `_group`, `[1]` `_position`, `[2]` type ("MOVE"), `[3]` formation ("COLUMN"), `[4]` speed ("LIMITED"), `[5]` combatmode ("SAFE"), `[6]` onComplete ("").
- **Outputs:** Returns waypoint `[_group,1]`. Side effects: `doFollow` leader; ensures a waypoint 1 exists; sets its position/behaviour/speed/formation/type/completion-radius/statements; sets current waypoint.
- **Calls:** none (leaf — engine waypoint commands only).
- **Called by:** All movement behaviors (14 sites): AquaticPatrol, CivilianCommuter, EngageReportedGroup, Flee, Guard, GuardBuilding, MilitaryTrafficPatrol, Occupy, Patrol, PatrolBuildings, RandomPatrolRoute, Search, Stroll (see _xref.md move).
- **Processing:** Read args → `doFollow` leader → if ≤1 waypoint, add one → set waypoint 1's attributes → completion radius 25 if leader mounted else 10 → set statements ["true", onComplete] → set current waypoint → return `[_group,1]`.
- **Theory of operation:** By always reusing waypoint index 1, behaviors can retask a group without accumulating waypoints; the oncomplete string is where the self-respawn recursion lives, making this the linchpin of the whole patrol/guard/search loop system.
- **Whys & questions:** Hardcoded reuse of index 1 assumes waypoint 0 is the initial/hold WP — fragile if a group has other waypoints. Mounted vs on-foot completion radius (25/10) is the only branch.
- **Unresolved issues:** All behaviors depend on the "waypoint 1" convention; any code adding extra waypoints elsewhere breaks it. `_marker`/`_markername`/`_script` declared but unused.
- **Reforger port notes:** Enfusion waypoint API differs substantially (no direct `setWaypointType`/index model); this helper's contract must be redesigned. Key porting choke-point.

### a3e_fnc_onEnemyDetected  —  `Code/functions/AI/fn_onEnemyDetected.sqf`  ·  _status: documented_
- **Purpose:** EnemyDetected event handler: when a CIVILIAN group spots a player and the mission's war-crime score is high enough, has a plausible civilian radio in a sighting to HQ (with animation/lip-sync), after a report delay.
- **Inputs:** `params ["_grp","_newTarget"]` (from the addEventHandler). Globals: `A3E_Warcrime_Score`, `A3E_Warcrime_Score_CivilianFear` (default 1000), `A3E_Radio_Reporting`, `A3E_var_ReportTime` (default 10). Reads group var `A3E_LastReportedPlayer`. NOTE: references `_player` (never defined in this scope — likely a bug; should be `_newTarget`).
- **Outputs:** No return. Sets group var `A3E_LastReportedPlayer` (time). Side effects: `say3D`/`setRandomLip`/`playmovenow` via remoteExec; calls `A3E_fnc_recordSighting`. Logs via `A3E_fnc_log`.
- **Calls:** `A3E_Fnc_GetPlayers`, `A3E_fnc_recordSighting`, `A3E_fnc_log`; engine `say3D`/`setRandomLip`/`playmovenow` via `remoteExec`.
- **Called by:** Wired as an `EnemyDetected` event handler in `Spawning/fn_onCivilianGroupSpawn.sqf:6` and `Spawning/fn_onEnemyGroupSpawn.sqf:5` — `{_this call A3E_fnc_onEnemyDetected;}`. [engine/event]
- **Processing:** Log sighting → exit if target isn't a player → only proceed if group is civilian → check knowsAbout≥2.5, score≥threshold, `isPlayer _player`, and 300s cooldown → pick radio-capable units (distance/suppression/stance/hidden filters) → have a random reporter say a radio sound, lip-sync, play a listening animation → after `ReportTime`s, if still alive record the sighting and stamp `A3E_LastReportedPlayer`.
- **Theory of operation:** Implements the "civilians fear you and rat you out" mechanic gated on the war-crime score — a soft consequence for atrocities that funnels intel into the SearchLeader sighting system via `recordSighting`.
- **Whys & questions:** Uses undefined `_player` in guards (line 15/16/19) and in `recordSighting` — should almost certainly be `_newTarget`; as written the guard `isPlayer _player` would error or use a global. The military (`onEnemyGroupSpawn`) also wires this handler, but the body only acts for `side == civilian` — so enemy detections here are a no-op beyond logging.
- **Unresolved issues:** BUG candidate: `_player` is never defined in this function (only `_newTarget`); the reporting path may throw/misbehave. Enemy groups get this handler but it does nothing for them (dead branch / misuse). Report-fail `else` mirrors a `while...exitwith` structure that is unusual.
- **Reforger port notes:** EnemyDetected EH, remoteExec of say3D/anim, and the war-crime score all need Enfusion equivalents. TBD.

### a3e_fnc_resumeTask  —  `Code/functions/AI/fn_resumeTask.sqf`  ·  _status: documented_
- **Purpose:** None — the file is empty (0 bytes). Presumably a placeholder for restoring a group to its prior task (e.g. after combat or on zone reload) that was never implemented.
- **Inputs:** None (empty file).
- **Outputs:** None.
- **Calls:** none.
- **Called by:** _xref: no `fnc_` references found. Dead/placeholder file.
- **Processing:** N/A (empty).
- **Theory of operation:** N/A. The task-resume role appears to be handled instead by the `_oncomplete` self-respawn strings and by DeserializeZoneGroups dispatching to Patrol/Stroll/etc.
- **Whys & questions:** Was a unified resume-task mechanism intended (vs the current per-behavior respawn strings)? Safe to delete unless declared in `functions.hpp`.
- **Unresolved issues:** Empty file / dead code — candidate for removal.
- **Reforger port notes:** N/A.

### a3e_fnc_spawnGarisson  —  `Code/functions/AI/fn_spawnGarisson.sqf`  ·  _status: documented_
- **Purpose:** Spawns a garrison of infantry inside a building at that building's precomputed spawn positions (position + facing), as one group of the given side. (Note the misspelling "Garisson".)
- **Inputs:** `_this` via `bis_fnc_param`: `[0]` `_building` (objNull), `[1]` `_side` (index into A3E_Sides/A3E_GroupMembers, default 0). Globals: `A3E_GroupMembers`, `A3E_Sides`.
- **Outputs:** No return. Creates a group and units placed via `setposASL`/`setdir` at building positions. Debug chat of position count.
- **Calls:** `a3e_fnc_findSpawnPosBuilding`, `a3e_fnc_debugChat`.
- **Called by:** _xref: no `fnc_` references found — entry point or dead code. Not spawned/called by any indexed file; verify it isn't dynamically dispatched or dead. Likely unused/legacy.
- **Processing:** Read building + side → get spawn positions via findSpawnPosBuilding → debug-chat the count → pick unit array `A3E_GroupMembers select _side` → create group of `A3E_Sides select _side` → for each position, create a random unit, `setposASL`, `setdir` (uses index 4 of the position tuple for direction).
- **Theory of operation:** A direct building-garrison spawner keyed off `findSpawnPosBuilding`'s position tuples; distinct from the Guard/Occupy garrison flow (which moves existing groups into buildings rather than spawning new ones).
- **Whys & questions:** Uses `A3E_GroupMembers`/`A3E_Sides` index arrays (older faction model) rather than the current faction template functions — is this legacy? No callers found — dead?
- **Unresolved issues:** Likely dead code (no callers). Misspelled function name ("Garisson"). Position tuple assumes index 4 = direction (coupling to findSpawnPosBuilding's format). Uses `a3e_fnc_debugChat` unconditionally (not gated by A3E_Debug).
- **Reforger port notes:** Building-position spawning maps to Enfusion spawn points/smart objects; the legacy side-index model would be replaced. TBD.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-07-01 | Claude | Documented all entries |
</content>
</invoke>
