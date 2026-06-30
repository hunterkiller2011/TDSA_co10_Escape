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
| 2 | Common | 35 | pending |
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
| Common | [Common.md](Common.md) | 35 | pending |
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

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Created; Sprint 0 setup complete; Sprint 1 started |
