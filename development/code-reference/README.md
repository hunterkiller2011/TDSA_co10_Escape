# Code Reference — Legacy Arma 3 Source Map
_Last updated: 2026-06-30 (local)_ · _Status: skeleton_

> A reverse-engineering reference of the **existing Arma 3 mission code**, so the Reforger port is
> driven by real understanding of what each piece does and why. **This is documentation of the legacy
> source — not the port itself.**
>
> Structure mirrors the code: **one doc per `Code/functions/` category**, plus
> [`_init-and-includes.md`](_init-and-includes.md) for the entry-point/config files. Each doc contains
> **one entry per source file**. As of this skeleton every field is a stub (`_(to document)_`); no
> analysis has been written yet.

## How to use

Fill one entry at a time as you study a function. When an entry raises a question or surfaces a
problem, also log it in the trackers and link the ID back here:
- design questions → [open-questions.md](../trackers/open-questions.md) (`Q-NNN`)
- bugs → [bugs-app.md](../trackers/bugs-app.md) (`BUG-NNN`)
- risks / tech debt → [risks-tech-debt.md](../trackers/risks-tech-debt.md) (`RD-NNN`)

> **Call names:** entry headings use the call name inferred from the file name (`a3e_fnc_*` for `A3E`
> categories, `drn_fnc_*` for DRN, `ace_fnc_*` for ace). CfgFunctions class names sometimes differ in
> casing from file names — confirm the exact name against [`Code/include/functions.hpp`](../../Code/include/functions.hpp)
> when documenting. The **path** on each heading line is authoritative.

> **SQF reviewer caveats** (do NOT flag these as bugs):
> - **Magic variables** are auto-bound by the engine and are *not* undefined inside their constructs:
>   `_x` / `_y` / `_forEachIndex` (in `forEach`/`count`/`select`/`apply`/`findIf`), `_this` (params, `call`,
>   event handlers), `this` / `thisList` / `thisTrigger` (triggers), `_exception` (`catch`), `_thisScript`,
>   `_fnc_scriptName`. Only flag one if it is used **outside** any such construct — always check the
>   enclosing scope first (an `_x` at top-level function scope with no surrounding iterator *is* a real
>   defect; an `_x` inside a `forEach` block is correct).
> - **`call`/`spawn` inherit the caller's locals:** a called function or code block can read local variables
>   (including a `forEach` `_x`) from the scope that invoked it, unless it re-declares them (`params`/`private`).
>   So a bare `_x` in a function may be legitimately supplied by a caller's loop — trace the **call chain**
>   (who calls it, and is that call site inside a `forEach`?), not just the function's own body, before flagging.
> - **Case-insensitivity:** function/command names are case-insensitive (`a3e_fnc_Foo` == `A3E_FNC_FOO`);
>   casing mismatches are style noise (tracked as RD-008), not bugs.
> - Verify any suspected undefined variable against its enclosing scope before recording it as a bug.

## Entry template

Each entry uses these fields:

```
### <call_name>  —  `Code/functions/<Cat>/fn_<Name>.sqf`  ·  _status: stub | documented_
- **Purpose:** what it's for and why it exists, in a line or two.
- **Inputs:** parameters; global state read (A3E_VAR_* / a3e_var_*); preconditions.
- **Outputs:** return value; global state written; side effects (units/markers spawned, remoteExec).
- **Calls:** functions/scripts/files it invokes (callees).
- **Called by:** what invokes it (callers) — mark indirect: postInit / Chronos / template-array / trigger / event / remoteExec; "[engine/scheduler]" for entry points. See [_xref.md](_xref.md).
- **Processing:** the key steps / control flow.
- **Theory of operation:** why it works this way; how it fits the larger system (brief).
- **Whys & questions:** design rationale; open questions (link Q-NNN).
- **Unresolved issues:** suspected bugs, tech debt, uncertainties (link BUG-NNN / RD-NNN).
- **Reforger port notes:** how this maps to Enfusion / Enforce Script (optional / TBD).
```

> **Working files:** [_xref.md](_xref.md) is the generated caller cross-reference index (who calls
> each function, including indirect registrations). [_PROGRESS.md](_PROGRESS.md) is the per-category
> documentation ledger — the resume point if work is interrupted. An entry is **done** when it has no
> `_(to document)_` fields left.

## Category index

| Doc | Code dir | Files |
|-----|----------|-------|
| [Server.md](Server.md) | `Code/functions/Server/` | 30 |
| [Spawning.md](Spawning.md) | `Code/functions/Spawning/` | 20 |
| [AI.md](AI.md) | `Code/functions/AI/` | 32 |
| [Templates.md](Templates.md) | `Code/functions/Templates/` | 45 |
| [Zones.md](Zones.md) | `Code/functions/Zones/` | 6 |
| [SearchLeader.md](SearchLeader.md) | `Code/functions/SearchLeader/` | 8 |
| [Chronos.md](Chronos.md) | `Code/functions/Chronos/` | 4 |
| [Statistics.md](Statistics.md) | `Code/functions/Statistics/` | 8 |
| [Common.md](Common.md) | `Code/functions/Common/` | 35 |
| [Helper.md](Helper.md) | `Code/functions/Helper/` | 7 |
| [Garrison.md](Garrison.md) | `Code/functions/Garrison/` | 5 |
| [Debug.md](Debug.md) | `Code/functions/Debug/` | 11 |
| [Intel.md](Intel.md) | `Code/functions/Intel/` | 3 |
| [DRN.md](DRN.md) | `Code/functions/DRN/` | 20 (legacy) |
| [ace.md](ace.md) | `Code/functions/ace/` | 4 |
| [_init-and-includes.md](_init-and-includes.md) | entry points & includes | 8 |
| [Scripts-Escape.md](Scripts-Escape.md) | `Code/Scripts/Escape/` (legacy) | 11 |
| [Scripts-Support.md](Scripts-Support.md) | `Code/Scripts/{DRN,AT,outlw_magRepack}/` | 7 |
| [Templates-Iso.md](Templates-Iso.md) | `Code/templates/` (Iso data) | 11 |

## Coverage & gaps

The code-reference documents **`Code/functions/**`** (238 functions, 15 category docs) **+ the entry/config files**
(`_init-and-includes.md`: `description.ext`, `XEH_preInit.sqf`, `fn_bootstrapEscape`, `fn_initServer`,
`include/{functions,params,defines}.hpp`, `config.sqf`). Other repo code is **not yet covered** — listed here so the
gap is explicit:

| Area | Files | Status | Notes |
|------|-------|--------|-------|
| `Code/Scripts/` | 18 | **documented** → [Scripts-Escape.md](Scripts-Escape.md) (11) + [Scripts-Support.md](Scripts-Support.md) (7) | Live legacy helpers + the `EscapeSurprises` reinforcement system + DRN CommonLib + AT drone hack + third-party magRepack. Findings: BUG-032/033, RD-031…033, Q-023. |
| `Code/templates/` | 11 | **documented** → [Templates-Iso.md](Templates-Iso.md) | Live Iso roadblock data-templates — all 11 referenced by per-mod `A3E_RoadblockTemplates` (none orphaned; `rb_bis_rb4` is used by CSLA/SFP, just not the vanilla default). Findings: RD-034. |
| `Code/cba_settings.sqf` + CBA usage | 1 | **evaluate (Q-022)** | Default CBA settings + the mission's CBA touchpoints. Evaluate what must be brought under the mission's control for Reforger (no CBA there). |
| `Code/Revive/` | 45 | **TODO (owner): vendor in** | ATR revive + HSC — currently a git submodule; to be brought into this repo so it's part of the conversion. |
| `Islands/` | ~476 | data — **evaluated** | Per-world config: `WorldConfig.sqf` sets counts/distances (`A3E_ComCenterCount`, `A3E_AmmoDepotCount`, `A3E_MinComCenterDistance`, `A3E_WorldName`); `*Markers.sqf` are `[[x,y,z], dir]` spawn-location lists (com centers, villages, patrol boats). Data — no per-file docs planned. |
| `Mods/` | ~89 | data — **evaluated** | Per-mod `UnitClasses.sqf`: side/flag setup, unit/vehicle/weapon spawn pools (probability-weighted classname "random arrays"), and the `A3E_*Templates` selection arrays (RD-028). |
| `Factions/` | 1 | **dead/unfinished system** (RD-030) | Not just data — an *unwired* faction-abstraction: `loadFaction`/`selectFaction`/`getRndEntryFromFaction` have no callers and the `A3E_*Factions` pools are never populated (only `BIS_Syndikat.sqf` authored). Live unit system is `Mods/UnitClasses`. Resolves Q-018. |
| root `compile.py`, `pack_addons.py` | 2 | out of scope | Deprecated build scripts (noted in CLAUDE.md). |

**Plan:** document `Code/Scripts/` (own effort, split up) and `Code/templates/` next; **vendor `Code/Revive/` into the repo** (owner TODO); **evaluate CBA** internalization (Q-022). `Islands/`/`Mods/`/`Factions/` are data (schema above) — no per-file docs planned.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton; per-category docs + entry stubs (no analysis) |
| 2026-07-02 | Claude | Added SQF reviewer caveats; added Coverage & gaps (Scripts/templates/data not yet covered) |
