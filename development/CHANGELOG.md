# Changelog
_Last updated: 2026-07-03 (local)_ · _Status: active_

> Notable project-level changes, newest first.

## 2026-07-03

- **Bug re-evaluation (with user, one at a time):** reassessed the static-review findings BUG-001…019
  against how the mission actually plays. All were downgraded — none were the medium/high mission-breakers
  first flagged: dead code (BUG-002/003/010), latent/harmless for current callers (BUG-005/006/007/009/011),
  ACE-only/dormant for the ATR config (BUG-008/012½/013), perf/debug-only (BUG-001/004), and two
  high→low corrections where a working path exists (BUG-014 broken-duplicate, BUG-019 works-by-call-inheritance
  — civilian reporting is live via the `KnowsAboutChanged` handler).
- **New, player-facing findings surfaced during the re-eval:** BUG-036 (garrisons over-stuff one
  building/room), BUG-037 (AI keep engaging downed players → tank collateral + area denial, impedes revives),
  BUG-038 (finicky `cursorObject` hack/heal prompt), and RD-037 (the DRN garbage collector is disabled but
  still fed → long-session unit leak; root-causes the confirmed perf decline alongside RD-026).
- Confirmed SQF string `switch`/`==` is case-sensitive (in-repo `toLower` proves it); documented the existing
  debug tooling (live log streaming + `A3E_DebugLogFilter` + `startDebugView`) as a testing aid; clarified the
  250 m extraction clearance is by-design.

## 2026-07-01 – 2026-07-02

- Started the **integration** phase (linking the per-file code-reference into system-level views): added
  three architecture docs — [lifecycle-and-timeline.md](docs/architecture/lifecycle-and-timeline.md)
  (boot→escape→end sequence across server/client/JIP, P0–P6, sync latches), 
  [state-and-data-flow.md](docs/architecture/state-and-data-flow.md) (load-bearing globals as
  producer→consumer maps), and [runtime-loops.md](docs/architecture/runtime-loops.md) (the recurring
  control loops L1–L9). Surfaced RD-035 (dead `civilianReporting` win-gate) and locked in the BUG-031
  spawn/escape race in-sequence.
- Traced the **extraction subsystem** end-to-end
  ([subsystem-extraction.md](docs/architecture/subsystem-extraction.md): locate → hack → select zone →
  signal → evac run → win/lose). Surfaced BUG-034 (extraction pools duplicate on repeated hacks),
  BUG-035 (unbounded board-wait can stall evac), and the dead DRN extraction path (→ RD-031). Confirmed
  evac markers originate in per-island `Missions/<Island>/mission.sqm` (handoff to the procedural-gen trace).
- Traced the **procedural world-generation** data path
  ([subsystem-world-generation.md](docs/architecture/subsystem-world-generation.md): island + mod data →
  placement/exclusion → the two build mechanisms (fn-composition vs Iso data-templates) → zone-population
  garrisoning). Documented the island/mod data schema, confirmed RD-028/Q-015/BUG-021 in the build path,
  and surfaced RD-036 (unbounded placement loops can hang world-gen).
- Completed the legacy Arma 3 **code-reference** — all 246 per-function/file entries across 16 docs documented
  (Sprints 1–7, one commit per sprint; Templates done family-by-family via part-files + a merge script).
- Logged review findings to the trackers: `BUG-001…029`, `RD-006…029`, `Q-009…021`; filled
  `docs/security-privacy.md` (data collection + config hardening) and `docs/architecture/testing.md` from the review.
- Added the **test-scenarios** tracker (`TS-001…005`) and an empirical-evidence principle: the mission is in active
  use, so "mission-breaking" static findings (e.g. BUG-028) are provisional until a playtest scenario confirms them.
- Corrected two analysis errors during review: the `_x`/dead-code check on `initPatrolZone`/`populateLocationZone`,
  and the DRN live/dead reclassification (the ambient/traffic/aquatic calls sit in a dead `if(false)` block).

## 2026-06-30

- Bootstrapped the documentation workspace (`development/` + `wiki/`) from
  [project-template.md](docs/project-template.md): docs, trackers, and wiki skeletons created with the
  standard header/Revision-History conventions.
- Seeded `trackers/open-questions.md` (Q-001…Q-008) and `trackers/risks-tech-debt.md` (RD-001…RD-005)
  with the known unknowns/risks of the Arma 3 → Reforger conversion. No development decisions made.
- Created the `code-reference/` skeleton: one doc per `Code/functions/` category plus
  `_init-and-includes.md`, each stubbed with one entry per source file (no analysis yet).
- Moved `project-template.md` into `development/docs/` (its canonical location per the guide).

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton + bootstrap entry |
