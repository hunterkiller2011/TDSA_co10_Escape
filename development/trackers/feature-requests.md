# Feature Requests
_Last updated: 2026-07-03 (local)_ · _Status: active_

> Requested features. **ID scheme:** `FR-NNN` (stable, never reused).

## FR-001 — Self-hosted mission-statistics backend
- **Status:** proposed
- **Requested by / date:** Peter / 2026-07-03
- **Description:** Redirect the session statistics (currently GET-sent to `co10esc.anzp.de` via `htmlLoad`)
  to an **owner-controlled long-running database** for mission-history tracking, and design the schema to
  serve the **Reforger port** too. Full design (current mechanism, Options A/B/C, starter schema, caveats,
  port angle) in [docs/stats-backend.md](../docs/stats-backend.md). **Blocking dependency: Q-016** (does the
  `htmlLoad` send fire on a dedicated server?). Related: BUG-022 (duplicate `server=` — clean up in the same edit).

---

_Format for new entries:_
```
## FR-NNN — <short title>
- **Status:** proposed | accepted | in-progress | done | declined
- **Requested by / date:** <who> / YYYY-MM-DD
- **Description:** <what and why>
```

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton |
| 2026-07-03 | Claude | Added FR-001 (self-hosted mission-statistics backend → docs/stats-backend.md) |
