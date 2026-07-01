# Open Questions
_Last updated: 2026-06-30 (local)_ · _Status: active_

> Unresolved questions and assumptions for the Arma 3 → Reforger conversion. **ID scheme:** `Q-NNN`
> (stable, never reused). These are decision *points*, not decisions — record decisions as ADRs in
> [decision-log.md](decision-log.md).

## Q-001 — Target Reforger mod/project structure
**Status:** open
What should the Enfusion mod look like — Workbench project layout, addon/Prefab organization, how the
procedurally-generated content is composed? Gates the production directory layout.

## Q-002 — SQF → Enforce Script port strategy
**Status:** open
Full reimplementation vs. partial port? Which subsystems are ported first (e.g. core escape loop before
ambient systems)? How much of the ~215-function `A3E` surface carries over conceptually?

## Q-003 — Terrain / island story
**Status:** open
Which of the ~119 Arma 3 islands have Reforger terrain equivalents, and how is procedural
placement (prison/COM/ammo/extraction) adapted to the available Reforger terrains?

## Q-004 — AI behavior mapping
**Status:** open
How do Reforger's AI APIs map to the Arma 3 patrol / search / guard / extraction behaviors and the
`Chronos` scheduler + `SearchLeader` escalation model?

## Q-005 — Build & packaging pipeline
**Status:** open
What replaces `EscapeCompiler.exe` / `.pbo` packaging (per mod×island) — Enfusion Workbench addon
build, and how are the per-mod/per-island config permutations expressed?

## Q-006 — Multiplayer / replication model
**Status:** open
How do `missionNamespace` / `publicVariable` / `remoteExec` patterns translate to Enfusion's
replication/RPC and authority model (server vs client)?

## Q-007 — Faction / mod configs
**Status:** open
How are the faction/mod permutations (CUP, RHS, SOGPF, SPE, GM, etc.) represented in Reforger's
modding ecosystem, given different available mods/assets?

## Q-008 — Test strategy for Reforger
**Status:** open
Is there a viable automated test approach in Enfusion, or does validation remain manual playtesting?
The answer determines whether `development/tests/` is added.

## Q-009 — Marker-shape handling in position helpers
**Status:** open
`Helper/fn_RandomMarkerPos.sqf` uses elliptical sampling regardless of ELLIPSE vs RECTANGLE marker
shape, and `Helper/fn_getBuildingsInMarker.sqf` reads but ignores marker rotation (inline TODO for a
`bis_fnc_inTrigger` shape filter). Is rectangle/rotation accuracy required, or is the circle/ellipse
approximation intentional? Affects how zone placement ports. _(Surfaced Sprint 1.)_

## Q-010 — Chronos registration robustness
**Status:** open
`Chronos/fn_Chronos_Register.sqf` parses its args twice (`params` then `BIS_fnc_param` per arg) and has
no de-dup guard, so a function registered twice is scheduled twice. Intended, or cleanup for the port's
scheduler design? _(Surfaced Sprint 1.)_

## Q-011 — Server-local debug markers visibility
**Status:** open
`Common/fn_InitVillageMarkers.sqf` runs server-side using `createMarkerLocal`, whose markers aren't
visible to clients — verify the debug village markers appear anywhere. Its `[true]` arg is ignored (reads
`A3E_Debug`). _(Surfaced Sprint 2.)_

## Q-012 — `handleScore` gating & registration asymmetry
**Status:** open
`Common/fn_handleScore.sqf` gates on `!isNil "a3e_var_Escape_SearchLeader_civilianReporting"` (variable
presence, not value) — may misfire if defined-but-false. It is registered server-side (initPlayer) whereas
`handleRating` is client-side (initLocalPlayer) — intentional asymmetry? _(Surfaced Sprint 2.)_

---

_Format for new entries:_
```
## Q-NNN — <short title>
**Status:** open | resolved (→ ADR-NNNN / commit)
<the question, assumptions, and what a resolution would unblock>
```

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton; seeded Q-001…Q-008 (conversion unknowns) |
| 2026-06-30 | Claude | Added Q-009, Q-010 from code-reference Sprint 1 |
| 2026-07-01 | Claude | Added Q-011, Q-012 from code-reference Sprint 2 (Common) |
