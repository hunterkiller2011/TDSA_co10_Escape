# co10_Escape Findings Accuracy Review (Copilot)
Date: 2026-07-03
Reviewer: GitHub Copilot (GPT-5.3-Codex)

## Scope
Static review of tracked application findings in development/trackers/bugs-app.md against current SQF source under Code/.

## Overall Verdict
Most tracked findings look accurate. I agree with the majority of BUG-001..BUG-035 as written or with minor wording adjustments.

I found three disagreements and two additional findings.

## Disagreements (ordered by severity)

### 1) BUG-025 is likely not accurate as written (medium -> low)
- Tracker claim says site placement "returns before building".
- In Code/functions/Server/fn_createAmmoDepots.sqf and Code/functions/Server/fn_createMortarSites.sqf, `exitWith {_positions};` is inside the `while` expression. That exits the loop expression, but script execution continues to the template-build code below.
- Practical risk is still present (fewer than intended sites can be built), but this is not a hard early-return from the function.

### 2) BUG-016 should be reclassified (medium bug -> tech debt/design ambiguity)
- Code/functions/Server/fn_RunExtractionBoat.sqf:41-42 calls `A3E_fnc_ExtractionCar` with boats.
- Code/functions/AI/fn_ExtractionCar.sqf implements generic vehicle state handling and can operate on boats.
- Code/functions/AI/fn_ExtractionBoat.sqf appears unused (no call sites found).
- This looks more like orphaned duplicate logic / naming confusion than a proven runtime bug.

### 3) BUG-023 looks like a false positive
- In Code/functions/SearchLeader/fn_ReportToHQ.sqf, the condition combines:
  - `(_grp knowsAbout (vehicle _x)) >= _knowledgeThreshold`
  - `{alive _x} count (units _grp) > 0`
- The second expression is boolean after `> 0`, so `&&` is type-correct. I do not see a precedence bug here.

## Additional Findings (new)

### A-001 (medium) — fn_findFlatArea success-return logic is inverted in non-exceeded path
- File: Code/functions/Common/fn_findFlatArea.sqf
- `_retval` starts as `[]` and is assigned `_final_pos` only when `_max_num_search_areas_excceded` is true.
- If a valid flat position is found before the limit is exceeded, function still returns `[]`.
- With default `_max_num_search_areas = 0`, code works "by accident" because `_ii > 0` flips the exceeded flag on first iteration.
- This is a stronger issue than current BUG-011 wording.

### A-002 (medium) — RoadBlocks assumes 2 connected roads, can index out of bounds on dead-end segments
- File: Code/functions/Server/fn_RoadBlocks.sqf
- Code checks `if(count(_roadConnectedTo) == 0) exitWith ...;` but then accesses both `_roadConnectedTo select 0` and `_roadConnectedTo select 1`.
- If `count(_roadConnectedTo) == 1`, `select 1` is invalid and can throw a script error.
- Suggested guard: require `count(_roadConnectedTo) >= 2` before computing direction.

## Candidate Findings I Recommend Promoting To Confirmed
- BUG-005: confirmed stale `_vehicleIndex` write in serialize path (first occupant can keep `-1`).
- BUG-006: confirmed malformed cargo check `count(_vehiclePosition==1)`.
- BUG-007: confirmed undefined `_trigger` delete in zone deactivation.
- BUG-008: confirmed tight loop in ACE captive handler without sleep.
- BUG-017: confirmed markerless `Stroll` path can use unset `_destinationPos`.
- BUG-018: confirmed artillery loop fires `_artilleryRounds + 1` and CAS returns constant true.
- BUG-024: confirmed motor pool position shape flip (`pos` vs `[pos,dir]`) before publish.
- BUG-026: confirmed global mortar min/max are mutated in place.

## Notes
This review is static analysis only. Runtime-sensitive findings (spawn races, extraction boarding stalls, mission-flow timing) should still be validated with targeted playtests in development/trackers/test-scenarios.md.
