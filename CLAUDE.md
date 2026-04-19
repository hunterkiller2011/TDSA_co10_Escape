# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

co10_Escape is a dynamic, procedurally-generated Arma 3 co-op mission where captured players escape a prison, find weapons, contact friendly forces, and reach an extraction zone. Each playthrough is different. The codebase supports 70+ island maps and multiple mod configurations (Vanilla, ACE, CUP, RHS, SOGPF, SPE, GM, etc.).

## Build System

Mission files are compiled using a custom C# WPF application:

```
Editing_and_Porting/Tools/Compiler/EscapeCompiler.exe
```

This reads `Configs/config.json` (which mods × islands × mission types to build) and generates individual `.pbo` mission files for each combination. Output files are deployed directly to an Arma 3 server's `mpmissions/` folder. `compile.py` in the root is deprecated.

Per-mod build inputs live in `Configs/{Mod}.json`. Per-island patrol zones, spawn locations, and faction loadouts live in `Islands/{IslandName}/`.

## Architecture

### Initialization

```
XEH_preInit.sqf       → Creates CBA settings from mission parameters
fn_initServer.sqf     → Server-side main: loads templates, inits factions,
                         sets up patrol zones, prison, extraction, spawns AI
fn_bootstrapEscape.sqf → Client postInit setup
```

### Function Organization

All functions use Arma 3's `CfgFunctions` system, declared in `Code/include/functions.hpp`. The namespace tag is `A3E`. Functions are called as:

```sqf
[] call a3e_fnc_functionName
```

Categories mirror directory names under `Code/functions/`:
- `A3E::Server` — server init and management (31 functions)
- `A3E::Spawning` — dynamic unit/vehicle spawning
- `A3E::AI` — patrol, search, guard, extraction, drone, chopper behaviors
- `A3E::Templates` — building template constructors for prison/comcenter/etc.
- `A3E::Zones` — patrol zone activation/deactivation
- `A3E::SearchLeader` — weapon-fire detection and enemy search escalation
- `A3E::Chronos` — event scheduling system
- `A3E::Statistics` — kill/death/time tracking, session logging
- `A3E::Common` — utility functions (briefing, markers, helpers)
- `drn::DRN` — legacy DRN library compatibility

### Key Subsystems

**Dynamic generation**: Prison, COM centers, ammo depots, mortar sites, crash sites, and extraction zones are all placed procedurally per-session using island config data.

**Search Mechanic** (`SearchLeader/`): Detects player weapon fire, reports sightings to HQ, dispatches search groups to last known positions, and escalates reinforcements.

**Revive** (`Code/Revive/`): Git submodule providing ATR revive with hindsight camera (HSC). Initialize with `git submodule update --init`.

**Statistics**: Sessions log to an external API at `http://co10esc.anzp.de/api`.

### Configuration

Mission parameters are defined in `Code/include/params.hpp` (difficulty, squad size, weather, time, revive mode, etc.) and exposed as in-game parameters. Runtime config is in `Code/config.sqf`. The preprocessor constant `BUILD` is injected from git commit hash at compile time.
