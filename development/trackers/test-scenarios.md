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
- **Update (static trace, 2026-07-02):** escape has **3 triggers** — weapon pickup (`count weapons > 0`),
  moving 15–100 m from start, and gate-door open — so it **can't softlock**; **BUG-028 is resolved as a false
  positive**. This scenario is now optional, only useful to confirm the *gate-open alarm* for building-as-gate layouts.
- **Status:** low priority (BUG-028 resolved statically).

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

## TS-006 — Prison guards should not enter the prison
- **Confirms/denies:** BUG-030 (guards patrol into the prison → near-instant-failure risk).
- **Config:** any world; higher difficulty (more guards); watch the prison area from spawn across several restarts.
- **Milestones:** observe the guards' patrol paths for ~2 min from spawn — note whether any guard walks into the
  prison interior / clips the door, and how soon after spawn it happens; note whether it leads to an early failure.
- **Expected (desired):** guards patrol *around* the prison and never path inside. Current behavior (guards
  entering, sometimes within seconds) confirms BUG-030 — `drn_guardAreaMarker` is a 50 m ellipse centered on the prison.
- **Status:** planned (user reports this occurs frequently).

---

## TS-007 — Spawn sequence must not start the escape
- **Confirms/denies:** BUG-031 (spawn/init race prematurely starts the escape via the weapon trigger).
- **Config:** MP with 2+ players; deliberately join late / on a loaded or laggy server; also watch normal fresh starts.
- **Milestones:** on each (re)spawn, confirm the black screen covers the corner-spawn + gear-strip + teleport;
  confirm `A3E_EscapeHasStarted` does NOT become true as a side effect of a player joining/spawning (only from the
  three intended triggers: weapon pickup / 15–100 m from start / gate open).
- **Expected:** escape never starts from spawning. Premature escape right after a join/spawn confirms BUG-031.
- **Status:** planned (user reports intermittent instant-fail after spawn).

---

## TS-008 — Zone garrison serialize / deserialize
- **Confirms/denies:** BUG-005 (crew index -1), BUG-006 (cargo index), BUG-007 (trigger leak), BUG-015 (empty `SeekShelter`).
- **Config:** any world; approach a location/village zone whose garrison includes a **crewed vehicle**.
- **Setup:** use **DH-2** (force zone deactivate→reactivate) if available; otherwise leave the zone (~800 m+) to
  deactivate, then return to reactivate.
- **Milestones:** (1) note the garrison (crew in vehicle seats, units in buildings); (2) deactivate; (3) reactivate —
  are crew back in the **same seats** (BUG-005/006)? any **leftover/duplicate triggers** (BUG-007, use DH-7)? any
  groups left **idle with no orders** (BUG-015)?
- **Expected:** units restored to prior seats/positions; no trigger leak; no idle groups.
- **RNG:** needs a zone with a crewed vehicle; DH-2 makes it repeatable.

## TS-009 — Zone population: large villages & location garrisons
- **Confirms/denies:** BUG-020 (large-village Opfor branch + stray `systemchat`), BUG-021 (location buildings not garrisoned).
- **Config:** a world with a large town (village area > 5000); NATO v CSAT, no mods.
- **Milestones:** (1) enter a **large** village — does it get the extra Opfor the `>5000` branch should add (BUG-020)?
  (2) watch chat for stray **numeric `systemchat` spam** when villages populate (BUG-020 debug line, visible to all);
  (3) at a location zone (com center / ammo / etc.), are the **surrounding buildings garrisoned** with units (BUG-021)?
- **Expected:** large villages get Opfor; no stray systemchat; location buildings garrisoned.
- **RNG:** which villages are large is per-world; DH-3 helps see zone bounds.

## TS-010 — Boat extraction behavior
- **Confirms/denies:** BUG-016 (boat runner spawns the *car* behavior; `fn_ExtractionBoat` orphaned).
- **Config:** a coastal/island world; **force extraction type = boat (DH-1)** or replay until a water extraction is offered.
- **Milestones:** reach the extraction; observe whether the extraction **boats** path on water sensibly, pick up players,
  and leave — or behave like land vehicles (stuck at shore, odd pathing).
- **Expected:** boats function as an extraction. Car-on-water behavior / stuck boats confirm the runner mismatch.
- **RNG:** extraction type is random and terrain-dependent — DH-1 is the practical enabler.

## TS-011 — ACE interactions: hijack, heal, captive
- **Confirms/denies:** BUG-012 (hijack ignores ACE-unconscious), BUG-013 (heal-at-building bypasses ACE Medical), BUG-008 (`CaptiveHandle` busy-spin).
- **Config:** **with ACE**; NATO v CSAT.
- **Milestones:** (a) start hacking a terminal/enemy vehicle, then go **ACE-unconscious** mid-hack — does the hack keep
  progressing (BUG-012)? (b) take an ACE wound, use the **heal-at-building** action — are wounds cleared consistently /
  is there any cooldown (BUG-013)? (c) while a captured player is ACE-unconscious, watch server FPS for a spin (BUG-008,
  use DH-4).
- **Expected:** hack pauses while unconscious; heal respects ACE medical; no FPS spin.
- **RNG:** needs ACE + reaching a hackable object / heal building.

## TS-012 — Search escalation & reinforcements
- **Confirms/denies:** BUG-027 (DRN `InsertionTruck` stray `sideChat`; `MotorizedSearchGroup`/`SearchGroup` behavior), BUG-023 (`ReportToHQ` condition).
- **Config:** any world; after escaping, get spotted and **hold contact** so the search leader escalates (or **DH-5** to force it).
- **Milestones:** observe reinforcement/search assets — motorized search groups, the **search chopper**, an **insertion
  truck**; watch chat for the stray `sideChat` when the insertion truck spawns (BUG-027); confirm search groups are
  actually **dispatched to your last-known position** (BUG-023).
- **Expected:** search assets dispatch correctly; no stray sidechat.
- **RNG:** escalation timing needs sustained contact; DH-5 forces it.

## TS-013 — Civilian strollers
- **Confirms/denies:** BUG-017 (`Stroll` markerless path leaves `_destinationPos` unset).
- **Config:** a world with populated towns; civilians enabled; run with `-showScriptErrors`.
- **Milestones:** watch civilian strollers in town — do they wander normally, or do some spawn and stand still / raise a
  script error?
- **Expected:** strollers wander. Frozen strollers / script errors confirm the bug.
- **RNG:** civilians spawn via `CivilianCommuters` (Chronos) — present in towns.

---

## TS-014 — Roadblock manned-slot alignment under rotation (BUG-029)
- **Confirms/denies:** BUG-029. Pass = gunners/vehicles cover the road (aligned with the barriers); fail = they face off by ~the road heading.
- **Config:** any world with roads at varied headings.
- **Setup:** find/force roadblocks (spawn dynamically 1500-2000 m from players on roads; or pin a roadblock template via a debug hook). Compare one on a ~N-S road (rotation ≈ 0) vs an E-W road (rotation ≈ 90).
- **Milestones:** at each roadblock, note the static-gunner / manned-vehicle facing vs (a) the road direction and (b) the barrier alignment.
- **Expected (if bug):** on angled roads, manned slots face off by ~the road heading while barriers align to the road; on a ~heading-0 road they look correct (rotation ≈ 0 masks it).
- **Status:** planned

## Testing aids — debug hooks worth adding

Many scenarios are gated by RNG (which template/variant spawns, extraction type, when a search escalates). The existing
debug framework (`A3E_Debug`, `a3e_debug_overwrite`, `a3e_debug_artillery`, `DebugRoadblocks` in `Code/config.sqf`)
already reveals some markers and can be extended:

- **DH-1 — Force template / extraction selection:** debug override so `selectRandom`/`callRandomFunction` picks a pinned
  entry for prisons (`fn_createStartpos`/`A3E_PrisonTemplates`), depots/com-centers/motor-pools/mortars (`fn_create*`),
  roadblocks (`A3E_RoadblockTemplates`), and the extraction type (`fn_SelectExtractionZone`). → TS-001, TS-002, TS-010.
- **DH-2 — Force zone deactivate→reactivate:** admin action to cycle the nearest `A3E_Zones` entry so serialize/deserialize
  runs on demand. → TS-008 (no 800 m walk).
- **DH-3 — Reveal hidden markers:** extend `A3E_Debug` to `setMarkerAlpha` all zone/patrol/depot/guard-area markers
  (many are alpha-0). → zone bounds, the prison guard area (BUG-030), camp spacing.
- **DH-4 — State readout (log/HUD):** `A3E_EscapeHasStarted`, `A3E_SoundPrisonAlarm`, max guard `knowsAbout`,
  `count a3e_var_artillery_units`, active-trigger count, grouped-entity count. → TS-001/003/006/007/011 + leak checks.
- **DH-5 — Force events:** admin triggers to force the prison alarm, an artillery fire mission, or a search escalation. → TS-003, TS-012.
- **DH-6 — Spawn-race repro:** a debug delay before the client gear-strip (or a "spawn with gear" toggle) to reproduce
  BUG-031 deterministically. → TS-007.
- **DH-7 — Leak counters:** log active-trigger + grouped-entity counts over time. → BUG-007 (trigger leak), RD-026 (template objects never despawned).

### Debug tooling that already exists (use now)

Two under-used tools are already in the mission (confirmed 2026-07-03):

- **Live log streaming** — `a3e_fnc_log` tags every message with categories and routes them to **systemChat + the
  `.rpt`**. `A3E_DebugLogFilter` has **dual semantics** (`fn_logMessage.sqf:19-21`): with `A3E_Debug = true` it is a
  **mute-list** (everything streams except listed categories); with `A3E_Debug = false` it is a **watch-list**
  (nothing streams except listed categories — the useful mode for focusing on one subsystem without full-debug spam).
  Categories: `Zones`, `Spawning`, `Serialization`, `MilitaryTraffic`, `CivilianCommuters`, `Garisson` (sic — misspelled
  at `populateLocationZone:33`), `ERROR`, `Debugging`, `SearchLeader`, `Extraction`.
  - Verify **BUG-036**: `A3E_Debug=false; A3E_DebugLogFilter=["Spawning"]` → compare `Found N enterable Buildings… in
    Zone X` vs `Creating group with N units`.
  - Verify **BUG-005/006/007**: `A3E_DebugLogFilter=["Serialization"]` → `Group serialized and deleted` / `Group deserialized`.
- **`startDebugView`** — a dialog listing the last 25 stored messages (`A3E_DebugLog`, capped 100). It is **unbound**
  (call `[] call a3e_fnc_startDebugView` from the debug console), a **one-shot snapshot** (no auto-refresh), and its
  category-filter arg is BUG-004 (unused by the sole caller). Worth wiring to a keybind + adding auto-refresh as a
  future testing aid.

## Bugs better confirmed by inspection than by a scenario

Code-confirmed and either dead or not observable in normal play — verify by reading the fix (a one-line `diag_log` at the
site confirms most), not a playtest: **BUG-001** (cache perf), **BUG-002/003/010** (dead code), **BUG-004** (debug tooling),
**BUG-009/011** (harmless with current callers), **BUG-022** (stats URL — inspect the server request), **BUG-024/026**
(subtle / harmless-once), **BUG-025** (only on bad terrain — very low repro). BUG-028 is already **resolved** (false positive).

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
| 2026-07-02 | Claude | TS-001 updated (BUG-028 resolved via static trace); added TS-006 (guards enter prison) |
| 2026-07-02 | Claude | Added TS-007 (spawn sequence must not start escape) |
| 2026-07-02 | Claude | Added TS-008…013 (from tracked bugs), debug-hooks section (DH-1…7), and code-only bug list |
| 2026-07-03 | Claude | Documented existing debug tooling (live log streaming + A3E_DebugLogFilter dual semantics + startDebugView) as a usable testing aid |
