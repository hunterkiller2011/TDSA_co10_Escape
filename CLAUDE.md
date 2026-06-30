# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

co10_Escape is a dynamic, procedurally-generated Arma 3 co-op mission where captured players escape a prison, find weapons, contact friendly forces, and reach an extraction zone. Each playthrough is different. The codebase supports ~119 island maps and ~17 mod configurations (Vanilla, ACE, CUP, RHS, SOGPF, SPE, GM, etc.) — the same `Code/` is combined with per-island and per-mod data to emit one `.pbo` per (mod × island × mission-type) combination.

## Build System

Mission files are compiled with a custom **Windows WPF GUI** application (no command-line interface):

```
Editing_and_Porting/Tools/Compiler/EscapeCompiler.exe
```

Workflow: launch the exe, point it at the repository folder and an output folder, build. It reads `Configs/config.json` (which mods × islands × mission types to build), performs the string-replacement templating, injects the current git commit hash into the `BUILD` constant, and writes individual `.pbo` files (output can be thousands of missions). Build progress/errors go to `Editing_and_Porting/Tools/Compiler/log.txt`.

`compile.py` and `pack_addons.py` in the root are **deprecated** legacy Python build/pack scripts; the C# compiler is the current tool.

There is **no automated test suite, linting, or CI** (only `.github/FUNDING.yml` exists). Validation is manual in-game playtesting.

### Local development / live editing

`Editing_and_Porting/linkCode.bat` is the fast iteration loop: it junction-links the source folders (`Code/functions`, `Code/include`, `Code/Scripts`, `Code/Revive`, `Factions/`) and per-island/per-mod files into a local `...\Arma 3\<profile>\missions\Escape_Dev.<Island>` folder, so you can edit source and reload in the Arma 3 editor without recompiling. Set `source`, `target`, `island`, and `mod` at the top of the script before running it.

## Architecture

### Initialization

Wired via `Code/description.ext`, which registers a CBA PreInit event handler:

```
XEH_preInit.sqf            → Creates CBA settings from mission parameters (params.hpp)
fn_bootstrapEscape.sqf     → postInit (runs after object init). call-compiles config.sqf
                             and the per-island Island/*.sqf, then on the server spawns
                             a3e_fnc_missionFlow + a3e_fnc_initServer, and on clients
                             spawns a3e_fnc_initLocalPlayer
fn_initServer.sqf          → Server-side main: loads templates, inits factions, sets up
                             patrol zones, prison/COM/ammo/mortar/crash sites, extraction,
                             search leader, statistics, and registers Chronos tasks
```

Server-only vs client logic is separated with `isServer` / `hasInterface` guards.

### Function Organization

All functions use Arma 3's `CfgFunctions` system, declared in `Code/include/functions.hpp`. The namespace tag is `A3E`. Functions are called as:

```sqf
[] call a3e_fnc_functionName
```

Categories mirror directory names under `Code/functions/` (approximate counts):
- `Server` (~30) — server init and management
- `Common` (~35) — utilities: briefing, arsenal, markers, the bootstrap
- `AI` (~32) — patrol, search, guard, extraction, drone, chopper behaviors
- `Templates` (~45) — building/object template constructors (prison, COM center, ammo, mortar, crash site, roadblock)
- `Spawning` (~20) — dynamic unit/vehicle spawning, village population
- `Zones` (6) — patrol zone activation/deactivation
- `Statistics` (8) — kill/death/time tracking, session logging
- `Searchleader` (8) — weapon-fire detection and enemy search escalation (directory is `SearchLeader/`; the CfgFunctions class is `Searchleader` — mind the case)
- `Chronos` (4) — recurring event scheduler
- `Helper` (7) — math/geometry utilities (circles, markers, buildings)
- `Garrison` (4) — building-position helpers
- `Debug` (7) — logging, markers, tracking
- `Intel` (3) — intel collection/revelation
- `drn::DRN` (20) — legacy DRN library compatibility
- `ace` (4) — ACE medical integration

The ATR revive + ATHSC hindsight camera functions are `#include`d into `functions.hpp` from the `Code/Revive` submodule (excluded when `A3E_EDITOR` is defined).

### Key Subsystems

**Dynamic generation**: Prison, COM centers, ammo depots, mortar sites, crash sites, and extraction zones are placed procedurally per-session using island config data.

**Chronos** (`Chronos/`): The recurring-task scheduler. `fn_Chronos_Init` creates a trigger firing every `A3E_CronTime` (~5s); functions are registered via `A3E_FNC_Chronos_Register` and dispatched on their own interval. It drives the ambient systems — RoadBlocks, AmbientPatrols, MilitaryTraffic, CivilianCommuters, and group tracking. Tuning the cadence/volume of these systems generally means changing their registration in `fn_initServer.sqf` and the config values they read.

**Search Mechanic** (`SearchLeader/`): Detects player weapon fire, reports sightings to HQ (via "known position" helper objects), dispatches idle patrol groups to last-known positions, and escalates with reinforcements and artillery/CAS the longer contact is held.

**Revive** (`Code/Revive/`): Git submodule providing ATR revive with hindsight camera (HSC). Initialize with `git submodule update --init --recursive`.

**Statistics**: Sessions log to an external API at `http://co10esc.anzp.de/api`.

### Configuration

- `Code/include/params.hpp` — mission parameters (difficulty, squad size, enemy skill, spawn distance, weather, time, revive mode, etc.), exposed as in-game parameters and turned into CBA settings by `XEH_preInit.sqf`.
- `Code/config.sqf` — runtime config variables (`a3e_var_*`: search range, investigation chance, debug flags, artillery, roadblocks, etc.).
- `Configs/config.json` — top-level build config: `Subconfigs` (the per-mod files to include), global `replace` map, `ParsedFiles` (which files get template substitution), `Mods`, and `Islands`.
- `Configs/{Mod}.json` — per-mod build inputs. Each mod entry defines `require` (addon dependencies) and a `replace` map (`PLAYERSIDE`, `PLAYERUNIT_1`..`PLAYERUNIT_10`, `PLAYER_INIT`, etc.).
- `Islands/{IslandName}/` — per-island data: `WorldConfig.sqf`, `VillageMarkers.sqf`, `CommunicationCenterMarkers.sqf`, `PatrolBoatMarkers.sqf` (patrol zones, spawn locations).

The `BUILD` preprocessor constant (`Code/include/defines.hpp`) is the placeholder `{* COMMIT *}`, replaced with the git commit hash by the compiler at build time and exposed as `EscapeBuild` in `description.ext`.

### Conventions

- Functions: `a3e_fnc_*` (also written `A3E_FNC_*` at call sites).
- Globals / replicated state: `A3E_VAR_*`, `a3e_var_*`, `A3E_Param_*`, stored in `missionNamespace` (pass `true` as the third `setVariable` arg to broadcast to JIP clients).
- Locals: `_camelCase` (underscore-prefixed, function-scoped).
- AI groups carry state via `setVariable` (e.g. `A3E_TaskState` = `"IDLE"`/`"PATROL"`), queried by `side` + task state.

## Documentation (keep it current)

Planning & engineering docs live under [`development/`](development/README.md) — **start there**. It is a
planning workspace and is **NOT shipped**; production code is the top-level Arma 3 dirs (`Code/`,
`Configs/`, `Islands/`, `Mods/`, `Factions/`). End-user (player) help lives under [`wiki/`](wiki/README.md).

Key entry points:
- [development/README.md](development/README.md) — documentation index/map.
- [development/code-reference/](development/code-reference/README.md) — per-function reference of the
  existing SQF code (inputs/outputs/processing/theory/whys/issues/port-notes), used to inform the
  Arma 3 → Reforger port. The branch `convert-to-reforger` tracks that conversion.
- `development/trackers/` — `open-questions.md` (Q-NNN), `risks-tech-debt.md` (RD-NNN),
  `decision-log.md` (ADR-NNNN), bugs, feature requests.

When you change code or direction, update the doc(s) that reference it: bump the `_Last updated:_`
line, add a Revision History row, note it in [development/CHANGELOG.md](development/CHANGELOG.md), and log
decisions/bugs/questions in the appropriate tracker. Doc conventions are defined in
[development/docs/project-template.md](development/docs/project-template.md).
