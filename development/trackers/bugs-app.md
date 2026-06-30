# Bugs — Application
_Last updated: 2026-06-30 (local)_ · _Status: skeleton_

> Bugs in the mission/application code. **ID scheme:** `BUG-NNN` (stable, never reused). Bugs in the
> test scripts/infra go in [bugs-tests.md](bugs-tests.md) instead.

> Surfaced during code-reference Sprint 1 (foundational categories). "Confirmed" = verified against
> source by hand; "candidate" = reported by analysis, not yet independently reproduced.

## BUG-001 — `getBuildingPositions` cache never persists (typo)
- **Status:** open · **Severity:** medium (perf)
- **Repro / context:** `Code/functions/Garrison/fn_getBuildingPositions.sqf:17` — `isNil("A3I_BuildingPositions")` tests an `A3I_` var that is never set; the cache it initialises is `A3E_BuildingPositions`. **Confirmed.**
- **Notes:** `isNil` is always true → cache re-initialises every call, defeating memoisation. Fix the variable name to `A3E_BuildingPositions`.

## BUG-002 — `getBuildingPositionsInMarker` calls an undefined function (dead/broken)
- **Status:** open · **Severity:** low (unreferenced)
- **Repro / context:** `Code/functions/Garrison/fn_getBuildingPositionsInMarker.sqf:6` calls `A3E_fnc_getHousePositions`, which is **not defined anywhere** (not in `functions.hpp`). **Confirmed.** Function has no callers.
- **Notes:** Likely rename-rot of `getBuildingPositions`. Fix-or-delete.

## BUG-003 — `TrackGroup` body is unreachable
- **Status:** open · **Severity:** low (dead code)
- **Repro / context:** `Code/functions/Debug/fn_TrackGroup.sqf:4` — `if(true) exitWith {};` short-circuits the whole function. **Confirmed.** Callers (`fn_activatePatrolZone.sqf:58,80`) are no-ops.
- **Notes:** Decide remove vs revive (debug-only).

## BUG-004 — `getDebugMessages` type check compares value, not type
- **Status:** open · **Severity:** low
- **Repro / context:** `Code/functions/Debug/fn_getDebugMessages.sqf:11` — `if(_filter == "STRING")` should be `if(_filter isEqualType "STRING")`. **Confirmed.**
- **Notes:** As written, a plain-string filter is never normalised to an array, breaking the later `_x in _filter` membership test.

## BUG-005 — `SerializeZoneGroups` stores vehicle index before push (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `Code/functions/Zones/fn_SerializeZoneGroups.sqf:31,50` — `_vehicleList find (vehicle _x)` read before the vehicle is added → `-1` for the first crew member.
- **Notes:** May mis-seat crew on deserialize.

## BUG-006 — `DeserializeZoneGroups` cargo-index test looks wrong (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:56` — `case "cargo": if(count(_vehiclePosition==1))` — `count` of an equality is almost certainly not the intended cargo-index check.

## BUG-007 — `deactivateZone` deletes an undefined `_trigger` (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `Code/functions/Zones/fn_deactivateZone.sqf:22` — `deleteVehicle _trigger`, but `_trigger` is never defined in that scope (trigger handles live in the zone HashMap). Likely deletes nothing / the wrong object.

## BUG-008 — `ace_fnc_CaptiveHandle` busy-spins (candidate)
- **Status:** open · **Severity:** medium (perf) · **candidate — verify**
- **Repro / context:** `Code/functions/ace/fn_CaptiveHandle.sqf` — `while {...} do {_unit setCaptive true;}` with no `sleep`, a per-frame spin while unconscious; also a workaround for an unidentified captive-reset cause.

---

_Format for new entries:_
```
## BUG-NNN — <short title>
- **Status:** open | in-progress | fixed | wontfix
- **Severity:** low | medium | high
- **Repro / context:** <steps; affected files>
- **Notes:** <findings, fix, links>
```

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton |
| 2026-06-30 | Claude | Logged BUG-001…008 from code-reference Sprint 1 |
