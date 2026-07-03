# Architecture — Subsystem: Procedural World Generation

_Last updated: 2026-07-02 (local)_ · _Status: active (integration — draft)_

> A deep trace of how each session's world is **procedurally built**: from the per-island + per-mod data
> inputs, through position selection and exclusion, to the two template-build mechanisms and the zone
> population that garrisons everything. This is the server-side build phase
> ([lifecycle-and-timeline.md P3a](lifecycle-and-timeline.md#p3a--server-world-build)) seen as a data
> pipeline, and it resolves the extraction-marker handoff from
> [subsystem-extraction.md](subsystem-extraction.md).
>
> Per-file detail: [Server.md](../../code-reference/Server.md) / [Spawning.md](../../code-reference/Spawning.md)
> / [Templates.md](../../code-reference/Templates.md) / [Zones.md](../../code-reference/Zones.md) /
> [Helper.md](../../code-reference/Helper.md). Citations are `file:line` in the legacy Arma 3 source.

## The two data inputs

The **same `Code/`** is combined with per-island and per-mod data at build time (one PBO per
mod×island). At runtime those data files define *where* things can go and *what* fills them:

**Island data** — `Islands/<Island>/` (compiled by bootstrap, [P2](lifecycle-and-timeline.md#p2--postinit-bootstrap)) + `Missions/<Island>/mission.sqm` (editor markers):

| Global / marker | Source file | Meaning |
|-----------------|-------------|---------|
| `A3E_WorldName` | `WorldConfig.sqf` | display name |
| `A3E_ComCenterCount` | `WorldConfig.sqf` | max com-centers (Altis: 6) |
| `A3E_AmmoDepotCount` | `WorldConfig.sqf` | max ammo depots (Altis: 10) |
| `A3E_MinComCenterDistance` | `WorldConfig.sqf` | min spacing, com-centers & start (Altis: 5000) |
| `a3e_communicationCenterMarkers` | `CommunicationCenterMarkers.sqf` | list of `[[x,y,z], dir]` candidate com-center spots |
| `a3e_villageMarkers` | `VillageMarkers.sqf` | candidate village zones |
| patrol-boat markers | `PatrolBoatMarkers.sqf` | naval patrol spots |
| `A3E_*ExtractionPos*` / `*SpawnPos*` | `mission.sqm` | evac locations (→ [extraction](subsystem-extraction.md)) |
| `A3E_ExclusionZone*` | `mission.sqm` | no-spawn areas (scanned from `allMapMarkers`) |
| `drn_insurgentAirfieldMarker` | `mission.sqm` | seeds `A3E_Var_ClearedPositions` |

**Mod data** — `Mods/<Mod>/UnitClasses.sqf` (loaded by `loadLocalClasses` in P3a):

| Global family | Example | Role |
|---------------|---------|------|
| `A3E_VAR_Side_*` | `Opfor=east`, `Ind=resistance` | faction sides (+ `_Str`) |
| `A3E_*Templates` (fn-composition) | `A3E_PrisonTemplates`, `A3E_ComCenterTemplates`, `A3E_MotorPoolTemplates`, `A3E_AmmoDepotTemplates` | arrays of **`a3e_fnc_BuildX` name strings** |
| `A3E_RoadblockTemplates` (Iso data) | `rb_bis_rb1…` | names of **data-template files** in `Code/templates/` |
| `a3e_arr_Escape_InfantryTypes[_Ind]` | classname list | garrison/patrol unit pools |
| `a3e_arr_ComCenStaticWeapons` / `…ParkedVehicles` / `…Defence_*Armor` | classname lists | com-center contents/defence |
| `a3e_arr_Escape_AmmoDepot_*`, `a3e_arr_AmmoDepot*` | classname lists | depot statics + loot |
| `a3e_arr_extraction_*`, `a3e_arr_extractiontypes` | classname lists | evac vehicles/types |
| `a3e_arr_PrisonBackpacks`, `…StartPositionGuardTypes` | classname lists | prison contents |

## Pipeline

```
 ISLAND data  ─┐                    ┌─ findFlatArea (prison)              ┌─ fn-composition: A3E_*Templates
 (markers,     ├─▶ placement ───────┤─ marker-list (comcenter/village/   ├─   → callRandomFunction/remoteExec
  counts,      │   + exclusion      │   extraction: shuffle+minDist+cap)  │   → a3e_fnc_BuildX (inline createVehicle)
  distances)   │   + cleared-pos    └─ count-based (ammo/mortar/crash)    │
 MOD data     ─┘        │                                                 └─ Iso data: A3E_RoadblockTemplates
 (pools,                │                                                     → LoadTemplates → A3E_Templates
  templates)            ▼                                                     → isoTemplateRestore (data→objects)
                 initLocationZone / initVillages
                        │
                        ▼
                 initZone → A3E_Zones (HashMap) ──▶ populateLocationZone / PopulateVillageZone
                                                       → spawnPatrol + Guard/GuardBuilding
                                                       (consumes a3e_arr_*InfantryTypes + getDynamicSquadSize)
```

---

## Stage 1 — Load the data

- **Bootstrap** ([P2](lifecycle-and-timeline.md#p2--postinit-bootstrap)) compiles the island `WorldConfig`
  / `*Markers` files (and `throw`s if any island global is nil).
- **initServer** ([P3a](lifecycle-and-timeline.md#p3a--server-world-build)) runs `loadLocalClasses`
  (mod `UnitClasses.sqf` → all the `a3e_arr_*` / `A3E_*Templates` / side globals) and
  **`fn_LoadTemplates.sqf`**, which reads `A3E_RoadblockTemplates`, `call compile`s each
  `Code/templates/<name>.sqf` **Iso data file** into a data array, and stores them in `A3E_Templates`
  (dropping any that fail to load). *(This loader currently handles only the roadblock Iso templates; the
  Build* families are plain function-name arrays resolved at call time.)*

## Stage 2 — Exclusion zones & cleared positions

- **`A3E_ExclusionZones`** = every `allMapMarkers` name containing `A3E_ExclusionZone` (from `mission.sqm`),
  hidden unless debug (`initServer:175-183`). The start position must fall **outside** all of them.
- **`A3E_Var_ClearedPositions`** accumulates placed anchors — seeded with the start position and
  `drn_insurgentAirfieldMarker` (`:197-199`), then appended by each com-center — so later placement can
  keep its distance.

## Stage 3 — Prison / start position

1. **`A3E_StartPos = [] call a3e_fnc_findFlatArea`** (`initServer:190`), retried in a `while` until it is
   outside every exclusion zone (`:191-193`). `findFlatArea` picks a random map point (inset by an offset
   from the SW/NE corners) and calls `findFlatAreaNear` to find flatness within a gradient; **it loops
   until a spot is found** (see finding below).
2. **`fn_createStartpos.sqf`** selects a random `A3E_PrisonTemplates` entry (mod-defined; default 6
   `a3e_fnc_BuildPrison*`) + a random `a3e_arr_PrisonBackpacks`, and **`remoteExec`s the build function
   globally** (`_template, 0, true` — JIP-persistent). Sets **`A3E_FenceIsCreated`** (the placement
   latch, [§ latches](lifecycle-and-timeline.md#synchronization-latches)).

## Stage 4 — Site placement strategies

After the wait-for-players gate, a parallel `spawn` builds the objective sites
(`initServer:217-232`). Three placement strategies:

| Site | Placer | Strategy | Count / spacing |
|------|--------|----------|-----------------|
| Com-centers | `CreateComCenters` | **marker-list**: shuffle `a3e_communicationCenterMarkers`, keep those ≥ `A3E_MinComCenterDistance` from other picks **and** the start | cap at `A3E_ComCenterCount` |
| Villages | `initVillages` | **marker-list**: every `a3e_villageMarkers` zone | all |
| Extraction | `SelectExtractionZone` (on hack) | **marker-list** from `mission.sqm` by type + mode | one per hack |
| Ammo depots | `CreateAmmoDepots` | **count-based** near cleared area | `A3E_AmmoDepotCount` |
| Motor pools | `CreateMotorPools` | count/marker-based | config |
| Mortar sites | `createMortarSites` | count-based (fills `a3e_var_artillery_units`) | config |
| Crash sites | `createCrashSites` | count-based | `CrashSiteCountMax` (config.sqf) |
| Roadblocks | `RoadBlocks` (Chronos) | dynamic, near players | `MaxNumberOfRoadblocks` |

`CreateComCenters` is the canonical example (`fn_CreateComCenters.sqf`): for each accepted marker it
picks a build function from `A3E_ComCenterTemplates` via `callRandomFunction` (passing the mod pools
`a3e_arr_ComCenStaticWeapons` / `…ParkedVehicles`), drops the `o_hq` POI location marker + a hidden 75 m
patrol ellipse, records the position in `a3e_var_Escape_communicationCenterPositions`, and calls
`initLocationZone` (Stage 6) + `drn_fnc_Escape_InitializeComCenArmor`.

## Stage 5 — The two build mechanisms

**A. Function-composition** (`A3E_*Templates`): the template array holds **function-name strings**.
`fn_callRandomFunction.sqf` does `selectRandom` then `_params call (missionNamespace getVariable _name)`,
invoking `a3e_fnc_BuildComCenter*` / `BuildPrison*` / `BuildAmmoDepot*` / `BuildMotorPool*`, which
**`createVehicle` an inline composition** of objects/statics/loot. The prison uses `remoteExec` instead
(so the fence exists on all machines).

**B. Iso data-templates** (`A3E_RoadblockTemplates`): the array holds **data-file names**.
`fn_LoadTemplates` compiles them into data arrays (`A3E_Templates`); `fn_isoTemplateRestore.sqf` later
walks a template's `Objects` list and `createVehicle`s each, applying per-object attributes — `terminal`
(→ `A3E_isTerminal`, the hackable com-center object; see [extraction Stage 2](subsystem-extraction.md#stage-2--hack-the-terminal)),
`indestructable`, `static` / `parkedvehicle` / `ammobox` (deferred spawn lists), `inflame`, `yeet`, and
a compiled `init` string. It also honours a `Clearance` box (hides terrain objects in the footprint).

> Two mechanisms for the same job (**RD-028**): composition functions vs data-driven Iso templates. The
> Iso path (data + one restorer) is the better port target; the `Build*` families are ~40 copy-pasted
> functions with no cleanup (**RD-026/RD-027**).

## Stage 6 — Zone population (garrisoning)

Placement records positions; **population** puts units there via the `A3E_Zones` HashMap framework:

- **`initLocationZone`** (`[pos, size, side, type]`) → `initZone` registers an **ELLIPSE zone** in
  `A3E_Zones` with the populator `A3E_FNC_populateLocationZone` and a `type`
  (`COMCENTER`/`AMMODEPOT`/`MOTORPOOL`/`MORTAR`/`ROADBLOCK`). **`initVillages`** does the same per village
  marker with `PopulateVillageZone` / type `Village`.
- **`populateLocationZone`** (run when the zone activates) sets a **patrol count by type** — COMCENTER 6,
  MOTORPOOL 5, AMMODEPOT 4, MORTAR 2, ROADBLOCK 2, default 4 — chooses the infantry pool by side
  (`a3e_arr_Escape_InfantryTypes` / `…_Ind`), spawns some **building guards** and `_patrolCount` patrol
  groups (`spawnPatrol`, size from `getDynamicSquadSize`), and assigns each `Guard` (70 %) or
  `GuardBuilding` (30 %). Groups are stored back on the zone.

> This is the **live** zone framework (`A3E_Zones` + `initZone` + populate*). The older `patrolZones` /
> `initPatrolZone` pair is legacy/dead — which framework is authoritative is **Q-015**.

## RNG & determinism

World generation is **RNG-driven** end-to-end: `findFlatArea` (random point), `selectRandom` for every
template pick and pool draw, `random` spacing/facing, shuffled marker order, `getDynamicSquadSize`,
`BIS_fnc_randomPosTrigger` for garrison spots, the 70/30 Guard split. There is **no seed control**, so no
two sessions are alike and a bug tied to a specific layout is hard to reproduce. For testing, the
debug-hooks in [test-scenarios.md](../../trackers/test-scenarios.md) (force template / force position)
are the way to pin a layout — relevant to the RNG-dependency question raised there.

## Findings / issues

- **RD-028** (two template mechanisms) and **RD-026/RD-027** (copy-paste `Build*`, no cleanup) — see Stage 5.
- **Q-015** (two zone frameworks; `A3E_Zones` live, `patrolZones` legacy) — see Stage 6.
- **BUG-021** — `populateLocationZone:32` uses `_x` (`[_x] call a3e_fnc_getBuildingsInMarker`) *before*
  the `for "_x"` loop at `:48` rebinds it; `_marker` is intended. Already tracked (this trace confirms
  the call-site).
- **BUG-032** — the `Functions.sqf` `_PopulateVehicle` counter no-op (already tracked) sits in this build
  path.
- **RD-036** (new) — **world-gen placement loops have no bounded fallback.** `findFlatArea`'s
  `_max_num_search_areas=0` "give up" path is effectively dead (the `while` only exits when a position is
  found), and the exclusion-zone retry (`initServer:191`) is likewise unbounded — on a pathological map
  (all-water / fully excluded) generation can spin forever. Add a bounded retry + fallback for the port.
- **Layout risk** — `A3E_ComCenterCount` can exceed what `A3E_MinComCenterDistance` allows (Altis: 6
  wanted, 5 km spacing) → fewer centers than requested. Design tradeoff, not a bug, but worth a param note.

## Reforger port notes

- **Data inputs** → world/scenario config + a per-faction data asset, not compiled `.sqf` globals; the
  per-mod×island PBO permutation becomes scenario/config variants (Q-001/Q-005/Q-007).
- **Placement** → a spawn-point/placement system querying pre-authored `SCR_SpawnPoint`-style entities or
  sampling navmesh for flat ground; **bound the retries** (RD-036) and keep exclusion zones as trigger/area
  volumes.
- **Build mechanisms** → **unify on the data-driven path**: prefabs (`.et`) selected by a weighted table
  and instantiated by a spawner component; drop the ~40 composition functions. The Iso `terminal`/`static`/
  `parkedvehicle`/`ammobox`/`init` attributes map to prefab components/attributes.
- **Zone population** → a garrison/zone manager component that spawns AI groups into an area from a faction
  pool, with per-type counts as config; replace the `A3E_Zones` HashMap + string populators.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-07-02 | Claude | Initial world-generation subsystem trace (data inputs → placement → build mechanisms → zone population; RNG note). Surfaced RD-036 (unbounded placement loops); confirmed RD-028/Q-015/BUG-021 in the build path |
