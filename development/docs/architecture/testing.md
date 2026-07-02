# Architecture — Testing
_Last updated: 2026-07-02 (local)_ · _Status: active (partial)_

> Test strategy, harness, and infrastructure. _(skeleton — to be filled)_
>
> Note: the Arma 3 mission currently has no automated tests/CI — validation is manual playtesting.
> The Reforger test approach is itself an open question (see
> [Q-008](../../trackers/open-questions.md)).

## Strategy

Validation is **manual playtesting** by the test team — there is no automated harness (no SQF unit-test runner is
used here). The mission is played frequently, so **empirical play evidence is the source of truth**: a code path
that looks broken under static analysis but works in play is a false positive. Suspected findings from the code
review are confirmed or denied with reproducible **[test scenarios](../../trackers/test-scenarios.md)** (`TS-NNN`),
each naming a world/faction/mod config and observation milestones within a playthrough.

## Harness / tooling

_(to write — whether `development/tests/` is added depends on Q-008)_

## What gets tested

The [test-scenarios](../../trackers/test-scenarios.md) tracker seeds checks for the highest-value suspected
findings: prison-escape trigger across prison variants (TS-001), roadblock/asset alignment (TS-002), mortar
artillery (TS-003), civilian reporting / search escalation (TS-004), and com-center hack + highlight (TS-005). Add
a scenario whenever a review finding (`BUG-`/`Q-`/`RD-`) needs in-game confirmation.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton |
| 2026-07-02 | Claude | Filled Strategy + What-gets-tested; pointed to test-scenarios tracker |
