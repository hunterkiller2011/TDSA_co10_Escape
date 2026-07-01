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

## BUG-014 — `onEnemyDetected` uses undefined `_player`
- **Status:** open · **Severity:** high · **confirmed**
- **Repro / context:** `Code/functions/AI/fn_onEnemyDetected.sqf` — params are `_grp, _newTarget` (`:1`), but the civilian-reporting branch uses `_player` at `:15,19,23,50,54`, which is never defined in that scope (should be `_newTarget`). The civilian "radio-in a sighting" path therefore acts on an undefined variable — civilian reporting is effectively broken.
- **Notes:** The `EnemyDetected` handler is also attached to enemy groups, but the body only acts when `side _grp == civilian`, so enemy detections are log-only.

## BUG-015 — `SeekShelter` is empty but is called
- **Status:** open · **Severity:** medium · **confirmed**
- **Repro / context:** `Code/functions/AI/fn_SeekShelter.sqf` is 0 bytes, yet `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:91` does `[_grp] call A3E_FNC_SeekShelter`. Groups deserialized into a "shelter" state receive no orders (silent no-op). Implement or reroute.

## BUG-016 — Extraction-boat runner spawns the car behavior
- **Status:** open · **Severity:** medium · **confirmed**
- **Repro / context:** `Code/functions/Server/fn_RunExtractionBoat.sqf:41-42` spawns `A3E_fnc_ExtractionCar` (passing the boats), while `Code/functions/AI/fn_ExtractionBoat.sqf` has no callers (orphaned). Either the boat behavior was abandoned in favor of reusing the car state machine, or this is a wrong-function bug. Verify intent.

## BUG-017 — `Stroll` markerless path leaves `_destinationPos` unset (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `Code/functions/AI/fn_Stroll.sqf` — the no-marker branch calls `a3e_fnc_move` without first setting `_destinationPos` (unlike `fn_Patrol.sqf`), risking an undefined-variable use.

## BUG-018 — `FireArtillery` fires one extra round; `CallCAS` always returns true (candidate)
- **Status:** open · **Severity:** low · **candidate — verify**
- **Repro / context:** `Code/functions/AI/fn_FireArtillery.sqf` — an inclusive `for … from 0 to _artilleryRounds` fires `_artilleryRounds+1` shells. `Code/functions/AI/fn_CallCAS.sqf` returns a hard-coded `true` regardless of outcome.

## BUG-019 — `onCivilianGroupSpawn` attaches event handlers to undefined `_group`
- **Status:** open · **Severity:** high · **confirmed**
- **Repro / context:** `Code/functions/Spawning/fn_onCivilianGroupSpawn.sqf` — param is `_grp` (`:1`), but the `EnemyDetected` and `KnowsAboutChanged` `addEventHandler` calls target `_group` (`:6,:8`), which is undefined. The civilian detection/reporting handlers likely fail to register. Same `_group`/`_grp` family as BUG-014.

## BUG-020 — `populateVillageZone` large-village branch never fires + debug spam
- **Status:** open · **Severity:** medium · **confirmed**
- **Repro / context:** `Code/functions/Spawning/fn_populateVillageZone.sqf:8` tests `_zoneArea`, but the value read is `_area` (`:5`); `_zoneArea` is undefined so the ">5000 ⇒ add Opfor" branch never runs. Also leftover `systemchat str _patrolCount` (`:37`) broadcasts to all clients.

## BUG-021 — Undefined-variable cluster in Spawning zone/spawn functions
- **Status:** open · **Severity:** medium · **confirmed** (populateLocationZone, initPatrolZone) / candidate (findSpawnPosBuilding)
- **Repro / context:** Verified each `_x` is at **top-level function scope, outside any `forEach`/`count`/`select`**, so it is genuinely nil (not the SQF magic iterator): `populateLocationZone.sqf:32` passes `_x` to `getBuildingsInMarker` where the zone marker `_marker` (`:4`) was intended (also computes an unused `_guardCount` at `:36`); `initPatrolZone.sqf:31-34` index `_x select 0..3` for marker setup where the `_shape` param tuple (`:16`, cf. `:18-21`) was intended. `findSpawnPosBuilding.sqf:156` references undefined `_site`/`_newGrp` (candidate — not re-verified). Same undefined-local family as BUG-014/019.

## BUG-022 — `StartSession` duplicates the `server=` query param
- **Status:** open · **Severity:** low · **confirmed**
- **Repro / context:** `Code/functions/Statistics/fn_StartSession.sqf:30` and `:32` both append `&server=<name>` to the stats URL (copy-paste).

## BUG-023 — `ReportToHQ` mixes boolean and count in one condition (candidate)
- **Status:** open · **Severity:** low · **candidate — verify**
- **Repro / context:** `Code/functions/SearchLeader/fn_ReportToHQ.sqf:29` — an `&&` combines `(_grp knowsAbout …) >= threshold` with `{alive _x} count (units _grp) > 0`; verify precedence yields the intended "knows enough AND has living units".

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
| 2026-07-01 | Claude | Added BUG-014…018 from code-reference Sprint 3 (AI) |
| 2026-07-01 | Claude | Added BUG-019…023 from code-reference Sprint 4 (Spawning/SearchLeader/Statistics) |
