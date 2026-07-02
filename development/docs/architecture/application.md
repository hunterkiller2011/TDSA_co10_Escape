# Architecture — Application
_Last updated: 2026-07-02 (local)_ · _Status: active (partial)_

> How the mission is built and runs (components, data model, control flow). _(skeleton — to be filled)_
>
> The legacy Arma 3 implementation is mapped in detail under
> [../../code-reference/](../../code-reference/README.md); this doc is the higher-level picture and,
> over time, the Reforger target architecture.

## Components

_(to write — init flow, server vs client, the major subsystems)_

## Data model / state

_(to write — global variables, mission namespace, group state)_

## Control flow

### Prison start — escape & alarm state (current Arma 3 behavior)

Players spawn **captive** at `A3E_StartPos` and must escape. Two distinct states, often conflated:

**`A3E_EscapeHasStarted`** — the escape has begun (players are un-captived; the prison task completes once a player is
>50 m out, `fn_missionFlow.sqf:64`). Set by **any of three triggers** (`fn_initServer.sqf:603-655`), and only for
players already placed (`A3E_PlayerInitializedServer`):
1. an initialized player is **15–100 m** from `A3E_StartPos` (`:613`);
2. an initialized player **holds a weapon** — `count weapons > 0` (`:617-618`);
3. the **gate/door opens** — `animationPhase "Door_1_rot"/"Door_2_rot" > 0.5` (`:647-655`).

**Guard awareness** (`_guardGroup knowsAbout _player > 2.5`) is **not** an escape trigger — before escape it does
nothing; it is only read *after* escape has started, where it triggers the alarm (`:641`).

**`A3E_SoundPrisonAlarm`** — the prison alarm: a **one-shot** ~30 s event (`A3E_fnc_soundAlarm`, `:589-599`) that plays
the loudspeaker siren (via `A3E_PrisonLoudspeakerObject`, wired in `fn_briefing.sqf:9`) and **reveals all players to
every guard group** (`A3E_fnc_revealPlayers`). Triggered by **either**:
1. a guard becoming **aware of a player** (`knowsAbout > 2.5`) *after escape has started* (`:641-643`); or
2. the **gate/door opening** (`:654`).

So: arming up or walking away **starts the escape silently**; opening the gate **starts the escape AND sounds the
alarm**; guard-awareness only **sounds the alarm once the escape is already underway**. Spawn placement and its
interaction with these triggers is covered by BUG-030 / BUG-031.

### Other flow

_(to write — initialization → procedural generation → runtime loops)_

## Reforger target architecture

_(to write — TBD; see [open-questions Q-001/Q-002/Q-004/Q-006](../../trackers/open-questions.md))_

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton |
| 2026-07-02 | Claude | Documented the prison escape/alarm state machine (Control flow) |
