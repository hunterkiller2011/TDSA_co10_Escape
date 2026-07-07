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
- **Status:** open · **Severity:** low (perf) · **TODO — one-char fix, low priority**
- **Repro / context:** `Code/functions/Garrison/fn_getBuildingPositions.sqf:17` — `isNil("A3I_BuildingPositions")` tests an `A3I_` var that is never set; the cache it initialises is `A3E_BuildingPositions`. **Confirmed.**
- **Notes:** `isNil` is always true → cache re-initialises every call, defeating memoisation. Fix is one character (`A3I_`→`A3E_`).
- **Player-impact re-eval (2026-07-03):** correctness is unaffected — positions returned are always correct; the only cost is recomputed `buildingPos` + per-position raycasts on the garrison/civilian-flee path (`getRndBuildingWithPositions`). Playtest confirms a frame drop on enemy spawn-in and lower FPS in village fights, but that is **dominated by AI spawn/equip cost**, not this; the cache miss only adds avoidable recompute on top. **In-situ check:** debug-console `count A3E_Buildings` stays ≤1 with the bug (would grow to dozens if the cache worked). Downgraded medium→low.

## BUG-002 — `getBuildingPositionsInMarker` — dead code hiding an abandoned area-wide garrison design
- **Status:** open · **Severity:** low (dead code) · **TODO — revive & incorporate (feature branch)**
- **Repro / context:** `Code/functions/Garrison/fn_getBuildingPositionsInMarker.sqf` has **no callers**, and the
  `A3E_fnc_getHousePositions` it calls (`:6`) is **defined nowhere** — rename-rot of the current
  `getBuildingPositions`. **Confirmed dead** (would error if ever called).
- **Intent (analyzed 2026-07-03):** an **area-wide garrison-position collector**. `nearObjects ["Building",70.5]`
  (70.5 ≈ 50·√2, the half-diagonal of a 100 m square) over-scans by radius, then a `±50 m` box filter clips to an
  exact **100 m × 100 m square**, returning every building garrison position inside it **split into all-positions +
  indoor-only**. It was meant to feed an **even, zone-wide distribution** of a garrison across many buildings
  (indoor/outdoor aware) — the opposite of the live model where each group crams into one random building.
- **Disposition:** not delete — **revive & incorporate** (on a separate feature branch so the intended behavior can
  be tested in-game). This is the natural basis for fixing **BUG-036** (over-stuffing): distribute a garrison across
  all zone building positions instead of one-building-per-group. Requires restoring/porting
  `getHousePositions` ≡ `getBuildingPositions`. _(Re-eval w/ user 2026-07-03.)_

## BUG-003 — `TrackGroup` body is unreachable — OBSOLETE (superseded)
- **Status:** open · **Severity:** low (dead debug code) · **disposition: delete (do not revive)**
- **Repro / context:** `Code/functions/Debug/fn_TrackGroup.sqf:4` — `if(true) exitWith {};` hard-disables the whole
  function (preempting even the `if(!A3E_Debug)` gate on `:5`). **Confirmed.** Its only callers
  (`fn_activatePatrolZone.sqf:58,80`) are part of the fully-dead legacy patrolZone framework
  (`activatePatrolZone` is unregistered — `functions.hpp:162` commented; `initPatrolZone` has no callers,
  superseded by `A3E_Zones`/`initZone`, Q-015).
- **Superseded by (confirmed 2026-07-03):** the live `A3E_fnc_TrackGroup_Add` + `A3E_FNC_TrackGroup_Update` pair
  (Chronos-registered at `initServer:683`) — this is the debug AI-dot overlay seen with `A3E_Debug` on, and it is
  strictly more capable: per-group leader marker with a **task-state + unit-count label**, vehicle-type icon
  (`b_inf`/`b_armor`/`b_motor_inf`), a **waypoint line**, and **one `mil_dot` per unit**, color-coded by side, all
  driven by one Chronos loop (vs `TrackGroup`'s per-group `while` thread). The developer hard-disabled `TrackGroup`
  because this replaced it.
- **Disposition:** **delete** `fn_TrackGroup` with the dead patrolZone framework — do **not** revive. No player impact.
  Note: the live overlay is the tool to verify BUG-036 (watch `GARRISONED` groups' unit dots cluster in one building).

## BUG-004 — `getDebugMessages` type check compares value, not type
- **Status:** open · **Severity:** low · **latent — debug-only, no live trigger**
- **Repro / context:** `Code/functions/Debug/fn_getDebugMessages.sqf:11` — `if(_filter == "STRING")` should be `if(_filter isEqualType "STRING")`. **Confirmed.**
- **Notes:** As written, a plain-string filter is never normalised to an array, breaking the later `_x in _filter` membership test.
- **Re-eval (2026-07-03):** the sole caller `fn_startDebugView.sqf:8` passes **no filter** → default `_filter=""` → line 21 `count("")==0` is coincidentally true → the full (unfiltered) last-25 list returns correctly. The buggy branch only fires if a **non-empty string** filter is passed, which no caller does (an array filter also works). **Zero player impact**; debug-only. Note the *live* output filter (`A3E_DebugLogFilter` in `logMessage`) is a separate, correct mechanism (see test-scenarios "Debug tooling that already exists"). One-line fix (`isEqualType`) only needed if `startDebugView` gains category filtering. Downgraded to latent-low.

## BUG-005 — `SerializeZoneGroups` stores vehicle index before push
- **Status:** open · **Severity:** low · **latent/masked — no reachable multi-vehicle group**
- **Repro / context:** `Code/functions/Zones/fn_SerializeZoneGroups.sqf:31,50` — `_vehicleList find (vehicle _x)` read at `:31` (→ `-1` when the vehicle isn't serialized yet) is stored as `_vehicleIndex` at `:50` *before* the vehicle is pushed (`:46`), so the **first crew member of each vehicle** is saved with index `-1`.
- **Re-eval (2026-07-03, code + playtest):** **fully masked** in this mission. (1) Most zone AI is **foot** (`populateLocationZone`/`populateVillageZone`) and skips the vehicle path entirely. (2) The only zone-group source that owns manned vehicles is `fn_RoadBlocks.sqf`, which spawns **one vehicle per group** (`BIS_fnc_spawnVehicle` returns its own group per slot; static gunners one-per-group too); com-center armor (`InitializeComCenArmor`) is a separate DRN spawn, **not** a zone group, so it is never serialized. ⇒ every serialized vehicle group has exactly **one** vehicle → deserialize's `_groupVehicles select -1` returns that only vehicle = correct. (3) Any residual mis-seat is self-corrected by Arma AI seat management (observed: AI re-enter an empty driver seat). Would only bite if a **multi-vehicle single-group** were ever added to a zone.
- **Disposition:** trivial correct-for-the-future fix (store `count _vehicleList - 1` after the push); low priority — guard/fix during the port if multi-vehicle groups are introduced.

## BUG-006 — `DeserializeZoneGroups` re-seat switch: malformed cargo test + possible case mismatch
- **Status:** open · **Severity:** low · **candidate — needs targeted test (debug-log)**
- **Repro / context:** `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:56` — `if(count(_vehiclePosition==1))` mis-places the paren: it evaluates `["Cargo"]==1` (array `==` number → type error) instead of the intended `count(_vehiclePosition)==1` (plain cargo vs cargo/FFV-turret). Additionally (`:50`) the switch cases are **lowercase** (`"driver"/"cargo"/"turret"`) while saved `assignedVehicleRole` is **capitalized** (`"Driver"/"Cargo"/"Turret"`) — and SQF **string-value `switch`/`==` IS case-sensitive** (corroborated in-repo: `CheckCampDistance:19` deliberately `toLower`s its input before a lowercase switch — pointless unless case-sensitive), so the re-seat switch very likely matches **nothing**. The one unconfirmed detail is `assignedVehicleRole`'s exact returned case → the debug-log test settles it. Confidence the defect is real is **higher** post-analysis; practical impact stays **low** (rare intact-revisit + AI self-reseat/man-empty-static).
- **Re-eval (2026-07-03, code + playtest):** effect is confined to **deserialized (revisited) roadblock vehicle crews + static gunners** — foot patrols and first-spawn are unaffected. Practically **masked/self-healing**: AI reseat empty vehicle seats, and **passing patrols man empty static weapons** (user-confirmed behavior), so a dismounted deserialized gunner tends to get re-manned. Trigger is rare — checkpoints are destroyed or bypassed, seldom cleanly revisited intact. Never conclusively observed.
- **Disposition:** fix the `count()` paren regardless (trivial). The case-sensitivity is the open question — resolve by test, not guess. Downgraded medium→low.
- **Debug hook / test:** add `diag_log format["deserialize seat: role=%1", _vehiclePosition]` before the switch (`:50`) + a log per case; revisit an **intact** roadblock (leave >900 m, return) and read the `.rpt` for the exact role case + which case matched. → refine TS-008.

## BUG-007 — `deactivateZone` deletes an undefined `_trigger` — dead path (unfinished zone teardown)
- **Status:** open · **Severity:** low · **dead path — never executes**
- **Repro / context:** `Code/functions/Zones/fn_deactivateZone.sqf:22` — `deleteVehicle _trigger`, but `_trigger` is never defined in that scope (trigger handles live in the zone HashMap as `"trigger"`/`"deactivationtrigger"`).
- **Re-eval (2026-07-03):** the `deletevehicle _trigger` sits inside `if(_zone getorDefault ["markedfordeletion",false])` — and `markedfordeletion` is **never set anywhere in the repo** (repo-wide grep: only this read). So the branch **never executes**; the undefined-var line never runs. It exposes an **unfinished zone-teardown**: no zone is ever marked cleared, so zones keep both triggers for the whole mission (idle-trigger leak). Harmless to correctness — a cleared objective's zone naturally stays empty (empty `serializedgroups` → nothing respawns).
- **Perf context (user-confirmed):** gradual long-session decline is real, but this trigger leak is a **minor** contributor; dominant causes are **RD-026** (spawned composition objects never despawned) and **RD-037** (garbage collector disabled but still fed). Not carcasses — capped by `description.ext` (`corpseLimit=30`/`wreckLimit=10`).
- **Disposition:** low. **Port:** finish teardown — set `markedfordeletion` when an objective is neutralized and delete BOTH `_zone get "trigger"` and `"deactivationtrigger"`; model bounded cleanup on `fn_updateTraps` (the good in-repo pattern).

## BUG-008 — `ace_fnc_CaptiveHandle` busy-spins
- **Status:** open · **Severity:** low · **ACE-only — dormant for ATR/vanilla configs**
- **Repro / context:** `Code/functions/ace/fn_CaptiveHandle.sqf` — `while {_unit getVariable ["ACE_Revive_isUnconscious",false]} do {_unit setCaptive true;}` has no `sleep`; remoteExec'd to the downed player's client (`fn_HandleUnconscious.sqf:8`), so it re-applies `setCaptive true` every scheduler slice for the whole unconscious duration (thousands/sec).
- **Re-eval (2026-07-03):** fires **only under ACE Medical**. The user's group runs **ATR/vanilla revive**, so this is **dormant for them**. Where it does run, correctness is fine (unit stays captive) but it wastes CPU on the downed client. It's a **workaround** for an unidentified captive-reset (per the caller comment), not a fix.
- **Disposition:** low. Fix = add `sleep 0.5` in the loop (keeps captive at ~2/s at negligible cost); separately root-cause what un-captives the unit.
- **Related — ATR path & "AI shoot downed bodies":** `Code/Revive/functions/Revive/fn_Unconscious.sqf` sets a downed player `setCaptive true` **once** (`:29`) with **no** re-assert loop, but also `allowDammage false` (`:28`) — so an **ATR-downed player is invulnerable** while unconscious (reversed on recovery, `:85-86`). The downed player takes **no direct damage**, but AI that keep firing on the body cause **collateral damage + area denial** — tracked as **BUG-037** (armor levels the surroundings and blocks rescues). ATR's lack of a captive re-assert (vs the ACE `CaptiveHandle`) is a prime suspect there.

## BUG-009 — `CheckCampDistance` default-branch typo + no switch default
- **Status:** open · **Severity:** low · **latent/harmless — works for sole caller**
- **Repro / context:** `Code/functions/Common/fn_CheckCampDistance.sqf:23` sets `_checkagainst` (lowercase g) not `_checkAgainst`; and the `switch` (`:25`) has no `default`, so an unknown type leaves `_positions` nil and the function silently returns `true`.
- **Re-eval (2026-07-03):** the **sole caller** `SelectExtractionZone.sqf:16` passes `[_pos,250,"all"]` (always 3 args, always `"all"`); line 19 `toLower`s it → `case "all"` → works. The typo fallback (`:23`) and missing `default` (`:25`) are never reached → **no player impact**. Note: the 250 m clearance only spaces evac from *cleared positions* (com-centers/prison/airfield), **not** from patrols/roadblocks or the ~800 m spawn radius, so **enemy camps within ~1 km of extraction are by-design** (intended LZ-clearing tension, esp. heli; the 250 m is tunable — possible FR, not a bug). Low cleanup: fix the typo + add a safe `default:`.

## BUG-010 — `findControl` floods the client (~9M sidechats)
- **Status:** open · **Severity:** low · **dead debug code — delete on port**
- **Repro / context:** `Code/functions/Common/fn_findControl.sqf:11` — the `else` branch runs `player sidechat` on every non-match inside a 3000×3000 nested loop (~9M iterations), freezing/flooding the client.
- **Re-eval (2026-07-03):** **no callers** (grep-confirmed — only doc references). It's a throwaway UI-debug tool (find a control's display/control IDC by displayed text). Never wired to anything; would only freeze a client if manually run from the debug console. **Zero player impact.** Delete on port (batch with BUG-002/003 dead-debug cleanup).

## BUG-011 — `findFlatArea` return gated by misspelled/inverted flag
- **Status:** open · **Severity:** low · **latent/harmless — default limit works; folds into RD-036**
- **Repro / context:** `Code/functions/Common/fn_findFlatArea.sqf` — return gated by `_max_num_search_areas_excceded` (misspelled); the "exceeded"(failure) semantics are inverted vs the success return. Works with the default limit 0, but a large limit could drop a valid found position.
- **Re-eval (2026-07-03):** all callers use the **default `_max_num_search_areas = 0`** (`[] call a3e_fnc_findFlatArea`), so the flag flips true after the first pass and the found position returns correctly. The inverted-flag defect only bites if a caller passes a large limit (**none does**), and the limit never actually breaks the `while` (only success does) — the **RD-036** unbounded-loop issue. **Not observed:** no world-gen hangs; map rotation is pre-tested incl. water-surrounded islands. Fix both together in the port. **No player impact.**

## BUG-012 — `hijack` downed-check misses ACE unconscious + terminal-lock on DC
- **Status:** open · **Severity:** low-medium · **Half 1 ACE-only (dormant); Half 2 rare DC soft-lock (high annoyance cost)**
- **Repro / context:** `Code/functions/Common/fn_hijack.sqf`. **Half 1:** the hack countdown guards on `!(AT_Revive_isUnconscious)` (ATR flag) — **correct under ATR** (hack aborts if the hacker is downed), but under **ACE** the downed flag is `ACE_Revive_isUnconscious`, so an ACE-downed hacker would keep hacking to completion (ACE-only → **dormant** for the user's ATR config). **Half 2:** `A3E_Terminal_Hacked` is set true (broadcast) at hack **start** as a mutex (blocks a second hacker + hides the action via `addUserActions`), and abort branches revert it. A **hard disconnect mid-hack** kills the local script before the revert → the flag stays true → that terminal is permanently "Terminal already used!" / no hack action. (Normal downed/walk-away interruptions *do* revert correctly.)
- **Re-eval (2026-07-03):** Half 2 is bounded by needing only **one** com-center to trigger extraction (most islands have several) — usually a nuisance — **but** the user notes a perceived-unfixable mission costs ~an hour and pushes players to restart, so the annoyance cost is high. Not observed yet.
- **Disposition:** Half 1 low (ACE port fix: check both revive flags). Half 2 low-medium — **trivial worthwhile fix:** reset `A3E_Terminal_Hacked` when the hacking player disconnects/dies mid-hack (`handleDisconnect` cleanup, a time-limited mutex, or track the hacker and clear on their exit).

## BUG-013 — `healAtBuilding` full-heal bypasses ACE Medical
- **Status:** open · **Severity:** low · **ACE-only bypass (dormant for ATR); niche feature**
- **Repro / context:** `Code/functions/Common/fn_healAtBuilding.sqf` — `_unit setDamage 0.0` (+ "Medic" anim): an instant full heal at a `Land_Medevac_House_V1_F`.
- **Re-eval (2026-07-03):** under **ACE**, `setDamage 0` bypasses ACE's wound/bleeding tracking → possible medical-state desync (ACE-only → **dormant** for the user's ATR/vanilla, where it's a clean full heal). No cooldown, but it's a station at a fought-for com-center → plausibly intended. **Niche/obscure** (user + players didn't know it existed; redundant when a combat-life-saver is present). **Inconsistently available:** the medevac house is placed only by the **base `fn_BuildComCenter.sqf:230`**, not the other ~5 com-center variants (user-confirmed). Shares the finicky **cursorObject** detection + **hard-coded** `Land_Medevac_House_V1_F` classname (BUG-038 family — won't appear on modsets lacking it).
- **Disposition:** low. Port: if kept, make availability consistent + discoverable, use robust detection (BUG-038 fix) + a mod-agnostic building/marker; or drop as redundant with CLS healing.

## BUG-014 — `onEnemyDetected` uses undefined `_player` — broken DUPLICATE (civilian reporting works elsewhere)
- **Status:** open · **Severity:** low · **broken but redundant — no player impact**
- **Repro / context:** `Code/functions/AI/fn_onEnemyDetected.sqf` — params `_grp, _newTarget` (`:1`), but the civilian-report branch uses `_player` (`:15,19,23`), which is undefined → `isPlayer <nil>` = false → `!(…) exitwith` at `:15` fires → the report code never runs. Registered as the `EnemyDetected` EH on civilian groups (`onCivilianGroupSpawn:6`).
- **Re-eval (2026-07-03, user-corrected):** civilian reporting is **NOT dead**. It works via a **separate, correct** handler — `onCivilianGroupSpawn:8-68` registers a `KnowsAboutChanged` EH whose body correctly `params ["_grp","_player",…]` from the EH args and does the radio-report → `recordSighting`. Players **do** see civilians radio in positions (user-confirmed), once `A3E_Warcrime_Score > A3E_Warcrime_Score_CivilianFear` (1000). So `onEnemyDetected` is a **broken duplicate** — it exits early and does nothing, but has **zero impact** (KnowsAboutChanged already reports). (For enemy groups the handler is log-only — `side _grp != civilian`.) Revises the earlier "high / civilian reporting broken."
- **Disposition:** low — **delete** `onEnemyDetected` + its `EnemyDetected` registration as a redundant broken copy (or fix `_player`→`_newTarget` if both paths are genuinely wanted).

## BUG-015 — `SeekShelter` is empty but is called — dead/unfinished feature
- **Status:** open · **Severity:** low · **dead branch — never reached**
- **Repro / context:** `Code/functions/AI/fn_SeekShelter.sqf` is 0 bytes; `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:89-91` has `case "SHELTER": [_grp] call A3E_FNC_SeekShelter`.
- **Re-eval (2026-07-03):** grep-confirmed **nothing ever sets a group's task state to "SHELTER"** — the only `"SHELTER"` reference in `Code/` is the deserialize `case` itself; `SetTaskState` is never called with it. So the case never matches and the empty function is **never called** → **no player impact**. It's an **unfinished/abandoned** "take cover / seek shelter" behavior (stubbed, given a case, never wired). Civilian fleeing already exists via a different path (`onCivilianSpawn` FiredNear → hide in building).
- **Disposition:** low — delete the empty function + dead case, or implement SHELTER in the port if wanted (likely redundant with GARRISONED/OCCUPY + civilian-flee).

## BUG-016 — Extraction-boat runner spawns the car behavior
- **Status:** open · **Severity:** low · **confirmed — functionally harmless (copy-paste artifact)**
- **Repro / context:** `Code/functions/Server/fn_RunExtractionBoat.sqf:41-42` spawns `A3E_fnc_ExtractionCar` (passing the boats), leaving `Code/functions/AI/fn_ExtractionBoat.sqf` orphaned. Cloned from `RunExtractionCar` (log at `:51` says "fn_RunExtractionCar"; boats published as `A3E_EvacHeli1/2/3`).
- **Re-eval (2026-07-03, user-confirmed):** boat evac **works** (boats arrive, wait, board, leave). The car/boat state machines are near-identical generic vehicle logic; `land "LAND"/"NONE"` is a no-op for boats *and* cars, and `fn_ExtractionBoat.sqf` even carries the same `isTouchingGround` check — nothing boat-specific is lost by the swap. Observed issues (boats colliding, beaching, driving back-and-forth near shore) are **generic AI pathing + boat evac-marker placement too close to shore** (per-island `mission.sqm` data), **not** the function swap.
- **Disposition:** low — delete the orphaned `ExtractionBoat` (or wire it) as cleanup. Separately: boat evac-marker placement near shore is a **per-island data-quality** item (boats path poorly to shore-adjacent points) — worth a placement guideline for the port.

## BUG-017 — `Stroll` markerless path leaves `_destinationPos` unset
- **Status:** open · **Severity:** low · **latent/harmless — case unreachable + graceful default**
- **Repro / context:** `Code/functions/AI/fn_Stroll.sqf` — `_destinationPos` is only assigned in the `_markerName != "noMarker"` block (`:28-37`); the markerless path falls through to `:39` `… call a3e_fnc_move` with `_destinationPos` still nil.
- **Re-eval (2026-07-03):** the nil-destination case is **not reachable** — all callers supply a marker or a restored homeMarker: `Occupy` (marker), `populateVillageZone:66` (marker), Stroll's own oncomplete (marker), and `DeserializeZoneGroups:83` (no marker, but `a3e_homeMarker` is restored to the zone marker at deserialize `:71`, so the `:8-10` fallback resolves it). Even if hit, `a3e_fnc_move` defaults a nil position to `[0,0,0]` via `bis_fnc_param` (`_position = [_this,1,[0,0,0],[[]]]`) — group walks to the map corner rather than erroring. **No player impact.**
- **Disposition:** low — set a fallback `_destinationPos` (e.g. random pos near the leader) in the markerless branch for robustness.

## BUG-018 — `FireArtillery` fires one extra round; `CallCAS` always returns true
- **Status:** open · **Severity:** low · **both real but negligible/inert**
- **Repro / context:** `Code/functions/AI/fn_FireArtillery.sqf:11` — inclusive `for "_i" from 0 to _artilleryRounds` fires `_artilleryRounds+1` shells. `Code/functions/AI/fn_CallCAS.sqf:33` returns a hard-coded `true`.
- **Re-eval (2026-07-03):** the artillery off-by-one is **trivial** (one extra shell; artillery is already lethal). CallCAS's always-true is **inert** — its only consumer is commented out: `fn_SearchLeader.sqf:90-92` sets `A3E_var_LastArtilleryStrike` **unconditionally** (`//if(_strikesuccess) then {` disabled), so `_strikesuccess` is a dead value and the bogus return never matters; strike cadence is time-gated by that timestamp regardless. The escalation works (80% artillery / 20% CAS when contact held ≥ threshold; both also make nearby OPFOR/IND groups flee the impact).
- **Disposition:** low — fix the off-by-one for correctness (`to _artilleryRounds-1` / `< _artilleryRounds`); CallCAS's return is moot unless the `if(_strikesuccess)` gate is restored. Both dormant if `A3E_Param_Artillery = 0`. **User-confirmed active + frequent** (artillery enabled; "expect to be mortar'd soon" is a group refrain) — so the off-by-one fires often but remains imperceptible; SearchLeader escalation is definitely live (relevant to BUG-023).

## BUG-019 — `onCivilianGroupSpawn` attaches EHs to `_group` — works by call-inheritance (fragile)
- **Status:** open · **Severity:** low · **false positive for breakage; real fragility (code-smell)**
- **Repro / context:** `Code/functions/Spawning/fn_onCivilianGroupSpawn.sqf` — params `_grp` (`:1`), but the `EnemyDetected` (`:6`) and `KnowsAboutChanged` (`:8`) `addEventHandler` calls target `_group` (undeclared in this function).
- **Re-eval (2026-07-03, user-corrected):** civilian reporting demonstrably **works** (user sees civilians radio-in), so `_group` is **not** nil at registration. It's the SQF **call-inherits-caller-locals** case: both callers — `fn_spawnCivilianStroller.sqf:22` and `fn_SpawnCivilianVehicle.sqf:28` — do `[_group] call A3E_fnc_onCivilianGroupSpawn` with a local literally named `_group` and use **`call`** (not `spawn`), so `_group` is inherited into this function and the EHs register on the correct group. **False positive** for broken behavior. Real issue = **fragility**: works only because every caller happens to name the var `_group` and use `call` — a `spawn`, or a `_grp`-named caller, would silently break EH registration.
- **Disposition:** low code-smell — use `_grp` (the declared param) in the `addEventHandler` calls for robustness. The `KnowsAboutChanged` handler here is the **live** civilian-informant path (see BUG-014).

## BUG-020 — `populateVillageZone`: large-village Opfor branch dead + (server-local) systemchat
- **Status:** open · **Severity:** medium · **confirmed (code + playtest — villages are Independent-only)**
- **Repro / context:** `Code/functions/Spawning/fn_populateVillageZone.sqf`:
  - **:8** tests `_zoneArea`, but the zone area is `_area` (`:5`). `_zoneArea` is undefined → the `>5000 ⇒ add A3E_VAR_Side_Opfor to the sides pool` branch never fires (and `nil > 5000` throws a per-village script error; execution continues, villages still populate). **User-confirmed: all villages are Independent-only** — the intended Opfor mix-in for large villages is entirely absent.
  - **:37** `systemchat str _patrolCount`. **Correction (2026-07-03):** `systemchat` is **local** and this function runs **server-side**, so it shows only on the server (nothing on a dedicated server; a listen-host would see it) — **not** broadcast to clients (user confirmed no stray numbers). My earlier "all clients" was wrong; it's harmless server log noise.
- **Re-eval (2026-07-03):** villages still populate (Ind patrols + civilians scaled by `A3E_Param_VillageSpawnCount` + zone size), but every village is **mono-faction Independent** — a real difficulty/variety loss (esp. where Independent = militia vs Opfor = main military).
- **Disposition:** medium — fix `_zoneArea`→`_area` (restores large-village Opfor + kills the error); delete the `systemchat` line.

## BUG-021 — `populateLocationZone` passes undefined `_x` to getBuildingsInMarker
- **Status:** open · **Severity:** low · **confirmed nil `_x`, but the result is dead computation — no player impact**
- **Repro / context:** `Code/functions/Spawning/fn_populateLocationZone.sqf:32` — `[_x] call a3e_fnc_getBuildingsInMarker`. It is dispatched dynamically: `Zones/fn_initLocationZone.sqf:4` registers `"A3E_FNC_populateLocationZone"` as the zone `oninit`, invoked at `Zones/fn_activateZone.sqf:20` (`[_zoneIndex] call (getVariable _onInit)`), itself fired by the zone trigger (`Zones/fn_initZone.sqf:56`). **No frame in that chain is inside a `forEach`** — checked specifically because SQF `call` would otherwise inherit an enclosing loop's `_x` — so `_x` is genuinely nil. The intended variable is the zone marker `_marker` (`:4`). Also computes an unused `_guardCount` (`:36`).
- **Notes:** `findSpawnPosBuilding.sqf:156` (`_site`/`_newGrp`) is a separate candidate — not re-verified against caller scope. The `initPatrolZone.sqf:31-34` `_x`-for-`_shape` case originally grouped here is **dead code** (function has no callers; superseded by `initZone`, which does the marker setup correctly) — moved to RD-018.
- **Re-eval (2026-07-03):** nil `_x` confirmed, **but the result is dead computation** — `_buildingsPositions` feeds only the log line (`:33`, "Found 0 enterable Buildings") and the **unused** `_guardCount` (`:36`); the actual garrison (`:48-60`) uses `_patrolCount` + `_marker` and self-selects buildings via `GuardBuilding`→`getRndBuildingWithPositions`. So **no functional/player effect** — just a misleading log. It's a **vestige of the abandoned area-wide garrison distribution** (same family as BUG-002 / BUG-036). **Downgraded to low.** Fix `_x`→`_marker` for an accurate log; the real fix is wiring area-wide distribution (→ BUG-036 / BUG-002).

## BUG-022 — `StartSession` duplicates the `server=` query param
- **Status:** open · **Severity:** low · **confirmed — harmless (backend stats, same value twice)**
- **Repro / context:** `Code/functions/Statistics/fn_StartSession.sqf:30` and `:32` both append `&server=<name>` to the stats URL (copy-paste).
- **Re-eval (2026-07-03):** both use the **same** `_servername`, so the API receives `server=` twice with identical values and reads one — **no functional or player effect** (external `co10esc.anzp.de` stats backend). Gated on `A3E_Param_SendStatistics == 1` (dormant if stats off). Related **Q-016**: the GET fires via `htmlLoad` on a hidden `RscHTML` control, which may not work on a **dedicated** server (no UI) — the whole stats system (and this bug) could be silently inert there.
- **Disposition:** low/cosmetic — delete the duplicate `:32`. See also the [self-hosted stats-backend proposal](../docs/stats-backend.md) (redirect this API to an own DB) — roll this cleanup into that edit.

## BUG-023 — `ReportToHQ` mixes boolean and count in one condition — FALSE POSITIVE
- **Status:** closed — false positive (precedence is correct) · **Severity:** n/a
- **Repro / context:** `Code/functions/SearchLeader/fn_ReportToHQ.sqf:29` — `if((_grp knowsAbout (vehicle _x)) >= _knowledgeThreshold && {alive _x} count (units _grp)>0)`.
- **Re-eval (2026-07-03):** precedence is **correct**. In SQF, binary commands (`count`) and comparisons (`>=`,`>`) both bind **tighter than `&&`**, so this parses as `((knowsAbout) >= threshold) && ((count of living units) > 0)` — exactly "group knows the player well enough **AND** has ≥1 living unit." The `_x` in `{alive _x}` is the `count` iterator (each unit), correctly shadowing the outer player `_x`. **Not a bug.** `ReportToHQ` is the live enemy→HQ reporting path (feeds `recordSighting` → the artillery/CAS escalation, user-confirmed).
- **Notes:** it is the **third** near-identical copy of the radio-report routine (`onEnemyDetected` [broken dup, BUG-014], `onCivilianGroupSpawn` KnowsAboutChanged [civilian], `ReportToHQ` [enemy]) → **RD-038**.

## BUG-024 — `createMotorPools` publishes inconsistent position-list element shape
- **Status:** open · **Severity:** low · **latent/harmless — only consumer unreachable; line 86 is dead**
- **Repro / context:** `Code/functions/Server/fn_createMotorPools.sqf` — `:86` `pushBack (_x select 0)` (plain positions), but `:89` **overwrites** the whole variable with `_mpPosition` (`[pos,dir]` tuples). So the published value is tuples and `:86` is dead (discarded).
- **Re-eval (2026-07-03):** the **only** consumer is `CheckCampDistance.sqf:29` (`case "motorpool"`), which is **never called** — its sole caller (`SelectExtractionZone`) passes `"all"` (see BUG-009). So the tuple-vs-position inconsistency never bites → **no player impact.**
- **Disposition:** low — remove the dead `:86`; standardize the element shape if the `"motorpool"` CheckCampDistance case is ever wired.

## BUG-025 — Site-placement early-out returns before building
- **Status:** open · **Severity:** low · **latent — failsafe never reached (empirically confirmed)**
- **Repro / context:** `fn_createAmmoDepots.sqf:81-83` / `fn_createMortarSites.sqf` — `if(_i>100) exitWith {_positions}` inside the placement `while` exits the **whole function** (SQF `exitWith` leaves the enclosing scope, not just the loop), **before** the build loop (`:87-95`). So hitting the 100-iteration cap builds **zero** depots/sites — not even the ones already placed.
- **Re-eval (2026-07-03, user-confirmed):** **never triggered in practice** — hundreds-to-~1000 plays across dozens of maps, always had ammo depots / mortars / objectives. The loop reaches `A3E_AmmoDepotCount` in far fewer than 100 iterations because island configs keep the count within what the map fits. So the misdesigned failsafe is **unreachable** on the real rotation → **no player impact.** Downgraded medium→low.
- **Disposition:** low — port robustness: build the partial `_positions` (`exitWith`→`break`, or move the build after the loop) + log a warning, so a future over-set count degrades gracefully instead of silently losing an objective.

## BUG-026 — `createMortarSites` mutates global count vars in place
- **Status:** open · **Severity:** low · **latent re-entrancy — called once, no impact**
- **Repro / context:** `fn_createMortarSites.sqf:19-20` — `A3E_MortarSiteCountMin/Max = A3E_MortarSiteCountMin/Max * A3E_Param_Artillery` mutates the **globals** in place (should be locals).
- **Re-eval (2026-07-03):** called **once** (initServer), so the globals scale by `A3E_Param_Artillery` exactly once → `_mortarSiteCount` correct → **no compounding, no player impact**. A second call would re-scale (compound), since the isNil defaults (`:13-18`) don't reset already-set globals — a **latent re-entrancy** hazard only. Aside: `A3E_Param_Artillery = 0` → count 0 → no mortar sites (artillery-off correctly yields no mortars; user runs it enabled → mortars spawn). Shares the BUG-025 early-out.
- **Disposition:** low — use locals (`private _min = A3E_MortarSiteCountMin * A3E_Param_Artillery`) for the port.

## BUG-027 — DRN live-function bug candidates
- **Status:** open · **Severity:** low · **all three latent/harmless or server-invisible**
- **Repro / context + re-eval (2026-07-03):**
  - `fn_SearchGroup.sqf:21` `_searchAreaMarkerName = param[1,grpNull]` — a marker-**name** (String) param defaulting to **grpNull** (a Group), copy-pasted from param 0. **Latent** type mismatch — never hit: callers always pass a real marker name (search groups work). Fix default to `""`.
  - `fn_MotorizedSearchGroup.sqf:434-435` — two identical `addWaypoint [_enemyPos, 0]` → a harmless **redundant** waypoint (group still just goes to the enemy pos). Remove the dup.
  - `fn_InsertionTruck.sqf:94,162` `player sideChat` — `:94` is a guarded CommonLib-version-fail loop (CommonLib is bundled at the right version → never fires); `:162` "Deleting dead unit" is a debug line. Both run **server-side** → `player` null on a dedicated server → no-op/invisible (a listen-host would see `:162` spam). Delete/gate.
- **Disposition:** low — the aquatic/ambient DRN candidates are moot (those functions are dead, RD-025). Cleanups for the port.

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
- **Re-eval (2026-07-03, user-corroborated):** beyond the hard-hang edge, this gate causes a **real, recurring
  "slow to leave in a timely fashion"** across **all** evac types (heli/car/boat) — the user independently suspected
  the player-loaded check. The gate requires **every** `A3E_fnc_GetPlayers` unit to be `in` an evac vehicle (polled
  each 1 s), so a straggler, a downed/being-revived player, or a player struggling to board a **repositioning**
  vehicle (the `Land`↔`WaitForPlayers` reposition) delays departure for everyone; the never-leaves hard-stall is the
  extreme. **Fix:** bound with a timeout (depart with whoever's aboard) and/or gate only on **alive + conscious**
  players and/or add a manual "ready to go" signal; hold the vehicle still while waiting. Bumps practical severity.

## BUG-036 — Garrison groups clump into one building/room (over-stuffing)
- **Status:** open · **Severity:** low-medium (gameplay quality) · **confirmed (code + playtest)**
- **Repro / context:** `Code/functions/AI/fn_MoveInBuilding.sqf:37-49` distributes a garrison group across a building's
  `buildingPos -1` (shuffled, one per unit). Two failure modes produce the "empty-looking village, then a whole
  squad crammed in one room" surprise players report:
  1. **Capacity-blind selection** — `fn_getRndBuildingWithPositions.sqf:2` accepts *any* building within 50 m with
     `>0` positions, so a 1-position shack qualifies for a 6-man squad; and
  2. **Surplus units are never placed** — when `positions < units`, the `foreach` runs out (`deleteAt 0`) and the
     leftover units get **no move order**, clumping at the entrance where `doStop` left them (`:39-49`). In large
     multi-room buildings the same clustering appears when the per-unit `doMove` to interior `buildingPos` fails to
     path (Arma jank), leaving units bunched near the initial group waypoint.
- **Player effect (confirmed 2026-07-03):** occasionally a full squad (~4-6) is found jammed in one small room —
  small guard shacks, a shed behind a house, or one room of a larger building — instead of spread through the
  structure; surprises searching players. Uncommon but recurring.
- **Fix direction:** prefer buildings whose `buildingPos` count ≥ group size (capacity-aware selection); when
  positions run short, spill surplus units to adjacent buildings/exterior cover instead of leaving them unordered;
  consider a per-building occupancy cap so two groups don't stack. Distinct from BUG-001 (perf). Not a mission-breaker.
  **Natural fix basis:** the dead `getBuildingPositionsInMarker` (BUG-002) is an abandoned *area-wide* garrison-position
  collector — reviving it to distribute a garrison across all zone building positions (rather than one-building-per-group)
  directly addresses this clustering. _(User-reported; code-confirmed.)_

## BUG-037 — AI keep engaging downed players → area denial + collateral damage
- **Status:** open · **Severity:** medium-high (gameplay) · **confirmed (playtest); root cause to isolate**
- **Repro / context:** A downed (unconscious, **revivable**) player under ATR revive is `allowDammage false` + `setCaptive true` — set **once** in `Code/Revive/functions/Revive/fn_Unconscious.sqf:28-29`, with **no re-assert loop** (unlike the ACE path's `CaptiveHandle`, BUG-008, which exists precisely because "the unit gets set out of captive mode here and there"). In practice AI — especially **armored vehicles** — keep firing on the downed body.
- **Player effect (user-reported 2026-07-03):** the downed player is invulnerable, but the *continued fire* is the harm: (1) it **denies the area** — teammates can't approach to revive without taking the (real) collateral fire; (2) **tank cannon/MG fire continuously at the body**, destroying **surrounding vehicles, cover, and whole buildings**, endangering rescuers, until the enemy runs out of ammo. Impedes the core revive/recovery mechanic; sometimes forces abandoning the body.
- **Root-cause candidates (isolate):** (a) ATR never **re-asserts** captive, so the intermittent un-captive the ACE `CaptiveHandle` works around leaves the downed player targetable; (b) AI don't **drop an existing engagement** when a target becomes captive (keep suppressing the last-known position); (c) **LAMBS/VCOM** AI mods overriding captive / finishing wounded. Test without AI mods to separate mission vs mod.
- **Fix direction:** on the ATR downed path, **re-assert captive** (mirror `CaptiveHandle` but throttled with a `sleep` — folds in BUG-008's fix) and/or **actively disengage nearby enemies** from the downed unit (`{_x forgetTarget _downed; _x doTarget objNull} forEach <nearby enemies>`, `_downed setCaptive true`, reveal 0), with special handling for armor (which won't stop on its own). 
- **Relation:** BUG-008 (ACE has a captive re-assert; the ATR path lacks it). Revises the earlier "cosmetic" read — the downed body is invulnerable, but the collateral + area-denial is real harm.

## BUG-038 — Com-center "Hack terminal" prompt is finicky to trigger (cursorObject detection)
- **Status:** open · **Severity:** low-medium (usability) · **user-reported**
- **Repro / context:** `Code/functions/Common/fn_addUserActions.sqf` — the hack action's show-condition `at_fnc_checkTerminalHack` uses **`cursorObject`** (object under the crosshair) + `player distance _target <= 3` + `A3E_isTerminal`. `cursorObject` requires the player to aim precisely at the terminal prop **and** for the engine to have revealed/rendered it — the code even does `player reveal _target` as a *"Force reveal for engine optimization workaround"* (`:6`), acknowledging the detection is unreliable.
- **Player effect (user-reported 2026-07-03):** the yellow "Hack terminal" UI often takes real effort to appear — players report having to **wait**, or carefully **aim/look at a specific spot** on the terminal, before the action shows. Friction on a **core** action (hacking a com-center is what triggers extraction, BUG-012 / extraction subsystem).
- **Fix direction:** replace the finicky `cursorObject` gate with a more forgiving detection — e.g. `nearestObjects [player,[],3]` filtered to `A3E_isTerminal` within a forward cone, or attach the action **to the terminal object** (addAction on the terminal with a radius) instead of a player action gated on cursorObject, or an ACE-interact point. _(Terminal-interaction review.)_

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
| 2026-07-03 | Claude | Bug re-evaluation w/ user: BUG-001 downgraded medium→low (perf TODO); added BUG-036 (garrison over-stuffs one building/room, confirmed) |
| 2026-07-03 | Claude | Re-eval: BUG-002 reframed as revive-&-incorporate TODO (abandoned area-wide garrison collector); linked to BUG-036 as fix basis |
| 2026-07-03 | Claude | Re-eval: BUG-003 marked obsolete/delete — superseded by the live TrackGroup_Add/Update Chronos overlay (the AI-dot debug system) |
| 2026-07-03 | Claude | Re-eval: BUG-004 latent (debug-only); BUG-005 downgraded medium→low (masked — all serialized vehicle groups are single-vehicle) |
| 2026-07-03 | Claude | Re-eval: BUG-006 downgraded medium→low (narrow trigger + AI-reseat/man-empty-static self-heal); needs debug-log test for case-sensitivity |
| 2026-07-03 | Claude | Re-eval: BUG-007 downgraded medium→low (dead path — markedfordeletion never set); perf-decline root-caused → added RD-037 (disabled-but-fed GC) |
| 2026-07-03 | Claude | Re-eval: BUG-008 downgraded medium→low (ACE-only, dormant for ATR); documented ATR invulnerability → "AI shoot downed bodies" is cosmetic |
| 2026-07-03 | Claude | Added BUG-037 (AI keep engaging downed players → area denial + collateral damage; user-reported, mission-impeding) |
| 2026-07-03 | Claude | Re-eval: BUG-009 latent/harmless (sole caller uses "all"); clarified 250 m extraction clearance is by-design. Raised BUG-006 confidence (SQF string switch is case-sensitive; toLower in-repo proves it) |
| 2026-07-03 | Claude | Re-eval: BUG-010 confirmed dead debug code (no callers) — delete on port, zero player impact |
| 2026-07-03 | Claude | Re-eval: BUG-011 latent/harmless (default limit works; folds into RD-036, not observed — maps pre-tested) |
| 2026-07-03 | Claude | Re-eval: BUG-012 (Half 1 ACE-dormant; Half 2 DC terminal-lock low-med, trivial fix). Added BUG-038 (finicky cursorObject hack prompt, user-reported) |
| 2026-07-03 | Claude | Re-eval (user-corrected): BUG-013 low (ACE-only/niche); BUG-014 high→low (broken duplicate — civilian reporting works via KnowsAboutChanged); BUG-019 high→low (false positive — works by call-inheritance) |
| 2026-07-03 | Claude | Re-eval: BUG-015 dead/unfinished (SHELTER never set); BUG-016 low (harmless copy-paste; boat issues are AI/marker-placement); BUG-017 latent/harmless; corroborated BUG-035 (slow evac departures, all types) |
| 2026-07-03 | Claude | Re-eval: BUG-018 low (artillery off-by-one trivial; CallCAS always-true is inert — the if(_strikesuccess) consumer is commented out) |
| 2026-07-03 | Claude | Re-eval: BUG-020 (Opfor branch dead — villages all-Independent confirmed; corrected systemchat to server-local); BUG-021 med→low (nil _x but dead computation) |
| 2026-07-03 | Claude | Re-eval: BUG-022 low/harmless (duplicate server= param, same value; backend stats only) |
| 2026-07-03 | Claude | Re-eval: BUG-023 CLOSED false positive (precedence correct); added RD-038 (triplicated report logic). FR-001 + docs/stats-backend.md from BUG-022 follow-up |
| 2026-07-03 | Claude | Re-eval: BUG-024 low/latent (dead line 86; consumer unreachable); BUG-025 med→low (failsafe never reached — ~1000 plays); BUG-026 low/latent (called-once global mutation) |
| 2026-07-03 | Claude | Re-eval: BUG-027 low (all three latent/redundant/server-invisible DRN cleanups) |
