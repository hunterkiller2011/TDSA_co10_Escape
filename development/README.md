# co10_Escape → Reforger — Documentation Index
_Last updated: 2026-07-02 (local)_ · _Status: active_

> Start here. This is the map of all planning & engineering documentation for porting the Arma 3
> mission **co10_Escape** to **Arma Reforger** (Enfusion / Enforce Script).

## The one rule

**`development/` is a planning/engineering workspace and is NOT shipped.** Production code lives in
top-level directories. Keeping them separate lets the docs and the code evolve independently. When
asked to build/port code, work in the production tree — do not turn these planning docs into app code.

## Repository layout & intent

**Current production — the Arma 3 mission (legacy, source of the port):**
- `Code/` — SQF functions (`A3E` namespace), includes, scripts
- `Configs/` — per-mod build configs consumed by the compiler
- `Islands/` — per-island spawn/patrol data
- `Mods/` — faction/unit class definitions
- `Factions/` — faction loadouts
- Build tool: `Editing_and_Porting/Tools/Compiler/EscapeCompiler.exe` (WPF GUI → `.pbo`)

**Reforger target — the Enfusion mod:**
- Structure **TBD** — a decision for a later sprint. See [open question Q-001](trackers/open-questions.md).

**Other top-level:**
- `wiki/` — end-user (player) help. Start at [wiki/README.md](../wiki/README.md).

## Documentation map

### docs/ — design & architecture
- [docs/design.md](docs/design.md) — design intent: vision, principles, key flows.
- [docs/development-plan.md](docs/development-plan.md) — goals, constraints, proposed phases.
- [docs/glossary.md](docs/glossary.md) — shared domain terms (Arma 3 + Enfusion).
- [docs/security-privacy.md](docs/security-privacy.md) — data handling, secrets, the statistics API.
- [docs/architecture/application.md](docs/architecture/application.md) — how the app/mission works (overview).
- **Integration docs** (how the per-file code links together):
  - [docs/architecture/lifecycle-and-timeline.md](docs/architecture/lifecycle-and-timeline.md) — end-to-end boot→escape→end sequence (timelines).
  - [docs/architecture/state-and-data-flow.md](docs/architecture/state-and-data-flow.md) — load-bearing globals as producer→consumer maps (data paths).
  - [docs/architecture/runtime-loops.md](docs/architecture/runtime-loops.md) — the recurring control loops (Chronos, SearchLeader, mission-flow).
  - [docs/architecture/subsystem-extraction.md](docs/architecture/subsystem-extraction.md) — deep subsystem trace: com-center locate → hack → evac → win/lose.
  - [docs/architecture/subsystem-world-generation.md](docs/architecture/subsystem-world-generation.md) — deep subsystem trace: island/mod data → placement → build → garrison.
- [docs/architecture/testing.md](docs/architecture/testing.md) — test strategy & infrastructure.
- [docs/architecture/operations.md](docs/architecture/operations.md) — build, deploy, environments, runbooks.
- [docs/project-template.md](docs/project-template.md) — the reusable blueprint these docs follow (project-agnostic).

### trackers/ — living lists
- [trackers/feature-requests.md](trackers/feature-requests.md) — `FR-NNN`
- [trackers/bugs-app.md](trackers/bugs-app.md) — `BUG-NNN`
- [trackers/bugs-tests.md](trackers/bugs-tests.md) — `TBUG-NNN`
- [trackers/decision-log.md](trackers/decision-log.md) — `ADR-NNNN` (empty — no decisions yet)
- [trackers/open-questions.md](trackers/open-questions.md) — `Q-NNN` (seeded with conversion unknowns)
- [trackers/risks-tech-debt.md](trackers/risks-tech-debt.md) — `RD-NNN` (seeded)
- [trackers/test-scenarios.md](trackers/test-scenarios.md) — `TS-NNN` (playtest scenarios that confirm/deny findings)

### code-reference/ — legacy Arma 3 source map
- [code-reference/README.md](code-reference/README.md) — reverse-engineering reference of the existing
  SQF code (per-function: inputs, outputs, processing, theory of operation, whys/questions, unresolved
  issues, Reforger port notes). One doc per `Code/functions/` category.

### Other
- [CHANGELOG.md](CHANGELOG.md) — notable project-level changes, newest first.
- `Claude-chats/` — dated archive of Claude sessions (summary + transcript).
- `prototypes/` — design artifacts / throwaway prototypes (optional).

## Keep docs current

When you change code or direction, update the doc(s) that reference it: bump the `_Last updated:_`
line, add a Revision History row, note it in [CHANGELOG.md](CHANGELOG.md), and log
decisions/bugs/questions in the appropriate tracker.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton |
| 2026-07-02 | Claude | Added the integration architecture docs (lifecycle-and-timeline, state-and-data-flow, runtime-loops) to the map |
