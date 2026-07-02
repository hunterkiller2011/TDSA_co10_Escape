# Code Reference — Documentation Progress Ledger
_Last updated: 2026-06-30 (local)_ · _Status: active_

> **Resume point.** This sprint-series fills the per-file entries in the code-reference docs. If work is
> interrupted, a fresh session resumes from here: pick the next `pending` category and run the runbook
> in [README.md](README.md). An entry is **done** when it has no `_(to document)_` fields left, so
> `grep -rl "_(to document)_" development/code-reference/` shows exactly what remains.

## Setup (Sprint 0) — done

- [x] Entry template expanded to 10 fields (added **Calls**, **Called by**).
- [x] Category docs + `_init-and-includes.md` + README regenerated/updated to the 10-field template.
- [x] Caller cross-reference index built → [_xref.md](_xref.md).
- [x] This ledger created.

## Sprints

| Sprint | Categories | Entries | Status |
|--------|-----------|---------|--------|
| 1 | Helper, Garrison, Zones, Chronos, Intel, ace, Debug | 40 | **done** (awaiting review) |
| 2 | Common | 35 | **done** |
| 3 | AI | 32 | **done** |
| 4 | Spawning, SearchLeader, Statistics | 36 | **done** |
| 5 | Server, _init-and-includes | 38 | **done** |
| 6 | DRN | 20 | **done** |
| 7 | Templates (dedupe variants) | 45 | **done** |

## Per-category status

| Category | Doc | Entries | Status |
|----------|-----|---------|--------|
| Helper | [Helper.md](Helper.md) | 7 | done |
| Garrison | [Garrison.md](Garrison.md) | 5 | done |
| Zones | [Zones.md](Zones.md) | 6 | done |
| Chronos | [Chronos.md](Chronos.md) | 4 | done |
| Intel | [Intel.md](Intel.md) | 3 | done |
| ace | [ace.md](ace.md) | 4 | done |
| Debug | [Debug.md](Debug.md) | 11 | done |
| Common | [Common.md](Common.md) | 35 | done |
| AI | [AI.md](AI.md) | 32 | done |
| Spawning | [Spawning.md](Spawning.md) | 20 | done |
| SearchLeader | [SearchLeader.md](SearchLeader.md) | 8 | done |
| Statistics | [Statistics.md](Statistics.md) | 8 | done |
| Server | [Server.md](Server.md) | 30 | done |
| _init & includes | [_init-and-includes.md](_init-and-includes.md) | 8 | done |
| DRN | [DRN.md](DRN.md) | 20 | done |
| Templates | [Templates.md](Templates.md) | 45 | done |

## Concern intake (consolidated into trackers centrally)

Agents return suggested questions/risks/bugs here; they are folded into
`development/trackers/{open-questions,risks-tech-debt,bugs-app}.md` after each sprint to avoid
concurrent edits.

**Sprint 1 intake (folded into trackers):**
- Bugs → `bugs-app.md` BUG-001…008 (BUG-001..004 confirmed by hand; 005..008 candidates to verify).
- Risks → `risks-tech-debt.md` RD-006 (dynamic-dispatch xref blind spot), RD-007 (dead-code candidates), RD-008 (name casing), RD-009 (`getSideColor` duplication).
- Questions → `open-questions.md` Q-009 (marker-shape helpers), Q-010 (Chronos registration robustness).
- One false positive corrected: `RevealPOI`'s call to `A3E_fnc_UpdateLocationMarker` is **valid** (declared `functions.hpp:141`); Intel.md fixed.

**Sprint 2 intake (Common)** — folded into `bugs-app.md` BUG-009…013, `risks-tech-debt.md` RD-010…013, `open-questions.md` Q-011…012:
- BUG (`CheckCampDistance`): line 23 default branch assigns `_checkagainst` (lowercase g) instead of `_checkAgainst`; also the `switch` has no `default`, so an unknown type yields nil `_positions` and silently returns true. Harmless today because the only caller passes all 3 args.
- BUG-candidate (`findFlatArea`): return is gated by the misspelled flag `_max_num_search_areas_excceded`; with default `_max_num_search_areas=0` it becomes true on the first iteration so the found pos is returned, but the "exceeded"(=failure) semantics are inverted vs. the success return. If a caller passed a large limit, a valid found position could be dropped (returned `[]`) until the counter is exceeded. Review needed.
- BUG-candidate (`fn_hijack`): downed detection uses only `AT_Revive_isUnconscious`, not `ACE_Revive_isUnconscious` — under ACE the hack may continue while the hacker is unconscious. Also the `A3E_Terminal_Hacked` flag is set true at hack start (to lock others out) then reverted on failure, briefly showing a failed terminal as hacked.
- BUG-candidate (`healAtBuilding`): `setDamage 0` full-heal likely bypasses ACE Medical wound tracking (inconsistent state under ACE); no cooldown/limit.
- BUG-candidate (`findControl`): `else` branch does `player sidechat` on every non-match across a 3000×3000 loop (~9M sidechats) — would freeze/flood the client. Dead debug scaffolding; no callers. Delete or gate.
- RD/dead-code (`CompileGroupVar`, `GetEnemyCount`, `groupChat`, `systemChat`, `findControl`): no `fnc_` callers indexed — candidate dead/debug-only code to confirm & prune. `GetEnemyCount` may be superseded by `Spawning/fn_getDynamicSquadsize` (duplicate difficulty→count logic). `checkUnitClasses` is intentionally manual (dev QA tool) but overwrites `A3E_Param_*` globals as a side effect — must never run at runtime.
- RD/duplication (`RandomPatrolPos` vs `RandomSpawnPos`): near copy-paste (both keep an unused leftover `_minSpawnDistance` in their `private` list); neither has a max-iteration guard (theoretical infinite loop). Consider merging.
- RD/duplication (`getSideColor`): duplicated identically in `Helper/` and `Common/` (confirms RD-009 from Sprint 1) — pick one canonical copy.
- RD/perf (`GetPlayers`): hot function recomputed twice per iteration inside `fn_RunExtraction*` `while` loops (`count(...)!=count(...)`); consider caching per iteration.
- RD/perf (`cleanupTerrain`): one persistent JIP `hideObjectGlobal` remoteExec per object × 30+ camps could bloat the JIP queue; no batching; hidden objects never restored.
- RD/perf (`initArsenal`): full `CfgWeapons` config scan per box call (~2× per depot).
- RD/tech-debt (`getAssocArrayEntry`): uses `[]` as not-found sentinel (ambiguous if a real value is `[]`); parallel-array map while `loadLocalClasses` uses modern HashMaps — data-structure inconsistency across Common.
- RD/tech-debt (`toggleEarplugs`): `_activated` not declared `private` (leaks scope); hard-coded UI positions may not fit all resolutions.
- RD/tech-debt (`RotatePosition`): some AmmoDepot_VN_US callers pass a 4th argument that the 3-param function ignores — verify no lost per-object rotation and whether an older signature existed.
- RD/casing: pervasive `A3E_*` vs `a3e_*` inconsistency (function names are case-insensitive so functional-harmless, but noise) — reinforces RD-008.
- Q (`InitVillageMarkers`): called only on the server with `createMarkerLocal`, whose local markers aren't visible to clients — verify debug village markers actually appear anywhere. The `[true]` arg is ignored (reads `A3E_Debug`).
- Q (`bootstrapEscape`): uses `throw` on missing config inside a postInit function — verify the throw is caught / that the mission fails visibly rather than silently.
- Q (`handleScore`): gates on `!isNil "a3e_var_Escape_SearchLeader_civilianReporting"` (presence of the var) rather than its boolean value — may misfire if the var is defined-but-false. Also registered on server (initPlayer) whereas `handleRating` is registered client-side (initLocalPlayer) — intentional asymmetry?

**Sprint 3 intake (AI)** — folded into `bugs-app.md` BUG-014…018, `risks-tech-debt.md` RD-014…016, `open-questions.md` Q-013…014:
- BUG-candidate (`onEnemyDetected`): references `_player` throughout (guards `isPlayer _player`, filters, and `A3E_fnc_recordSighting`) but `_player` is never defined in the function — only `_grp`/`_newTarget` are params. Almost certainly should be `_newTarget`; as written the civilian-reporting path likely errors or reads an unintended global. Also the `EnemyDetected` handler is wired for BOTH civilian and enemy groups (`onCivilianGroupSpawn`, `onEnemyGroupSpawn`) but the body only acts for `side == civilian`, so enemy detections are a no-op beyond logging.
- BUG-candidate (`SeekShelter`): file is empty (0 bytes) yet is `call`ed from `Zones/fn_DeserializeZoneGroups.sqf:91` for groups deserialized into a shelter state — those groups receive no orders on load (silent behavior gap). Verify which saved state maps here.
- BUG-candidate (`ExtractionBoat` naming/dead-code): `Server/fn_RunExtractionBoat.sqf:41-42` spawns `A3E_fnc_ExtractionCar` (not `ExtractionBoat`) for its boats; `fn_ExtractionBoat.sqf` has no indexed callers and may be orphaned. Function-name vs runner-name mismatch is a maintenance trap.
- BUG-candidate (`Stroll`): markerless path never assigns `_destinationPos` before the `a3e_fnc_move` call (Patrol handles this branch; Stroll does not) — possible undefined-variable use if called with no marker and none stored.
- RD/duplication (extraction variants): `ExtractionBoat`/`ExtractionCar`/`ExtractionChopper` are near-identical `State`-var polling state machines (differ only in approach thresholds and heli `flyInHeight`). Two runner pairs also overlap (`RunExtraction`+`RunExtractionHeli` → Chopper; `RunExtractionBoat`+`RunExtractionCar` → Car). Consolidation candidate.
- RD/duplication (building-garrison variants): `GuardBuilding`/`Occupy`/`PatrolBuildings` share one skeleton (differ in formation, state string, timeout, and respawn target Guard/Stroll/Patrol). Likewise `Patrol`/`Guard`/`Stroll`/`AquaticPatrol` share the marker+water random-pos skeleton. Strong dedup candidates.
- RD/duplication (flee scatter): the "scatter nearby Opfor/Ind away from impact" block is copy-pasted between `fn_CallCAS` and `fn_FireArtillery`.
- RD/duplication (aerial drones): `fn_SearchDrone` and `fn_LeafletDrone` are the same Engima Search-Chopper state machine; only the SEARCHING state (SAD vs leaflet drop) differs. Both use `player sideChat` for debug in a server-side script and depend on legacy DRN CommonLib.
- RD/dead-code: `fn_Loiter.sqf` and `fn_resumeTask.sqf` are empty (0 bytes); `fn_RandomPatrolRoute` only caller is commented out (`DRN/fn_PopulateLocation.sqf:62`); `fn_spawnGarisson` has no indexed callers and uses the legacy `A3E_GroupMembers`/`A3E_Sides` index model. Candidates to confirm-and-prune (check `functions.hpp`).
- Q (waypoint-timeout ordering): `Guard` uses `setWaypointTimeout [0,20,6]` and `Search` `[0,20,6]` — max(6) < mid(20), which looks like a min/mid/max typo (should be `[0,6,20]`?). Confirm intended dwell behavior.
- Q (`a3e_fnc_move` waypoint-1 convention): every behavior reuses waypoint index 1 and stores its self-respawn recursion in the oncomplete statement; this convention is fragile if any code adds extra waypoints. Confirm no group ever gets additional waypoints. Also the key Reforger port choke-point (Enfusion has no equivalent index/`setWaypointType` model).
- Q (`AquaticPatrol` state): boats are tagged task state `"PATROL"` (same as foot patrols) rather than a distinct state — verify this doesn't cause OrderSearch/SeekShelter to mis-treat boats.
- Q (`AddStaticGunner`): creates a new group per static gunner (many statics → group bloat toward the 288-group limit); default side is `A3E_VAR_Side_Ind` though callers pass Opfor; Opfor `switch` case is redundant.
- RD/off-by-one (`FireArtillery`): `for "_i" from 0 to _artilleryRounds` fires rounds+1 shells (inclusive loop). `_success`/return of `CallCAS` is hard-coded `true` regardless of actual strike outcome.
- RD/perf (`OrderSearch`, `EngageReportedGroup`): iterate `AllGroups` per report; `EngageReportedGroup` has a dead `if(isNil("_group"))` check and unbounded accuracy growth until the 300s cutoff.

**Sprint 4 intake (Spawning/SearchLeader/Statistics)** — folded into `bugs-app.md` BUG-019…023, `risks-tech-debt.md` RD-017…020, `open-questions.md` Q-015…017; privacy facts → `docs/security-privacy.md`. Confirmed by hand: `onCivilianGroupSpawn` `_group` typo (EHs don't register), `populateVillageZone` `_zoneArea` undefined, `onPlayerSpotted` 0-byte empty, `StartSession` duplicate `server=`.

**Sprint 5 intake (Server/_init)** — folded into `bugs-app.md` BUG-024…026, `risks-tech-debt.md` RD-021…024, `open-questions.md` Q-018…020; config-hardening facts → `docs/security-privacy.md`. Confirmed by hand: `description.ext` dev config (debug console / recompile / remoteExec mode 2 / localhost URI), `initServer.sqf:251` dead `if(false)` block; BUG-016 re-confirmed from the Server side.

**Sprint 6 intake (DRN)** — folded into `bugs-app.md` BUG-027, `risks-tech-debt.md` RD-025 (+ RD-018 corrected). **Correction:** the DRN ambient/traffic/aquatic calls (`AmbientInfantry`, `InitAquaticPatrols`, `Populate`/`DepopulateAquaticPatrol`, `MilitaryTraffic`) are inside the dead `if(false)` block (`initServer:251-441`) → **dead, not live** as the sub-agent first reported; DRN.md carries a correction note.

_Raw agent notes (DRN = legacy third-party ambient-AI library; much is superseded by A3E `Spawning/`/`Zones/`):_

- BUG-candidate (`PopulateAquaticPatrol`): loop `for [{_i=0},{_i<=_groups},...]` is inclusive, spawning `_groups+1` boats; and `_groups` derives from `random 1` (a float 0..1) via `InitAquaticPatrols:48` — fractional/off-by-one group counts.
- BUG-candidate (`GarrisonUnits`): `_rbpos = (floor random _numberofBpos)+1` can exceed the valid `buildingPos` index range (off-by-one), snapping soldiers to `[0,0,0]`. Also ignores its `_soldiertype` arg (hardcodes `a3e_arr_Escape_InfantryTypes`, line 4) and has no isServer guard; creates one one-man group per garrisoned soldier (group bloat).
- BUG-candidate (`PopulateLocation`): passes undefined `_soldiertype`/`_markername` (lowercase) to `drn_fnc_GarrisonUnits` (line 78) — the local is `_markerName`; these args are nil/leaked (RD-008 casing + genuine nil-arg smell). GarrisonUnits ignores `_soldiertype` so partially masked.
- BUG-candidate (`MoveVehicle`): `_destinationSegment` is only set on the random-destination path but dereferenced unconditionally at line 47 when a `_firstDestinationPos` is supplied → nil-var error on that branch. (Function is also dead — see below.)
- BUG-candidate (`InsertionTruck`): unconditional `player sideChat "Deleting dead unit"` (line 162) spams all clients regardless of `_debug`; dead-unit handling only `setPos`es, never deletes.
- BUG-candidate (`MotorizedSearchGroup`): duplicate `addWaypoint` (line 434-435) — harmless but wasteful.
- BUG-candidate (`SearchGroup`): `param [1,grpNull]` uses a group-null default for a marker-NAME (string) param (line 21) — type mismatch (masked because all 5 callers pass a name).
- BUG-candidate (`InitAquaticPatrols` / `InitAquaticPatrolMarkers`): the marker-init caller is **commented out** at `initServer.sqf:206`, but `InitAquaticPatrols` (live at :285) creates triggers referencing `a3e_aquaticPatrolMarkerN` markers that may never be created → possible silent no-op / bad trigger.
- RD-018 duplication (DRN vs A3E): **`MilitaryTraffic`** runs LIVE from DRN (`initServer:399/400`) while the A3E-native `Spawning/fn_MilitaryTraffic.sqf` is ALSO Chronos-registered (`initServer:681`) — two traffic systems concurrently; confirm intent. `MoveVehicle` duplicates the inline `drn_fnc_MilitaryTraffic_MoveVehicle`. `AmbientInfantry` overlaps `Spawning/fn_AmbientPatrols.sqf`.
- Dead / superseded DRN functions (no `fnc_` callers in `_xref.md`; A3E equivalent named):
  - `DepopulateVillage` + `PopulateVillage` → superseded by `Spawning/fn_populateVillageZone.sqf` (+ `fn_initVillages`, `Zones/`).
  - `InitGuardedLocations` (+ its `PopulateLocation`/`DepopulateLocation`/`GarrisonUnits` chain) → no live caller; A3E has `Spawning/fn_populateLocationZone.sqf`. Whole guarded-location path appears retired (verify — may be invoked only from an un-indexed external `Scripts/DRN/...`).
  - `MoveInfantryGroup` → only a commented-out caller; replaced by `A3E_fnc_Patrol` (used in `AmbientInfantry:160`).
  - `MoveVehicle` → dead + duplicated (see above).
  - `MonitorEmptyGroups` → dead diagnostic tool, never wired.
  - `InitAquaticPatrolMarkers` → caller commented out (`initServer:206`); aquatic-patrol feature may be disabled.
- Still-LIVE DRN functions (keep in mind for port): `AmbientInfantry` (initServer:347), `InitAquaticPatrols` (:285) + `Populate/DepopulateAquaticPatrol` (trigger-wired), `MilitaryTraffic` (:399/400), `InitVillageMarkers` (:205, via `A3E_fnc_` alias), `InsertionTruck` (CreateReinforcementTruck), `MotorizedSearchGroup` (CreateMotorizedSearchGroup), `SearchChopper` (CreateSearchChopper/EscapeSurprises), `SearchGroup` (5 callers — core foot-search primitive).
- RD/tech-debt (whole library): hard external dependency on legacy DRN CommonLib (`drn_fnc_CL_*` + `a3e_var_commonLibInitialized` nag-loops) across ~10 functions; pervasive unused `private` declarations; magic-index soldier-record schemas that DIFFER between `PopulateVillage` and `PopulateLocation` (data-format drift); `A3E_*`/`a3e_*`/`drn_*` casing/namespace straddle (RD-008), esp. `InitVillageMarkers` registered/called under both `drn` and `A3E_fnc_`.
- Q (`AmbientInfantry`): hardcoded 6:5 Ind:Opfor faction weighting (line 46) carries the author's own `//WHY!?!?!?!?!` comment — intent unknown; `_minUnitsInGroup`/`_maxUnitsInGroup` params are dead (squad size from `getDynamicSquadSize`).

**Sprint 7 intake (Templates)** — folded into `bugs-app.md` BUG-028…029, `risks-tech-debt.md` RD-026…029, `open-questions.md` Q-021. Documented by family (BuildPrison + AmmoDepot/ComCenter/MotorPool/MortarSite/Roadblock/Misc) via per-family part-files, merged into `Templates.md`. Key reconciliation: the `fn_Roadblock*` compositions are **dead** — live roadblocks use the Iso data-template system (`LoadTemplates`→`IsoTemplateRestore`→`RoadBlocks`); `MortarSite2` is a byte-identical copy of `MortarSite`. Raw BuildPrison notes below:

_BuildPrison family (6):_
- **BUG-candidate (potential mission-breaker):** prisons that use a whole *building* as the gate object
  (`BuildPrison2`=`Land_Shed_05_F`, `BuildPrison4`=`Land_Slum_House03_F`, `BuildPrison5`=`Land_Slum_House02_F`, set
  as `A3E_PrisonGateObject`) rely on `initServer.sqf:647-649` polling `animationPhase "Door_1_rot"/"Door_2_rot" > 0.5`
  for escape detection. If those base-game classes don't expose exactly those animation sources, the gate-open
  (escape) condition never fires for those layouts — verify in-game/config.
- RD (duplication): 6 near-identical Map-Builder exports; collapse to one data-driven builder fed an object array.
- RD: ~35-50 decorative `createVehicleLocal` objects per client, never tracked/despawned (benign; built once/session).
- RD: hardcoded vanilla classnames (`Land_TinWall_01_*`, `Land_Shed_0[57]_F`, `Land_Slum_House0[23]_F`, …) — a
  rename/removal silently drops objects, no error handling.
- Q: `fn_BuildPrison` (the `Land_City_Gate_F` variant) does not set `allowDamage false` on its gate, unlike the 5
  siblings — intentional (destructible) or oversight?
- Q: `A3E_PrisonGateObject` is a plain global (not `publicVariable`'d) unlike `A3E_PrisonLoudspeakerObject`.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Created; Sprint 0 setup complete; Sprint 1 started |
| 2026-07-01 | Claude | Sprint 2 (Common, 35) documented; findings folded into trackers |
| 2026-07-01 | Claude | Sprint 3 (AI, 32) documented; findings folded into trackers |
| 2026-07-01 | Claude | Sprint 4 (Spawning/SearchLeader/Statistics, 36) documented; findings folded; security-privacy updated |
| 2026-07-02 | Claude | Sprint 5 (Server/_init, 38) documented; findings folded; security-privacy hardening added |
| 2026-07-02 | Claude | Sprint 6 (DRN, 20) documented; corrected DRN live/dead (if(false) block); findings folded |
| 2026-07-02 | Claude | Sprint 7 in progress by family — BuildPrison (6/45) documented; findings stashed |
| 2026-07-02 | Claude | Sprint 7 complete — Templates 45/45 (by family, merged); **all 246 entries documented**; findings folded |
| 2026-07-01 | Claude | Sprint 3 (AI, 32) documented; concerns listed for tracker intake |
| 2026-07-02 | Claude | Sprint 6 (DRN, 20) documented; concerns listed for tracker intake |
