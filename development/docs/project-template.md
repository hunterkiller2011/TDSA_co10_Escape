# Project Template Guide
_Last updated: 2026-06-30 (local)_ · _Status: reference_

> A reusable blueprint for bootstrapping a **new application repository**. It captures the file/folder
> structure, the reasoning behind each part, the documentation conventions, and a copy-paste
> `CLAUDE.md` template. Derived from the Vow Craft setup — adapt names, add or drop pieces to fit the
> new project, but keep the conventions so every project feels the same.

## How to use this guide

1. Create the repo and the top-level structure below (omit what doesn't apply yet — empty dirs can be
   placeholders with a `.gitkeep`).
2. Copy the **documentation skeleton** (`development/` + `wiki/`) and the conventions verbatim.
3. Drop in the **`CLAUDE.md` template** at the end and fill the placeholders.
4. Record the initial setup in `development/CHANGELOG.md` and archive the bootstrap session in
   `development/Claude-chats/`.

The single most important rule: **`development/` is a planning/engineering workspace and is _not_ the
shipped application.** Production code lives in top-level dirs (`frontend/`, `backend/`, …). Keeping
these separate is what lets the docs evolve freely without touching app code, and vice-versa.

## Top-level repository structure

```
<project>/
├─ CLAUDE.md              # guidance for Claude Code (see template below)
├─ README.md             # public/repo-level readme
├─ .gitignore
├─ frontend/             # production frontend (real, shipped app code)
├─ backend/              # production backend / API (or api/, server/, hub/ — name to fit)
├─ configs/              # non-secret config + templates (e.g. config.ini.example)
├─ wiki/                 # end-user help the app links to
│  ├─ README.md          # wiki home / index
│  ├─ getting-started.md
│  ├─ faq.md
│  └─ troubleshooting.md
└─ development/          # planning & engineering workspace — NOT shipped
   ├─ README.md          # documentation index / map (start here)
   ├─ CHANGELOG.md       # notable project-level changes
   ├─ docs/
   │  ├─ design.md             # design intent
   │  ├─ development-plan.md   # goals + proposed phases
   │  ├─ glossary.md           # shared domain terms
   │  ├─ security-privacy.md   # auth, secrets, data handling
   │  ├─ project-template.md   # this guide (keep it project-agnostic)
   │  └─ architecture/
   │     ├─ application.md      # how the app works (front + back)
   │     ├─ testing.md          # how testing works + infrastructure
   │     └─ operations.md       # deployment, environments, CI/CD, runbooks
   ├─ trackers/
   │  ├─ feature-requests.md
   │  ├─ bugs-app.md
   │  ├─ bugs-tests.md
   │  ├─ decision-log.md        # ADRs
   │  ├─ open-questions.md
   │  └─ risks-tech-debt.md
   ├─ Claude-chats/             # one file per session: YYYY-MM-DD[-NN]-topic.md
   ├─ prototypes/               # design artifacts / throwaway prototypes (optional)
   └─ tests/                    # test harness/pipeline if kept separate from app code
```

## Why each part exists

### Production code (top-level)
| Path | Purpose | Why it's separate |
|------|---------|-------------------|
| `frontend/` | The real, shipped UI. | Kept apart from `development/` so design prototypes never get mistaken for production. |
| `backend/` (or `api/`, `server/`, `hub/`) | The real API/service code. | Same reason; name it for the project's actual architecture. |
| `configs/` | Non-secret config and `*.example` templates. | Config that ships or is referenced by CI; **never** real secrets. |
| `README.md` | Repo-level overview for humans. | Public face of the repo; distinct from internal docs. |
| `CLAUDE.md` | Operating guidance for Claude Code. | Lets any future Claude be productive fast; see template below. |

### End-user help (`wiki/`)
User-facing, plain-language help the application links to. Kept top-level (not under `development/`)
because it is part of the product experience, not internal planning. Start with a home page, a
getting-started guide, an FAQ, and troubleshooting.

### Planning & engineering workspace (`development/`)
| Path | Purpose |
|------|---------|
| `README.md` | The index/map of all documentation — the entry point. |
| `CHANGELOG.md` | Notable project-level changes, newest first. |
| `docs/design.md` | The design intent: vision, personas, principles, brand, key flows. |
| `docs/development-plan.md` | Goals, constraints, proposed phases, and milestones. |
| `docs/glossary.md` | Defines domain terms once so docs and code stay consistent. |
| `docs/security-privacy.md` | Auth, authorization, data privacy, secrets handling. |
| `docs/architecture/application.md` | How the app is built and runs (components, data model, APIs). |
| `docs/architecture/testing.md` | Test strategy, harness, fixtures, CI test stages. |
| `docs/architecture/operations.md` | Environments, deployment, CI/CD, config, runbooks. |
| `trackers/feature-requests.md` | Requested features (`FR-NNN`). |
| `trackers/bugs-app.md` | Application bugs (`BUG-NNN`). |
| `trackers/bugs-tests.md` | Bugs in the test scripts/infra (`TBUG-NNN`), kept separate from app bugs. |
| `trackers/decision-log.md` | Architecture/product decisions as ADRs (`ADR-NNNN`). |
| `trackers/open-questions.md` | Unresolved questions/assumptions (`Q-NNN`). |
| `trackers/risks-tech-debt.md` | Known risks and tech debt (`RD-NNN`). |
| `Claude-chats/` | A dated archive of every Claude session so other clients can follow decisions. |
| `prototypes/` | Design artifacts / throwaway prototypes; reference, not production. |
| `tests/` | The test pipeline/harness when it lives outside the app code. |

> Add new trackers or docs as needed — each new tracker gets its **own** document. Drop pieces that
> don't apply to a given project (e.g. no `prototypes/` if there was no design phase).

## Documentation conventions (apply to every doc)

**Header** — directly under the H1 title:
```
# <Doc Title>
_Last updated: YYYY-MM-DD HH:MM (local)_ · _Status: skeleton | active | reference_
```

**Footer** — a revision history table:
```
## Revision History

| Date | Author | Change |
|------|--------|--------|
| YYYY-MM-DD | <name> | <what changed> |
```

**ID schemes** (stable, never reused): `FR-001` features · `BUG-001` app bugs · `TBUG-001` test bugs ·
`ADR-0001` decisions · `Q-001` open questions · `RD-001` risks/debt.

**ADR format** — one section per decision: `## ADR-NNNN — <title>` with **Date / Status
(proposed·accepted·superseded·deprecated) / Context / Decision / Consequences**.

**Chat archive** — one file per session named `YYYY-MM-DD[-NN]-topic.md` (the `-NN` keeps same-day
sessions ordered). Body = a `## Summary` header (topics, decisions, open questions, action items)
followed by a `## Transcript` (cleaned).

**Keep docs current** — when you change code or direction, update the doc(s) that reference it, bump
the `_Last updated:_` line, add a revision-history row, note it in `CHANGELOG.md`, and log significant
decisions/bugs/questions in the appropriate tracker.

## The CLAUDE.md file

`CLAUDE.md` is the first thing a new Claude Code session reads. Make it the highest-signal map of the
repo. **Include:** what the project is, the repository layout and the production-vs-workspace
distinction, how to build/run/test (with the exact commands), the big-picture architecture that spans
multiple files, project-specific gotchas, and a pointer to the documentation + the upkeep rule.
**Avoid:** generic software advice, obvious instructions, and exhaustive file-by-file listings that are
easy to discover.

Copy the template below into a new project's `CLAUDE.md` and fill the `<…>` placeholders:

````markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

<One-paragraph description of the product, who it's for, and the core domain concept.>

## Repository layout & intent

<Map the top-level dirs. Make the key distinction explicit:>
- Production code lives in `frontend/`, `backend/`, … (real, shipped app).
- `development/` is a planning/engineering workspace and is NOT shipped.
- `wiki/` is end-user help.
When asked to build the app, create code under the appropriate top-level dir — do not extend
design prototypes under `development/`.

## Building, running & testing

<Exact commands. How to run the app, run the full test suite, and run a single test.
Note any required setup (services, env vars, DB).>

## Architecture

<The big-picture, cross-file architecture: main components and how they talk; the data model;
state/auth model; anything non-obvious that requires reading several files to grasp.>

## Project-specific notes & gotchas

<Conventions, naming, known inconsistencies, things that will trip someone up.>

## Documentation (keep it current)

Docs live under `development/` (engineering/planning) and `wiki/` (end-user help); start at
[development/README.md](development/README.md). When you make changes, update the docs that reference
the affected area: edit the relevant doc(s), bump their `_Last updated:_` line and add a Revision
History row; record notable changes in `development/CHANGELOG.md`; log decisions in
`trackers/decision-log.md`; file bugs in `trackers/bugs-app.md` / `bugs-tests.md`; capture features in
`trackers/feature-requests.md`; add unknowns to `trackers/open-questions.md` /
`trackers/risks-tech-debt.md`. At the end of a session, archive it in `development/Claude-chats/`
using the summary + transcript format.
````

## Bootstrap checklist for a new project

- [ ] Create the repo; add `README.md`, `.gitignore`, and empty production dirs (`frontend/`, …).
- [ ] Create `development/` and `wiki/` skeletons from this guide (docs, trackers, wiki pages).
- [ ] Add `development/README.md` index and `development/CHANGELOG.md`.
- [ ] Seed `trackers/decision-log.md` with the first ADRs (e.g. stack choices) and
      `open-questions.md` with the first unknowns.
- [ ] Write `CLAUDE.md` from the template and fill in the placeholders.
- [ ] Apply the header (`_Last updated:_`) and Revision History footer to every doc.
- [ ] Archive the bootstrap session in `development/Claude-chats/`.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-29 | Peter | Initial version (generalized from the Vow Craft setup) |
| 2026-06-30 | Peter | Moved to `development/docs/` (canonical location per this guide) |
