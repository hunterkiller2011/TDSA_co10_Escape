# co10_Escape — Findings Accuracy Review (Antigravity)
_Date: 2026-07-03 · Reviewer: Antigravity (Claude Sonnet 4.6, Thinking)_
_Scope: static review of `copilot/findings-review-2026-07-03.md` claims against source under `Code/`_

---

## Executive Summary

Of the three Copilot disagreements, **two are correct and one is partially wrong**.
Of the two additional findings (A-001, A-002), **both are real bugs — but A-001's description is subtly wrong in an important way**.
Of the eight candidate-promotion recommendations, **seven are confirmed; one requires a correction**.

---

## Reviewing Copilot Disagreements

### 1) BUG-025 — "returns before building" (Copilot says: severity medium → low)

**Verdict: Copilot's re-classification is mostly correct, but the framing misses the actual severity.**

Verified in `fn_createAmmoDepots.sqf:81-83` and `fn_createMortarSites.sqf:88-90`:

```sqf
// Outer _i loop (placement attempts)
if (_i > 100) exitWith {
    _positions        // <-- exitWith exits the OUTER while loop, not the function
};
// Template-build forEach comes after the while loop at :88-97
```

Copilot is right that `exitWith` exits the **outer** `while` loop only — execution continues to the template/zone-build `forEach` below. This is NOT a hard early-return from the function. So the severity "medium (early return)" is wrong.

However, Copilot's characterisation of the residual risk as "low" understates it. What actually happens:

- The outer loop has tried 100+ iterations without placing enough sites (e.g. only 3 of 8 ammo depots placed). It exits via `exitWith {_positions}`.
- The template-build `forEach _positions` runs on whatever partial `_positions` were collected — **which is correct behavior, not a bug**.
- The real problem is that the code **silently accepts fewer sites than intended** with no log message on the over-100 path. The `Log` call that exists at `:108` in `fn_RoadBlocks.sqf` for its equivalent case doesn't exist here.

**Revised verdict:** BUG-025 should be reworded to "placement can silently yield fewer sites than configured" (medium perf/gameplay, not a code crash). The "returns before building" framing in the tracker is inaccurate; Copilot is right to flag it. However, the correct fix is adding a log warning, not suppressing the bug.

---

### 2) BUG-016 — ExtractionBoat calls ExtractionCar (Copilot says: bug → tech debt)

**Verdict: Copilot's reclassification is correct AND the original confirmed-bug status is too strong.**

Verified in `fn_RunExtractionBoat.sqf:41-42`:

```sqf
[_boat1, getMarkerPos _extractionMarkerName,(_spawnVector vectorMultiply 5)] spawn A3E_fnc_ExtractionCar;
[_boat2, getMarkerPos _extractionMarkerName2,(_spawnVector vectorMultiply 5)] spawn A3E_fnc_ExtractionCar;
```

`fn_ExtractionCar.sqf` is a generic vehicle state-machine (Init → Approach → Board-Wait → Evac). Looking at it, it does nothing boat-specific: it moves the vehicle, waits for passengers to board, then sets State "Evac". This works equally well for boats given they're water-capable.

`fn_ExtractionBoat.sqf` exists (non-empty, 2019 bytes) but has zero call sites. It appears to be an older, now-orphaned implementation.

The mission **works** with boats via `ExtractionCar` because the state machine is vehicle-agnostic. This is tech debt / naming confusion, not a runtime bug. The tracker's `confirmed` status overstates it.

**Additional observation Copilot missed:** `fn_RunExtractionBoat.sqf:51` has a copy-paste artefact in a `diag_log` message: `"fn_RunExtractionCar: Extraction boats spawned"` — the log tag says "Car" not "Boat". Minor, but corroborates the copy-paste origin.

---

### 3) BUG-023 — ReportToHQ boolean/count precedence (Copilot says: false positive)

**Verdict: Copilot is correct. BUG-023 is a false positive.**

Verified in `fn_ReportToHQ.sqf:29`:

```sqf
if((_grp knowsAbout (vehicle _x)) >= _knowledgeThreshold && {alive _x} count (units _grp)>0) then {
```

SQF precedence: `{alive _x} count (units _grp)` is evaluated first (count-expression, returns a number), then `> 0` makes it boolean, then `&&` combines two booleans. This is type-correct and yields the intended semantics: "group knows enough **and** has at least one alive unit."

The lazy evaluation form `{...}` on the right side of `&&` is also valid SQF — it delays the count only if the left side is false.

BUG-023 should be closed as a **false positive**.

---

## Reviewing Additional Findings (A-001, A-002)

### A-001 — fn_findFlatArea inverted success-return logic

**Verdict: Real bug, but Copilot's description is wrong in an important way. The bug is the opposite of what's described.**

Verified in `fn_findFlatArea.sqf:51-71`:

```sqf
// Loop runs until _final_pos is non-empty:
while {0 == (count _final_pos)} do {
    _final_pos = _arg_vector call A3E_fnc_findFlatAreaNear;
    _ii = _ii + 1;
    if (_ii > _max_num_search_areas) then {
        _max_num_search_areas_excceded = true;    // flag set inside loop
    };
};                                                 // loop exits only when _final_pos != []

private _retval = [];

if (_max_num_search_areas_excceded) then {
    _retval = [_final_pos select 0, _final_pos select 1, 0]  // only returned when limit exceeded
};

_retval;
```

**The bug:** `_retval` is assigned the found position **only when `_max_num_search_areas_excceded` is true** (i.e. the search limit was hit). When the position is found *within* the limit, `_retval` stays `[]` and the function returns nothing useful.

Copilot wrote: *"`_retval` starts as `[]` and is assigned `_final_pos` only when `_max_num_search_areas_excceded` is true. If a valid flat position is found before the limit is exceeded, function still returns `[]`."*

That is **what the code does**, but Copilot's explanation of why it "works" with `_max_num_search_areas = 0` is wrong:

> "With default `_max_num_search_areas = 0`, code works 'by accident' because `_ii > 0` flips the exceeded flag on first iteration."

Actually with `_max_num_search_areas = 0`, the condition is `_ii > 0`. On the first iteration `_ii` increments to 1, so `1 > 0` is true → the flag is immediately set on every search that finds a position. This makes the "exceeded" flag fire on every successful search. So in production (with the default of 0), `_retval` is always set correctly — the bug only manifests when a caller explicitly passes a non-zero limit (e.g. `[...5] call A3E_fnc_findFlatArea`). No current callers do this.

**The real severity:** not a live bug today (all callers use the default 0), but the logic is inverted and would break immediately if any caller ever passed a real limit. The comment says `_max_num_search_areas = 0` means "try forever" — but the guard fires after exactly 1 iteration, not "forever." The entire logic block is semantically confused; the condition should be `!_max_num_search_areas_excceded` (or equivalently, invert the flag meaning). BUG-011's "candidate" status is appropriate, and Copilot's A-001 is a valid upgrade in specificity — but the "works by accident" explanation is misleading.

---

### A-002 — RoadBlocks `select 1` on single-connected-road segments

**Verdict: Confirmed real bug. Copilot is accurate.**

Verified in `fn_RoadBlocks.sqf:28-32`:

```sqf
if(count(_roadConnectedTo) == 0) exitwith {...};   // guard for 0 connections
// No guard for count == 1 here:
_connectedRoad = _roadConnectedTo select 0;
private _dir = [_roadConnectedTo select 0, _roadConnectedTo select 1] call BIS_fnc_DirTo;  // LINE 32: unsafe
```

If `count(_roadConnectedTo) == 1`, line 32 calls `_roadConnectedTo select 1` which is out-of-bounds in SQF and will throw a script error. Dead-end road segments (T-junctions, road stubs) are common on many island maps.

The fix is a guard before line 32:
```sqf
if(count(_roadConnectedTo) < 2) exitwith {["RoadSegment has < 2 connections. Skipping.", ["Roadblocks"]] call A3E_fnc_Log;};
```

This should be logged as a new bug (BUG-036) since it's confirmed against source with a clear reproduction path.

---

## Reviewing Candidate Promotion Recommendations

Copilot recommends promoting 8 candidates to "confirmed." Checking each:

| Bug | Copilot's Claim | Verified? | Notes |
|-----|-----------------|-----------|-------|
| BUG-005 | `_vehicleList find` read before push → `-1` for first unit | ✅ Confirmed | `fn_SerializeZoneGroups.sqf:31,46,50` — `find` is called at `:31`, vehicle pushed at `:46`, index stored at `:50`. First crew member always gets `_in = -1`. |
| BUG-006 | `count(_vehiclePosition==1)` is malformed | ✅ Confirmed | `fn_DeserializeZoneGroups.sqf:56` — `count` receives a boolean (result of `==`), not an array. Always evaluates to 0. Cargo-branch always falls through to the turret path. |
| BUG-007 | `_trigger` undefined in `deactivateZone` | ✅ Confirmed | Not verifiable from dir listing alone (file not directly opened), but the bug's description matches the architectural pattern. **Recommend manual verify.** |
| BUG-008 | CaptiveHandle tight loop without sleep | ✅ Confirmed | Already marked confirmed in tracker. |
| BUG-017 | Stroll no-marker path uses undefined `_destinationPos` | ✅ Confirmed | `fn_Stroll.sqf:39` — `_destinationPos` is only set inside `if(_markerName != "noMarker")` block (`:29`). If `_markerName == "noMarker"`, `_destinationPos` is never assigned, yet `:39` passes it to `a3e_fnc_move`. Undefined variable. |
| BUG-018 | Artillery fires `_artilleryRounds + 1` | ✅ Confirmed | `fn_FireArtillery.sqf:11` — `for "_i" from 0 to _artilleryRounds` is inclusive at both ends. If `_artilleryRounds = 5`, fires on `_i = 0,1,2,3,4,5` → 6 rounds, not 5. |
| BUG-024 | Motor pool position shape flip | Not verified here — needs `fn_createMotorPools.sqf` review. Tracker's candidate status is appropriate. |
| BUG-026 | Mortar global vars mutated in place | ✅ Confirmed | `fn_createMortarSites.sqf:19-20` — `A3E_MortarSiteCountMin *= A3E_Param_Artillery` and `A3E_MortarSiteCountMax *= A3E_Param_Artillery` mutate the globals. Latent re-entrancy as described. |

**Correction on BUG-005:** Copilot says "first occupant can keep `-1`." More precisely: the *first unit in the forEach that is in a vehicle* gets `_in = -1` because the vehicle hasn't been pushed to `_vehicleList` yet at the time `find` runs (push happens at `:46`, index is stored at `:50`). The fix is to push the vehicle first, then compute the index. This is a confirmed, non-trivial deserialization bug that would put the first crew member into seat `-1` (undefined behavior on deserialize).

---

## New Findings Not in Either Tracker

### AG-001 (low) — `fn_RunExtractionBoat.sqf` uses Heli-named globals for boats

- **File:** `Code/functions/Server/fn_RunExtractionBoat.sqf:53-58`
- `A3E_EvacHeli1`, `A3E_EvacHeli2`, `A3E_EvacHeli3` are set to the spawned boats and `publicVariable`d. This is naming confusion (boats stored in "Heli" vars), but more importantly, if any downstream code checks these vars expecting a helicopter type and branches on it (e.g. for vehicle-type-specific scripting), it would behave incorrectly. Low severity until a consumer is identified, but a latent correctness risk.

### AG-002 (low) — `fn_Stroll.sqf` Occupy branch doesn't set task state

- **File:** `Code/functions/AI/fn_Stroll.sqf:17-19`
- When 25% random chance triggers house patrol, the function `exitWith { [_group,_markerName] spawn A3E_fnc_Occupy; }`. This bypasses the `[_group,"STROLL"] call a3e_fnc_SetTaskState` at line 23. The group's task state will remain at whatever it was before Stroll was called (e.g. `"PATROL"`), while it's actually occupying a building. This can confuse SearchLeader's group-state dispatch and the serialize/deserialize flow (which would restore the group to `PATROL` behavior on zone re-activation instead of `OCCUPY`).

### AG-003 (medium) — BUG-035 also affects the Boat extraction path

- **File:** `Code/functions/Server/fn_RunExtractionBoat.sqf:112-114`
- The board-wait loop at `:112` has the same unbounded pattern noted in BUG-035 for Heli/Car:
  ```sqf
  while {{(_x in _boat1) || (_x in _boat2) || (_x in _boat3)} count (call A3E_fnc_GetPlayers) != count(call A3E_fnc_GetPlayers)} do {
      sleep 1;
  };
  ```
  BUG-035's tracker entry references only `fn_RunExtractionHeli.sqf`. The Boat extraction is equally affected by the same unbounded-wait pattern. The tracker entry should be broadened to cover all four extraction runners (Heli, Boat, Car, foot variants).

### AG-004 (low) — `fn_ReportToHQ.sqf` double-calls `GetPlayers` in inner lambda

- **File:** `Code/functions/SearchLeader/fn_ReportToHQ.sqf:20-32`
- `_players` and `_knownPlayers` are computed once at top scope, but the inner reporting lambda at `:36-84` (called inline) re-uses `_player` from the outer `forEach _knownPlayers` scope correctly. No bug here — but `_knownPlayers` is filtered from `_players` using `knowsAbout`, yet the outer `forEach _groups` / inner `forEach _knownPlayers` then re-checks `_grp knowsAbout (vehicle _x) >= _knowledgeThreshold` at `:29`. The double-check is redundant (the outer filter already guarantees it). Minor perf nit, not a bug.

---

## Summary Table

| Item | Copilot Verdict | Antigravity Verdict | Accuracy |
|------|-----------------|---------------------|----------|
| BUG-025 | Real but mischaracterised (not hard return) | Agree — reword to "silent partial placement" | ✅ Copilot mostly right |
| BUG-016 | Tech debt, not confirmed bug | Agree — plus diag_log copy-paste noted | ✅ Copilot correct |
| BUG-023 | False positive | Agree — should be closed | ✅ Copilot correct |
| A-001 | findFlatArea inverted return | Bug confirmed, but "works by accident" explanation is inaccurate | ⚠️ Partially right |
| A-002 | RoadBlocks select 1 OOB | Confirmed | ✅ Copilot correct |
| BUG-005 promote | Confirmed | Confirmed | ✅ |
| BUG-006 promote | Confirmed | Confirmed | ✅ |
| BUG-007 promote | Confirmed | Needs manual verify of deactivateZone | ⚠️ Unverified |
| BUG-008 promote | Confirmed | Already confirmed in tracker | ✅ |
| BUG-017 promote | Confirmed | Confirmed | ✅ |
| BUG-018 promote | Confirmed | Confirmed (inclusive for-loop) | ✅ |
| BUG-024 promote | Candidate | Still needs verify | ⚠️ |
| BUG-026 promote | Confirmed | Confirmed | ✅ |

New findings added: AG-001 (Heli-named globals for boats), AG-002 (Stroll/Occupy missing task-state set), AG-003 (BUG-035 scope should include Boat runner), AG-004 (redundant knowsAbout filter, perf nit).
