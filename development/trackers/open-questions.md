# Open Questions
_Last updated: 2026-06-30 (local)_ · _Status: active_

> Unresolved questions and assumptions for the Arma 3 → Reforger conversion. **ID scheme:** `Q-NNN`
> (stable, never reused). These are decision *points*, not decisions — record decisions as ADRs in
> [decision-log.md](decision-log.md).

## Q-001 — Target Reforger mod/project structure
**Status:** open
What should the Enfusion mod look like — Workbench project layout, addon/Prefab organization, how the
procedurally-generated content is composed? Gates the production directory layout.

## Q-002 — SQF → Enforce Script port strategy
**Status:** open
Full reimplementation vs. partial port? Which subsystems are ported first (e.g. core escape loop before
ambient systems)? How much of the ~215-function `A3E` surface carries over conceptually?

## Q-003 — Terrain / island story
**Status:** open
Which of the ~119 Arma 3 islands have Reforger terrain equivalents, and how is procedural
placement (prison/COM/ammo/extraction) adapted to the available Reforger terrains?

## Q-004 — AI behavior mapping
**Status:** open
How do Reforger's AI APIs map to the Arma 3 patrol / search / guard / extraction behaviors and the
`Chronos` scheduler + `SearchLeader` escalation model?

## Q-005 — Build & packaging pipeline
**Status:** open
What replaces `EscapeCompiler.exe` / `.pbo` packaging (per mod×island) — Enfusion Workbench addon
build, and how are the per-mod/per-island config permutations expressed?

## Q-006 — Multiplayer / replication model
**Status:** open
How do `missionNamespace` / `publicVariable` / `remoteExec` patterns translate to Enfusion's
replication/RPC and authority model (server vs client)?

## Q-007 — Faction / mod configs
**Status:** open
How are the faction/mod permutations (CUP, RHS, SOGPF, SPE, GM, etc.) represented in Reforger's
modding ecosystem, given different available mods/assets?

## Q-008 — Test strategy for Reforger
**Status:** open
Is there a viable automated test approach in Enfusion, or does validation remain manual playtesting?
The answer determines whether `development/tests/` is added.

## Q-009 — Marker-shape handling in position helpers
**Status:** open
`Helper/fn_RandomMarkerPos.sqf` uses elliptical sampling regardless of ELLIPSE vs RECTANGLE marker
shape, and `Helper/fn_getBuildingsInMarker.sqf` reads but ignores marker rotation (inline TODO for a
`bis_fnc_inTrigger` shape filter). Is rectangle/rotation accuracy required, or is the circle/ellipse
approximation intentional? Affects how zone placement ports. _(Surfaced Sprint 1.)_

## Q-010 — Chronos registration robustness
**Status:** open
`Chronos/fn_Chronos_Register.sqf` parses its args twice (`params` then `BIS_fnc_param` per arg) and has
no de-dup guard, so a function registered twice is scheduled twice. Intended, or cleanup for the port's
scheduler design? _(Surfaced Sprint 1.)_

## Q-011 — Server-local debug markers visibility
**Status:** open
`Common/fn_InitVillageMarkers.sqf` runs server-side using `createMarkerLocal`, whose markers aren't
visible to clients — verify the debug village markers appear anywhere. Its `[true]` arg is ignored (reads
`A3E_Debug`). _(Surfaced Sprint 2.)_

## Q-012 — `handleScore` gating & registration asymmetry
**Status:** open
`Common/fn_handleScore.sqf` gates on `!isNil "a3e_var_Escape_SearchLeader_civilianReporting"` (variable
presence, not value) — may misfire if defined-but-false. It is registered server-side (initPlayer) whereas
`handleRating` is client-side (initLocalPlayer) — intentional asymmetry? _(Surfaced Sprint 2.)_

## Q-013 — `a3e_fnc_move` waypoint convention (port choke-point)
**Status:** open
All AI behaviors reuse waypoint index 1 and embed self-respawn recursion inside the waypoint's oncomplete
string — fragile if extra waypoints exist, and a key rework point for Enfusion (different waypoint API).
Also `Guard`/`Search` set `setWaypointTimeout [0,20,6]` (max < mid) — looks like a min/mid/max typo. _(Surfaced Sprint 3.)_

## Q-014 — Aquatic patrols share the foot-patrol state tag
**Status:** open
`fn_AquaticPatrol.sqf` tags boat groups with state `"PATROL"`, the same tag as foot patrols — verify
`OrderSearch`/`SeekShelter` and other consumers don't mis-treat boats as infantry. _(Surfaced Sprint 3.)_

## Q-015 — Which zone/spawn framework is authoritative?
**Status:** open
`initPatrolZone`/`activatePatrolZone` (legacy patrolZones + BIS pairs) vs the `A3E_Zones` HashMap framework
(`initZone`/populate*), and is `MilitaryTraffic` duplicated (Spawning + DRN via initServer)? This decides the
Reforger spawn/zone architecture. See RD-018. _(Surfaced Sprint 4.)_

## Q-016 — Does the hidden-RscHTML stats GET fire on a dedicated server?
**Status:** open
The external stats lifecycle issues its GET via `htmlLoad` on a hidden `RscHTML` UI control. On a headless/
dedicated server (no UI) this may never fire, silently no-op'ing the whole external-stats system. Verify. _(Surfaced Sprint 4.)_

## Q-017 — SearchLeader detection latch serializes two sides
**Status:** open
`A3E_var_PlayerCanBeDetected` is a single global latch shared by the OPFOR and Independent detection triggers,
so only one side can report a sighting at a time. Intended, or should each side latch independently? _(Surfaced Sprint 4.)_

## Q-018 — Faction functions: live via dynamic dispatch, or dead? — RESOLVED (dead/unfinished)
**Status:** resolved (2026-07-02) — **dead / unfinished**
**Resolution:** the whole `Factions/` faction-abstraction is unwired. `loadFaction`/`selectFaction`/
`getRndEntryFromFaction` have **zero callers** (not even string/dynamic-dispatch), and the side pools
`selectFaction` reads (`A3E_EnemyFactions`/`A3E_IndepFactions`/`A3E_CivilianFactions`/`A3E_PlayerFaction`) are
**never populated** anywhere in the repo — so `selectFaction` would error on a nil global if ever called. Only one
faction file exists (`Factions/BIS_Syndikat.sqf`, an Independent faction), and `selectFaction` still carries a
`//ToDo` for positional selection. It's an **abandoned/unfinished feature**; the live unit system is
`Mods/{Mod}/UnitClasses.sqf` (the `a3e_arr_*` arrays + `A3E_*Templates`). Tracked as tech-debt in RD-030.

## Q-019 — Lobby params vs CBA settings precedence
**Status:** open
Parameters exist both as lobby params (`params.hpp`) and CBA settings (`XEH_preInit.sqf`), gated by
`A3E_UseCBASettings`, and are also resolved by `parameterInit`. Which source wins when they disagree? _(Surfaced Sprint 5.)_

## Q-020 — Init ordering / serialization
**Status:** open
`fn_bootstrapEscape` spawns `missionFlow` and `initServer` in parallel with no ordering guarantee — race if one
reads the other's globals? And `initServer` does `waitUntil {scriptDone _scriptHandle}` on the search-chopper
`execVM` (`:452`), serializing init behind chopper creation — intentional? _(Surfaced Sprint 5.)_

## Q-021 — ComCenter objective visual-cue inconsistency
**Status:** open
Vanilla/VN com-center variants call `BIS_fnc_DataTerminalColor` (green glow) on the hackable terminal, but the
SPE/SPE-GER radio variants (`SPE_Radio_Us`/`SPE_Radio_Ger`) do not — SPE players lose the visual highlight (the
`A3E_isTerminal` hack still works). Also `_spe_ger1`/`_vn_us*` force-texture their German/US flags to the generic
Opfor texture. Intended, or cosmetic oversight? _(Surfaced Sprint 7.)_

## Q-022 — CBA dependency: how deep, and what must be internalized for Reforger?
**Status:** open
The mission depends on **CBA** (Community Base Addons): settings via `XEH_preInit.sqf` + `cba_settings.sqf`
(`CBA_fnc_addSetting`, `cba_settings_hasSettingsFile`), the `Extended_PreInit_EventHandlers` PreInit hook,
`CBA_fnc_addEventHandler` (e.g. the ACE-unconscious handler), and possibly CBA calls inside `Code/Scripts/`.
Reforger has no CBA. Evaluate every CBA touchpoint and decide which parts to **bring under the mission's direct
control** vs replace with Enfusion equivalents. _(Surfaced from the coverage review; see code-reference Coverage & gaps.)_

## Q-023 — magRepack third-party licensing / redistribution
**Status:** open
`Code/Scripts/outlw_magRepack/*` (Outlawled/GiPPO Mag Repack v3.1.3) is vendored into the mission with **no license
stated in-file**. Confirm redistribution rights before shipping, and decide whether to keep/reimplement it for the
Reforger port (it's pure Arma-3 dialog/magazine API). See RD-033. _(Scripts review.)_

_Format for new entries:_
```
## Q-NNN — <short title>
**Status:** open | resolved (→ ADR-NNNN / commit)
<the question, assumptions, and what a resolution would unblock>
```

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton; seeded Q-001…Q-008 (conversion unknowns) |
| 2026-06-30 | Claude | Added Q-009, Q-010 from code-reference Sprint 1 |
| 2026-07-01 | Claude | Added Q-011, Q-012 from code-reference Sprint 2 (Common) |
| 2026-07-01 | Claude | Added Q-013, Q-014 from code-reference Sprint 3 (AI) |
| 2026-07-01 | Claude | Added Q-015…017 from code-reference Sprint 4 (Spawning/SearchLeader/Statistics) |
| 2026-07-02 | Claude | Added Q-018…020 from code-reference Sprint 5 (Server/init) |
| 2026-07-02 | Claude | Added Q-021 from code-reference Sprint 7 (Templates) |
| 2026-07-02 | Claude | Added Q-022 (CBA dependency evaluation) from coverage review |
| 2026-07-02 | Claude | Resolved Q-018 — Factions/ system is dead/unfinished (→ RD-030) |
| 2026-07-02 | Claude | Added Q-023 (magRepack third-party licensing) from Scripts review |
