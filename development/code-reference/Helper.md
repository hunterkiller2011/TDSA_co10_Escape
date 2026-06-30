# Code Reference — Helper
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Math/geometry helpers (circles, markers, building queries). One entry per source file in `Code/functions/Helper/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_GetCircularSpawnPos  —  `Code/functions/Helper/fn_GetCircularSpawnPos.sqf`  ·  _status: documented_
- **Purpose:** Finds a spawn position in a ring (`_minDis`..`_maxDis`) around a randomly chosen player, far enough from *all* players, so ambient AI/traffic/roadblocks spawn off-screen.
- **Inputs:** `params [["_minDis",1000],["_maxDis",2000],["_mode","NONE"]]`. `_mode` is one of `NONE`/`WATER`/`ROAD`. Reads global game state via `A3E_fnc_GetPlayers` (player list). Precondition: at least one player exists (else `selectRandom` on empty list).
- **Outputs:** Returns a position `[x,y,0]`, or `[]` if no valid position found in 10 tries. No globals written, no side effects.
- **Calls:** `A3E_fnc_GetPlayers`, `A3E_fnc_GetRandomCirclePosition`, `A3E_fnc_NearestObjectDis` (all leaf-ish helpers).
- **Called by:** `fn_RoadBlocks.sqf:14` (ROAD mode), `fn_AmbientPatrols.sqf:52`, `fn_CivilianCommuters.sqf:56` (ROAD), `fn_MilitaryTraffic.sqf:53` (ROAD) — i.e. the ambient-spawn subsystems.
- **Processing:** If mission `time<6` (just started) override `_minDis=300`. Loop up to 10x: pick a random player as reference, call `GetRandomCirclePosition` for a candidate; if it has 3 elements, check distance to nearest player ≥ `_minDis`; if so, return it.
- **Theory of operation:** Two-stage rejection sampling — `GetRandomCirclePosition` enforces surface/road constraints, this wrapper additionally enforces the all-players minimum-distance so units don't pop in next to a different player than the reference.
- **Whys & questions:** `time<6` shortens the ring early so the very first ambient spawns happen close (likely to populate quickly before players move). Why 10 iterations and not parameterised? Magic number.
- **Unresolved issues:** Lines 12-13 compute local `_distance`/`_dir` that are never used (dead vars — actual work done inside `GetRandomCirclePosition`). `_dir`/`_distance` are not declared `private`, leaking into caller scope. Casing: declared `GetCircularSpawnPos` but `fn_RoadBlocks` calls `a3e_fnc_getCircularSpawnPos` (lowercase g) — works only because SQF function names are case-insensitive.
- **Reforger port notes:** TBD — depends on Reforger spawn-distance/streaming model; the ring-sampling math itself is trivial to port.

### a3e_fnc_GetRandomCirclePosition  —  `Code/functions/Helper/fn_GetRandomCirclePosition.sqf`  ·  _status: documented_
- **Purpose:** Returns a single random position in a ring around a given centre, optionally constrained to dry land, water, or a usable road.
- **Inputs:** `params ["_startPos",["_minDis",1000],["_maxDis",2000],["_mode","NONE"]]`. `_startPos` is `[x,y,...]`. `_mode` ∈ `NONE`/`WATER`/`ROAD`. No global state read. Precondition: `_startPos` provided (no default).
- **Outputs:** Returns `[x,y,0]` meeting the constraint, or `[]` after 10 failed attempts. No globals written, no side effects.
- **Calls:** none (leaf function — only engine commands `surfaceIsWater`, `nearRoads`, `getRoadInfo`).
- **Called by:** `fn_GetCircularSpawnPos.sqf:14`; also directly by `fn_CivilianCommuter.sqf:8` and `fn_MilitaryTrafficPatrol.sqf:8` (ROAD mode) to pick a drive-to destination.
- **Processing:** Loop up to 10x: pick random `_distance` in ring and random bearing, project with cos/sin to `_pos`. NONE → accept if not water. WATER → accept if water. ROAD → `nearRoads 50`, filter out road segments where `getRoadInfo #2` (isOnBridge?) or `#8` is true, return `getpos` of a random surviving road.
- **Theory of operation:** A cheap surface-aware position picker; mode dispatch lets one helper serve land patrols, naval patrols, and road traffic. ROAD mode snaps to an actual road object rather than the raw projected point.
- **Whys & questions:** The `getRoadInfo` indices `#2` and `#8` are unlabelled — per the Bohemia spec `#2` is `isPedestrian`-ish/bridge and `#8` relates to road type; they appear chosen to reject bridges/unsuitable segments. Confirm exact semantics against current engine docs before porting.
- **Unresolved issues:** `_dir` is not declared `private` (scope leak). On failure returns `[]`, but callers using ROAD mode (`fn_CivilianCommuter`) don't all guard against empty — possible downstream issue.
- **Reforger port notes:** Ring math trivial. Road/water surface queries map to different Reforger APIs — TBD.

### a3e_fnc_NearestObjectDis  —  `Code/functions/Helper/fn_NearestObjectDis.sqf`  ·  _status: documented_
- **Purpose:** Returns the distance from a position to the closest object/position in a supplied list (used to keep spawns away from players).
- **Inputs:** `_this select 0` = `_pos` (position, read via `BIS_fnc_param` accepting types 2/3), `_this select 1` = `_list` (array of objects/positions). No global state read.
- **Outputs:** Returns the minimum distance (Number), or `nil`/exits with nothing if `_list` is empty. No side effects.
- **Calls:** `BIS_fnc_param` (x2). Otherwise leaf.
- **Called by:** `fn_GetCircularSpawnPos.sqf:16`; and the ambient spawners `fn_AmbientPatrols.sqf:25`, `fn_CivilianCommuters.sqf:25`, `fn_MilitaryTraffic.sqf:25` (distance to nearest player check).
- **Processing:** If `_list` empty → exitWith (returns nothing). Seed `_minDis` with distance to first element, then `forEach` the list updating `_minDis` to the smaller distance.
- **Theory of operation:** Straightforward linear-scan min-distance; lighter than `nearestObjects` when you already hold the candidate list (e.g. all players).
- **Whys & questions:** Uses legacy `BIS_fnc_param` + `private[...]` style rather than modern `params` — pre-dates the `params` command era; kept for compatibility.
- **Unresolved issues:** Empty-list path returns `nil`, so a caller doing `>= _minDis` on the result would error; callers must ensure a non-empty list. Old-style declaration is tech debt.
- **Reforger port notes:** Pure math, trivial to port (becomes a small loop or LINQ-style min over distances).

### a3e_fnc_RandomMarkerPos  —  `Code/functions/Helper/fn_RandomMarkerPos.sqf`  ·  _status: documented_
- **Purpose:** Returns a uniformly-ish random point inside a marker's footprint, honouring the marker's rectangular/elliptical size and rotation.
- **Inputs:** `_this select 0` = `_marker` (marker name String, via `BIS_fnc_param`, default `"noMarker"`). Reads marker state via `getMarkerSize`/`getMarkerPos`/`markerDir`. Precondition: marker exists.
- **Outputs:** Returns position `[x,y,0]`. No globals written, no side effects.
- **Calls:** `BIS_fnc_param`. Otherwise leaf (engine marker commands only).
- **Called by:** Heavily used by patrol/destination logic: `fn_AquaticPatrol.sqf:14/17`, `fn_Guard.sqf:29/31`, `fn_Patrol.sqf:29/31`, `fn_RandomPatrolRoute.sqf:76/78`, `fn_Stroll.sqf:29/31`, `fn_PopulateAquaticPatrol.sqf:23/25`.
- **Processing:** Read size/pos/dir (dir negated). Pick random angle `_i` and random radial fractions; compute offsets `_a,_b` scaled by half-extents and cos/sin; rotate offset by `_dir` and add to marker centre.
- **Theory of operation:** Parametric point-in-ellipse/rect sampling with a 2D rotation matrix so points land inside rotated markers. `markerDir` negation aligns SQF clockwise marker rotation with the math convention.
- **Whys & questions:** Sampling isn't perfectly uniform over area (uses `random 1.0` on each axis, biases toward edges/centre depending on shape) — acceptable for scattering patrol waypoints. The same `_a/_b` formula is used regardless of ELLIPSE vs RECTANGLE shape, so rectangles get an elliptical-ish scatter; intended? Open question.
- **Unresolved issues:** Does not distinguish marker shape (ELLIPSE vs RECTANGLE) — may place points outside a rectangle's corners or fail to cover them. Legacy `private[...]` declaration style.
- **Reforger port notes:** Pure math; trivial to port once a marker/area abstraction exists in Reforger.

### a3e_fnc_calcMarkerArea  —  `Code/functions/Helper/fn_calcMarkerArea.sqf`  ·  _status: documented_
- **Purpose:** Computes a marker's area in square kilometres, distinguishing elliptical vs rectangular markers.
- **Inputs:** `_this select 0` = `_marker` (marker name String, via `BIS_fnc_param`, default `"noMarker"`). Reads `getMarkerSize`/`markerShape`. Precondition: marker exists.
- **Outputs:** Returns area in km² (Number). No globals written, no side effects.
- **Calls:** `BIS_fnc_param`. Otherwise leaf.
- **Called by:** _xref.md reports no `fnc_` references found — likely an entry point or dead code. Not found in postInit/Chronos/trigger appendices either; treat as a **dead-code candidate** pending confirmation.
- **Processing:** ELLIPSE → `pi * a * b`; else (rectangle) → `4 * a * b` (size values are half-extents). Divide by 1,000,000 to convert m² → km².
- **Theory of operation:** Simple closed-form area; the /1e6 scaling suggests it was meant to drive density-based spawn counts (units per km²), though no current caller uses it.
- **Whys & questions:** `pi` hard-coded as `3.141` (low precision). Why km² rather than m²? Presumably for human-readable density tuning. If no caller exists, what was it for — orphaned from a removed feature?
- **Unresolved issues:** Appears unused (dead code). `3.141` is an imprecise pi literal. Legacy declaration style.
- **Reforger port notes:** Pure math, trivial to port — but verify it's still needed before bothering.

### a3e_fnc_getBuildingsInMarker  —  `Code/functions/Helper/fn_getBuildingsInMarker.sqf`  ·  _status: documented_
- **Purpose:** Returns all enterable building positions (`buildingPos`) for houses/buildings within a marker's covering radius — used to populate a location zone with garrisoned units.
- **Inputs:** `_this select 0` = `_mrk` (marker name String, via `BIS_fnc_param`, default `"NoName"`). Reads `getMarkerPos`/`markerShape`/`markerDir`/`getMarkerSize`. Precondition: marker exists.
- **Outputs:** Returns a flat array of building position arrays. No globals written, no side effects.
- **Calls:** `BIS_fnc_param`. Otherwise leaf (`nearestObjects`, `buildingPos`).
- **Called by:** `fn_populateLocationZone.sqf:32` — `[_x] call a3e_fnc_getBuildingsInMarker`.
- **Processing:** Derive a circular `_radius` that bounds the marker: for ELLIPSE use the larger half-extent; for rectangle use larger half-extent × √2 (corner reach). `nearestObjects [_pos,["House","Building"],_radius,true]`, then for each building append all `buildingPos -1` (all index positions) into one list.
- **Theory of operation:** Converts a (possibly rotated) marker into a conservative bounding circle and collects every garrison slot inside it. Over-covers slightly (circle ⊃ marker) but that's fine for populating.
- **Whys & questions:** Comment at line 23 notes a possible improvement: filter positions with `bis_fnc_inTrigger` so buildings outside the actual marker shape are excluded — currently not done, so it returns buildings in the bounding circle, not strictly the marker.
- **Unresolved issues:** Ignores marker rotation (`_rotation` read but unused). No shape-precise filtering (noted TODO). Legacy declaration style. Overlaps conceptually with the Garrison helpers (`getBuildingPositionsInMarker`) — possible duplication of intent.
- **Reforger port notes:** TBD — depends on Reforger building/`buildingPos` enumeration API, which differs significantly from Arma 3.

### a3e_fnc_getSideColor  —  `Code/functions/Helper/fn_getSideColor.sqf`  ·  _status: documented_
- **Purpose:** Maps a `side` to a CBA/Arma marker-colour name (e.g. `west` → `"ColorBlue"`) for debug/track markers.
- **Inputs:** `_this select 0` = `_side` (Side, via `BIS_fnc_param`). No global state read.
- **Outputs:** Returns a colour-name String. No globals written, no side effects.
- **Calls:** `bis_fnc_param`. Otherwise leaf.
- **Called by:** `fn_TrackGroup.sqf:13` (`_marker setmarkercolor ...`); `fn_TrackGroup_Update.sqf:57` (commented-out). Only the Debug track-group tooling uses it.
- **Processing:** `switch(_side)`: civilian→ColorWhite, west→ColorBlue, east→ColorRed, resistance→ColorGreen, default→ColorBlack.
- **Theory of operation:** Tiny lookup table to colour debug markers by faction. Trivial.
- **Whys & questions:** Why does this exist in two categories? See below.
- **Unresolved issues:** **DUPLICATION** — an identical/near-identical `getSideColor` also exists in **Common** (`Code/functions/Common/`). Two copies of the same logic in different categories is a maintenance hazard; only one is referenced by the Debug tooling. Note `functions.hpp:123` declares a `getSideColor` class — confirm which category's file the engine actually binds to (the duplicate may be shadowed/unreachable).
- **Reforger port notes:** Trivial enum→colour map; port once, drop the duplicate.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-06-30 | Claude | Documented all entries |
