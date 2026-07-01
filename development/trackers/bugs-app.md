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

## BUG-009 — `CheckCampDistance` default-branch typo + no switch default
- **Status:** open · **Severity:** low · **confirmed**
- **Repro / context:** `Code/functions/Common/fn_CheckCampDistance.sqf:23` sets `_checkagainst` (lowercase g) not `_checkAgainst`; and the `switch` (`:25`) has no `default`, so an unknown type leaves `_positions` nil and the function silently returns `true`. Harmless today (sole caller passes all 3 args).

## BUG-010 — `findControl` floods the client (~9M sidechats)
- **Status:** open · **Severity:** medium (if run) · **confirmed**; dead code
- **Repro / context:** `Code/functions/Common/fn_findControl.sqf:11` — the `else` branch runs `player sidechat` on every non-match inside a 3000×3000 nested loop (~9M iterations), freezing/flooding the client. No callers (dead debug scaffolding). Delete or gate.

## BUG-011 — `findFlatArea` return gated by misspelled flag (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `Code/functions/Common/fn_findFlatArea.sqf` — return gated by `_max_num_search_areas_excceded` (misspelled); the "exceeded"(failure) semantics look inverted vs the success return. Works with the default limit 0, but a large limit could drop a valid found position.

## BUG-012 — `hijack` downed-check misses ACE unconscious (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `Code/functions/Common/fn_hijack.sqf` — downed detection reads only `AT_Revive_isUnconscious`, not `ACE_Revive_isUnconscious`, so under ACE the hack can continue while the hacker is unconscious. Also `A3E_Terminal_Hacked` is set true at start then reverted on failure (brief false "hacked" state).

## BUG-013 — `healAtBuilding` full-heal bypasses ACE Medical (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `Code/functions/Common/fn_healAtBuilding.sqf` — `setDamage 0` likely bypasses ACE Medical wound tracking (inconsistent state under ACE); no cooldown/limit.

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
| 2026-07-01 | Claude | Added BUG-009…013 from code-reference Sprint 2 (Common) |
