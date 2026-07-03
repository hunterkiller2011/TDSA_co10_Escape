# Risks & Tech Debt
_Last updated: 2026-07-02 (local)_ · _Status: active_

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
**Update (Sprint 6):** the DRN `MilitaryTraffic` spawns (`initServer:399/400`) are inside the dead `if(false)`
block (`:251-441`), so they do **not** run — there is **no live traffic duplication**; the live traffic system
is A3E `MilitaryTraffic` via Chronos (`:681`).

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

## RD-021 — Shipped dev/insecure mission config
**Severity:** medium · **Status:** open
`Code/description.ext` ships with `enableDebugConsole = 1` (`:40`), `allowFunctionsRecompile = 1` (`:41`),
`CfgRemoteExec.Functions mode = 2` (whitelist ignored, `:104`), and an `allowedHTMLLoadURIs` list that
includes a dev endpoint `http://localhost:5093/api/session*` (`:215`) plus plain-HTTP stat endpoints. Harden
(disable debug console/recompile, mode 1 + explicit whitelist, drop the dev/cleartext URIs) for public builds. _(Sprint 5.)_

## RD-022 — `initServer` dead code & intra-file duplication
**Severity:** medium · **Status:** open
`fn_initServer.sqf` contains a large dead `if(false) then {…}` legacy DRN block (`:251-441`), a duplicated
crash-site loop (also in `fn_CreateCrashSites`), a duplicate `a3e_var_Escape_enemyMin/MaxSkill` assignment
(`:161-164`), and a war-crime decay loop marked "move to Chronos" (`:688-697`). Prune before/during the port. _(Sprint 5.)_

## RD-023 — Extraction & site-placement duplication
**Severity:** medium · **Status:** open
`RunExtraction`/`RunExtractionHeli`/`RunExtractionBoat`/`RunExtractionCar` are near-duplicate runners (collapse
into one parameterized runner; ties to RD-015 and BUG-016). `createAmmoDepots`/`createMortarSites` share an
identical quadrant/clearance placement loop — dedup. _(Sprint 5.)_

## RD-024 — Build-pipeline & submodule coupling
**Severity:** low · **Status:** open
`include/functions.hpp` `#include`s the ATR/ATHSC revive configs, so a missing Revive submodule breaks config
parse; `include/defines.hpp` relies on `EscapeCompiler.exe` substituting `{* … *}` tokens (incl. `BUILD`), so an
uncompiled build ships garbage version/build metadata. Both matter when standing up the Reforger build. _(Sprint 5.)_

## RD-025 — DRN legacy library is largely dead / superseded
**Severity:** medium · **Status:** open
`Code/functions/DRN/` is mostly not live — a major prune opportunity for the port:
- **Disabled** (inside the dead `if(false)` block at `initServer:251-441`): `AmbientInfantry`, `InitAquaticPatrols`
  and its trigger-wired `PopulateAquaticPatrol`/`DepopulateAquaticPatrol`, and `MilitaryTraffic`.
- **Superseded** (no callers; A3E equivalent exists): `PopulateVillage`/`DepopulateVillage`
  (→ `Spawning/fn_populateVillageZone`); the `InitGuardedLocations` → `PopulateLocation`/`DepopulateLocation`/
  `GarrisonUnits` chain (→ `Spawning/fn_populateLocationZone`); `MoveInfantryGroup` (→ `AI/fn_Patrol`);
  `MoveVehicle`; `MonitorEmptyGroups`; `InitAquaticPatrolMarkers`.
- **Still live** (verify): `InitVillageMarkers` (`:205`), and the search-chopper/insertion path
  (`SearchChopper`/`SearchGroup`/`MotorizedSearchGroup`/`InsertionTruck`) via external `Scripts\Escape\*`.
Also hard-depends on an external CommonLib (`drn_fnc_CL_*`) and uses magic-index soldier schemas that differ
from the A3E ones. _(Sprint 6.)_

## RD-026 — Template compositions: duplication + no cleanup
**Severity:** medium · **Status:** open
The composition families (Prison, AmmoDepot, ComCenter, MotorPool, MortarSite) are Map-Builder-exported scripts
with massive copy-paste (loot-fill loops, placement helpers repeated across ~40 files) and **no cleanup** — every
object/box/flag/gunner/vehicle is `createVehicle`'d and never tracked or despawned, so a mission with N ammo
depots + com centers + motor pools + mortars accumulates persistent entities that are never removed (even when an
objective is neutralized). Prime port target: one data-driven builder per type + lifecycle-tracked entities. _(Sprint 7.)_

## RD-027 — Dead / duplicate template compositions
**Severity:** low · **Status:** open
The 6 `fn_Roadblock*` composition functions have **no callers** — the live roadblocks use the Iso data-template
system instead (`A3E_RoadblockTemplates` = `rb_bis_rb*` → `fn_LoadTemplates` → `A3E_fnc_IsoTemplateRestore` →
`Server/fn_RoadBlocks.sqf` spawns guards/statics). `fn_Roadblock*` are orphaned source the `rb_*` data files were
derived from. Also `fn_MortarSite2.sqf` is a byte-for-byte copy of `fn_MortarSite.sqf`. Prune. _(Sprint 7.)_

## RD-028 — Template registration & mod-classname coupling
**Severity:** low · **Status:** open
The `A3E_*Templates` selection arrays are set per-mod in `Mods/{Mod}/UnitClasses.sqf` (with hardcoded defaults in
the `Server/fn_create*.sqf` functions), **not** in `fn_LoadTemplates.sqf`. The `_spe*`/`_vn*`/`_ger*` variants
hardcode mod-specific classnames (`SPE_*`, `Land_vn_*`, `vn_*`) that would error if selected under a mismatched mod
— safe only because each is registered exclusively in its mod's UnitClasses. Two template mechanisms coexist
(function-compositions vs Iso data-templates); unify for the port. _(Sprint 7.)_

## RD-029 — Shipped dev/debug residue in templates
**Severity:** low · **Status:** open
`fn_isoTemplateStore.sqf` is a dev-only authoring tool (`copyToClipboard`/`systemChat`, no runtime callers) shipped
in the release PBO; the SPE/VN MotorPool builders `diag_log` every placed object; commented-out Map-Builder export
scaffolding is left throughout the template files. _(Sprint 7.)_

## RD-030 — Unfinished/dead faction-abstraction system (`Factions/`)
**Severity:** low · **Status:** open
`Factions/*.sqf` + `A3E_fnc_loadFaction`/`selectFaction`/`getRndEntryFromFaction` implement a data-driven faction
system (a faction file → key/value unit pools; per-side pools `A3E_*Factions`; random unit picks) — but it is
**never wired in**: the functions have **no callers** and the side pools are **never populated** (only
`Factions/BIS_Syndikat.sqf` was ever authored, and `selectFaction` has an unimplemented positional-selection TODO).
The live unit system is `Mods/{Mod}/UnitClasses.sqf`. **Port decision:** either delete this dead system, or *finish
it* — a data-driven faction abstraction is arguably a cleaner fit for Reforger than the scattered
`Mods/UnitClasses` classname globals. Resolves Q-018. _(Coverage review.)_

## RD-031 — `Code/Scripts/` legacy dead / superseded code
**Severity:** low · **Status:** open
Dead/superseded scripts under `Code/Scripts/`: `Escape/AIskills.sqf` (loaded at `initServer:13` but its
`EGG_EVO_skill` has no live callers), `Escape/SearchLeader.sqf` (commented `//depreciated` at `initServer:236` —
confirms RD-019; superseded by the `Code/functions/SearchLeader/` category), several `drn_fnc_CL_*` in
`DRN/CommonLib/CommonLib.sqf` (`InitParams`/`GetMarkerWithinRange`/`GetClosestMarker`/`RotatePosition`/`AddScore*`
unused; the garbage collector's body is fully commented out — inert), and possibly-shadowed helpers in
`Escape/Functions.sqf`. Also the **DRN-era extraction path** in `Escape/Functions.sqf:150-166`
(`drn_fnc_Escape_CreateExtractionPointServer` + the `drn_EscapeExtractionEventArgs`
`addPublicVariableEventHandler`) is dead — nothing outside that block sets the PV or calls the function
(grep-confirmed); superseded by `A3E_fnc_SelectExtractionZone` → `A3E_fnc_CreateExtractionPoint` (see
[subsystem-extraction.md](../docs/architecture/subsystem-extraction.md)). Prune during the port. _(Scripts review; extraction trace.)_

## RD-032 — Reinforcement system (`EscapeSurprises`/`*Chopper`) fragility & leaks
**Severity:** medium · **Status:** open
`Code/Scripts/Escape/EscapeSurprises.sqf` appends a successor entry on every firing and never removes executed
entries, so its `foreach` scans an ever-growing `_surprises` list (memory/CPU leak on long sessions).
`DropChopper.sqf`'s cleanup `while{!missionCompleted}` never exits if the chopper dies mid-flight (leaked thread +
wreck; no death/abort guard). `CreateDropChopper`/`CreateSearchChopper` share the `drn_searchChopperN` global
var-name family with independent counters — collision avoided only coincidentally. _(Scripts review.)_

## RD-033 — Bundled third-party scripts: port / licensing debt
**Severity:** low · **Status:** open
`Code/Scripts/outlw_magRepack/*` (Outlawled/GiPPO Mag Repack v3.1.3, 2015) is bundled with **no license stated
in-file** (see Q-023) and is entirely Arma-3 dialog/magazine API — **do not port; reimplement natively if wanted**
(stray `}:` typo at `MagRepack_Main.sqf` ~:898). `Code/Scripts/AT/hackdrone.sqf` hard-codes vanilla + `*_lxWS`
UAV/terminal classname lists (silently no-ops on other modsets); the Reforger UAV model differs — redesign or drop. _(Scripts review.)_

## RD-034 — Iso roadblock template schema cruft
**Severity:** low · **Status:** open
In `Code/templates/*.sqf`: the `["probability",N]` attribute on optional gun slots (rb_bis_rb2/rb4, rb_gm_rb3) is
**never read** by `isoTemplateRestore`/`RoadBlocks`, so those slots always emit; and the `ammoboxes` slot type is
fully unused on both producer and consumer sides. Minor schema debt to drop/implement in the port. _(Iso-templates review.)_

## RD-035 — Vestigial `civilianReporting` clean-win gate (superseded by war-crime score)
**Severity:** low · **Status:** open
`a3e_var_Escape_SearchLeader_civilianReporting` gates the **end2 clean-win** trigger
(`fn_missionFlow.sqf:17`: `... && !a3e_var_Escape_SearchLeader_civilianReporting && ...`), but it is
**only ever assigned `false` in live code** (`missionFlow:4`); the single `= true` site is the deprecated
`Code/Scripts/Escape/SearchLeader.sqf:30` (RD-019, not loaded). So the gate term is **always true** — the
implied "shot civilians ⇒ no clean win" mechanic is inert. That penalty is now carried by the **war-crime
score** path (`A3E_Warcrime_Score` → end4 tainted win at >1000; see
[state-and-data-flow.md §2/§5](../docs/architecture/state-and-data-flow.md#2-mission-outcome-chain)).
`fn_handleScore.sqf:3` only checks the var's *presence* (`!isNil`), not its value, so it doesn't revive it.
**Port decision:** delete the dead gate, or re-wire civilian-reporting to actually set it. Verify in-game
first. _(Integration data-flow review.)_

## RD-036 — World-gen placement loops have no bounded fallback
**Severity:** low-medium · **Status:** open
The procedural placement retries are unbounded: `A3E_fnc_findFlatArea` is called with
`_max_num_search_areas = 0` and its "give up" branch is effectively dead (the `while {count _final_pos == 0}`
only exits when a flat spot is found), and the start-position exclusion retry
(`fn_initServer.sqf:191`, `while {A3E_StartPos inArea exclusionZone} …`) likewise loops until success. On a
pathological map (all-water, or fully covered by exclusion zones) world generation can spin forever with no
timeout/fallback, hanging the mission at load. Add a bounded retry count + a sensible fallback position for
the port. **Not yet triggered in practice** (user 2026-07-03): the group's map rotation is pre-tested — incl.
water-surrounded islands — and always generates, since any map with *some* flat land resolves quickly; the risk
is for untested/pathological maps. Pre-testing is the current mitigation. See also BUG-011 (the same function's
inverted return-flag) — fix both together. _(World-generation trace; see [subsystem-world-generation.md](../docs/architecture/subsystem-world-generation.md) Stage 3.)_

## RD-037 — Garbage collector disabled but still fed (long-session unit leak)
**Severity:** medium · **Status:** open
`drn_fnc_CL_RunGarbageCollector` (removes empty groups + units queued via `drn_fnc_CL_AddUnitsToGarbageCollector`,
`Code/Scripts/DRN/CommonLib/CommonLib.sqf:444`) is **commented out** at `fn_initServer.sqf:244`, so it never runs —
yet spent search/reinforcement groups are still **queued** into it at runtime (`fn_SearchGroup.sqf:169`,
`fn_MotorizedSearchGroup.sqf:213,233` call `AddUnitsToGarbageCollector`). Those units are therefore **never
collected**; they persist for the whole session and `a3e_var_CL_GarbageCollectorUnits` grows unbounded. A direct
contributor to the **confirmed gradual long-session performance decline** (user-reported 2026-07-03), alongside
**RD-026** (spawned composition objects never despawned) and the minor **BUG-007** (idle zone triggers never
deleted). Note the decline is **not** carcasses — capped by `description.ext` (`corpseLimit=30`/`wreckLimit=10`).
**Port:** implement a real periodic cleanup — the traps system `fn_updateTraps.sqf` (bounded list + distance-based
despawn) is the good in-repo pattern — or remove the dead GC queueing. _(Perf-decline investigation.)_

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
| 2026-07-02 | Claude | Added RD-021…024 from code-reference Sprint 5 (Server/init) |
| 2026-07-02 | Claude | Added RD-025 + corrected RD-018 (DRN traffic dead) from Sprint 6 (DRN) |
| 2026-07-02 | Claude | Added RD-026…029 from code-reference Sprint 7 (Templates) |
| 2026-07-02 | Claude | Added RD-030 (dead/unfinished Factions/ faction-abstraction system) |
| 2026-07-02 | Claude | Added RD-031…034 from Scripts/ + Iso-templates review |
| 2026-07-02 | Claude | Added RD-035 (dead civilianReporting win-gate) from integration data-flow review |
| 2026-07-02 | Claude | Added RD-036 (unbounded world-gen placement loops) from world-generation trace |
| 2026-07-03 | Claude | Added RD-037 (garbage collector disabled but still fed) from long-session perf-decline investigation |
