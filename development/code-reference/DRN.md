# Code Reference — DRN
_Last updated: 2026-07-02 (local)_ · _Status: documented_

> Legacy DRN library — ambient population, traffic, and search groups (compatibility layer). One entry per source file in `Code/functions/DRN/`. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).
>
> **Library context:** These functions are declared under the `drn` CfgFunctions tag and called as `drn_fnc_<Name>` (NOT `a3e_fnc_`). "DRN" is the original third-party author (Engima of Östgöta Ops). Several of these are partially superseded by newer A3E systems in `Spawning/` and `Zones/` (there are A3E-native `fn_MilitaryTraffic`, `fn_AmbientPatrols`, `fn_CivilianCommuters`, `fn_populateVillageZone`, `fn_initVillages`). Many DRN functions depend on an external "CommonLib" (`drn_fnc_CL_*`) that lives outside this folder (in `Scripts/DRN/CommonLib/`). Where a DRN function is dead/superseded, the A3E equivalent is named.
>
> **⚠ Correction (dead `if(false)` block):** In `initServer.sqf` the legacy DRN ambient/traffic/aquatic calls
> sit inside a disabled `if(false) then { … }` block spanning **`:251-441`** (`:250` comments "Uncommenting all
> legacy scripts for now"). So despite their "Called by" citations below, **`drn_fnc_AmbientInfantry` (:347),
> `drn_fnc_InitAquaticPatrols` (:285), `drn_fnc_MilitaryTraffic` (:399/400), and — via that dead init —
> `drn_fnc_PopulateAquaticPatrol`/`drn_fnc_DepopulateAquaticPatrol` are DISABLED (dead)**, not live. The live
> enemy-population/traffic systems are the A3E ones (`initVillages`, `AmbientPatrols`/`MilitaryTraffic` via
> Chronos `:681`, `populate*Zone` via Zones). Per-entry "Called by" fields will be tightened in the final re-review.

### drn_fnc_AmbientInfantry  —  `Code/functions/DRN/fn_AmbientInfantry.sqf`  ·  _status: documented_
- **Purpose:** Spawn/despawn manager that keeps a target number of ambient infantry groups alive in a ring around the player group, patrolling and garbage-collecting units that drift too far away. (header lines 1-20)
- **Inputs:** `_this select 0..12` — reference group, side, infantry classes (array or faction string like `"USMC"`), groups count (def 10), min/max spawn dist (def 1500/2000), min/max units, min/max skill, garbage-collect distance (def 750), `_fnc_OnSpawnUnit`, `_fnc_OnSpawnGroup`, debug (line 30-42). Reads globals `A3E_VAR_Side_Ind/_Opfor`, `a3e_arr_Escape_InfantryTypes[_Ind]`, `a3e_arr_AmbientInfantry_Inf_*`, `A3E_Debug`. Server-only (line 22).
- **Outputs:** No return (infinite loop). Writes `A3E_DebugMarkers`, `A3E_DebugMarkerNo`, `A3E_DebugMsg`, `drn_AmbientInfantry_CurrentEntityNo`. Side effects: creates groups/units, names the leader via `setVehicleVarName` + a compiled global var, starts `A3E_fnc_Patrol` per group, deletes far/dead units and sets the searchleader despawn flag in `A3E_StatusOfPatrols` (line 274-280).
- **Calls:** `a3e_fnc_RandomSpawnPos`, `a3e_fnc_getDynamicSquadSize`, `A3E_fnc_Patrol`, `drn_fnc_CL_ShowDebugTextAllClients`; commented-out `drn_fnc_MoveInfantryGroup` (line 158). External CommonLib dep noted (line 51).
- **Called by:** `Code/functions/Server/fn_initServer.sqf:347` — LIVE `spawn drn_fnc_AmbientInfantry` (this is the mission's primary enemy-infantry pressure generator). One caller.
- **Processing:** Outer `while{true}`: top-up loop creates groups at random spawn positions (a random faction picked from a hardcoded weighted Ind/Opfor array, line 46), builds units, assigns rank/skill/patrol script; then flags far-away units (alive beyond maxSpawnDistance, dead beyond garbageCollectDistance), deletes whole groups that are entirely far away (terminating their patrol/spawn scripts), prunes all-dead groups, sleeps 60s (1s in debug).
- **Theory of operation:** A self-balancing population controller: the ring of active groups follows the players and is continuously recycled to bound unit count. Naming each leader with a compiled global gives waypoint-statement scripts a stable handle.
- **Whys & questions:** The `//WHY!?!?!?!?!` comment (line 45) on the faction array is the original author's own confusion — a 6:5 Ind:Opfor weighting with no explanation (candidate Q). Why does it re-derive `_possibleInfantryTypes` from `_faction` (line 115-120) rather than the caller's `_infantryClasses`?
- **Unresolved issues:** DRN-vs-A3E duplication with `Spawning/fn_AmbientPatrols.sqf` (RD-018 context) — both do ambient enemy population; unclear which is authoritative. `_minUnitsInGroup/_maxUnitsInGroup` params are ignored (squad size comes from `a3e_fnc_getDynamicSquadSize`, line 124), so two documented params are dead. `_group` used at line 267/275 relies on outer-scope leakage from the `_activeUnits` loop (line 210) — fragile. CommonLib nag-loop (line 49-53) is a hard external dependency.
- **Reforger port notes:** TBD — this ambient-population role likely maps to Reforger's own spawn/despawn systems (e.g. an A3E-native replacement of AmbientPatrols); the DRN implementation is unlikely to port verbatim.

### drn_fnc_DepopulateAquaticPatrol  —  `Code/functions/DRN/fn_DepopulateAquaticPatrol.sqf`  ·  _status: documented_
- **Purpose:** Trigger-deactivation handler that deletes the boats/crews of an aquatic patrol zone when players leave the zone (companion to PopulateAquaticPatrol). (whole file)
- **Inputs:** `_this select 0` = aquatic-patrol-zone array `[markerName, pos, groupsCount, boatsArray]`; reads `boatsArray` (index 3). Reads `A3E_Debug`. Server-only (line 1).
- **Outputs:** No return. Side effects: for each boat, terminates its `A3E_GroupPatrolScript`, deletes crew + boat + group — but only if no player is aboard and the group is non-empty (guard flag, line 21-26).
- **Calls:** none (leaf function); uses an inline local `_deleteBoatDelayed`.
- **Called by:** wired via trigger deactivation statement built in `Code/functions/DRN/fn_InitAquaticPatrols.sqf:65` (`spawn drn_fnc_DepopulateAquaticPatrol`). Indirect / trigger-driven.
- **Processing:** Reads boats array; per boat spawns `_deleteBoatDelayed` (with 0.5s stagger), which sets `_flag=false` if the group is empty or any occupant is a player, else terminates patrol script and deletes crew/group/boat.
- **Theory of operation:** Mirrors PopulateAquaticPatrol so the trigger pair can cheaply spawn/despawn sea patrols as players approach/leave, keeping only nearby boats live.
- **Whys & questions:** `_flag` is declared `private` at top (line 5) but the inner `_deleteBoatDelayed` re-reads/writes it as if shared — works because `spawn` copies, but the guard logic is easy to misread.
- **Unresolved issues:** Live only if `InitAquaticPatrols` is (it is — initServer:285). Several declared privates (`_soldiers`, `_damage`, etc.) are unused leftovers (RD tech-debt). `_deleteBoatDelayed` deletes only crew and boat, not any passengers not in `crew` — minor.
- **Reforger port notes:** TBD — legacy library; sea-patrol lifecycle likely reimplemented via Reforger triggers/zones.

### drn_fnc_DepopulateLocation  —  `Code/functions/DRN/fn_DepopulateLocation.sqf`  ·  _status: documented_
- **Purpose:** Trigger-deactivation handler that despawns the guards of a "guarded location" (ammo depot / mortar site) and records each soldier's damage so it can respawn with the same wounds. (whole file)
- **Inputs:** `_this select 0` = location array `[markerName, "", soldierObjects, pos]`; iterates `soldierObjects` (index 2), each entry `[type, skill, spawned, damage, obj, scriptHandle, hasScript]`. Reads `A3E_Debug`. Server-only.
- **Outputs:** No return. Mutates each soldierObject in place: stores current damage, clears obj/spawned/script flags. Deletes soldier objects, terminates `A3E_GroupPatrolScript`, deletes groups.
- **Calls:** none (leaf function).
- **Called by:** wired via trigger deactivation statement built in `Code/functions/DRN/fn_InitGuardedLocations.sqf:101` (`spawn drn_fnc_DepopulateLocation`). Indirect / trigger-driven.
- **Processing:** For each spawned soldier: capture `damage` (or 1 if `!canStand`), delete the unit, terminate the group patrol script, delete the group, then reset the persistence tuple (spawned=false, damage saved, obj/script=objNull, hasScript=false).
- **Theory of operation:** The soldierObject array is a persistence record: depopulate saves state, PopulateLocation restores it, so a location "remembers" casualties across activation cycles.
- **Whys & questions:** Why delete the group per-soldier inside the loop rather than once per group? Likely a leftover from a design where each guard was its own group.
- **Unresolved issues:** Superseded overlap: A3E has `Spawning/fn_populateLocationZone.sqf` + `Zones/` for guarded/location population; unclear if this DRN path is still the live one. Live only if `InitGuardedLocations` is actually invoked — the xref shows no `fnc_` caller for InitGuardedLocations (see below), so this whole aquatic/guarded-location chain may be dead. Many declared privates unused.
- **Reforger port notes:** TBD — legacy; damage-persistence-across-despawn is a concept worth preserving if the location system is reimplemented.

### drn_fnc_DepopulateVillage  —  `Code/functions/DRN/fn_DepopulateVillage.sqf`  ·  _status: documented_
- **Purpose:** Trigger-deactivation handler that despawns all patrol groups of a village, saving each soldier's damage for later respawn. (whole file)
- **Inputs:** `_this select 0` = village array `[markerName, pos, groups, ...]`; iterates `groups` (index 2), each group entry `[soldiers, side]`, each soldier a persistence tuple. Reads `A3E_Debug`. Server-only.
- **Outputs:** No return. Mutates soldier tuples in place (saves damage, clears obj/flags), deletes units, terminates `A3E_GroupPatrolScript`, deletes groups (via delayed `_deleteGroupDelayed`).
- **Calls:** none (leaf function); inline `_deleteGroupDelayed`.
- **Called by:** **No `fnc_` references found in xref — dead/unused, or wired only from an external `Scripts/DRN/...VillagePatrols` path not indexed here.** Superseded by A3E `Spawning/fn_populateVillageZone.sqf` + `Zones/fn_deactivateZone.sqf` (village population/despawn is now zone-driven).
- **Processing:** For each group: resolve leader, loop soldiers saving damage and deleting units + group, then spawn `_deleteGroupDelayed` (0.5s stagger) which deletes any remaining units, terminates the patrol script, and deletes the group.
- **Theory of operation:** Same persistence pattern as DepopulateLocation but one level deeper (village → groups → soldiers).
- **Whys & questions:** The commented-out `setPos [-1000,...]` + `sleep 15` block (line 22-28) hints at an older "hide then delete" approach abandoned for direct deletion.
- **Unresolved issues:** Appears **dead / superseded** by A3E village-zone system (RD-018 duplication). Redundant deletion (per-soldier delete + `_deleteGroupDelayed`). Nested magic indices (`select 0/1/2/3/5/6/8`) with no schema doc.
- **Reforger port notes:** TBD — legacy; drop in favor of the Reforger equivalent of the A3E village-zone system.

### drn_fnc_GarrisonUnits  —  `Code/functions/DRN/fn_GarrisonUnits.sqf`  ·  _status: documented_
- **Purpose:** Place extra soldiers inside specific military structures (watchtowers, HQ/cargo bunkers, towers) near a guarded location, positioning each on a random building position. (whole file)
- **Inputs:** `_this select 0/2/3` = side, markerName, locationObject (whose index 3 is the position). `_soldiertype` is forced to `a3e_arr_Escape_InfantryTypes` (line 4, ignoring `_this select 1`). Server context assumed (no explicit isServer guard).
- **Outputs:** No return. Side effects: creates a fresh group per garrisoned soldier, spawns the unit at a random marker pos, runs `drn_fnc_Escape_OnSpawnGeneralSoldierUnit`, then `setPosATL` onto a random building position of a nearby structure.
- **Calls:** `drn_fnc_CL_GetRandomMarkerPos`, `drn_fnc_Escape_OnSpawnGeneralSoldierUnit`.
- **Called by:** `Code/functions/DRN/fn_PopulateLocation.sqf:78` (`spawn drn_fnc_GarrisonUnits`). One caller — live only if PopulateLocation/guarded-locations chain runs.
- **Processing:** For each of five structure classes found within 50m (`Land_Cargo_Patrol_V1_F`, `Land_Cargo_HQ_V1_F`, `Land_Cargo_Tower_V1_F`, `Land_Bunker_01_HQ_F`, `Land_Bunker_01_small_F`, `Land_Bunker_01_tall_F`), spawn a randomized number of soldiers (1 per watchtower; `random 3/7/3/3/4` for the others) and snap each to a random `buildingPos`.
- **Theory of operation:** Adds static defenders to hardened structures so guarded locations feel fortified rather than just having roaming patrols.
- **Whys & questions:** Each garrisoned soldier gets its OWN group (`createGroup` inside the loop) — dozens of one-man groups, no patrol script attached, so they are effectively static. Intended? Group-count bloat is a concern.
- **Unresolved issues:** Ignores the `_soldiertype` argument (line 4) — hardcoded to Escape infantry (RD). `buildingPos -1` returns all positions; `_rbpos = (floor random n)+1` can exceed valid index (off-by-one, may `setPosATL` to `[0,0,0]`) — candidate BUG. No isServer guard (relies on caller). Live only if the guarded-location chain is live (see InitGuardedLocations — no fnc caller found).
- **Reforger port notes:** TBD — legacy; garrisoning is covered by A3E `Garrison/` + `Spawning/fn_findSpawnPosBuilding.sqf` in the modern path.

### drn_fnc_InitAquaticPatrolMarkers  —  `Code/functions/DRN/fn_InitAquaticPatrolMarkers.sqf`  ·  _status: documented_
- **Purpose:** Load per-island patrol-boat marker definitions and create local map markers (`a3e_aquaticPatrolMarkerN`) for each aquatic patrol zone. (whole file)
- **Inputs:** No script params used; reads `Island\PatrolBoatMarkers.sqf` (compiled at runtime) → `a3e_patrolBoatMarkers`, and `A3E_Debug` (marker visibility). Server-only (`if isServer`).
- **Outputs:** Creates local markers per zone; sets `a3e_var_aquaticPatrolMarkersInitialized = true`. Errors via `BIS_fnc_error` if markers missing.
- **Calls:** `BIS_fnc_error`; engine marker commands (`createMarkerLocal`, `setMarker*Local`). Compiles external `Island\PatrolBoatMarkers.sqf`.
- **Called by:** `Code/functions/Server/fn_initServer.sqf:206` — but **the call is commented out** (`//[true] call drn_fnc_InitAquaticPatrolMarkers;`). So markers are created elsewhere or the aquatic-patrol feature is currently disabled. Candidate dead-code.
- **Processing:** Compile island marker file; for each `[pos, dir, shape, size]` entry, create a local marker, hide it unless debug, apply shape/dir/size; increment index; set initialized flag.
- **Theory of operation:** Establishes the geometry that InitAquaticPatrols later attaches presence triggers to; markers double as debug visualization.
- **Whys & questions:** Since the initServer call is commented out, how are `a3e_aquaticPatrolMarkerN` markers created before InitAquaticPatrols references them? Possible latent bug (InitAquaticPatrols may create triggers with no markers).
- **Unresolved issues:** Commented-out caller → likely **dead / disabled** aquatic-patrol feature (candidate Q/RD). If re-enabled, note the marker-name mismatch risk with the village markers below.
- **Reforger port notes:** TBD — legacy; marker-driven zone definition maps to Reforger's world/zone entities.

### drn_fnc_InitAquaticPatrols  —  `Code/functions/DRN/fn_InitAquaticPatrols.sqf`  ·  _status: documented_
- **Purpose:** For each patrol-boat marker, create a player-presence trigger whose activation/deactivation spawn/despawn sea patrols (populate/depopulate). (whole file)
- **Inputs:** `_this select 0..10` — reference unit, side, infantry classes, min/max soldiers per group, area-per-group, min/max skill, spawn radius, `_fnc_onSpawnGroup`, debug (line 17-30). Reads `a3e_patrolBoatMarkers`, requires `a3e_var_villageMarkersInitialized` (exits with nag if unset, line 10). Server-only.
- **Outputs:** Builds `a3e_arr_aquaticPatrols_Markers` (zone records), sets `drn_fnc_AquaticPatrols_OnSpawnGroup`. Creates one presence trigger per zone with populate/depopulate statements.
- **Calls:** none directly (leaf); creates triggers referencing `drn_fnc_PopulateAquaticPatrol` / `drn_fnc_DepopulateAquaticPatrol` via `setTriggerStatements`.
- **Called by:** `Code/functions/Server/fn_initServer.sqf:285` — LIVE `call drn_fnc_InitAquaticPatrols`. One caller.
- **Processing:** Guard on village-markers-initialized; parse params; for each boat marker build a zone record `[name, pos, groupsCount, []]` where `groupsCount = random 1` (0 or up to 1 group), create an `EmptyDetector` trigger attached to the reference vehicle with `MEMBER PRESENT` activation and populate/depopulate spawn statements.
- **Theory of operation:** Presence triggers keep sea patrols cheap — only spawned when a player is within `_spawnRadius` of a boat marker.
- **Whys & questions:** `_maxGroupsCount = random 1` (line 48) yields a float 0..1; downstream `_groupsCount` is used as a loop bound (`_i <= _groups`, PopulateAquaticPatrol line 20) — fractional group counts are odd. The much richer area-based formula is commented out (line 47).
- **Unresolved issues:** Depends on `InitAquaticPatrolMarkers`, whose caller is commented out (line 206) — so triggers may reference markers that were never created (candidate BUG). `drn_fnc_AquaticPatrols_OnSpawnGroup = _fnc_OnSpawnGroup` uses a mis-cased var (`_fnc_onSpawnGroup` vs `_fnc_OnSpawnGroup`, line 38) — case-insensitive so OK (RD-008), but confusing. Many unused privates.
- **Reforger port notes:** TBD — legacy; sea patrols likely reimplemented via Reforger zone triggers.

### drn_fnc_InitGuardedLocations  —  `Code/functions/DRN/fn_InitGuardedLocations.sqf`  ·  _status: documented_
- **Purpose:** Build presence triggers around a set of guarded-location markers (`<markerName>N`) so guards populate/depopulate as players approach; pre-generates each location's soldier persistence records. (whole file)
- **Inputs:** `_this select 0..10` — reference group, location marker base name, side, infantry classes, max groups, min/max soldiers, min/max skill, spawn radius, debug (line 7-18). Reads `a3e_arr_InitGuardedLocations_Inf_*`. Server-only.
- **Outputs:** Creates a numbered global `a3e_var_guardedLocations<instanceNo>` array and increments `a3e_var_guardedLocationsInstanceNo`. Creates one presence trigger per existing location marker with populate/depopulate statements referencing PopulateLocation/DepopulateLocation.
- **Calls:** `a3e_fnc_getDynamicSquadSize`; engine trigger/marker commands. Uses `call compile format` to name per-instance globals.
- **Called by:** **No `fnc_` references found in xref — dead/unused, or invoked only from an external `Scripts/DRN/...` path not indexed.** The A3E-native guarded/location population lives in `Spawning/fn_populateLocationZone.sqf`; this DRN path appears superseded.
- **Processing:** Faction/class resolution; increment instance counter; loop over `<markerName>0,1,2,...` while the marker exists (non-zero pos), building a soldier list (`getDynamicSquadSize` units, each a persistence tuple) and a `location` record, then create an `EmptyDetector` trigger (`MEMBER PRESENT`, radius `_spawnRadius`) whose statements spawn PopulateLocation / DepopulateLocation.
- **Theory of operation:** Same lazy-spawn pattern as villages/aquatic patrols, using dynamically named per-instance globals so multiple guarded-location sets can coexist.
- **Whys & questions:** Why `call compile format` to build indexed globals instead of a nested array? Legacy style predating array literals. Since no caller is found, is this feature retired?
- **Unresolved issues:** **Likely dead / superseded** (candidate Q/RD-018) — no fnc caller, and A3E has `populateLocationZone`. If invoked externally, note the `_side` used in PopulateLocation comes from the trigger statement string (line 101), not verified here. Many unused privates.
- **Reforger port notes:** TBD — legacy; drop for the Reforger equivalent of the A3E location-zone system.

### drn_fnc_InitVillageMarkers  —  `Code/functions/DRN/fn_InitVillageMarkers.sqf`  ·  _status: documented_
- **Purpose:** Load per-island village marker definitions and create local map markers (`drn_villageMarkerN`) for each village zone. (whole file)
- **Inputs:** No script params used; compiles `Island\VillageMarkers.sqf` → `a3e_villageMarkers`; reads `A3E_Debug`. Server-only.
- **Outputs:** Creates local markers per village; sets `a3e_var_villageMarkersInitialized = true`. Errors via `BIS_fnc_error` if `a3e_villageMarkers` missing.
- **Calls:** `BIS_fnc_error`; engine marker commands. Compiles external `Island\VillageMarkers.sqf`.
- **Called by:** `Code/functions/Server/fn_initServer.sqf:205` — LIVE, but called as `[true] call A3E_fnc_InitVillageMarkers` (A3E_fnc alias, case-insensitive). One caller. Also gates InitAquaticPatrols (which requires `a3e_var_villageMarkersInitialized`).
- **Processing:** Compile island marker file; per `[pos, dir, shape, size]` entry create a hidden-unless-debug local marker with shape/dir/size; set initialized flag.
- **Theory of operation:** Defines village geometry consumed by the village population system and (as a prerequisite flag) by InitAquaticPatrols. Identical structure to InitAquaticPatrolMarkers but for `drn_villageMarker*`.
- **Whys & questions:** Marker prefix is `drn_villageMarker` (DRN namespace) even though the function is called via the `A3E_fnc_` alias — naming straddles both systems.
- **Unresolved issues:** Function is registered under BOTH `drn` and effectively invoked as `A3E_fnc_InitVillageMarkers` — the CfgFunctions class name should be confirmed against `functions.hpp` (RD-008 casing/namespace). Whether the resulting `drn_villageMarker*` markers are still consumed by a live populate path (vs A3E `initVillages`/`populateVillageZone`) needs confirmation.
- **Reforger port notes:** TBD — legacy; marker-driven village definition maps to Reforger world/zone entities.

### drn_fnc_InsertionTruck  —  `Code/functions/DRN/fn_InsertionTruck.sqf`  ·  _status: documented_
- **Purpose:** Drive a truck carrying a cargo group to a drop point on a road inside a marker, unload the group, then return the truck home and clean it up. (header lines 1-10)
- **Inputs:** `_this select 0..5` — truck, cargo group, drop marker, attackOnSight (def false), `_fncOnUnloadGroup`, debug. Server-only. Requires CommonLib.
- **Outputs:** No return. Side effects: loads cargo into truck, drives via generated waypoints, unloads and runs `_fncOnUnloadGroup`, deletes truck + crew group on return. Sets truck vars `waypointFulfilled`, `missionCompleted`, `reinforcementTruckReturning`.
- **Calls:** `drn_fnc_CL_ShowDebugTextAllClients`, `drn_fnc_CL_PositionIsInsideMarker`, `drn_fnc_CL_SetDebugMarkerAllClients`, `drn_fnc_CL_DeleteDebugMarkerAllClients`; inline `_fnc_GetDropPosition`, `_fnc_ClearAllWaypoints`.
- **Called by:** `Code/Scripts/Escape/CreateReinforcementTruck.sqf:77` (`spawn drn_fnc_InsertionTruck`). One caller (external Escape script). LIVE reinforcement mechanic.
- **Processing:** Name/validate truck; load cargo; spawn a monitor thread that watches for enemy sighting (optionally interrupts to attack), unloads on arrival, waits for cargo to disembark, then routes the truck home and deletes it. Main thread computes a road drop position inside the marker and issues MOVE waypoints, re-routing if the marker (drop area) moves.
- **Theory of operation:** A reusable "reinforcement delivery" primitive — separates transport crew from cargo group, so the cargo can be handed to a search-group behavior after drop.
- **Whys & questions:** Dead cargo handling `_x setPos getPos _truck` (line 163) with a `player sideChat "Deleting dead unit"` looks like leftover debug that never actually deletes. Why `sleep 60` before returning (line 170)?
- **Unresolved issues:** `player sideChat` debug spam on all clients (line 162) regardless of `_debug` — candidate BUG/RD. Hard CommonLib dependency. Overlaps conceptually with A3E extraction/drop-chopper scripts.
- **Reforger port notes:** TBD — legacy; reinforcement delivery would be a Reforger group-transport behavior.

### drn_fnc_MilitaryTraffic  —  `Code/functions/DRN/fn_MilitaryTraffic.sqf`  ·  _status: documented_
- **Purpose:** Continuously spawn road vehicles (military per side, or civilian) that drive between distant road segments around the players, despawning them when far away. (whole file)
- **Inputs:** `params` (line 8): side, vehicle classes, vehicle count (def 10), min/max spawn dist, min/max skill, `_fnc_OnSpawnVehicle`, debug. Reads `a3e_arr_Escape_MilitaryTraffic_*VehicleClasses[_Ind]`, `A3E_VAR_Side_*`. Auto-scales spawn distances by map size (line 17-56). Requires CommonLib.
- **Outputs:** No return (infinite loop). Writes `drn_fnc_MilitaryTraffic_MoveVehicle`, `drn_MilitaryTraffic_CurrentEntityNo`. Side effects: spawns vehicles+crews via `BIS_fnc_spawnVehicle`, names them, drives them, deletes far/empty ones.
- **Calls:** `A3E_FNC_GetPlayers`, `a3e_fnc_onVehicleSpawn`, `BIS_fnc_spawnVehicle`, `drn_fnc_CL_ShowDebugTextAllClients`, `drn_fnc_CL_SetDebugMarkerAllClients`, `drn_fnc_CL_DeleteDebugMarkerAllClients`; inline `_fnc_FindSpawnSegment`, `drn_fnc_MilitaryTraffic_MoveVehicle`.
- **Called by:** `Code/functions/Server/fn_initServer.sqf:399` (Opfor) and `:400` (Ind) — LIVE `spawn drn_fnc_MilitaryTraffic`; also `:681` `["A3E_FNC_MilitaryTraffic"] call A3E_FNC_Chronos_Register` (registers the A3E-native Spawning version, not this one). Multiple callers.
- **Processing:** Map-size distance tuning; 3-min delay for non-civilian; define the recursive `MoveVehicle` waypoint-cycler; loop: find a valid off-road-clear spawn road segment at range, compute an outbound destination + facing direction, spawn the vehicle, name it, start it moving, track it; then delete vehicles beyond max distance with no players aboard.
- **Theory of operation:** Fills the road network with plausible traffic that appears/vanishes around the player bubble; the `nearestTerrainObjects`/`nearObjects` clearance check (line 174-187) prevents spawning inside obstacles.
- **Whys & questions:** Why does DRN MilitaryTraffic run LIVE (399/400) while a parallel A3E `Spawning/fn_MilitaryTraffic.sqf` is ALSO registered with Chronos (681)? Two traffic systems concurrently — clear duplication (RD-018). The 180s hardcoded delay (line 66) is undocumented.
- **Unresolved issues:** **DRN-vs-A3E duplication** with `Spawning/fn_MilitaryTraffic.sqf` — strongest candidate for the RD-018 "two systems" concern; confirm which is intended. `_minSkill/_maxSkill` params are effectively unused (crew-skill loop is empty, line 344-349). Commented-out civilian/faction branches (line 308-314). Heavy per-tick `nearestTerrainObjects` cost.
- **Reforger port notes:** TBD — legacy; ambient traffic maps to a Reforger road-traffic/ambient system; do not port both DRN and A3E versions.

### drn_fnc_MonitorEmptyGroups  —  `Code/functions/DRN/fn_MonitorEmptyGroups.sqf`  ·  _status: documented_
- **Purpose:** Debug/diagnostic loop that reports total groups, empty groups, and total unit count whenever those counts change. (whole file)
- **Inputs:** No params. Requires CommonLib (nag if missing). Runs anywhere (no isServer guard).
- **Outputs:** No return (infinite loop). Side effect: broadcasts a diagnostics string via `drn_fnc_CL_ShowDebugTextAllClients`.
- **Calls:** `drn_fnc_CL_ShowDebugTextAllClients` (leaf otherwise).
- **Called by:** **No `fnc_` references found in xref — dead/unused** diagnostic tool (never wired in). Candidate dead-code.
- **Processing:** Every 5s, count `allGroups`, count empty ones, and if either differs from last tick, print `Total groups / Empty groups / Total units`.
- **Theory of operation:** A group-leak watchdog for debugging the spawn/despawn systems (empty groups are a known Arma memory concern).
- **Whys & questions:** Was likely used during DRN development to catch group leaks; superseded by A3E's own group cleanup (`fn_MonitorGroups`/deactivate paths) if any.
- **Unresolved issues:** **Dead code** — not called anywhere; keep or delete decision for the port. No debug-gate (always prints if CommonLib present).
- **Reforger port notes:** TBD — legacy diagnostic; not needed in the port (drop).

### drn_fnc_MotorizedSearchGroup  —  `Code/functions/DRN/fn_MotorizedSearchGroup.sqf`  ·  _status: documented_
- **Purpose:** Drive a mounted search group to a search-area marker, dismount/mount as appropriate, patrol the area, and engage detected enemies — a full mount/move/engage state machine. (whole file)
- **Inputs:** `_this select 0/1` = vehicle, search-area marker name. Reads `A3E_Debug`. Requires CommonLib. Server-only.
- **Outputs:** No return (runs until vehicle destroyed + no soldiers). Side effects: creates garbage groups for dead units, adds/reroutes waypoints, sets group behaviour/formation, hands dead/abandoned units to CommonLib garbage collector.
- **Calls:** `drn_fnc_CL_ShowDebugTextAllClients`, `drn_fnc_CL_GetRandomMarkerPos`, `drn_fnc_CL_PositionIsInsideMarker`, `drn_fnc_CL_AddUnitsToGarbageCollector`, `drn_fnc_CL_SetDebugMarkerAllClients`, `drn_fnc_CL_DeleteDebugMarkerAllClients`; inline helpers (`_fnc_isMounted`, `_fnc_isUnMounted`, `_fnc_ClearAllWaypoints`, `_fnc_GetKnownEnemyPosition`, `_fnc_SetNewState`).
- **Called by:** `Code/Scripts/Escape/CreateMotorizedSearchGroup.sqf:66` (`spawn drn_fnc_MotorizedSearchGroup`). One caller (external Escape script). LIVE search mechanic.
- **Processing:** Wait for search marker; determine walk-vs-drive; large state machine (`READY / BEGIN MOUNT|UNMOUNT / MOUNTING / UNMOUNTING / BEGIN MOVE / BEGIN ENGAGE / MOVING / ENGAGING`) that picks destinations inside the marker, mounts if far, walks if near, engages on `findNearestEnemy`, abandons the vehicle if immobilized, and resets if stationary too long.
- **Theory of operation:** Motorized counterpart to SearchGroup — reinforcements can drive to the players' last-known area, then dismount for infantry search, giving the AI hunt a mounted phase.
- **Whys & questions:** `_fnc_GetKnownEnemyPosition` relies on `nearTargets` accuracy < 100 (line 95) — tuning value; why 100? Duplicate `addWaypoint` (line 434-435) looks accidental.
- **Unresolved issues:** Duplicate waypoint add (line 434-435) — candidate BUG (harmless but wasteful). Casing: `_fnc_IsUnMounted`/`_fnc_IsMounted` (line 460/470) vs the defined `_fnc_isUnMounted` — case-insensitive so OK (RD-008). Hard CommonLib dependency. Overlaps A3E `AI/fn_Search*` behaviors.
- **Reforger port notes:** TBD — legacy; motorized search maps to a Reforger AI hunt/mounted-patrol behavior.

### drn_fnc_MoveInfantryGroup  —  `Code/functions/DRN/fn_MoveInfantryGroup.sqf`  ·  _status: documented_
- **Purpose:** Give an infantry group a single random long-range MOVE waypoint (avoiding water) that, on completion, re-invokes the move script to keep the group wandering. (whole file)
- **Inputs:** `_this select 0/1` = a unit (its group is moved), debug flag. Hardcoded `_worldSizeX/Y = 30000`, `_searchRange = 5000`. Server-only.
- **Outputs:** No return. Side effect: adds a waypoint whose completion statement re-runs `Scripts\DRN\AmbientInfantry\MoveInfantryGroup.sqf` (external file) via `execVM`.
- **Calls:** none (leaf); the waypoint statement `execVM`s an external DRN script.
- **Called by:** Only a **commented-out** reference in `Code/functions/DRN/fn_AmbientInfantry.sqf:158` (`//... spawn drn_fnc_MoveInfantryGroup`). **Dead** — AmbientInfantry now uses `A3E_fnc_Patrol` instead (line 160). Superseded.
- **Processing:** Pick a random position within ±5000m of the unit that isn't water; pick a random formation; add a MOVE waypoint with a completion statement that recursively re-invokes the external move script.
- **Theory of operation:** Original DRN wander behavior for ambient infantry; replaced by the A3E patrol system.
- **Whys & questions:** File explicitly begins as active but is bypassed. The completion statement calls the EXTERNAL `.sqf` (not `drn_fnc_MoveInfantryGroup`), so this compiled function and the external file diverge.
- **Unresolved issues:** **Dead / superseded** by `A3E_fnc_Patrol` (RD-018). Hardcoded 30000 world size + comment "This needs to be changed for stratis" (line 7) — stale. `_worldSizeX/Y` computed but unused.
- **Reforger port notes:** TBD — legacy; drop, patrol wander is handled by the A3E patrol behavior.

### drn_fnc_MoveVehicle  —  `Code/functions/DRN/fn_MoveVehicle.sqf`  ·  _status: documented_
- **Purpose:** Give a traffic vehicle a random distant road destination (or a supplied first destination), with a completion statement that re-invokes itself to keep the vehicle driving. (whole file)
- **Inputs:** `_this select 0/1/2` = vehicle, first destination pos (optional), debug. Server-only.
- **Outputs:** No return. Sets random fuel (0.2–0.9). Side effect: adds a MOVE waypoint whose completion statement re-spawns `drn_fnc_MoveVehicle`.
- **Calls:** none (leaf); waypoint statement re-invokes `drn_fnc_MoveVehicle`.
- **Called by:** **No `fnc_` references found in xref — dead/unused.** Superseded by the inline `drn_fnc_MilitaryTraffic_MoveVehicle` defined inside `fn_MilitaryTraffic.sqf` (line 70-105), which does the same thing; and by A3E `Spawning/fn_MilitaryTraffic.sqf`.
- **Processing:** If a first destination is given, use it; else pick one of 8 directional offsets (~5000/7071m) and find road segments there; set random fuel; add a MOVE waypoint that re-spawns this function on completion.
- **Theory of operation:** Recursive "keep driving" primitive for ambient vehicles — the direct ancestor of the inlined MilitaryTraffic mover.
- **Whys & questions:** Why keep a standalone copy when MilitaryTraffic inlines an identical version? Refactor leftover.
- **Unresolved issues:** **Dead / duplicated** (RD-018) — identical logic exists inline in MilitaryTraffic. Hardcoded 5000/7071 offsets don't scale to small maps (unlike MilitaryTraffic's map-size tuning). `_destinationSegment` may be `nil` when `_firstDestinationPos` is supplied yet is dereferenced at line 47 — candidate BUG (only reachable via the supplied-destination path).
- **Reforger port notes:** TBD — legacy; drop, covered by the traffic system.

### drn_fnc_PopulateAquaticPatrol  —  `Code/functions/DRN/fn_PopulateAquaticPatrol.sqf`  ·  _status: documented_
- **Purpose:** Trigger-activation handler that spawns armed patrol boats + crews on water within an aquatic patrol zone and starts each on an aquatic patrol. (whole file)
- **Inputs:** `_this select 0` = zone array `[markerName, pos, groupsCount, boatsArray]`; `_this select 1` = debug. Reads `a3e_arr_AquaticPatrols` (boat classes), `A3E_VAR_Side_Opfor`. Server-only.
- **Outputs:** No return. Writes the spawned boats back into the zone array (`_village set [3, _arrBoats]`) for DepopulateAquaticPatrol to consume. Side effects: spawns boats/crews, runs per-unit spawn callback, starts `A3E_fnc_AquaticPatrol`.
- **Calls:** `a3e_fnc_RandomMarkerPos`, `BIS_fnc_spawnVehicle`, `a3e_fnc_onVehicleSpawn`, `drn_fnc_Escape_OnSpawnGeneralSoldierUnit`, `A3E_fnc_AquaticPatrol`.
- **Called by:** wired via trigger activation statement built in `Code/functions/DRN/fn_InitAquaticPatrols.sqf:65` (`spawn drn_fnc_PopulateAquaticPatrol`). Indirect / trigger-driven. Live only if the aquatic-patrol chain runs (initServer:285 is live).
- **Processing:** Exit if `_groups == 0`; loop `_i = 0.._groups` (inclusive), find a water spawn position in the marker, spawn a random `a3e_arr_AquaticPatrols` boat as Opfor, run spawn callbacks on crew, start `A3E_fnc_AquaticPatrol`, collect the boat; finally store the boat array back into the zone record.
- **Theory of operation:** Presence-triggered sea patrol spawner; pairs with DepopulateAquaticPatrol via the shared zone record.
- **Whys & questions:** Loop is `_i <= _groups` (inclusive) so with `_groups`=1 it spawns 2 boats — off-by-one vs "number of groups"? And `_groups` can be a float from `random 1` (see InitAquaticPatrols).
- **Unresolved issues:** Off-by-one / fractional group count (candidate BUG). Depends on markers possibly never created (InitAquaticPatrolMarkers caller commented out). `_arrBoats set [count,...]` inside loop is fine but `_group`/`_crew` privates not declared. A3E has no direct village-patrol equivalent for boats, so this may be the only sea-patrol path.
- **Reforger port notes:** TBD — legacy; sea patrols would be a Reforger zone-spawn behavior.

### drn_fnc_PopulateLocation  —  `Code/functions/DRN/fn_PopulateLocation.sqf`  ·  _status: documented_
- **Purpose:** Trigger-activation handler that (re)spawns the guards of a guarded location from its persistence record, splitting them into groups, starting patrols, and garrisoning structures. (whole file)
- **Inputs:** `_this select 0..3` = location object, side, max groups count, debug. Location object index 2 = soldierObjects (persistence tuples), index 0 = marker, index 3 = pos. Server-only.
- **Outputs:** No return. Mutates each soldierObject (spawned=true, obj stored). Side effects: creates groups, spawns units at group size `ceil(count/maxGroups)`, sets damage from record, starts `A3E_fnc_Patrol` for group leaders, then spawns `drn_fnc_GarrisonUnits`.
- **Calls:** `drn_fnc_CL_GetRandomMarkerPos`, `drn_fnc_Escape_OnSpawnGeneralSoldierUnit`, `A3E_fnc_Patrol`, `drn_fnc_GarrisonUnits`.
- **Called by:** wired via trigger activation statement in `Code/functions/DRN/fn_InitGuardedLocations.sqf:101` (`spawn drn_fnc_PopulateLocation`). Indirect / trigger-driven. Live only if InitGuardedLocations runs (no fnc caller found — likely dead).
- **Processing:** Compute max group size; iterate soldierObjects; for each not-yet-spawned soldier with damage < 0.75, start a new group when the current one is full, spawn the unit (restoring saved damage), make the first unit of each group a SERGEANT leader with an `A3E_fnc_Patrol` script, and record the object; finally garrison nearby structures.
- **Theory of operation:** Restores a location's defenders from saved state, so casualties persist across activation cycles and the location stays fortified via GarrisonUnits.
- **Whys & questions:** `_soldiertype`/`_markername` passed to GarrisonUnits (line 78) are NOT declared/assigned in this function's scope (lowercase) — they resolve to whatever leaked from a caller or are nil; GarrisonUnits ignores `_soldiertype` anyway. Candidate BUG/RD.
- **Unresolved issues:** Undefined-var passing to GarrisonUnits (line 78) — `_soldiertype` and `_markername` are never set here (the local is `_markerName` with capital N) — RD-008 casing plus a genuine nil-arg smell. **Likely dead/superseded** (guarded-location chain has no live caller). A3E equivalent: `Spawning/fn_populateLocationZone.sqf`.
- **Reforger port notes:** TBD — legacy; location population + persistence maps to a Reforger zone/faction spawn system.

### drn_fnc_PopulateVillage  —  `Code/functions/DRN/fn_PopulateVillage.sqf`  ·  _status: documented_
- **Purpose:** Trigger-activation handler that (re)spawns a village's patrol groups from its persistence records and starts patrols for group leaders. (whole file)
- **Inputs:** `_this select 0` = village array `[markerName, pos, groups, side]`; `_this select 1` = debug. Each group entry `[soldiers, side]`; each soldier a persistence tuple `[type, damage, spawned, obj, ?, pos, skill, ammo, rank, hasScript]`. Server-only.
- **Outputs:** No return. Mutates soldier tuples (spawned=true, obj stored). Side effects: creates one group per village-group, spawns units at saved positions with saved damage/rank, starts `A3E_fnc_Patrol` for SERGEANT leaders, runs `drn_fnc_VillagePatrols_OnSpawnGroup` per group.
- **Calls:** `A3E_fnc_Patrol`, `drn_fnc_VillagePatrols_OnSpawnGroup`.
- **Called by:** **No `fnc_` references found in xref — dead/unused, or wired only from an external `Scripts/DRN/...VillagePatrols` path.** Superseded by A3E `Spawning/fn_populateVillageZone.sqf` (+ `Spawning/fn_initVillages.sqf`, `Zones/`).
- **Processing:** Exit if no groups; per village-group create a group of its side; per soldier not-yet-spawned with damage < 0.75, reset marker pos, spawn the unit at its saved position with saved damage/rank, and if the unit's rank is SERGEANT start an `A3E_fnc_Patrol` script; then run the village-patrol spawn callback and stagger.
- **Theory of operation:** Same persistence/lazy-spawn pattern as PopulateLocation, one nesting level deeper (village → groups → soldiers).
- **Whys & questions:** Reads soldier fields at magic indices (0,1,2,5,6,8) that differ from the location tuple layout — two incompatible soldier-record schemas in the same library (data-format drift).
- **Unresolved issues:** **Dead / superseded** by A3E village-zone population (RD-018). Magic-index soldier schema differs from PopulateLocation's — confusing, undocumented. Depends on `drn_fnc_VillagePatrols_OnSpawnGroup` being set elsewhere.
- **Reforger port notes:** TBD — legacy; drop for the Reforger equivalent of the A3E village-zone system.

### drn_fnc_SearchChopper  —  `Code/functions/DRN/fn_SearchChopper.sqf`  ·  _status: documented_
- **Purpose:** Fly a helicopter to loiter/search a moving search-area marker, then return home to refuel and repeat — a hunt-from-the-air behavior. (header lines 1-2)
- **Inputs:** `_this select 0..4` = chopper, search-area marker, search time (min), refuel time (min), debug. Requires CommonLib (`a3e_var_commonLibInitialized`). Runs where spawned (no isServer guard).
- **Outputs:** No return (state loop until chopper dead). Side effects: adds waypoints (idle CYCLE box, move-out, LOITER search, return, land), sets fuel, spawns debug smoke. Uses chopper var `waypointFulfilled`.
- **Calls:** `A3E_fnc_DebugMsg`, `drn_fnc_CL_MarkerExists`, `drn_fnc_CL_GetRandomMarkerPos`.
- **Called by:** `Code/Scripts/Escape/CreateSearchChopper.sqf:79` and `Code/Scripts/Escape/EscapeSurprises.sqf:264` (`spawn DRN_fnc_SearchChopper`). Two callers (external Escape scripts). LIVE aerial-hunt mechanic.
- **Processing:** State machine `IDLE → READY → MOVING OUT → SEARCHING → RETURNING → LANDING → REFUELING → (READY)`; inner monitor loop advances state on death, waypoint fulfillment, landing, refuel timeout, or search-time expiry. LOITER circles the search marker at random height/radius; RETURNING re-groups and flies home.
- **Theory of operation:** Provides persistent aerial search pressure that tracks the (moving) search-area marker set by the searchleader system, cycling out to refuel so it never simply lands and stops.
- **Whys & questions:** `_updateSearchAreaTime` (line 24) is set but unused. Uses `A3E_fnc_DebugMsg` unconditionally in some cases (line 141/149) but `_debug`-gated in others — inconsistent.
- **Unresolved issues:** Some debug prints ignore `_debug` (line 141, 149) — minor RD. No isServer guard (relies on caller being server). Hard CommonLib dependency. Author header credits "Engima of Östgöta Ops".
- **Reforger port notes:** TBD — legacy; aerial search maps to a Reforger helicopter-AI hunt behavior.

### drn_fnc_SearchGroup  —  `Code/functions/DRN/fn_SearchGroup.sqf`  ·  _status: documented_
- **Purpose:** Make an infantry group move to a search-area marker and patrol it, dynamically creating a sub-search-area around any spotted enemy and engaging — the core on-foot AI-hunt behavior. (header lines 1-10)
- **Inputs:** `param [0..3]` = group, search-area marker name, first position (def [0,0,0]), debug. Requires CommonLib (`waitUntil`). Server-only.
- **Outputs:** No return (loop until group empty). Side effects: `_group move`, sets behaviour/formation/combatMode/speed, creates/moves/deletes a local sub-search-area marker, hands dead units to CommonLib garbage collector, spawns a debug marker thread.
- **Calls:** `drn_fnc_CL_ShowDebugTextAllClients`, `drn_fnc_CL_MarkerExists`, `drn_fnc_CL_GetRandomMarkerPos`, `drn_fnc_CL_PositionIsInsideMarker`, `drn_fnc_CL_AddUnitsToGarbageCollector`, `drn_fnc_CL_SetDebugMarkerAllClients`, `drn_fnc_CL_DeleteDebugMarkerAllClients`.
- **Called by:** `Code/functions/Server/fn_initServer.sqf:312` (`spawn drn_fnc_searchGroup`), plus `Code/Scripts/Escape/CreateCivilEnemy.sqf:41`, `CreateReinforcementTruck.sqf:74`, `EscapeSurprises.sqf:172` & `:218`. Five callers. Heavily LIVE — the primary foot-search behavior.
- **Processing:** Wait for marker; state machine `TRANSPORTING → SEARCHING → ENGAGING`; inner move-monitor loop garbage-collects dead members, detects `findNearestEnemy`, on first contact switches to ENGAGING, on lost contact creates/moves a 100m sub-search-area marker and searches it for `_subAreaSearchTimeSec` (180s) before returning to the main area; a stationary-timeout picks a new destination.
- **Theory of operation:** Turns "an enemy was seen here" into a spreading, self-directing infantry sweep with a shrinking sub-area around the last sighting — the workhorse behind the mission's search escalation.
- **Whys & questions:** `param [1,grpNull]` default for a marker NAME (should be a string/`""`, not `grpNull`) — mismatched default type (line 21). Why 180s/100m tuning? Interaction with the newer `SearchLeader/` category needs mapping.
- **Unresolved issues:** `grpNull` default for the marker-name param (line 21) is a type smell (candidate BUG, though callers always supply it). Hard CommonLib dependency. Overlaps with A3E `SearchLeader/` and `AI/fn_Search*` — this DRN behavior is still the low-level "go search this marker" primitive they build on.
- **Reforger port notes:** TBD — legacy; the search/sub-area escalation is a strong candidate to reimplement as a Reforger AI hunt behavior (concept worth preserving even if code is rewritten).

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-07-02 | Claude | Documented all entries |
