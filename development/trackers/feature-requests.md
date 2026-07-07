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

## FR-002 — Prison line-of-sight integrity (no seeing/shooting through walls)
- **Status:** proposed
- **Requested by / date:** Peter / 2026-07-03
- **Description:** Guards should not detect, reveal, or fire on players **through prison walls**. Detection/engagement
  should require genuine line of sight — the **door open**, or a guard on **elevated ground** looking over/into the
  compound.
- **Problem it solves (bug-class):** players report that after picking up weapons — expecting to be unseen behind
  closed walls — guards start shouting, the alarm sounds, and they **shoot through the walls**. Immersion-breaking and
  a severe, unfair disadvantage; happens "often enough," not every time. Current field workaround: some edits **stack
  sandbags** (which have proper fire/view geometry) inside the prison to block through-wall fire.
- **Likely root cause:** the prison wall/composition objects (Map-Builder / `createVehicle`'d props) likely lack proper
  **view + fire geometry LODs**, so Arma AI vision and fire pass through them. Once the escape starts (weapon pickup,
  BUG-028 trigger #2) the players un-captive, so guards use normal senses; with no wall occlusion they reach
  `knowsAbout > 2.5` **through the wall**, tripping the alarm (`fn_initServer.sqf:641-644`) and engaging.
- **Implementation options:**
  1. **Asset/geometry fix:** ensure the prison wall objects carry proper view + fire geometry LODs (the "correct" fix;
     depends on the prison templates' objects — some may need swapping, or the sandbag approach generalized).
  2. **Scripted LOS gating (robust, port-friendly):** for each guard↔player pair while players are inside with the door
     closed, check real LOS (`lineIntersectsSurfaces` guard-eyes→player); if blocked, suppress knowledge
     (`_guard reveal [_player, 0]` / cap `knowsAbout` / `forgetTarget`). Keeps guards ignorant until genuine sight
     (open door or elevated angle) — works even with imperfect wall geometry.
  3. Keep players **less detectable** (or captive) while behind closed prison doors, releasing to normal detection only
     once the door opens or they leave the footprint.
- **Relation:** part of the "fair prison opening" cluster with **BUG-030** (guards patrolling into the prison) and
  **BUG-031** (spawn race). Together they define the intended opening: a **reasonable, unseen planning window** until
  the players choose to act. The **Reforger port** should build LOS integrity in from the start (Enfusion perception +
  proper prefab geometry).

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
| 2026-07-03 | Claude | Added FR-002 (prison line-of-sight integrity — no seeing/shooting through walls) |
