# Code Reference — Server
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Server-side init and mission management (procedural placement, extraction, traps, faction load). One entry per source file in `Code/functions/Server/`. Fields were stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_CreateCrashSites  —  `Code/functions/Server/fn_CreateCrashSites.sqf`  ·  _status: documented_
- **Purpose:** Places 1..N downed-vehicle crash sites at random flat locations as lootable/objective points of interest.
- **Inputs:** No params. Global read: `CrashSiteCountMax` (missionNamespace, default 3).
- **Outputs:** No return. Side effects: spawns `_crashSiteCount = ceil(random CrashSiteCountMax)` crash-site objects (each via a spawned thread).
- **Calls:** `A3E_fnc_findFlatArea` (`:3`), `A3E_fnc_crashSite` (`:4`, spawned — a Templates function).
- **Called by:** `fn_initServer.sqf:231` (`[] call A3E_fnc_createCrashSites`), inside the `[] spawn {…}` placement block. (See _xref Server.)
- **Processing:** Compute count from `CrashSiteCountMax`; loop 1..count; each iteration finds a flat area and spawns a crash site there.
- **Theory of operation:** Crash sites are optional POIs sprinkled around the map at mission start. `random` gives a per-session variable count so playthroughs differ.
- **Whys & questions:** `ceil(random N)` yields 1..N (0 only if random returns exactly 0). Duplicates logic inline in `fn_initServer.sqf:432-436` (the disabled legacy branch), which is the same loop but calls `A3E_fnc_crashSite` with `call` instead of `spawn`.
- **Unresolved issues:** Minor duplication with the dead legacy block in initServer (RD candidate). No min-count/exclusion-zone/clearance checks — crash sites can land near other placements (unlike depots/comcenters which check `A3E_Var_ClearedPositions`).
- **Reforger port notes:** TBD — maps to a procedural POI spawner over navmesh-valid flat terrain in Enfusion.

### a3e_fnc_CreateExtractionPoint  —  `Code/functions/Server/fn_CreateExtractionPoint.sqf`  ·  _status: documented_
- **Purpose:** Materializes the physical extraction point at a chosen marker: helipads + a "bacon" object carrying a `firedNear` event handler that triggers the actual evac when players throw smoke/flare nearby.
- **Inputs:** `params["_markerNo","_extractionType"]` where type ∈ {"air","sea","land","old"}. Reads marker positions named by type + number.
- **Outputs:** No return. Side effects: creates two `Land_HelipadEmpty_F` and one `Land_TacticalBacon_F` via `createVehicle`; attaches a compiled `firedNear` EH to the bacon; diag_log traces.
- **Calls:** none directly (leaf); the compiled EH string wires to `A3E_fnc_firedNearExtraction` at runtime (`:32`).
- **Called by:** `fn_SelectExtractionZone.sqf:117`.
- **Processing:** Switch type→marker-type prefix; build marker names `<prefix><no>` and `<prefix><no>_1`; create helipads at both and a bacon at the first; compile `[markerNo,"type",_this] call A3E_fnc_firedNearExtraction` and add it as the bacon's `firedNear` handler.
- **Theory of operation:** The bacon acts as a proximity fired-event sensor: any nearby weapon/thrown fire raises `firedNear`, letting a smoke grenade signal "call the evac". Uses `compile format` to bake the marker number and type into the handler.
- **Whys & questions:** Why a "TacticalBacon" prop as the sensor? Presumably a small always-present object with a `firedNear` EH. `"old"` retained for backward-compat with legacy single-type markers.
- **Unresolved issues:** `compile format` string dispatch is invisible to static xref (RD-006 pattern). Two helipads created but only the bacon carries the handler; `_location`/`_location2` are otherwise unused decoration.
- **Reforger port notes:** TBD — replace `firedNear` EH + bacon with an Enfusion trigger/area sensor reacting to smoke/signal items.

### a3e_fnc_FindSpawnRoad  —  `Code/functions/Server/fn_FindSpawnRoad.sqf`  ·  _status: documented_
- **Purpose:** Finds a random road segment within a ring (min..max spawn distance) around the players — a spawn anchor for ambient/road-based spawns.
- **Inputs:** No params. Globals read: `MinSpawnDistance` (def 1500), `MaxSpawnDistance` (def 2000). Uses player group + a random player as reference.
- **Outputs:** Returns a road segment object (`objNull` if none found within 25 tries).
- **Calls:** `A3E_fnc_getPlayerGroup` (`:1`), `A3E_fnc_getRandomPlayer` (`:7`).
- **Called by:** `Scripts/Escape/EscapeSurprises.sqf:129,331,348` (surprise-spawn script).
- **Processing:** Up to 25 tries: pick random bearing, offset a reference point by `(min + diff)` distance, `nearRoads diff`, pick a random segment, then validate every group member is within `[min,max]` of it (reject if too close or if all too far). Return the segment when OK.
- **Theory of operation:** Keeps spawns on roads at a tactical distance band from the squad — near enough to matter, far enough not to spawn on top of players.
- **Whys & questions:** Offset uses `(_minSpawnDistance + _spawnDistanceDiff)` = `_maxSpawnDistance`, so the search center sits at max distance and `nearRoads diff` sweeps inward — effectively a ring. `_isOk = true` is set twice (line 12 and 43); redundant but harmless.
- **Unresolved issues:** Potential returns `objNull` silently on failure; callers must handle. Redundant `_isOk=true` assignment (style noise).
- **Reforger port notes:** TBD — maps to querying road entities / navmesh road links around players in Enfusion.

### a3e_fnc_InitVillageMarkers  —  `Code/functions/Server/fn_InitVillageMarkers.sqf`  ·  _status: documented_
- **Purpose:** Loads the island's village-marker definitions and creates local map markers for each village zone.
- **Inputs:** Called with `[true]` but ignores its arg (no `params`). Reads `Island\VillageMarkers.sqf` (island-specific) which defines `a3e_villageMarkers`; reads `A3E_Debug`.
- **Outputs:** No return. Side effects: creates local markers `drn_villageMarker<i>` (shape/dir/size from data, alpha 0 unless debug); sets `a3e_var_villageMarkersInitialized = true`. Errors via `BIS_fnc_error` if markers missing.
- **Calls:** `BIS_fnc_error` (`:6`, only on failure). Duplicate-name function (also exists in Common/ and DRN/) — see _xref duplicate list.
- **Called by:** `fn_initServer.sqf:205` (`[true] call A3E_fnc_InitVillageMarkers`).
- **Processing:** Preprocess+compile the island village-marker file; if server and `a3e_villageMarkers` defined, iterate creating a local marker per `[pos,dir,shape,size]` entry, hiding unless debug.
- **Theory of operation:** Village zones drive civilian/patrol population; these markers are the geometric anchors. `createMarkerLocal` because they're only needed for local spawn logic/debug display.
- **Whys & questions:** Three files share the name `initvillagemarkers` (Common, DRN, Server) — which is the live one? The Server one is the one initServer calls (RD-008 casing/dup concern). Passed `[true]` but arg unused — legacy signature.
- **Unresolved issues:** Name collision across three categories (RD candidate; also flagged as _xref duplicate). Uninitialized `private` list (`_showMarkers`, `_markerName`, `_villageIndex`) declared then used — fine in SQF.
- **Reforger port notes:** TBD — village anchors become config/prefab-driven area entities in Enfusion.

### a3e_fnc_RoadBlocks  —  `Code/functions/Server/fn_RoadBlocks.sqf`  ·  _status: documented_
- **Purpose:** Spawns a single enemy/independent roadblock (template geometry + manned vehicles + static guns + garrison zone) at a random road position within a ring, up to a max count.
- **Inputs:** No `params` (ignores caller args). Globals read: `A3E_MinRoadblockSpawnDistance` (1500), `A3E_MaxRoadblockSpawnDistance` (2000), `A3E_MinRoadblockDistance` (1500), `A3E_MaxNumberOfRoadblocks` (15), `A3E_RoadBlocks`, `A3E_RoadblockTemplates`, faction weapon/vehicle arrays, `a3e_arr_ComCenStaticWeapons`, `A3E_Zones`.
- **Outputs:** No return. Side effects: restores an iso-template of clutter, creates a location marker, inits a location zone, spawns manned vehicles + static gunners, appends position to `A3E_RoadBlocks` global. Logs via `A3E_fnc_Log`.
- **Calls:** `A3E_fnc_Log`, `a3e_fnc_getCircularSpawnPos`, `BIS_fnc_DirTo`, `a3e_fnc_IsoTemplateRestore`, `a3e_fnc_createLocationMarker`, `A3E_fnc_initLocationZone`, `BIS_fnc_spawnVehicle`, `a3e_fnc_onVehicleSpawn`, `a3e_fnc_onEnemyGroupSpawn`, `a3e_fnc_onEnemySoldierSpawn`, `A3E_fnc_AddStaticGunner`.
- **Called by:** Chronos-registered at `fn_initServer.sqf:679` (`["A3E_FNC_RoadBlocks"] call A3E_FNC_Chronos_Register`) — fires periodically. Also `spawn`ed once directly in the disabled legacy block at `fn_initServer.sqf:428`.
- **Processing:** Bail if at max or if position/road/connectivity checks fail; compute facing from connected road, flip 180° half the time; restore template clutter; drop marker; init a 30m ROADBLOCK zone; spawn manned vehicles and static gunners for the chosen side, registering each via the on*Spawn hooks and pushing groups into the zone; record the block position.
- **Theory of operation:** Runs on the Chronos scheduler so roadblocks accrete over time up to a cap, spaced apart, giving a living-world checkpoint feel. Side chosen mostly Independent (3:1 vs Opfor) via `_factionsArray`.
- **Whys & questions:** `_connectedRoad` (`:30`) is assigned but never used. Static-gun loop guards on `count(a3e_arr_ComCenStaticWeapons) > 0` but the roadblock reuses ComCen static weapons — intentional sharing.
- **Unresolved issues:** Dead local `_connectedRoad` (RD candidate). No cleanup/despawn of roadblocks over time (they persist). Zone `groups` array read via `getordefault` then re-`set` — fine.
- **Reforger port notes:** TBD — checkpoint prefab + AI garrison placed on road network in Enfusion; Chronos cadence → scheduled system tick.

### a3e_fnc_RunExtraction  —  `Code/functions/Server/fn_RunExtraction.sqf`  ·  _status: documented_
- **Purpose:** Runs the legacy ("old") air-extraction sequence: spawns 2 evac choppers + 1 escort, flies them in, plays radio chatter, waits for all players to board, then flags mission complete / left-behind.
- **Inputs:** `params["_extractionPointNo",["_isWater",false]]` (`_isWater` unused). Reads `A3E_ExtractionPositions`, markers `A3E_Extraction*Pos<no>`, `a3e_arr_extraction_chopper(_escort)`, `A3E_VAR_Side_Blufor`. Server-only.
- **Outputs:** Side effects: spawns 3 aircraft + groups; sets public `A3E_EvacHeli1..3`, `A3E_Task_Exfil_Complete`; sets `a3e_var_Escape_MissionComplete` OR `a3e_var_Escape_MissionFailed_LeftBehind` (public); manipulates the extraction goal marker; radio via `sideChat` remoteExec.
- **Calls:** `BIS_fnc_spawnVehicle`, `A3E_fnc_ExtractionChopper` (spawned, `:31-32`), `A3E_fnc_GetPlayers`, `drn_fnc_CL_ShowTitleTextAllClients`, `sideChat` (remoteExec).
- **Called by:** `fn_firedNearExtraction.sqf:28` (case `"old"`), spawned.
- **Processing:** Compute spawn vector from spawn-marker→extraction-marker; spawn two choppers driven by `A3E_fnc_ExtractionChopper` toward the two landing markers, plus an escort set to LOITER; publish evac vehicles; run inline `_heloGuard`/`_extractionGuard` watchdog threads for damage chatter and "both birds down" marker update; wait until all players are aboard boat1/boat2; announce; wait 35s; complete if everyone still aboard else left-behind.
- **Theory of operation:** The evac is a scripted set-piece; the two boarding vehicles + escort provide cover. `A3E_fnc_ExtractionChopper` handles the actual approach/land/takeoff flight AI. Boarding is polled by counting players inside the two evac craft.
- **Whys & questions:** Local vars named `_boat1/_boat2/_boat3` though they're helicopters — copy-paste from a boat variant (naming noise). `_group3` escort uses LOITER radius 500. Comment "Verkar inte funka" (Swedish: "doesn't seem to work") on the LightOff action.
- **Unresolved issues:** Near-verbatim duplication with `fn_RunExtractionHeli.sqf` (RD candidate — see that entry). `driver` may be null if chopper spawns damaged (guarded in places, not all). Heavy code duplication across the four RunExtraction* runners.
- **Reforger port notes:** TBD — evac is a scripted vehicle behavior; port as a state-machine flight/board/depart sequence.

### a3e_fnc_RunExtractionBoat  —  `Code/functions/Server/fn_RunExtractionBoat.sqf`  ·  _status: documented_
- **Purpose:** Runs the sea-extraction sequence: 2 evac boats + 1 escort boat, board-and-flee, mission-complete/left-behind flagging.
- **Inputs:** `params["_extractionPointNo"]`. Reads `A3E_ExtractionPositions`, `A3E_BoatExtraction*Pos<no>` markers, `a3e_arr_extraction_boat(_escort)` (with hardcoded fallbacks by Blufor side), `A3E_VAR_Side_Blufor`. Server-only.
- **Outputs:** Same public flags/vars as RunExtraction (`A3E_EvacHeli1..3` reused for boats, `A3E_Task_Exfil_Complete`, `a3e_var_Escape_MissionComplete`/`_MissionFailed_LeftBehind`); marker updates; radio chatter.
- **Calls:** `BIS_fnc_spawnVehicle`, **`A3E_fnc_ExtractionCar`** (spawned, `:41-42` — see bug), `A3E_fnc_GetPlayers`, `drn_fnc_CL_ShowTitleTextAllClients`, `sideChat`.
- **Called by:** `fn_firedNearExtraction.sqf:20` (case `"sea"`), spawned.
- **Processing:** Optional fallback boat classes if `a3e_arr_extraction_boat` empty; compute spawn vector; spawn two evac boats driven by `A3E_fnc_ExtractionCar` + one escort boat set to SAD; publish; run `_heloGuard`/`_extractionGuard` watchdogs (sink chatter); wait until all players aboard boat1/2/3; announce; wait 35s; complete-or-left-behind.
- **Theory of operation:** Boat variant of the evac set-piece; escort uses SAD (search-and-destroy) rather than LOITER.
- **Whys & questions:** Uses `A3E_fnc_ExtractionCar` as the boat driver (see below) — presumably works because ExtractionCar just drives to a point, but a boat-specific driver would be more correct. Reuses `A3E_EvacHeli*` variable names for boats.
- **Unresolved issues:** **BUG-016 confirmed:** lines 41-42 spawn `A3E_fnc_ExtractionCar` for the extraction boats (should be a boat/aquatic extraction driver). This is a real cross-variant copy-paste error. Also the boarding wait counts boat1/2/3 but Evac-state is only set on boat1/2. Heavy duplication with other runners.
- **Reforger port notes:** TBD — same as RunExtraction; boat navigation over water.

### a3e_fnc_RunExtractionCar  —  `Code/functions/Server/fn_RunExtractionCar.sqf`  ·  _status: documented_
- **Purpose:** Runs the land (vehicle) extraction: 2 evac cars + 1 escort, board-and-flee, complete/left-behind flagging.
- **Inputs:** `params["_extractionPointNo"]`. Reads `A3E_ExtractionPositions`, `A3E_CarExtraction*Pos<no>` markers, `a3e_arr_extraction_car(_escort)`, `A3E_VAR_Side_Blufor`. Server-only.
- **Outputs:** Same public flags/vars as the other runners (`A3E_EvacHeli1..3` reused for cars, task/mission flags), marker updates, radio chatter.
- **Calls:** `BIS_fnc_spawnVehicle`, `A3E_fnc_ExtractionCar` (spawned, `:31-32` — correct here), `A3E_fnc_GetPlayers`, `drn_fnc_CL_ShowTitleTextAllClients`, `sideChat`.
- **Called by:** `fn_firedNearExtraction.sqf:24` (case `"land"`), spawned.
- **Processing:** Identical structure to RunExtractionBoat but with car class arrays; escort uses SAD; wait for all players in car1/2/3; announce; 35s; complete/left-behind.
- **Theory of operation:** Land variant of the evac set-piece; `A3E_fnc_ExtractionCar` drives the two evac vehicles to their landing markers.
- **Whys & questions:** This is the "canonical" ExtractionCar caller — RunExtractionBoat copied it but forgot to swap the driver. Group callsigns "Angel One/Two/Shepherd".
- **Unresolved issues:** Heavy duplication with Boat/Heli/RunExtraction runners (RD candidate — the four could share one parameterized runner). `driver` null-safety same caveat.
- **Reforger port notes:** TBD.

### a3e_fnc_RunExtractionHeli  —  `Code/functions/Server/fn_RunExtractionHeli.sqf`  ·  _status: documented_
- **Purpose:** Runs the air (helicopter) extraction — the modern "air" type, functionally identical to legacy `RunExtraction`.
- **Inputs:** `params["_extractionPointNo",["_isWater",false]]` (`_isWater` unused). Reads `A3E_HeliExtraction*Pos<no>` markers, `a3e_arr_extraction_chopper(_escort)`, `A3E_VAR_Side_Blufor`. Server-only.
- **Outputs:** Same public flags/vars as RunExtraction; marker updates; radio chatter.
- **Calls:** `BIS_fnc_spawnVehicle`, `A3E_fnc_ExtractionChopper` (spawned, `:31-32`), `A3E_fnc_GetPlayers`, `drn_fnc_CL_ShowTitleTextAllClients`, `sideChat`.
- **Called by:** `fn_firedNearExtraction.sqf:16` (case `"air"`), spawned.
- **Processing:** Byte-for-byte the same flow as `fn_RunExtraction.sqf` except marker prefixes are `A3E_HeliExtraction*` instead of `A3E_Extraction*`.
- **Theory of operation:** Air evac set-piece; the only difference from the legacy runner is which marker-name family it reads.
- **Whys & questions:** Why keep both `RunExtraction` (old) and `RunExtractionHeli` (air)? Backward-compat: legacy islands only have `A3E_ExtractionPos*` markers, newer ones have typed `A3E_HeliExtractionPos*`.
- **Unresolved issues:** Near-identical duplicate of `fn_RunExtraction.sqf` (RD candidate). Same `_boat*` misnaming and "Verkar inte funka" comment carried over.
- **Reforger port notes:** TBD — merge the four runners into one data-driven evac system in the port.

### a3e_fnc_SelectExtractionZone  —  `Code/functions/Server/fn_SelectExtractionZone.sqf`  ·  _status: documented_
- **Purpose:** After the COM-center hack, discovers all extraction markers on the map, picks one (by mode/proximity), marks it as the evac goal, and instantiates its extraction point.
- **Inputs:** `params[["_hackPos",[0,0,0]],["_select",-1]]`. Reads `A3E_Param_ExtractionSelection` (mode 0/1/2), `a3e_arr_extractiontypes`, `A3E_MinComCenterDistance`, `A3E_Debug`, `allMapMarkers`.
- **Outputs:** Builds/caches `A3E_{Old,Heli,Boat,Car}ExtractionPositions` and `A3E_ExtractionPositions`; sets `a3e_var_Escape_ExtractionMarkerPos` (public), `A3E_Task_ComCenter_Complete` (public); creates the green `a3e_extractionGoalMarker*`; radio message. Returns nothing meaningful (last stmt is remoteExec).
- **Calls:** `A3E_fnc_CheckCampDistance` (`:16`), `A3E_fnc_CreateExtractionPoint` (`:117`), `sideChat` (remoteExec).
- **Called by:** `fn_hijack.sqf:56` — `remoteExec ["A3E_fnc_SelectExtractionZone",2]` (executed on server when the generator/COM center is hijacked).
- **Processing:** Inner `_findMarkers` scans `allMapMarkers` for a name prefix (excluding `_1` twins), records `[no,pos,clearFlag,usedFlag,goalMarker,type]` and clears each of `CheckCampDistance`; lazily populate per-type position arrays; assemble `A3E_ExtractionPositions` per `a3e_arr_extractiontypes`; select a candidate (explicit `_select`, random, near `_hackPos`, or far from it depending on mode); mark used; drop goal marker; call `CreateExtractionPoint`; announce evac coords.
- **Theory of operation:** Decouples "which extraction marker" (this) from "spawn the evac craft" (CreateExtractionPoint→firedNearExtraction→RunExtraction*). Mode lets missions bias evac near/far from the hack point for pacing.
- **Whys & questions:** Comment notes range hardcoded (`*2`) rather than a param. `_select > 0` branch first `selectRandom`s then overrides via loop — the initial random is wasted if a match is found.
- **Unresolved issues:** If fewer than 6 typed positions, it appends old markers as fallback (`:63`). Marker discovery via string-prefix matching is fragile if islands misname markers. `_extraction` could be `[]`/nil if no positions at all — no guard before `set [3,true]`.
- **Reforger port notes:** TBD — extraction markers → placed extraction area entities; selection logic ports directly.

### a3e_fnc_UpdateLocationMarker  —  `Code/functions/Server/fn_UpdateLocationMarker.sqf`  ·  _status: documented_
- **Purpose:** Reveals or refreshes a point-of-interest map marker (from the `A3E_POIs` registry) — flips "unknown" markers to their real icon, and updates the locate-comcenter task when a COM-center is revealed.
- **Inputs:** `params["_markername",["_reveal",false]]`. Reads global `A3E_POIs`.
- **Outputs:** Returns `_what` (the resulting marker type string). Side effects: mutates the POI entry (`set [4,...]`, `[5,...]`), sets marker type/pos/color/alpha; may set `A3E_Task_LocateComcenter_Complete` public.
- **Calls:** none (leaf). Reads/writes marker + POI array only.
- **Called by:** `fn_RevealPOI.sqf:11` (Intel), and trigger-activation strings compiled in `fn_createLocationMarker.sqf:24,36` (`[<marker>,true] spawn A3E_fnc_UpdateLocationMarker`).
- **Processing:** Look up POI by marker name; unpack `[marker,type,color,pos,hidden,unknown,accuracy]`; if hidden & not revealing → show a red "hd_unknown" at a jittered position; if (not hidden & unknown) OR reveal → set the real type/pos/color, clear hidden/unknown, and (for `o_hq`) complete the locate task; else warn "already known".
- **Theory of operation:** POIs progress unknown→revealed as players approach (trigger) or gain intel. Jitter on hidden markers gives approximate rather than exact positions until fully revealed.
- **Whys & questions:** Two triggers in `createLocationMarker` both spawn this; the `hidden` vs `unknown` distinction drives the two-stage reveal. The `_poi params` order here matches the 7 leading fields written by `createLocationMarker` (the 8th, `_inIntel`, is ignored here).
- **Unresolved issues:** No `params` re-privatization of `_markername` collision-safe; fine. If POI type isn't `o_hq` there's no other task hookup — expected. Relies on caller passing a valid registered marker.
- **Reforger port notes:** TBD — POI reveal maps to Enfusion map-marker component visibility toggles.

### a3e_fnc_createAmmoDepots  —  `Code/functions/Server/fn_createAmmoDepots.sqf`  ·  _status: documented_
- **Purpose:** Procedurally places `A3E_AmmoDepotCount` ammo depots spread across the map quadrants, avoiding proximity to other cleared placements, then builds each via a random depot template and wraps it in a garrisoned zone.
- **Inputs:** No params, server-only. Globals: `A3E_AmmoDepotCount` (def 8), `A3E_Var_ClearedPositions`, `A3E_ClearedPositionDistance`, `A3E_AmmoDepotTemplates`, static/vehicle class arrays, `center`.
- **Outputs:** Sets `a3e_var_Escape_AmmoDepotPositions` (public); appends to `A3E_Var_ClearedPositions`; builds depots (template dispatch) and inits AMMODEPOT location zones.
- **Calls:** `A3E_fnc_findFlatArea` (`:22`), `A3E_fnc_callRandomFunction` (`:89`, template-array dispatch over `A3E_fnc_AmmoDepot*`), `A3E_fnc_initLocationZone` (`:94`).
- **Called by:** `fn_initServer.sqf:225` (inside the placement `spawn`).
- **Processing:** Quadrant counters (NW/NE/SE/SW) each capped at `ceil(count/4)`; loop until enough positions: repeatedly `findFlatArea`, classify by quadrant vs `center`, reject if that quadrant is full (bail after 100 inner tries); reject if within `A3E_ClearedPositionDistance` of any cleared position; else accept and record. After 100 outer tries, exit early. Then for each position, dispatch a random depot template and init a 60m Opfor zone.
- **Theory of operation:** Quadrant balancing spreads depots so loot isn't clustered; clearance distance keeps depots from overlapping the prison/comcenters. Template-array dispatch gives per-depot visual variety.
- **Whys & questions:** Quadrant cap uses `<=` `_regionCount`, allowing one extra per quadrant. Early-out at `_i>100` returns `_positions` mid-build (before templates run) — the partial list is returned but templating below is skipped in that path.
- **Unresolved issues:** Structural twin of `fn_createMortarSites.sqf` (identical quadrant/clearance loop) — strong RD dedup candidate. The `_i>100 exitWith {_positions}` path returns without building depots/zones (silent partial failure).
- **Reforger port notes:** TBD — depot placement over navmesh + prefab spawn; quadrant spread is a simple distribution rule to reimplement.

### a3e_fnc_createComCenters  —  `Code/functions/Server/fn_createComCenters.sqf`  ·  _status: documented_
- **Purpose:** Builds up to `A3E_ComCenterCount` communication centers at island-defined marker candidates, keeping them ≥ `A3E_MinComCenterDistance` apart and from start, each with a POI marker, patrol marker, garrison zone, and armor.
- **Inputs:** No params, server-only. Globals: `a3e_communicationCenterMarkers` (island), `A3E_ComCenterCount` (def 4), `A3E_MinComCenterDistance` (def 2000), `A3E_StartPos`, static/vehicle arrays, `A3E_ComCenterTemplates`.
- **Outputs:** Sets `a3e_var_Escape_communicationCenterPositions` (public); appends `A3E_Var_ClearedPositions`; builds comcenters, POI + patrol markers, COMCENTER zones; inits comcenter armor via DRN.
- **Calls:** `A3E_fnc_callRandomFunction` (`:46`, over `a3e_fnc_BuildComCenter*`), `A3E_fnc_createLocationMarker` (`:49`), `A3E_fnc_GetPlayerGroup` (`:71`), `A3E_fnc_initLocationZone` (`:66`), `drn_fnc_Escape_InitializeComCenArmor` (`:71`).
- **Called by:** `fn_initServer.sqf:219` (inside the placement `spawn`).
- **Processing:** Shuffle candidate markers; iterate, skipping any within min-distance of an already-placed comcenter or the start; for accepted ones build via random template, record cleared position, create an `o_hq` location marker + a hidden 75m patrol ellipse; stop at count. Then init COMCENTER zones and comcenter armor.
- **Theory of operation:** Comcenters are the primary objective (hack one to unlock extraction); spacing ensures they're spread and reachable. Patrol marker feeds the location-zone population.
- **Whys & questions:** Warns (not errors) if the template array is empty. Uses `createLocationMarker` for the `o_hq` POI so it participates in the reveal system.
- **Unresolved issues:** If island provides fewer usable markers than `A3E_ComCenterCount`, fewer are built silently. `_marker` patrol-ellipse variable name shadows within the loop — fine. No dedup RD as its structure differs from depots/mortars (marker-driven, not flat-area).
- **Reforger port notes:** TBD — comcenter = objective prefab + trigger; armor init ports to a defense-spawn system.

### a3e_fnc_createLocationMarker  —  `Code/functions/Server/fn_createLocationMarker.sqf`  ·  _status: documented_
- **Purpose:** Creates a POI map marker and registers it in `A3E_POIs`, applying the mission's marker-reveal policy (`A3E_Param_RevealMarkers`) — shown, unknown-until-near (proximity trigger), hidden, or empty.
- **Inputs:** `params["_markerName","_markerPosition","_markerType",["_color","ColorRed"],["_hidden",false],["_inIntel",true]]`. Reads `A3E_Param_RevealMarkers`, `A3E_Debug`, `A3E_VAR_Side_Blufor_Str`.
- **Outputs:** No return. Side effects: creates a marker; may create an `EmptyDetector` trigger with a compiled `A3E_fnc_UpdateLocationMarker` activation; pushes an 8-tuple into `A3E_POIs`.
- **Calls:** `A3E_fnc_getPlayers` (`:35`, for trigger attach); compiles `A3E_fnc_UpdateLocationMarker` into trigger statements (`:24,36`).
- **Called by:** `fn_createComCenters.sqf:49`, `fn_RoadBlocks.sqf:48`, and many Templates (AmmoDepot*, MotorPool*, CrashSite, MortarSite*) — see _xref (this is a widely-used helper).
- **Processing:** Create ICON marker; switch on reveal param: 0/debug → show real type immediately; 1 → hd_unknown + a 200m PRESENT trigger for Blufor that reveals on entry; 2/hidden → hidden hd_unknown + a GROUP trigger attached to player[0]; 3 → invisible Empty; >3 → warn. Register `[marker,type,color,pos,hidden,unknown,accuracy,inIntel]`.
- **Theory of operation:** Central marker factory so every placement participates uniformly in the fog-of-war reveal system; triggers lazily reveal markers as players approach.
- **Whys & questions:** Mode 2 attaches the trigger to `getPlayers select 0` — a specific player; if that player leaves/dies does the trigger still work? (JIP/robustness question.) `_accuracy` is always 0 here.
- **Unresolved issues:** Mode-2 trigger bound to a single player object (`:35`) may break the reveal for others if that player disconnects (Q candidate). `compile format` activation strings are xref-invisible (RD-006).
- **Reforger port notes:** TBD — marker reveal policy maps to Enfusion map-marker visibility + area triggers.

### a3e_fnc_createMortarSites  —  `Code/functions/Server/fn_createMortarSites.sqf`  ·  _status: documented_
- **Purpose:** Procedurally places mortar/artillery sites (count scaled by `A3E_Param_Artillery`) across the map quadrants with clearance spacing, building each from a random mortar template inside a garrison zone.
- **Inputs:** No params, server-only. Globals: `A3E_MortarSiteCountMin/Max` (def 4/6, ×`A3E_Param_Artillery`), `A3E_Var_ClearedPositions`, `A3E_ClearedPositionDistance`, `A3E_MortarSiteTemplates`, `center`.
- **Outputs:** No public var set (unlike depots). Side effects: appends `A3E_Var_ClearedPositions`; builds mortar sites (template dispatch) and inits MORTAR zones (Opfor/Ind).
- **Calls:** `A3E_fnc_findFlatArea` (`:29`), `A3E_fnc_callRandomFunction` (`:95`, over `A3E_fnc_MortarSite*`), `A3E_fnc_initLocationZone` (`:96`).
- **Called by:** `fn_initServer.sqf:228` (inside the placement `spawn`).
- **Processing:** Identical quadrant/clearance placement loop as `createAmmoDepots`; count = `min + random(max-min)` after Artillery scaling; then for each position dispatch a random mortar template and init a 40m zone.
- **Theory of operation:** Mortar sites let the search/artillery mechanic shell player positions; quadrant spread and Artillery scaling tune density per mission.
- **Whys & questions:** Mutates the global `A3E_MortarSiteCountMin/Max` in place (multiplies them) rather than a local — if this ran twice the counts would compound. Given single call at init, fine.
- **Unresolved issues:** Structural duplicate of `createAmmoDepots` (RD dedup candidate). In-place multiply of `A3E_MortarSiteCountMin/Max` globals is a latent re-entrancy bug if ever called twice (Q/RD candidate). No public position var (depots publish theirs; mortars don't) — intentional?
- **Reforger port notes:** TBD — mortar site prefab + indirect-fire behavior; Artillery param → density knob.

### a3e_fnc_createMotorPools  —  `Code/functions/Server/fn_createMotorPools.sqf`  ·  _status: documented_
- **Purpose:** Places motor pools (vehicle depots) at leftover comcenter marker candidates, count scaled by map size + enemy frequency, each built from a template and wrapped in a garrison zone.
- **Inputs:** No params, server-only. Globals: `a3e_communicationCenterMarkers`, `A3E_MotorPoolCount`, `A3E_Param_EnemyFrequency`, `A3E_Var_ClearedPositions`, `A3E_ClearedPositionDistance`, `A3E_MotorPoolTemplates`, static/vehicle/armor arrays, `NorthEast`/`SouthWest`.
- **Outputs:** Sets `a3e_var_Escape_MotorPoolPositions` (public); appends `A3E_Var_ClearedPositions`; builds motor pools and inits MOTORPOOL zones.
- **Calls:** `A3E_fnc_getPlayerGroup` (`:78`), `A3E_fnc_callRandomFunction` (`:83`, over `A3E_fnc_BuildMotorPool*`), `A3E_fnc_initLocationZone` (`:85`).
- **Called by:** `fn_initServer.sqf:222` (inside the placement `spawn`).
- **Processing:** Derive `_mpc` from map diagonal (0..5 for <5km..>25km); default count = `floor(random _mpc)+EnemyFrequency`; consume a shuffled copy of comcenter markers, accepting those not within clearance of a cleared position, until count reached or markers exhausted; then build each with `dir-180` orientation (hardcoded), init a 70m zone.
- **Theory of operation:** Motor pools reuse comcenter marker locations (so they sit at plausible military sites), scaled to map size so bigger islands get more vehicle depots.
- **Whys & questions:** `// Fixme: hard coding to 180° orientation` acknowledges a hack. `_playergroup` (`:78`) is fetched but never used. `a3e_var_Escape_MotorPoolPositions` is built as positions then overwritten at `:89` with the full marker tuples (`_mpPosition`), changing its element shape vs `:86`.
- **Unresolved issues:** Dead local `_playergroup` (RD). `a3e_var_Escape_MotorPoolPositions` set twice with different element types (`:75/86` push positions, `:89` overwrites with `[pos,dir]` tuples) — the published value contains tuples, potential consumer confusion (Q/BUG candidate). Hardcoded 180° orientation (RD).
- **Reforger port notes:** TBD — motor pool prefab; map-size scaling and marker reuse port directly.

### a3e_fnc_createStartpos  —  `Code/functions/Server/fn_createStartpos.sqf`  ·  _status: documented_
- **Purpose:** Builds the prison / starting compound at `A3E_StartPos` from a random prison template and spawns the starting backpack (later filled with guard weapons), returning the backpack.
- **Inputs:** No params. Reads `A3E_StartPos`, `a3e_arr_PrisonBackpacks` (def `["B_AssaultPack_khk"]`), `A3E_PrisonTemplates` (def BuildPrison..BuildPrison5).
- **Outputs:** Returns the created backpack object. Side effects: creates the backpack via `createVehicle`; `remoteExec`s the chosen prison template on all machines (prison built locally); sets `A3E_FenceIsCreated=true` (public).
- **Calls:** the selected prison template (`a3e_fnc_BuildPrison*`) via `remoteExec [_template,0,true]` (`:7`).
- **Called by:** `fn_initServer.sqf:201` (`private _backpack = [] call A3E_fnc_createStartpos`).
- **Processing:** Random fence rotation; create random backpack at start; pick random prison template; remoteExec it (JIP) with `[startPos,dir,backpack]`; publish `A3E_FenceIsCreated`; return backpack.
- **Theory of operation:** The prison is built on every client (remoteExec target 0, JIP true) because it's largely static local geometry; the backpack is a server object that initServer then stuffs with guard loadout weapons.
- **Whys & questions:** Prison template is `remoteExec`'d globally so late-joiners also get the compound (`true` JIP flag). Backpack returned so initServer can add weapon cargo.
- **Unresolved issues:** None obvious. Template dispatch by string is xref-visible via _xref template appendix.
- **Reforger port notes:** TBD — prison compound → prefab placed at start; backpack loot handled server-side.

### a3e_fnc_endMissionServer  —  `Code/functions/Server/fn_endMissionServer.sqf`  ·  _status: documented_
- **Purpose:** Central mission-end handler: finalizes statistics/session and triggers the given ending on all clients.
- **Inputs:** `params["_end"]` — an ending id string (e.g. "end1".."end4").
- **Outputs:** No return. Side effects: ends the stats session, saves statistics, ends the mission engine-side.
- **Calls:** `A3E_fnc_EndSession` (`:2`), `A3E_fnc_SaveStatistics` (`:3`), `BIS_fnc_endMissionServer` (`:4`).
- **Called by:** the win/fail trigger statement strings in `fn_missionFlow.sqf:17,26,34,42` (e.g. `"end2" call A3E_fnc_endMissionServer`).
- **Processing:** Three sequential calls: end session → save statistics → end mission with the ending id.
- **Theory of operation:** Single choke point so every ending path records stats before the engine tears the mission down; `BIS_fnc_endMissionServer` propagates the debrief to all clients.
- **Whys & questions:** Ending ids map to debrief screens defined in description.ext (end1 fail, end2 win, end3 MIA, end4 warcrime).
- **Unresolved issues:** None. Very small leaf orchestrator.
- **Reforger port notes:** TBD — GameMode end state; stats flush before shutdown.

### a3e_fnc_firedNearExtraction  —  `Code/functions/Server/fn_firedNearExtraction.sqf`  ·  _status: documented_
- **Purpose:** `firedNear` event handler for the extraction bacon — when players fire smoke/flare/chemlight near the evac point, it launches the appropriate extraction runner and consumes the sensor object.
- **Inputs:** Handler args `[markerNo, "type", _handler]` where `_handler` is the standard `firedNear` EH array `[unit,firer,distance,weapon,muzzle,mode,ammo]`.
- **Outputs:** No return. Side effects: spawns a RunExtraction* runner; deletes the sensor (`_unit`); groupChat to players; diag_log.
- **Calls:** `BIS_fnc_returnParents` (`:11`), `A3E_fnc_RunExtractionHeli/Boat/Car/RunExtraction` (spawned by type, `:16-28`), `A3E_fnc_getPlayerGroup` (`:35`), `groupChat` (remoteExec).
- **Called by:** the compiled `firedNear` handler installed by `fn_CreateExtractionPoint.sqf:32` (indirect / event).
- **Processing:** Log; unpack marker+type+handler; get the fired ammo's config parents; if the ammo derives from a smoke/chemlight/flare/smoke-launcher base, `switch` on type to spawn the matching runner, delete the bacon, and message players; else log "not allowed".
- **Theory of operation:** Signalling with smoke = "call evac" — the ammo-parent check ensures only signalling munitions (not bullets) trigger extraction. Deleting the sensor makes it one-shot.
- **Whys & questions:** `_handler params [...]` reads the raw EH payload passed as the third element by `CreateExtractionPoint`'s compiled string. Good use of `returnParents` to whitelist by ammo base class.
- **Unresolved issues:** If two players fire smoke near-simultaneously the bacon could try to launch twice before deletion (small race). `"old"` → `RunExtraction` (legacy). No guard that an extraction isn't already running for this marker.
- **Reforger port notes:** TBD — signal-item detection near an extraction area triggers the evac system.

### a3e_fnc_getRndEntryFromFaction  —  `Code/functions/Server/fn_getRndEntryFromFaction.sqf`  ·  _status: documented_
- **Purpose:** Picks a random unit/entry from a faction associative array, expanding probability-weighted category keys first.
- **Inputs:** `params[["_factionArr",...],["_entry",...],["_factionID",-1,...]]` — a faction assoc array and an entry key (or weighted array of keys).
- **Outputs:** Returns a randomly selected unit class (or `objNull` if none). No globals written.
- **Calls:** `a3e_fnc_expandProbabilities` (`:5`), `a3e_fnc_getAssocArrayEntry` (`:12`).
- **Called by:** _xref reports no `fnc_` references — likely called via dynamic dispatch (`call compile`) from a template/unit-classes context, or currently unused. Verify (dead-code candidate).
- **Processing:** If `_entry` is an array, expand it to a flat weighted list of keys; else wrap as single. For each key, append that faction category's units; `selectRandom` from the pooled units.
- **Theory of operation:** Lets templates request "a random unit of category X" where X may itself be a probability distribution over categories, centralizing weighted unit selection.
- **Whys & questions:** `_factionID` param is accepted but unused in the body — vestigial. No references in xref: is this live?
- **Unresolved issues:** No static callers found (RD/dead-code candidate — confirm it isn't reached via string dispatch). Unused `_factionID` param.
- **Reforger port notes:** TBD — weighted faction unit selection → config-driven spawn table.

### a3e_fnc_initPlayer  —  `Code/functions/Server/fn_initPlayer.sqf`  ·  _status: documented_
- **Purpose:** Server-side per-player initialization: makes the player captive, waits for prison creation, then places them (in prison at start, or into a teammate's vehicle if JIP after escape), and un-captives once escape begins.
- **Inputs:** `params["_player"]`. Reads `A3E_FenceIsCreated`, `A3E_StartPos`, `A3E_ParamsParsed`, `A3E_EscapeHasStarted`, players list.
- **Outputs:** No return. Side effects: adds `HandleScore` EH; `setCaptive` (remoteExec); teleports/moves the player; sets `A3E_PlayerInitializedServer` on the unit (public).
- **Calls:** `A3E_fnc_handleScore` (via EH string), `A3E_fnc_GetPlayers` (`:25`), `setCaptive`/`moveInAny` (remoteExec).
- **Called by:** `description.ext:107` (CfgFunctions allowedTargets=2, JIP=0) and `fn_initLocalPlayer.sqf:11` — `[player] remoteExec ["a3e_fnc_initPlayer", 2]` (each client asks the server to init it). (Note: the ATR_fnc_InitPlayer refs in _xref are a different Revive function.)
- **Processing:** Log; add score EH; set captive; wait until fence+startpos+params ready; if escape already started (JIP), try to seat the player in a teammate's vehicle (cargo/crew), else scatter near a random teammate; otherwise place near the prison; mark `A3E_PlayerInitializedServer`; wait for `A3E_EscapeHasStarted`; then un-captive.
- **Theory of operation:** Runs on the server for authority over placement and captive state; captive keeps AI from shooting prisoners pre-escape. JIP players are folded into the ongoing mission near the squad rather than dumped at an empty prison.
- **Whys & questions:** Typos in diag_log ("playe"). Uses `remoteExec ["moveInAny", _player]` so the seat change happens locally on the joining client.
- **Unresolved issues:** Placement fallback `setpos` uses `A3E_StartPos` z=0 (may float on slopes). The JIP vehicle-seating loop can leave a player unplaced if all vehicles full → falls to prison placement. Minor log typos.
- **Reforger port notes:** TBD — player spawn/possession + faction-neutral (captive) state handled by GameMode spawn logic.

### a3e_fnc_initServer  —  `Code/functions/Server/fn_initServer.sqf`  ·  _status: documented_
- **Purpose:** The server-side orchestrator (~697 lines). Parses params, loads templates/factions, sets time/weather/sides, picks the start position, builds the prison, procedurally places all objective sites, starts search/detection/statistics subsystems and the prison-guard/escape-detection machinery, and registers the Chronos recurring jobs.
- **Inputs:** No params (spawned). Reads essentially all `A3E_Param_*` and mission config; writes a large set of `A3E_*`/`a3e_var_*` globals. Server-only (`if(!isServer) exitwith`).
- **Outputs:** Many public vars (`A3E_Debug`, `A3E_StartPos`, `A3E_FenceIsCreated`, skill/date vars, task/mission flags); spawns numerous threads; registers Chronos jobs.
- **Calls (by section):**
  - *Param/env init:* `a3e_fnc_parameterInit` (`:10`); compiles `Scripts\Escape\Functions.sqf`, `AIskills.sqf`, `CommonLib.sqf`; `a3e_fnc_debugmsg`; `CBA_fnc_addEventHandler` (ACE unconscious).
  - *Statistics:* `A3E_fnc_LoadStatistics` (`:51`), later `A3E_fnc_startStatistics` (`:445`).
  - *Classes/templates:* `Units\UnitClasses.sqf`, `a3e_fnc_loadLocalClasses` (`:65`), `a3e_fnc_loadTemplates` (`:69`).
  - *Sides/weather/time:* `createCenter`, `setFriend`, `A3E_fnc_weather` (`:102`), `bis_fnc_setDate`, `setTimeMultiplier`.
  - *Start pos & prison:* `a3e_fnc_findFlatArea` (`:190/192`), `A3E_fnc_createStartpos` (`:201`), `A3E_fnc_InitVillageMarkers` (`:205`).
  - *Player wait / group:* `A3E_FNC_GetPlayers` (`:209`), `A3E_fnc_GetPlayerGroup` (`:211/258`).
  - *Surprises/placement:* `Scripts\Escape\EscapeSurprises.sqf` (`:214`); placement `spawn` calls `A3E_fnc_CreateComCenters/CreateMotorPools/CreateAmmoDepots/createMortarSites/createCrashSites` (`:219-231`).
  - *Search/detection/villages:* `A3E_fnc_SearchleaderInit` (`:237`), `A3E_fnc_PlayerDetection` (`:240`), `A3E_fnc_initVillages` (`:248`).
  - *Search chopper & traps:* `Scripts\Escape\CreateSearchChopper.sqf` (`:451`), `A3E_fnc_InitTraps` (`:456`).
  - *Guards/escape detection:* `a3e_fnc_getDynamicSquadSize` (`:466`), `A3E_fnc_Patrol` (`:578`), `A3E_fnc_GetPlayers`, `A3E_fnc_soundAlarm`/`revealPlayers` (inline).
  - *Chronos:* `A3E_FNC_Chronos_Register` × RoadBlocks/AmbientPatrols/MilitaryTraffic/CivilianCommuters/TrackGroup_Update (`:679-683`).
  - *Legacy (disabled `if(false)` block `:251-441`):* `drn_fnc_InitAquaticPatrols`, `drn_fnc_AmbientInfantry`, `drn_fnc_MilitaryTraffic`, `A3E_fnc_RoadBlocks`, `A3E_fnc_crashSite` — dead code.
- **Called by:** `fn_bootstrapEscape.sqf:36` (`[] spawn a3e_fnc_initServer`) — the postInit entry chain. `[engine/scheduler]` effectively.
- **Processing:** Sequential top-to-bottom: env/debug → statistics load → classes/templates → centers/relations → weather/time → skill mapping → exclusion zones → choose start (retry until outside exclusion zones) → build prison → village markers → wait for players → launch surprises + a `spawn` that places comcenters/motorpools/depots/mortars/crashes → search leader + player detection + villages → (dead legacy block) → statistics start → search chopper (waits for scriptDone) → traps → a big `spawn` that arms the prison backpack, spawns/strips guards, patrols them, and runs escape-start/alarm/captive watchdog threads → register Chronos jobs → warcrime-score decay loop.
- **Theory of operation:** Everything downstream depends on start position, prison, and gathered players, so those come first and gate the rest; independent subsystems are `spawn`ed to run concurrently; recurring world population is delegated to Chronos.
- **Whys & questions:** The large `if(false){…}` block (`:251-441`) is the old DRN ambient/traffic/roadblock/crashsite pipeline, kept for reference but disabled — its work now comes from Chronos + EscapeSurprises + the create* functions. Skill mapping "Kudos to Semiconductor". `waitUntil {scriptDone _scriptHandle}` on the search chopper serializes init on it.
- **Unresolved issues:** Big dead `if(false)` block (RD — dead code). Duplicate `a3e_var_Escape_enemyMinSkill/MaxSkill` assignment (`:161-164`). Crash-site loop duplicated here vs `fn_CreateCrashSites`. `waitUntil {scriptDone}` on the search chopper could stall init if that script hangs. Many private vars declared then only used in the dead block.
- **Reforger port notes:** TBD — becomes the GameMode/world init sequence; the create* calls → procedural placement systems; Chronos jobs → periodic game systems.

### a3e_fnc_initTraps  —  `Code/functions/Server/fn_initTraps.sqf`  ·  _status: documented_
- **Purpose:** Bootstraps the roadside-trap (mine/IED) system — only if the island/mod defines trap classes — by clearing the trap list and registering the periodic updater with Chronos.
- **Inputs:** No params. Reads `A3E_Trap_Classes`.
- **Outputs:** Sets `A3E_Traps=[]`; registers `A3E_fnc_updateTraps` as a Chronos job (call, every 5 ticks, non-JIP).
- **Calls:** `A3E_fnc_Chronos_Register` (`:3`).
- **Called by:** `fn_initServer.sqf:456` (`call A3E_fnc_InitTraps`).
- **Processing:** If `A3E_Trap_Classes` is non-empty, initialize the empty trap registry and register the updater.
- **Theory of operation:** Gates the whole trap subsystem on data availability so mods without trap classes pay nothing; Chronos then drives spawning/despawning.
- **Whys & questions:** The `"call",5,false` args are the Chronos register signature (mode/interval/JIP).
- **Unresolved issues:** None. Small guard-and-register leaf.
- **Reforger port notes:** TBD — mine/trap system as a scheduled game system gated on config.

### a3e_fnc_loadFaction  —  `Code/functions/Server/fn_loadFaction.sqf`  ·  _status: documented_
- **Purpose:** Loads a single faction definition file (`Factions\<name>.sqf`) and returns the compiled faction data structure.
- **Inputs:** `params[["_name",""],["_side","blue"],["_merge",""]]` (`_side`/`_merge` accepted but unused here).
- **Outputs:** Returns the faction array from the compiled file. No globals written.
- **Calls:** none (leaf; `call compile preprocessFileLineNumbers`).
- **Called by:** _xref reports no `fnc_` references — likely invoked via dynamic dispatch / from a loader (e.g. `loadTemplates`/`loadLocalClasses`) or during faction-array assembly. Verify.
- **Processing:** Preprocess+compile `Factions\<name>.sqf`; return its result.
- **Theory of operation:** Factions live as SQF data files per island/mod; this is the thin loader that turns a name into the in-memory faction assoc array.
- **Whys & questions:** `_side`/`_merge` params are declared but ignored — dead signature (maybe intended for future positional/merge loading, mirroring `selectFaction`).
- **Unresolved issues:** No static callers (RD/dead-code candidate — confirm dynamic use). Unused params `_side`/`_merge` (RD).
- **Reforger port notes:** TBD — faction files → config classes; loader becomes config resolution.

### a3e_fnc_missionFlow  —  `Code/functions/Server/fn_missionFlow.sqf`  ·  _status: documented_
- **Purpose:** Sets up the server-side win/lose state machine: creates the triggers that watch mission flags (complete, warcrime, MIA, all-dead, map/prison tasks) and end or fail the mission accordingly.
- **Inputs:** No params. Initializes `a3e_var_Escape_*` flags. Server-only body.
- **Outputs:** Resets flags; creates ~7 `EmptyDetector` triggers with statement strings; defines `A3E_fnc_InlineEverybodyUnconscious`.
- **Calls:** `A3E_fnc_endMissionServer` (via trigger strings `:17,26,34,42`), `A3E_fnc_GetPlayers`, `A3E_FNC_FailTasks`, `BIS_fnc_listPlayers` (in trigger strings).
- **Called by:** `fn_bootstrapEscape.sqf:35` (`[] spawn a3e_fnc_missionFlow`) — postInit entry chain.
- **Processing:** Zero the four outcome flags; if server, create triggers for: win (end2), win-but-warcrime (end4), MIA left-behind (end3), all-dead (end1), all-unconscious→AllPlayersDead+FailTasks, prison-task-complete (someone >50m from start), and map-task-complete (someone has a map). Each trigger's condition is a flag/expression and its action calls the ending or sets a task flag.
- **Theory of operation:** Uses lightweight `EmptyDetector` triggers as a declarative rules engine on global flags — decoupling the many mission-end conditions from the code that sets the flags. `A3E_fnc_InlineEverybodyUnconscious` supports both ATR and ACE revive.
- **Whys & questions:** The unconscious check uses `findIf {!(...isUnconscious)} == -1` for both ATR and ACE joined by OR — note: OR of two "everyone unconscious" checks means either revive system reporting all-down triggers it. Trigger timeouts `[3,3,3]` debounce wins to avoid flicker.
- **Unresolved issues:** The `A3E_fnc_InlineEverybodyUnconscious` OR-logic: if ACE var is unset (`false` default) the ACE findIf could evaluate to `-1` (everyone "not unconscious"==false → all conscious) — verify the boolean logic doesn't false-positive under ATR-only setups (Q candidate). Trigger-string dispatch is xref-visible only via the appendix.
- **Reforger port notes:** TBD — end-condition triggers → GameMode scoring/end-condition checks each frame/tick.

### a3e_fnc_parameterInit  —  `Code/functions/Server/fn_parameterInit.sqf`  ·  _status: documented_
- **Purpose:** Resolves mission parameters into `missionNamespace` variables — from CBA settings, saved profile params, or manual `paramsArray` — and broadcasts a parameters briefing.
- **Inputs:** No params. Reads `missionConfigFile >> Params`, `paramsArray`, `A3E_Param_Loadparams`, `a3e_UseCBASettings`, profile `A3E_SavedParams`.
- **Outputs:** Sets each param name as a public missionNamespace var; may save/publicVariable `paramsArray`; sets `A3E_ParamsParsed` (public); remoteExecs the briefing.
- **Calls:** `BIS_fnc_getParamValue`, `a3e_fnc_rptLog`, `A3E_fnc_WriteParamBriefing` (remoteExec), config helpers.
- **Called by:** `fn_initServer.sqf:10` (`call a3e_fnc_parameterInit`).
- **Processing:** Read param class names; default `paramsArray` for SP/editor; switch on `A3E_Param_Loadparams`: 0=save current to profile, 1=use CBA settings or reload saved profile params, 2=manual. Then for each param, set a public missionNamespace var from `paramsArray` and build an HTML briefing string; remoteExec the briefing; set `A3E_ParamsParsed`.
- **Theory of operation:** Unifies three parameter sources (in-game params, CBA settings, saved profile) into a single canonical set of missionNamespace vars that the rest of the code reads as `A3E_Param_*`.
- **Whys & questions:** FIXME comment notes param→variable recompile should be clientside for localization. Boolean CBA settings coercion is commented out (`:20-23`).
- **Unresolved issues:** Localization FIXME (`:43`) — param texts resolved server-side may not localize per client (RD/Q). Case 1 CBA path publicVariables paramsArray but case-1 profile fallback only publishes when non-empty.
- **Reforger port notes:** TBD — parameters → GameMode config / replicated settings.

### a3e_fnc_selectFaction  —  `Code/functions/Server/fn_selectFaction.sqf`  ·  _status: documented_
- **Purpose:** Selects a faction (or merged faction) for a given side from the loaded faction pools, optionally targeting a named special faction or merging all factions of a side.
- **Inputs:** `params[["_side","Enemy"],["_special",[]],["_merge",false]]`. Reads `A3E_PlayerFaction`, `A3E_EnemyFactions`, `A3E_IndepFactions`, `A3E_CivilianFactions`.
- **Outputs:** Returns a faction assoc array (or merged `[keys,values]`; `[]` on error). No globals written.
- **Calls:** `a3e_fnc_log`, `A3E_fnc_getAssocArrayEntry` (`:69`, for named lookup).
- **Called by:** _xref reports no `fnc_` references — likely called via dynamic dispatch or from a higher loader (during `loadTemplates`/`loadLocalClasses`). Verify.
- **Processing:** Map `_side` string to the relevant faction pool(s); error if empty; if `_merge`, union all factions' key/value assoc arrays into one; else if `_special` is an empty array pick a random faction (positional selection is a TODO), if `_special` is a string find the faction whose "FactionName" matches.
- **Theory of operation:** Central faction chooser so spawning code can ask for "an enemy faction" / "the faction named X" / "everything merged" without knowing the pool layout. The merge branch supports mixed-faction missions.
- **Whys & questions:** Positional/geographic faction selection is explicitly a TODO (`:60-63`) — currently always random. `_merge` uses `_forEachIndex` inside a `foreach (_subarr select 0)` — legitimate magic var (not a bug).
- **Unresolved issues:** No static callers (RD/dead-code candidate — confirm dynamic use). TODO positional selection unimplemented. Error paths return `[]`/nothing which callers must handle.
- **Reforger port notes:** TBD — faction pools → config; selection logic ports directly.

### a3e_fnc_updateTraps  —  `Code/functions/Server/fn_updateTraps.sqf`  ·  _status: documented_
- **Purpose:** The periodic trap (mine/IED) tick: despawns traps far from players or destroyed, and spawns new road-placed mines up to a cap near players, revealing them to AI/civilians but not players.
- **Inputs:** No params. Reads players, `A3E_Traps`, `A3E_Trap_MaxCount` (4), `A3E_Trap_SpawnDistance` (200), `A3E_Trap_Pathes`, `A3E_Trap_Classes`.
- **Outputs:** Mutates `A3E_Traps`; creates/deletes mines; reveals mines to Opfor/Ind/civilian; logs.
- **Calls:** `A3E_fnc_getPlayers` (`:1`), `A3E_fnc_RandomSpawnPos` (`:30`), `A3E_fnc_Log`, engine mine/road commands.
- **Called by:** Chronos job registered in `fn_initTraps.sqf:3` (indirect / scheduled).
- **Processing:** Despawn pass over a snapshot of `A3E_Traps` (remove dead; remove+delete any with no player within `2×spawnDistance`). If under `maxTraps`, pick a random spawn pos near players, find a nearby road segment of an allowed path type (skip bridges/`_info#8`), compute placement (center/roadside/random per trap-class subtype), create the mine, orient it, register it, and reveal it to non-players.
- **Theory of operation:** Traps only exist near players (spawn/despawn band) to bound object count; placement variety (roadside/center/random) and AI-reveal make them dangerous to players but not to friendly AI/civ traffic.
- **Whys & questions:** Trap class entries can be simple strings or `[mode, class]` arrays for placement style. `getRoadInfo #8` = is-bridge check. Reveal to civilian/Opfor/Ind prevents them detonating their own mines.
- **Unresolved issues:** `_roadDir`/`_posOnRoad` computed even for the simple-class branch that doesn't use them (minor). `[format[...] , _trapPos distance player]` in the Log uses `player` (server has no player) — harmless in log formatting but `player` is null on a dedicated server (Q/RD candidate). No upper bound on despawn scan cost with many traps (fine at cap 4).
- **Reforger port notes:** TBD — dynamic mine system; player-proximity streaming.

### a3e_fnc_watchKnownPosition  —  `Code/functions/Server/fn_watchKnownPosition.sqf`  ·  _status: documented_
- **Purpose:** Tracks a "known position" (enemy sighting record) object, keeping a debug marker updated and expiring the record after 10 minutes of no updates.
- **Inputs:** `params["_knownPosition"]` (an object carrying `A3E_LastUpdated`/`A3E_Accuracy`/`A3E_NumOfReports` vars). Reads `A3E_KnownPositions`, `A3E_Debug`.
- **Outputs:** Appends to `A3E_KnownPositions`; (debug) creates/updates/deletes a marker; on expiry removes from list and deletes the object.
- **Calls:** none (leaf; engine marker/var commands).
- **Called by:** `fn_createKnownPosition.sqf:17` (SearchLeader) and `Scripts/Escape/SearchLeader.sqf:258` — spawned per new sighting.
- **Processing:** Register the position; if debug, create a yellow mil_dot marker; loop every 10s updating the marker text with age/report-count/accuracy; exit when last-update age > 600s; clean up marker; remove from `A3E_KnownPositions` and delete the object.
- **Theory of operation:** Each sighting is a lightweight tracked entity that self-expires, feeding the search AI's notion of where enemies were last seen; the debug marker visualizes decay.
- **Whys & questions:** `_markername` is used without a leading `private` inside the debug branch (`:11`) — it's declared `private["_marker"]` at top but `_markername` is not; a global-ish leak, but harmless (magic-var caveat doesn't apply — this is a real undeclared local, minor RD).
- **Unresolved issues:** `_markername` not declared `private` (minor scope leak, RD candidate). 600s hardcoded expiry. Debug marker only; no production visualization.
- **Reforger port notes:** TBD — sighting records → AI perception memory entries with TTL.

### a3e_fnc_weather  —  `Code/functions/Server/fn_weather.sqf`  ·  _status: documented_
- **Purpose:** Sets mission weather (overcast, fog, wind, rain) from params, using weighted-random when a param is -1, then forces the change.
- **Inputs:** No params (spawned). Reads `A3E_Param_WeatherOvercast/Fog/Wind/Rain` (-1 = random).
- **Outputs:** Applies `setOvercast`/`setFog`/`setWind`/`setRain`; `forceWeatherChange`. No globals.
- **Calls:** none (leaf; engine weather commands, `selectRandomWeighted`).
- **Called by:** `fn_initServer.sqf:102` (`[] spawn A3E_fnc_weather`).
- **Processing:** For each of overcast/fog/wind/rain: if param is -1 pick a weighted-random level, else use the param; `switch` the level to a concrete `set*` call (with small randomized ranges); finally `forceWeatherChange`. Rain case 1 uses the `999999 setRain 0` engine quirk to prevent auto-rain under high overcast.
- **Theory of operation:** Instant weather set at mission start (time 0 transitions) with weighted randomness biased toward clear/light conditions; wind has extended joke levels up to "9001".
- **Whys & questions:** Extensive comments explain each level and the engine rain-override quirk. Overcast/fog `case 0`/wind `case 0` handling: wind `case 0` commented out to "let the engine decide"; rain `case 0` likewise.
- **Unresolved issues:** ~80 trailing blank lines (`:383-404`) — cosmetic. Wind/rain "let the engine decide" case-0 branches are commented out, so a param value of 0 for wind/rain falls through to no-op (Q: is 0 a valid selectable param value?).
- **Reforger port notes:** TBD — weather set via Enfusion weather system; weighted tables port directly.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-07-02 | Claude | Documented all entries |
