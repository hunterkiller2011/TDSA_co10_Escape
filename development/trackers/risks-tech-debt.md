# Risks & Tech Debt
_Last updated: 2026-06-30 (local)_ · _Status: active_

> Known risks and technical debt for the conversion. **ID scheme:** `RD-NNN` (stable, never reused).

## RD-001 — Enfusion AI differs fundamentally from Arma 3
**Severity:** high · **Status:** open
Patrol / search / guard / extraction logic likely needs a redesign against Reforger's AI framework
rather than a line-by-line port. Risks large rework if assumed to be a straight translation. See
[Q-004](open-questions.md).

## RD-002 — No 1:1 terrain equivalents
**Severity:** high · **Status:** open
Many of the ~119 Arma 3 islands have no Reforger counterpart; content/coverage will shrink and
per-terrain placement data must be rebuilt. See [Q-003](open-questions.md).

## RD-003 — Reforger scripting/modding API still evolving
**Severity:** medium · **Status:** open
Enforce Script and the modding APIs change between game updates — breaking-change risk across the
project's lifetime.

## RD-004 — Loss of the CBA/ACE/mod ecosystem
**Severity:** medium · **Status:** open
The mission relies on CBA settings, ACE medical, and large mod factions (CUP/RHS/…). Equivalents may
not exist in Reforger, requiring replacement or feature cuts. See [Q-007](open-questions.md).

## RD-005 — Large existing SQF surface
**Severity:** medium · **Status:** open
~215 `A3E` functions across ~13 categories plus templates/configs — full reimplementation is a
significant cost; scope must be phased. See [Q-002](open-questions.md) and
[../code-reference/](../code-reference/README.md).

## RD-006 — Dynamic dispatch hides call relationships (static-analysis blind spot)
**Severity:** medium · **Status:** open
Functions are invoked by name string via Chronos (`call compile format["call %1;",_function]`) and by
zone init via `call (missionNamespace getVariable _onInit)`. These calls are invisible to a textual
caller index, so the `_xref.md` "no references found" signal yields **false dead-code positives**.
Verify against the Chronos/template/trigger appendices before pruning anything. _(Surfaced Sprint 1.)_

## RD-007 — Dead-code candidates to confirm & prune
**Severity:** low · **Status:** open
No callers found (and not in indirect appendices): `getBuildingPositionsInMarker`, `getRndBuilding`,
`getRndBuildingPosition`, `calcMarkerArea`, `unit_debug_marker`, `startDebugView`, and the `"noMarker"`
branch of `drawMapLine`. Confirm (mind RD-006) then remove to shrink the port surface.

## RD-008 — Pervasive function-name casing inconsistency
**Severity:** low · **Status:** open
The same function is called as `a3e_fnc_`, `A3E_fnc_`, and `A3E_FNC_`; the `ace` category is defined and
called as `ACE_fnc_*` despite the CfgFunctions tag being `ace`. Harmless in SQF (case-insensitive) but
must be normalised before/during the port to Enforce Script (case-sensitive). _(Surfaced Sprint 1.)_

## RD-009 — `getSideColor` duplicated (Helper + Common)
**Severity:** low · **Status:** open
`fn_getSideColor.sqf` exists in both `Code/functions/Helper/` and `Code/functions/Common/` with the same
logic; `functions.hpp` declares one `GetSideColor`, so one copy is shadowed/unreachable. Consolidate.

## RD-010 — Dead / debug-only code candidates in Common
**Severity:** low · **Status:** open
No `fnc_` callers indexed for `CompileGroupVar`, `GetEnemyCount`, `groupChat`, `systemChat`, `findControl`
— candidate dead/debug-only code (mind RD-006 before pruning). `checkUnitClasses` is an intentional dev
QA tool but overwrites `A3E_Param_*` globals as a side effect — must never run at runtime. _(Sprint 2.)_

## RD-011 — Duplication in Common utilities
**Severity:** low · **Status:** open
`RandomPatrolPos` vs `RandomSpawnPos` are near copy-paste (both keep an unused `_minSpawnDistance`; neither
has a max-iteration guard). `GetEnemyCount` may duplicate `Spawning/fn_getDynamicSquadsize`. See RD-009. _(Sprint 2.)_

## RD-012 — Perf hotspots in Common
**Severity:** low-medium · **Status:** open
`GetPlayers` recomputed twice per iteration in `Server/fn_RunExtraction*` `while` loops; `cleanupTerrain`
issues one persistent JIP `hideObjectGlobal` remoteExec per object ×30+ camps (JIP-queue bloat, never
restored); `initArsenal` does a full `CfgWeapons` scan per box. _(Sprint 2.)_

## RD-013 — Inconsistent associative data structures
**Severity:** low · **Status:** open
`getAssocArrayEntry` uses parallel arrays with a `[]` not-found sentinel (ambiguous) while `loadLocalClasses`
uses modern HashMaps — inconsistent idioms across Common. _(Sprint 2.)_

## RD-014 — AI dead-code / empty placeholders
**Severity:** low · **Status:** open
Empty (0-byte) `fn_Loiter.sqf` and `fn_resumeTask.sqf` (dead placeholders); `fn_RandomPatrolRoute.sqf`
(its only caller is commented out); `fn_spawnGarisson.sqf` (no callers; legacy side-index model). Confirm
vs `functions.hpp` and prune. (Empty `fn_SeekShelter.sqf` is a *bug* — BUG-015 — because it is called.) _(Sprint 3.)_

## RD-015 — Heavy behavior duplication in AI
**Severity:** medium · **Status:** open
Near-parallel state machines: `ExtractionBoat/Car/Chopper`; `GuardBuilding/Occupy/PatrolBuildings`
(building-garrison); `Patrol/Guard/Stroll/AquaticPatrol` (marker/water); a flee-scatter block copy-pasted
between `CallCAS`↔`FireArtillery`; `SearchDrone`↔`LeafletDrone` (same drone state machine). Consolidate
before/into the port. _(Sprint 3.)_

## RD-016 — AI scaling / perf
**Severity:** low-medium · **Status:** open
`OrderSearch` and `EngageReportedGroup` iterate `allGroups` per report; `AddStaticGunner` creates a new
group per gunner (risking the 288-group engine limit); `RandomPatrolRoute` uses global (non-per-group)
debug-marker vars. _(Sprint 3.)_

## RD-017 — Spawning duplication & dead code
**Severity:** low · **Status:** open
`AmbientPatrols`/`CivilianCommuters`/`MilitaryTraffic` share near-identical cleanup+capped-spawn boilerplate
and copy-paste log tags (`CivilianCommuters` logs "Military Traffic created"). `getDynamicSquadsize` reads
`A3E_Param_DynamicGroupSizeMultiplier` but never applies it (dead multiplier), and its filename casing differs
from call sites; may overlap Common `GetEnemyCount`. `onEnemySoldierSpawn` has an empty silencer branch and
unused locals. _(Sprint 4.)_

## RD-018 — Two coexisting zone/spawn frameworks + possible duplicate traffic
**Severity:** medium · **Status:** open
A legacy `a3e_patrolZones` + BIS-pairs API (`initPatrolZone`/`activatePatrolZone`/`deactivatePatrolZone`)
coexists with the newer `A3E_Zones` HashMap framework (`initZone`/`populateLocationZone`/`populateVillageZone`).
`initServer` also spawns a DRN `MilitaryTraffic` alongside the Spawning one — possible duplicate systems.
Determine which is authoritative before porting. See Q-015. _(Sprint 4.)_
**Update (analysis):** `A3E_fnc_initPatrolZone` has **no callers** anywhere in the repo (grep) and is a stale
near-duplicate of the live `A3E_fnc_initZone` — the old `patrolZones` framework appears dead. It carries a
latent `_x`-for-`_shape` typo (`:31-34`), harmless only because it is unreachable. Confirm
`activatePatrolZone`/`deactivatePatrolZone` are likewise unused, then remove the old framework.

## RD-019 — SearchLeader dead/legacy residue
**Severity:** low · **Status:** open
`fn_onPlayerSpotted.sqf` is a 0-byte registered-but-empty function (`functions.hpp:268`); `fn_SearchLeader.sqf`
has a large commented-out "lost contact" block and writes `A3E_StatusOfPatrols` that nothing reads (write-only
dead data); `_strikesuccess` is assigned but unread; `SearchLeaderRadio` only logs (misnamed); a parallel legacy
`Code/Scripts/Escape/SearchLeader.sqf` still exists. Confirm the authoritative copy before porting. _(Sprint 4.)_

## RD-020 — Statistics: fragile external-API integration
**Severity:** medium · **Status:** open
External stats use a fire-and-forget `htmlLoad` on a hidden `RscHTML` control (no real HTTP client, no
error/retry handling) — may silently no-op on headless servers (see Q-016). `PingStatistics` is dead, targets a
legacy host, is NOT gated by the `A3E_Param_SendStatistics` opt-in, and injects an unescaped `serverName` into a
URL. `Save`/`Parse` statistics couple to a positional-tuple record schema with no shared definition. _(Sprint 4.)_

---

_Format for new entries:_
```
## RD-NNN — <short title>
**Severity:** low | medium | high · **Status:** open | mitigated | accepted | resolved
<description; impact; mitigation or link to ADR/Q>
```

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton; seeded RD-001…RD-005 |
| 2026-06-30 | Claude | Added RD-006…009 from code-reference Sprint 1 |
| 2026-07-01 | Claude | Added RD-010…013 from code-reference Sprint 2 (Common) |
| 2026-07-01 | Claude | Added RD-014…016 from code-reference Sprint 3 (AI) |
| 2026-07-01 | Claude | Added RD-017…020 from code-reference Sprint 4 (Spawning/SearchLeader/Statistics) |
