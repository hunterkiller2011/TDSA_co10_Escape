# Code Reference — Garrison
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Building-position helpers for garrisoning units. One entry per source file in `Code/functions/Garrison/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_getBuildingPositions  —  `Code/functions/Garrison/fn_getBuildingPositions.sqf`  ·  _status: documented_
- **Purpose:** Returns a building's garrison positions, each tagged indoor/outdoor; caches per-building results in global arrays so the expensive raycast classification runs once per building.
- **Inputs:** `params ["_Building",["_isIndoor",false]]`. Reads/writes globals `A3E_Buildings`, `A3E_BuildingPositions`, `A3E_BuildingPositionsIndoor` (nil-checks `A3I_BuildingPositions` — note typo, see below).
- **Outputs:** Returns array of `[position, isIndoorBool]` entries (or only indoor entries if `_isIndoor`). Writes/grows the three `A3E_*` cache globals.
- **Calls:** local `_fnc_isIndoor` (lineIntersectsObjs raycast). No external `a3e_fnc_*`.
- **Called by:** `fn_getRndBuildingWithPositions.sqf:10` — `[_x,_isIndoor] call A3E_fnc_getBuildingPositions`.
- **Processing:** Init caches if unset. Look up building in `A3E_Buildings`. On miss: for each `buildingPos -1`, raycast straight up ~4 m; if it hits geometry the slot is "indoor". Push results into the parallel cache arrays. On hit: reuse cached arrays. Optionally filter to indoor only.
- **Theory of operation:** Memoised parallel-array cache keyed by building object; indoor detection via short upward `lineIntersectsObjs` (roof above a slot ⇒ indoors). Avoids re-raycasting buildings that recur across garrison calls.
- **Whys & questions:** Indoor heuristic is approximate (overhangs/balconies could read as indoor). Three parallel arrays instead of one structured map is fragile but fast.
- **Unresolved issues:** **BUG-candidate:** nil-check tests `A3I_BuildingPositions` (note the `A3I` typo) but the code initialises `A3E_BuildingPositions`. Since `A3I_BuildingPositions` is never set, the `isNil` branch likely re-runs and **resets the cache on every call**, defeating the memoisation. Verify. Also `_dir`-style scope hygiene aside, the cache is global and never cleared between missions.
- **Reforger port notes:** TBD — `buildingPos`/`lineIntersectsObjs` have no direct Reforger equivalent; indoor detection would need a different approach (navmesh/usable-position API).

### a3e_fnc_getBuildingPositionsInMarker  —  `Code/functions/Garrison/fn_getBuildingPositionsInMarker.sqf`  ·  _status: documented_
- **Purpose:** Intended to collect building garrison positions (and the indoor subset) within a ±50 m box around a position. **Appears broken** — see Calls/Unresolved.
- **Inputs:** `params ["_pos",["_radius",70.5]]`. `_pos` is a position; `_radius` used for the `nearObjects` query. No global state read.
- **Outputs:** Returns `[_positions, _positionsIndoor]` (two arrays). No globals written, no side effects.
- **Calls:** `A3E_fnc_getHousePositions` (line 6) — **this function does not exist anywhere in the codebase** (grep finds the name only here; not declared in `functions.hpp`). So the call is a no-op/error at runtime.
- **Called by:** _xref.md reports no `fnc_` references found — not called by any function; not in postInit/Chronos/trigger appendices. Dead code / unreferenced.
- **Processing:** `nearObjects ["Building",_radius]`; for each, call the (missing) house-positions helper, then keep slots within a ±50 m square of `_pos`, accumulating all into `_positions` and indoor ones into `_positionsIndoor`.
- **Theory of operation:** Would have been a marker/area variant of the garrison lookup, narrowing a radius query to a square box. Superseded by/duplicative of `getBuildingsInMarker` (Helper) and `getBuildingPositions`.
- **Whys & questions:** Was `getHousePositions` an old name for `getBuildingPositions` that got renamed without updating this caller? Likely a rename-rot artefact.
- **Unresolved issues:** **BUG/dead-code:** calls undefined `A3E_fnc_getHousePositions`; would throw/return undefined. No callers. Hard-codes ±50 m while accepting a `70.5` radius (mismatch). Strong candidate for deletion.
- **Reforger port notes:** Do not port as-is; reconcile with `getBuildingPositions` first (likely delete).

### a3e_fnc_getRndBuilding  —  `Code/functions/Garrison/fn_getRndBuilding.sqf`  ·  _status: documented_
- **Purpose:** Picks a random `Building`-class object within a radius of a position.
- **Inputs:** `params ["_pos",["_radius",100]]`. No global state read.
- **Outputs:** Returns a building Object, or `objNull` if none nearby. No globals written, no side effects.
- **Calls:** none (leaf — `nearObjects`, `selectRandom`).
- **Called by:** _xref.md reports no `fnc_` references found — not called by any function; not in the appendices. Dead-code candidate (likely superseded by `getRndBuildingWithPositions`, which guarantees enterable positions).
- **Processing:** `_pos nearObjects ["Building",_radius]`; if non-empty, `selectRandom`.
- **Theory of operation:** Simplest "give me any building nearby" helper. Doesn't verify the building has usable garrison positions, which is probably why the *WithPositions* variant exists and this one is unused.
- **Whys & questions:** Kept as a convenience that the rest of the code outgrew? Confirm before relying on it.
- **Unresolved issues:** No callers (dead code). Returns buildings with no guarantee of `buildingPos`, unlike its siblings.
- **Reforger port notes:** Trivial nearby-object pick; TBD on Reforger object-query API.

### a3e_fnc_getRndBuildingPosition  —  `Code/functions/Garrison/fn_getRndBuildingPosition.sqf`  ·  _status: documented_
- **Purpose:** Returns a single random garrison position from a random nearby building that actually has positions.
- **Inputs:** `params ["_pos",["_radius",50],["_isIndoor",false]]`. No global state read directly (delegates).
- **Outputs:** Returns a single position array, or `[]` if none found. No globals written (but callee mutates the `A3E_*` caches).
- **Calls:** `A3E_fnc_getRndBuildingWithPositions`.
- **Called by:** _xref.md reports no `fnc_` references found — not called by any function; not in the appendices. Dead-code candidate.
- **Processing:** Call `getRndBuildingWithPositions [_pos,_radius,_isIndoor]`; if a building+positions came back (`count != 0`), `selectRandom (positions) select 0` to pull one position's coordinates.
- **Theory of operation:** Thin convenience wrapper that drops the building object and returns just one slot — useful when you only need a single spot to place a unit.
- **Whys & questions:** Unused despite being a natural API; possibly callers inlined the *WithPositions* form instead. `select 0` assumes each position entry is `[pos, indoorFlag]` shaped.
- **Unresolved issues:** No callers (dead code). Indexing `select 0` couples it tightly to the entry shape returned upstream.
- **Reforger port notes:** Trivial wrapper; port alongside `getRndBuildingWithPositions` if that survives.

### a3e_fnc_getRndBuildingWithPositions  —  `Code/functions/Garrison/fn_getRndBuildingWithPositions.sqf`  ·  _status: documented_
- **Purpose:** Finds a random nearby building that has at least one (indoor, if requested) garrison position, returning both the building and its positions. The primary garrison-placement entry point.
- **Inputs:** `params ["_pos",["_radius",50],["_isIndoor",false]]`. No global state read directly (callee uses the `A3E_*` caches).
- **Outputs:** Returns `[_Building, _positions]`, or `[]` if no suitable building. No globals written here (callee mutates caches).
- **Calls:** `A3E_fnc_getBuildingPositions`, `BIS_fnc_arrayShuffle`.
- **Called by:** Widely used by AI garrison behaviours: `fn_GuardBuilding.sqf:16`, `fn_Occupy.sqf:16`, `fn_PatrolBuildings.sqf:16` (all `[(getpos leader _group)] call ...`), `fn_onCivilianSpawn.sqf:59`, and the sibling `fn_getRndBuildingPosition.sqf:3`.
- **Processing:** `nearestObjects [_pos,["House","Building"],_radius]`, shuffle the list, then iterate: for each, get its positions via `getBuildingPositions`; the first building with `count>0` positions wins (`exitWith`). Return `[building, positions]` if found, else `[]`.
- **Theory of operation:** Shuffle-then-first-match gives a random qualifying building without computing positions for all of them — early-exits as soon as one has usable slots, amortised cheap thanks to the `getBuildingPositions` cache.
- **Whys & questions:** `nearestObjects` (here) vs `nearObjects` (in the dead siblings) — different ordering/semantics; the shuffle compensates for `nearestObjects` distance ordering. Note `_isIndoor` is passed through so indoor-only garrisoning is supported.
- **Unresolved issues:** `_return` and `_positions` are assigned without `private` in places (scope hygiene — `_return` at line 13 is not declared private). Depends on `getBuildingPositions`, whose cache-reset bug (above) would force re-classification each call. Otherwise sound.
- **Reforger port notes:** TBD — building enumeration + per-slot positions differ in Reforger; the shuffle/first-match selection logic ports trivially once a position-source exists.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-06-30 | Claude | Documented all entries |
