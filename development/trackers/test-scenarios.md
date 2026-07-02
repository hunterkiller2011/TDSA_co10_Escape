# Test Scenarios
_Last updated: 2026-07-02 (local)_ · _Status: active_

> Concrete, reproducible in-game scenarios that **confirm or deny** suspected findings (`BUG-`/`Q-`/`RD-`) from
> the code-reference review, run by the playtest team.
>
> **Guiding principle (empirical evidence wins):** co10_Escape is in active use (hundreds–thousands of playtested
> sessions). Any finding that implies the mission *cannot be played* (escape never triggers, an objective is
> unreachable, etc.) is almost certainly a static-analysis error — its severity is **provisional** until a
> scenario here confirms it. When play contradicts the analysis, the analysis is wrong; trace the real code path.

**ID scheme:** `TS-NNN` (stable, never reused). **Status:** planned | passed | failed | inconclusive.
One playthrough can satisfy several scenarios (record each milestone separately).

**Forcing a specific composition:** compositions are chosen by `selectRandom` from per-type arrays
(`A3E_PrisonTemplates` — see [fn_createStartpos.sqf:5](../../Code/functions/Server/fn_createStartpos.sqf#L5) —
plus `A3E_AmmoDepotTemplates`, `A3E_ComCenterTemplates`, `A3E_MortarSiteTemplates`, `A3E_MotorPoolTemplates`,
`A3E_RoadblockTemplates`). To force one, constrain its array to a single element (via a debug hook or a temporary
edit to the mod's `Mods/{Mod}/UnitClasses.sqf`). There is **no dedicated force-template debug flag** today
(`Code/config.sqf` has `a3e_debug_overwrite`, `DebugRoadblocks`, `a3e_debug_artillery` — see open-questions on
whether a force-template flag should be added). Otherwise replay until the target is randomly selected.

---

## TS-001 — Prison escape trigger fires for every prison variant
- **Confirms/denies:** BUG-028 (building-as-gate prisons may never register escape).
- **Config:** Enoch (Livonia), CSAT vs NATO, no mods.
- **Setup:** force each prison template in turn (`A3E_PrisonTemplates = ["a3e_fnc_BuildPrison<N>"]`), especially
  the building-as-gate layouts: `BuildPrison2` (`Land_Shed_05_F`), `BuildPrison4` (`Land_Slum_House03_F`),
  `BuildPrison5` (`Land_Slum_House02_F`).
- **Milestones:** (1) spawn in the prison; (2) open the gate/door; (3) confirm the escape state advances (the
  "escaped" objective/trigger fires).
- **Expected:** escape triggers for ALL six layouts. If a building-as-gate layout does NOT trigger → BUG-028 is
  real for that class. If all trigger → BUG-028 is a false positive; then **trace the actual escape-detection
  path(s)** beyond `initServer.sqf:647-649` and record it.
- **Status:** planned.

## TS-002 — Roadblock alignment with road & structure
- **Confirms/denies:** BUG-029 (Iso roadblock manned slots misaligned under rotation).
- **Config:** Tanoa, NATO vs CSAT, no mods.
- **Milestones:** drive around until you find roadblocks; for each, visually confirm (a) the roadblock is aligned
  to the road, and (b) the manned vehicle(s) and static gunner(s) are aligned with the structure (not
  rotated/offset relative to the props).
- **Expected:** props + manned slots share one orientation. Gunners/vehicles visibly rotated or offset at
  non-axis-aligned roadblocks → confirms BUG-029. (Note: default `A3E_RoadblockTemplates` is `rb_bis_rb1..3`.)
- **Status:** planned.

## TS-003 — Mortar sites fire live artillery
- **Confirms/denies:** that mortar sites are functional artillery (not props); context for BUG-018 (FireArtillery
  round count) and the `a3e_var_artillery_units` pruning question (RD-014-area).
- **Config:** any vanilla world (e.g. Altis), NATO vs CSAT, no mods; `a3e_debug_artillery = true` to visualise.
- **Milestones:** trigger detection and remain located long enough for the search leader to call artillery while a
  mortar site is alive; then destroy the mortar site and confirm artillery from it stops.
- **Expected:** artillery lands while a mortar is alive; stops once all mortars are destroyed. (Watch for dead
  mortars still firing → `a3e_var_artillery_units` not pruned.)
- **Status:** planned.

## TS-004 — Civilian reporting / search escalation
- **Confirms/denies:** BUG-014 (`onEnemyDetected` undefined `_player`) and BUG-019 (`onCivilianGroupSpawn`
  attaches EHs to undefined `_group`) — both imply the civilian "spot the escapee and radio HQ" path is broken.
- **Config:** a populated town on a vanilla world; NATO vs CSAT, no mods; war-crime score high enough to enable
  civilian reporting.
- **Milestones:** let a civilian clearly see the player; observe whether a reporter plays the radio-in animation
  and whether HQ/search escalation follows (search groups dispatched, known-position created).
- **Expected:** if civilian reporting demonstrably works in play, BUG-014/019 are false positives (re-trace the
  scope); if civilians never report despite line-of-sight, the bugs are real.
- **Status:** planned.

## TS-005 — Com-center hack works and is discoverable across variants
- **Confirms/denies:** Q-021 (SPE radio variants lack the `BIS_fnc_DataTerminalColor` highlight).
- **Config:** run once vanilla (Altis, NATO vs CSAT) and once with **SPE** (a WWII world) to hit the SPE
  com-center radios.
- **Milestones:** reach the com center; confirm the objective object is hackable within ~3 m (the hack action
  appears); note whether it has a visible highlight/glow cue.
- **Expected:** hackable in all cases. Vanilla/VN terminals glow; SPE radios may lack the cue → confirms Q-021
  (usability, not a break).
- **Status:** planned.

---

_Format for new entries:_
```
## TS-NNN — <short title>
- **Confirms/denies:** <BUG-/Q-/RD- id(s) and what a pass/fail means>
- **Config:** <world, factions, mods, relevant params>
- **Setup:** <forcing a template / preconditions> (optional)
- **Milestones:** <ordered observations within the playthrough>
- **Expected:** <pass condition, and what a fail proves>
- **Status:** planned | passed | failed | inconclusive  (add date + who)
```

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-07-02 | Claude | Created; seeded TS-001…005 from Sprint-review findings |
