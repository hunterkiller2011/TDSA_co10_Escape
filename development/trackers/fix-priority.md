# Prioritized Fix List / Roadmap
_Last updated: 2026-07-03 (local)_ · _Status: active_

> A prioritized, actionable synthesis of everything surfaced so far — the bug re-evaluation
> ([bugs-app.md](bugs-app.md)), feature requests ([feature-requests.md](feature-requests.md)), risks/tech-debt
> ([risks-tech-debt.md](risks-tech-debt.md)), and open questions ([open-questions.md](open-questions.md)). This is an
> **index/roadmap**, not the source of truth — each item links back to its full entry.
>
> **Priority** = player impact × frequency (cheap high-value items float up). **Effort:** ⚡trivial (≤ a few lines) ·
> ▪small · ◆medium · ⬛large. **Target:** 🅛 live Arma 3 mission · 🅟 Reforger port · 🅑 both.
>
> Only **open / actionable** items are listed. Closed/false-positive (BUG-023, BUG-028) and pure no-impact latents are
> parked in [P3](#p3--latent--no-current-impact--port-robustness).

---

## ⭐ Quick wins (one small batch — disproportionate value)

Trivial fixes, each a line or less, several with outsized payoff. Good first PR.

| ID | Fix | Payoff | Effort |
|----|-----|--------|--------|
| **BUG-032** | `_soldierCount + _soldierCount + 1;` → `_soldierCount = _soldierCount + 1;` | caps civil-vehicle crew **and kills the rare infinite-AI (BUG-039)** | ⚡ |
| **BUG-020** | `_zoneArea` → `_area` (`populateVillageZone:8`) | large villages get the intended **Opfor** mix (currently all-Independent) + kills a per-village script error | ⚡ |
| **BUG-033** | re-schedule uses `(4-freq)` → `(0.5 + (4-freq)/4)` | stops motorized-search **spam at max freq**; correct cadence at low/med | ⚡ |
| **BUG-040** | guard `count _roadConnectedTo < 2` before `select 1` (`RoadBlocks:32`) | no error / mis-rotated roadblock on dead-end segments | ⚡ |
| **BUG-001** | `A3I_BuildingPositions` → `A3E_…` | restores the garrison building-position cache | ⚡ |
| **BUG-018** | `for … from 0 to _artilleryRounds` → `to _artilleryRounds-1` | one fewer stray artillery shell | ⚡ |
| **BUG-022** | delete duplicate `&server=` line (`StartSession:32`) | tidy stats URL | ⚡ |

---

## P0 — Fix first (high player impact, recurring)

### Downed-player fairness
| ID | Item | Effort | Target |
|----|------|--------|--------|
| **BUG-037** | AI keep engaging **downed** players → tank/MG **collateral levels the area** and denies rescues (impedes the core revive mechanic). Fix: re-assert captive on the ATR downed path + actively `forgetTarget`/`doTarget objNull` nearby enemies (special-case armor). | ◆ | 🅛 |

### Prison "fair opening" cluster
The intended opening: a **reasonable, unseen planning window** until the players *choose* to act.
| ID | Item | Effort | Target |
|----|------|--------|--------|
| **BUG-030** | Guards **patrol into the prison** (50 m guard marker centered on the prison; patrol has no keep-out). Fix: confine patrol to a **perimeter ring outside** the footprint — no interior waypoints. Guards breaching *after* a player-triggered escape is fine. | ▪ | 🅑 |
| **FR-002** | Guards **see/shoot through walls** (likely missing wall view/fire geometry). Fix: **scripted LOS gating** (`lineIntersectsSurfaces` guard→player; suppress `knowsAbout`/reveal when blocked) and/or proper wall geometry LODs. | ◆ | 🅑 |
| **BUG-031** | **Spawn/init race** (JIP/reconnect): transient default loadout trips the weapon escape-trigger before the strip replicates → premature squad escape; rare **strip-failure** variant leaves a player armed. Fix: gate `A3E_PlayerInitializedServer`/the escape check on **actually unarmed + at prison**; harden the JIP gear-strip (verify+retry); cover the spawn under the black screen. | ▪-◆ | 🅑 |

### Long-session performance decline (confirmed by playtest)
| ID | Item | Effort | Target |
|----|------|--------|--------|
| **RD-037** | DRN **garbage collector disabled but still fed** — spent search/reinforcement units queued, never collected. Fix: re-enable a real periodic cleanup (model on `fn_updateTraps`) or stop queueing. | ▪ | 🅛 |
| **RD-026** | Spawned **composition objects never despawned** (prisons/com-centers/depots/roadblocks) — the dominant leak. Fix: track spawned objects per site/zone and despawn on clear/deactivate (ties to **BUG-007** zone teardown). | ◆-⬛ | 🅑 |

---

## P1 — Real, worth doing (mostly cheap)

| ID | Item | Effort | Target |
|----|------|--------|--------|
| **BUG-032 / BUG-039** | Civil-vehicle over-fill + the rare **infinite-AI recon drop-off** — one-line counter fix restores the cap (see Quick wins). | ⚡ | 🅑 |
| **BUG-036** | Garrisons **over-stuff one building/room** (surplus units unplaced + capacity-blind selection). Fix: **revive BUG-002's area-wide distribution** (spread a garrison across all zone building positions). | ◆ | 🅑 |
| **BUG-035** | Extraction **slow/never leaves** — unbounded board-wait across all 4 evac runners. Fix: bound with a **timeout** + gate on **alive+conscious** players; hold the vehicle still while waiting. | ▪ | 🅑 |
| **BUG-029** | Roadblock **manned slots misaligned** under rotation (rotation = road heading → ~every roadblock). Fix: store `_dir + _rotation` for deferred slots in `isoTemplateRestore`. Confirm frequency via **TS-014**. | ▪ | 🅑 |
| **BUG-038** | Com-center **hack/heal prompt finicky** (`cursorObject`). Fix: forgiving detection (`nearestObjects` + forward cone, or action-on-object). | ▪ | 🅑 |
| **BUG-020** | Villages are **Independent-only** (dead Opfor branch — see Quick wins) + server-only `systemchat`. | ⚡ | 🅑 |
| **BUG-033** | Motorized-search **spam at max freq** (see Quick wins). Only matters if max frequency is used. | ⚡ | 🅑 |
| **BUG-040** | RoadBlocks dead-end `select 1` (see Quick wins). | ⚡ | 🅑 |

---

## P2 — Cheap cleanups & dead code

| ID | Item | Action | Target |
|----|------|--------|--------|
| **BUG-003** | `TrackGroup` obsolete (superseded by the live `TrackGroup_Add`/`_Update` overlay) | delete with the dead patrolZone framework | 🅟 |
| **BUG-010** | `findControl` dead debug (~9M sidechats if run) | delete | 🅟 |
| **BUG-014** | `onEnemyDetected` broken duplicate of the working `KnowsAboutChanged` reporter | delete (or fix `_player`) | 🅟 |
| **BUG-015** | `SeekShelter` empty stub, `SHELTER` state never set | delete or implement | 🅟 |
| **BUG-002** | `getBuildingPositionsInMarker` dead, but it's the **abandoned area-wide garrison** design | **revive** (feature branch) → basis for BUG-036 | 🅑 |
| **BUG-012** | Terminal **lock on DC mid-hack** (Half 2) — rare but costs an hour | reset `A3E_Terminal_Hacked` on hacker disconnect/death | 🅛 |
| **RD-038** | Triplicated "radio report → recordSighting" logic (fixing it fixes BUG-014 by construction) | consolidate into one function | 🅟 |
| **BUG-009 / 011 / 026** | latent typos/mutations that work today | fix for robustness | 🅟 |

---

## P3 — Latent / no current impact / port-robustness

Confirmed defects with **no player impact** in the current build (masked, unreachable, dormant, or debug-only) — fix
opportunistically during the port; don't spend live-mission time on them.

| ID | Why parked |
|----|-----------|
| **BUG-004** | debug-only; sole caller passes no filter |
| **BUG-005** | masked — all serialized vehicle groups are single-vehicle (`select -1` = correct) |
| **BUG-006** | re-seat switch broken but self-healing (AI reseat / man empty statics); needs case-sensitivity test |
| **BUG-007** | dead path (`markedfordeletion` never set) — but wire it for zone teardown (→ RD-026) |
| **BUG-008 / 012(½) / 013** | ACE-only — dormant for the ATR/vanilla config |
| **BUG-017 / 021 / 024 / 025 / 034** | unreachable / dead computation / by-reference-safe / failsafe never hit |
| **BUG-019** | works by SQF call-inheritance (fragile) — use `_grp` for robustness |
| **BUG-027** | DRN cleanups (grpNull default, dup waypoint, server-side sideChat) |
| **RD-036** | unbounded world-gen placement loops — pre-tested maps mask it; add bounded fallback in the port |

---

## Features (separate track)

| ID | Feature | Notes |
|----|---------|-------|
| **FR-002** | Prison line-of-sight integrity (also in the P0 prison cluster) | [feature-requests.md](feature-requests.md) |
| **FR-001** | Self-hosted mission-statistics backend | design in [docs/stats-backend.md](../docs/stats-backend.md); blocked on **Q-016** (does the `htmlLoad` GET fire on a dedicated server?) |

---

## Port foundation (owner / larger efforts)

Not "bugs" — structural work the Reforger port depends on. See [risks-tech-debt.md](risks-tech-debt.md) /
[open-questions.md](open-questions.md).

| Item | Notes |
|------|-------|
| **Vendor in `Code/Revive/`** | ATR revive + HSC submodule → into the repo (owner TODO). BUG-037's fix lives here (`fn_Unconscious.sqf`). |
| **Q-022 — CBA internalization** | evaluate every CBA touchpoint; Reforger has no CBA |
| **RD-028 — unify template mechanisms** | fn-composition `Build*` (~40 copies) vs Iso data-templates → standardize on the data-driven path (prefabs) |
| **RD-030 — dead Factions system** | delete or finish (unwired faction abstraction); live system is `Mods/UnitClasses` |
| **Q-015 — zone framework** | `A3E_Zones` (live) vs legacy `patrolZones` (dead) → pick one authoritative model |
| **Q-001/005/007** | Reforger project layout, build/packaging, faction/mod permutations |

---

## Verification still owed (playtest)

| Test | Confirms |
|------|----------|
| **TS-014** | BUG-029 roadblock manned-slot rotation (every-time vs most) |
| **TS-006** | BUG-030 guards-into-prison after fix |
| **TS-007** | BUG-031 spawn-race (needs the DH-6 spawn-delay debug hook) |
| debug-log in `PopulateVehicle` | catch BUG-039 over-count when it recurs |
| exitWith-scope 3-line console test | settles BUG-025's mechanism (partial vs zero build) — academic (never triggers) |

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-07-03 | Claude | Initial prioritized fix list synthesizing the full bug re-evaluation, FRs, and key tech-debt/port items |
