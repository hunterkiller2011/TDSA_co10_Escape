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
| 3 | AI | 32 | pending |
| 4 | Spawning, SearchLeader, Statistics | 36 | pending |
| 5 | Server, _init-and-includes | 38 | pending |
| 6 | DRN | 20 | pending |
| 7 | Templates (dedupe variants) | 45 | pending |

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
| AI | [AI.md](AI.md) | 32 | pending |
| Spawning | [Spawning.md](Spawning.md) | 20 | pending |
| SearchLeader | [SearchLeader.md](SearchLeader.md) | 8 | pending |
| Statistics | [Statistics.md](Statistics.md) | 8 | pending |
| Server | [Server.md](Server.md) | 30 | pending |
| _init & includes | [_init-and-includes.md](_init-and-includes.md) | 8 | pending |
| DRN | [DRN.md](DRN.md) | 20 | pending |
| Templates | [Templates.md](Templates.md) | 45 | pending |

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

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Created; Sprint 0 setup complete; Sprint 1 started |
| 2026-07-01 | Claude | Sprint 2 (Common, 35) documented; findings folded into trackers |
