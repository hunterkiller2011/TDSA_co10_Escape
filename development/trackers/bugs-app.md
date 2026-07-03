# Bugs — Application
_Last updated: 2026-07-02 (local)_ · _Status: active_

> Bugs in the mission/application code. **ID scheme:** `BUG-NNN` (stable, never reused). Bugs in the
> test scripts/infra go in [bugs-tests.md](bugs-tests.md) instead.
>
> **Reality-check:** co10_Escape is in active use (thousands of playtested sessions). Any finding that implies the
> mission cannot be played is almost certainly a static-analysis error — severities here are **provisional** until
> confirmed by a scenario in [test-scenarios.md](test-scenarios.md). Prefer downgrading + a test scenario over
> asserting a mission-breaker. Most entries below are from static review and still need in-game confirmation.

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

## BUG-021 — `populateLocationZone` passes undefined `_x` to getBuildingsInMarker
- **Status:** open · **Severity:** medium · **confirmed** (call chain traced)
- **Repro / context:** `Code/functions/Spawning/fn_populateLocationZone.sqf:32` — `[_x] call a3e_fnc_getBuildingsInMarker`. It is dispatched dynamically: `Zones/fn_initLocationZone.sqf:4` registers `"A3E_FNC_populateLocationZone"` as the zone `oninit`, invoked at `Zones/fn_activateZone.sqf:20` (`[_zoneIndex] call (getVariable _onInit)`), itself fired by the zone trigger (`Zones/fn_initZone.sqf:56`). **No frame in that chain is inside a `forEach`** — checked specifically because SQF `call` would otherwise inherit an enclosing loop's `_x` — so `_x` is genuinely nil. The intended variable is the zone marker `_marker` (`:4`). Also computes an unused `_guardCount` (`:36`).
- **Notes:** `findSpawnPosBuilding.sqf:156` (`_site`/`_newGrp`) is a separate candidate — not re-verified against caller scope. The `initPatrolZone.sqf:31-34` `_x`-for-`_shape` case originally grouped here is **dead code** (function has no callers; superseded by `initZone`, which does the marker setup correctly) — moved to RD-018.

## BUG-022 — `StartSession` duplicates the `server=` query param
- **Status:** open · **Severity:** low · **confirmed**
- **Repro / context:** `Code/functions/Statistics/fn_StartSession.sqf:30` and `:32` both append `&server=<name>` to the stats URL (copy-paste).

## BUG-023 — `ReportToHQ` mixes boolean and count in one condition (candidate)
- **Status:** open · **Severity:** low · **candidate — verify**
- **Repro / context:** `Code/functions/SearchLeader/fn_ReportToHQ.sqf:29` — an `&&` combines `(_grp knowsAbout …) >= threshold` with `{alive _x} count (units _grp) > 0`; verify precedence yields the intended "knows enough AND has living units".

## BUG-024 — `createMotorPools` publishes inconsistent position-list element shape (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `Code/functions/Server/fn_createMotorPools.sqf` — `a3e_var_Escape_MotorPoolPositions` is filled with plain positions (`:75/86`) then overwritten with `[pos,dir]` marker tuples (`:89`); the published value ends up tuples. Any consumer expecting plain positions (e.g. `CheckCampDistance`) would misread element shape.

## BUG-025 — Site-placement early-out returns before building (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `fn_createAmmoDepots.sqf` / `fn_createMortarSites.sqf` — the placement loop has `if(_i>100) exitWith {_positions}` which returns *before* the template/zone is built, so 100 failed placement attempts silently yield a partial map (no depot/site) with no error.

## BUG-026 — `createMortarSites` mutates global count vars in place (candidate)
- **Status:** open · **Severity:** low · **candidate — verify**
- **Repro / context:** `fn_createMortarSites.sqf` — `A3E_MortarSiteCountMin/Max *= A3E_Param_Artillery` mutates the *globals* rather than locals; safe only because called once, but a second call would compound (latent re-entrancy).

## BUG-027 — DRN live-function bug candidates
- **Status:** open · **Severity:** low-medium · **candidate — verify**
- **Repro / context:** In DRN functions that are still live (the search/insertion path): `fn_SearchGroup.sqf` uses `grpNull` as the default for a **marker-name** parameter (type mismatch); `fn_MotorizedSearchGroup.sqf` issues a duplicate `addWaypoint`; `fn_InsertionTruck.sqf` does an unconditional `player sideChat` (null on dedicated servers; UI/log spam). The aquatic/ambient DRN bug candidates are moot — those functions are dead (see RD-025).

## BUG-028 — Building-as-gate prisons escape detection — RESOLVED (false positive)
- **Status:** closed — false positive (traced) · **Severity:** n/a
- **Finding:** `A3E_EscapeHasStarted` (the escape state) is set by **three independent triggers** in
  `fn_initServer.sqf`, not just the gate animation: (1) a player moves **15–100 m** from `A3E_StartPos` (`:613`);
  (2) a player **picks up a weapon** — `count weapons _x > 0` (`:617-618`); (3) the gate/door animates open —
  `animationPhase "Door_1_rot"/"Door_2_rot" > 0.5` (`:647-655`, which also sounds the alarm). So even if a
  building-as-gate prison never animates a door, escape still starts via the weapon-pickup or distance triggers —
  the mission is **never softlocked**; the door poll only drives the *alarm* for those layouts. (Guard
  `knowsAbout > 2.5` sounds the alarm but does not start escape, `:641`.) Confirms the empirical evidence.

## BUG-029 — Iso roadblock manned slots misaligned under rotation (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `Templates/fn_isoTemplateRestore.sqf` applies `setDir (_dir + _rotation)` to created scenery but stores manned-slot `dir` **raw**; `Server/fn_RoadBlocks.sqf:68-72` then re-applies the raw `_dir` without adding `_rotation`, so spawned manned vehicles / static gunners are misaligned vs the rotated static composition whenever `_rotation ≠ 0`. Live roadblock path.

## BUG-030 — Prison guards patrol into the prison (near-instant-failure risk)
- **Status:** open · **Severity:** medium-high (gameplay) · **confirmed (code + playtest)**
- **Repro / context:** Prison guards (3–8, `fn_initServer.sqf:460-580`) are given the patrol marker
  `drn_guardAreaMarker` — a **50×50 m ELLIPSE centered on `A3E_StartPos`, i.e. on the prison itself** (`:475-477`)
  — via `[_guardGroup,_marker] spawn A3E_fnc_Patrol` (`:578`). *Spawn* positions are kept ≥10 m from center
  (`:491-494`), but *patrol waypoints are not* — `A3E_fnc_Patrol` picks random points anywhere in the marker,
  including the prison interior, so guards walk into the prison (clipping through the Map-Builder door/walls),
  sometimes within seconds of spawn.
- **Why it causes instant failure:** players are captive until escape starts, but **picking up a weapon to prep
  instantly starts the escape** (BUG-028 trigger #2), un-captiving the players and revealing them to guards — if a
  guard has already clipped inside, that's a point-blank engagement with no time to react.
- **Fix direction:** exclude the prison footprint from the guard patrol (patrol a ring/donut outside the walls, or
  add a keep-out radius to the patrol waypoint selection in `A3E_fnc_Patrol`/the marker), and/or suppress the
  weapon-pickup escape trigger while a guard is inside the prison. Test with TS-006. _(User-reported; code-confirmed.)_

## BUG-031 — Spawn/init race can start the escape prematurely (candidate)
- **Status:** open · **Severity:** medium · **candidate — matches user report of intermittent instant-fail on spawn**
- **Repro / context:** The escape check (`fn_initServer.sqf:611-623`) starts the escape if an *initialized* player has
  `count weapons > 0` (`:617-618`). A joining player first spawns at the respawn point (map corner) **with their
  default loadout**, then the client strips gear (`fn_initLocalPlayer.sqf:23-33`). In parallel the server
  (`fn_initPlayer.sqf`) waits only on **global** flags (`:20` — the comment claims "no weapons etc" but it does not
  check the player's actual weapons), places the player, sleeps 0.5 s (`:57`), then sets
  `A3E_PlayerInitializedServer=true` (`:61`). If the client's weapon-removal hasn't replicated to the server before
  that flag flips, the escape check sees a weapon and **starts the escape for the whole squad** — which, combined
  with BUG-030 (guard already in the prison), reads as an instant failure. Intermittent, matching the report.
- **Fix direction:** gate `A3E_PlayerInitializedServer` (or the escape check) on the player actually being unarmed
  at the prison — e.g. `waitUntil {count weapons _player == 0 && (_player distance A3E_StartPos) < 15}` before
  setting the flag; or don't honour the weapon trigger until the player is confirmed stripped. Test with TS-007.
- **Related UX:** the 'corner spawn visible before the screen goes black' — the intro/black-screen
  (`fn_initLocalPlayer.sqf:88+`, gated on `A3E_PlayerInitializedServer`) does not cover the initial
  spawn + gear-strip + teleport.

## BUG-032 — `Functions.sqf` `_PopulateVehicle` soldier counter never increments
- **Status:** open · **Severity:** medium · **confirmed**
- **Repro / context:** `Code/Scripts/Escape/Functions.sqf` — all four seat-fill loops (`:520,539,558,577`) contain
  `_soldierCount + _soldierCount + 1;` (a discarded expression) instead of `_soldierCount = _soldierCount + 1;`.
  `_soldierCount` starts at 0 (`:507`) and gates the `while` loops (`:511,530,549,568`) but is **never incremented**,
  so the `_soldierCount <= _maxSoldiersCount` cap doesn't limit crew — the loops only stop on the seat-full
  (`_continue`) fallthrough. Live code (reinforcement / populate-vehicle path used by `EscapeSurprises`).

## BUG-033 — `EscapeSurprises` motorized-search re-fires immediately at max difficulty (candidate)
- **Status:** open · **Severity:** low-medium · **candidate — verify**
- **Repro / context:** `Code/Scripts/Escape/EscapeSurprises.sqf:137` — the MOTORIZEDSEARCHGROUP in-loop re-schedule
  uses `time + _timeInSek * (4 - _enemyFrequency)`, unlike every other branch's `time + _timeInSek * (0.5 + (4-freq)/4)`.
  At `_enemyFrequency == 4` (max) this is `time + 0` → the surprise re-fires immediately (spam).

## BUG-034 — Extraction zone pools duplicate on repeated com-center hacks (candidate)
- **Status:** open · **Severity:** low · **candidate — verify**
- **Repro / context:** `Code/functions/Server/fn_SelectExtractionZone.sqf`. Marker *discovery* is `isNil`-cached
  (`:25-45`), but the pool-*assembly* appends (`:54-64`, `A3E_ExtractionPositions append …`) are **not** guarded and
  run on every call. Each successful hack (one per com-center) re-appends the `air`/`land`/`sea`/`old` positions, so
  `A3E_ExtractionPositions` accumulates duplicate zone records across a multi-comcenter mission.
- **Notes:** Partly masked by the per-record `used` flag (`set[3,true]`) + the clear filter, but it biases random
  selection toward duplicated zones. Fix: build the assembled list once (guard it) or de-dup. Surfaced by the
  integration extraction trace ([subsystem-extraction.md](../docs/architecture/subsystem-extraction.md) Stage 3).

## BUG-035 — Extraction board-wait loop is unbounded (can stall evac) (candidate)
- **Status:** open · **Severity:** medium · **candidate — verify**
- **Repro / context:** `Code/functions/Server/fn_RunExtractionHeli.sqf:106` (and the Boat/Car/foot variants at the
  analogous line): `while { <not all players in the transports> } do { sleep 1 }` blocks until **every**
  `A3E_fnc_GetPlayers` unit boards. If a survivor can never board (dead body still counted, stuck geometry, or a
  disconnected-but-counted player), the loop never completes → `State` never becomes `"Evac"`, `Exfil_Complete` is
  never set, and neither `MissionComplete` nor `MissionFailed_LeftBehind` fires → extraction stalls silently.
- **Notes:** The `LeftBehind` path only handles *boarded-then-departed*, not *never-boarded*. Total-wipe is still
  covered by the `missionFlow` all-unconscious feeder, but not one stuck survivor. Fix: bound the board-wait with a
  timeout (then depart + `LeftBehind`). Verify `GetPlayers` semantics for dead/DC'd players. Surfaced by the
  integration extraction trace ([subsystem-extraction.md](../docs/architecture/subsystem-extraction.md) Stage 6).

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
| 2026-07-02 | Claude | Added BUG-024…026 from code-reference Sprint 5 (Server) |
| 2026-07-02 | Claude | Added BUG-027 from code-reference Sprint 6 (DRN) |
| 2026-07-02 | Claude | Added BUG-028…029 from code-reference Sprint 7 (Templates) |
| 2026-07-02 | Claude | Added reality-check note; reframed BUG-028 as likely false positive (→ TS-001) |
| 2026-07-02 | Claude | Added BUG-034/035 (extraction pool-dup / unbounded board-wait) from integration extraction trace |
| 2026-07-02 | Claude | Traced prison escape (3 triggers) → BUG-028 RESOLVED (false positive); added BUG-030 (guards patrol into prison) |
| 2026-07-02 | Claude | Added BUG-031 (spawn/init race can start escape via the weapon trigger) |
| 2026-07-02 | Claude | Added BUG-032 (Functions.sqf no-op counter, confirmed), BUG-033 (EscapeSurprises re-fire) from Scripts review |
