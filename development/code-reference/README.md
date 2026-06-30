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

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton; per-category docs + entry stubs (no analysis) |
