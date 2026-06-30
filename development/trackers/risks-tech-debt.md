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
