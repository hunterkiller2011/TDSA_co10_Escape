# Architecture — Subsystem: Extraction (objective → evac)

_Last updated: 2026-07-02 (local)_ · _Status: active (integration — draft)_

> A deep trace of the **extraction subsystem**: the chain from finding the enemy communication center,
> through hacking it, to signalling for pickup, the evac vehicle run, and the win/lose outcome. This is
> the producer of the mission-outcome latches ([state-and-data-flow.md §2](state-and-data-flow.md#2-mission-outcome-chain))
> and the back half of the mission timeline ([lifecycle-and-timeline.md P5→P6](lifecycle-and-timeline.md#p5--runtime-steady-state)).
>
> Per-file detail is in [Server.md](../../code-reference/Server.md) / [AI.md](../../code-reference/AI.md) /
> [Common.md](../../code-reference/Common.md). Citations are `file:line` in the legacy Arma 3 source.

## The chain at a glance

```
   locate com-center            hack terminal              select evac zone            create evac point
 ┌────────────────────┐      ┌──────────────────┐      ┌────────────────────┐      ┌──────────────────────┐
 │ POI revealed (intel│      │ addUserActions →  │      │ SelectExtractionZone│      │ CreateExtractionPoint │
 │ /proximity) →      │─────▶│ A3E_isTerminal →  │─────▶│  pick marker by     │─────▶│ spawn helipads +      │
 │ UpdateLocationMarker│  ✔  │ fn_hijack countdown│  ✔  │  type+mode; Evac    │  ✔  │ TacticalBacon w/      │
 │ ⇒ LocateComcenter ✔ │      │ ⇒ remoteExec Select│      │  marker; ⇒ ComCenter✔│      │ firedNear handler     │
 └────────────────────┘      └──────────────────┘      └────────────────────┘      └──────────┬───────────┘
                                                                                                │
   outcome                    evac vehicle run            signal for pickup                     │
 ┌────────────────────┐      ┌──────────────────┐      ┌────────────────────┐                   │
 │ all aboard ⇒        │      │ RunExtraction*   │      │ firedNearExtraction │                   │
 │ MissionComplete ✔   │◀─────│ spawn birds +    │◀─────│ smoke/flare near    │◀──────────────────┘
 │ else ⇒ LeftBehind ✔ │      │ ExtractionChopper │      │ bacon ⇒ dispatch by │   player throws smoke
 │ ⇒ Exfil task ✔      │      │ state machine     │      │ type                │
 └────────────────────┘      └──────────────────┘      └────────────────────┘
```

Five task signals are produced along the way (all in [§ task data path](state-and-data-flow.md#3-task-state-server--client-tasks--stats)):
`LocateComcenter_Complete` → `ComCenter_Complete` → `Exfil_Complete`, plus `Prison`/`Map` earlier.

---

## Stage 1 — Locate the communication center

- **Where:** `fn_UpdateLocationMarker.sqf` updates a point-of-interest marker from the `A3E_POIs` list.
  When a POI of type `"o_hq"` is **revealed** (via intel or proximity, `_reveal`/`_unknown`), it sets
  **`A3E_Task_LocateComcenter_Complete = true`** (`:23-26`).
- **Driven by:** `fn_createLocationMarker.sqf:24/36` builds a trigger whose activation is
  `[<marker>,true] spawn A3E_fnc_UpdateLocationMarker` — i.e. the reveal is trigger-driven off the
  intel/POI system. Before reveal the marker shows as `hd_unknown` at a jittered position (±125 m,
  `:16`); reveal snaps it to the true position and true type.
- **Note:** "Locate" is separate from "Hack" — locating only *reveals* the com-center on the map; the
  player must still travel there and hack the terminal (Stage 2).

## Stage 2 — Hack the terminal

- **Action wiring:** `fn_addUserActions.sqf:8` — when a player's cursor is on an object with
  `A3E_isTerminal` (set by every `BuildComCenter*` template + `isoTemplateRestore`, `:8/:9`) and not yet
  hacked, it stores `A3E_CurrentTerminal` on the player and offers the hack action → `fn_hijack.sqf`.
- **`fn_hijack.sqf` countdown:**
  - Guards against re-hack (`A3E_Terminal_Hacked`), colours the data terminal red (`BIS_fnc_DataTerminalColor`).
  - Duration **36 s**, or **12 s if the unit's class is an `engineer`** (`:10-14`) — a soft class incentive.
  - Ticks down while the player stays within 3 m and conscious, animating the terminal in 3 stages
    (`BIS_fnc_DataTerminalAnimate`). **Aborts** (and resets `A3E_Terminal_Hacked=false`) if the player
    goes unconscious or steps >3 m away (`:41-51`).
  - **On success (`_count==0`):** `[getpos _generatorTrailer] remoteExec ["A3E_fnc_SelectExtractionZone", 2]`
    (`:56`) — hand off to the server to pick an evac zone; re-lock the terminal as hacked.

## Stage 3 — Select the extraction zone

`fn_SelectExtractionZone.sqf` (`_hackPos` = terminal position, `_select` = -1):

1. **Marker discovery (`_findMarkers`, cached):** scans `allMapMarkers` for named markers, parsing a
   trailing number, building records `[markerNo, pos, clearOfCamps(250 m), used=false, "", type]` and
   **hiding** each marker (`setMarkerAlpha 0`) unless debug. Pools by prefix:
   - `A3E_ExtractionPos*` → `"old"` (heli fallback) · `A3E_HeliExtractionPos*` → `"air"` ·
     `A3E_BoatExtractionPos*` → `"sea"` · `A3E_CarExtractionPos*` → `"land"`.
   - **These markers are editor-placed per-island in `Missions/<Island>/mission.sqm`** (each also has a
     `…_1` secondary pad and a `…SpawnPos*` vehicle-origin marker) — the **handoff to procedural
     generation / island data (part b)**.
2. **Assemble `A3E_ExtractionPositions`** from the types allowed by `a3e_arr_extractiontypes` (per-mod/
   island config), falling back to `"old"` if fewer than 6 (`:47-65`).
3. **Pick by `A3E_Param_ExtractionSelection` (`_mode`):** 0 = random; 1 = prefer *close* to the hack
   (< `A3E_MinComCenterDistance*2`); 2 = prefer *far* (`:79-100`). A specific `_select` overrides.
4. Mark the zone used (`set[3,true]`), broadcast `a3e_var_Escape_ExtractionMarkerPos`, create/refresh the
   green **"Evac"** `hd_pickup` map marker (`:105-115`).
5. **Handoff:** `[markerNo, type] call A3E_fnc_CreateExtractionPoint` (`:117`).
6. Set **`A3E_Task_ComCenter_Complete = true`** (`:119`) — *this is why the "Hack" task completes at zone
   selection: hacking is what triggers it.* HQ sidechat announces the evac point (`:122`).

> ⚠ **Candidate BUG-034 — extraction pools duplicate on repeated hacks.** The pool *discovery* is
> `isNil`-guarded (cached once), but the **assembly appends** (`:54-62`) are **not** guarded and run on
> every call. With multiple com-centers, each successful hack re-appends the `air`/`land`/`sea` positions
> to `A3E_ExtractionPositions`, accumulating duplicates. Partially masked by the `used` flag + clear
> filter, but it skews random selection toward duplicated zones. Verify in a multi-comcenter playtest.

## Stage 4 — Create the extraction point

`fn_CreateExtractionPoint.sqf` (`_markerNo`, `_extractionType`):

- Maps the type back to the marker prefix, resolves the pad markers `…<n>` and `…<n>_1`.
- Spawns two `Land_HelipadEmpty_F` (landing references) and one **`Land_TacticalBacon_F`** at the pad
  (`:24-26`). The bacon is the **signal sensor**: it gets a `firedNear` event handler compiled to
  `[markerNo, type, _this] call A3E_fnc_firedNearExtraction` (`:32-34`).
- No cleanup/tracking of these spawned objects (consistent with the templates' no-despawn pattern,
  RD-026).

## Stage 5 — Signal for pickup

`fn_firedNearExtraction.sqf` (fired by the bacon's `firedNear`):

- **Ammo gate:** only `SmokeShell` / `Chemlight_base` / `FlareBase` / `SmokeLauncherAmmo` (checked via
  `BIS_fnc_returnParents`) trigger it (`:11-13`) — you signal with **smoke/flare/chemlight**, not gunfire.
- **Dispatch by type** (`:14-31`): `air → RunExtractionHeli`, `sea → RunExtractionBoat`,
  `land → RunExtractionCar`, `old → RunExtraction` (foot/heli fallback).
- Deletes the bacon (`deletevehicle _unit`, `:33` — one-shot), groupChats "Extraction should be on its
  way."

## Stage 6 — Run the extraction (Heli, representative)

`fn_RunExtractionHeli.sqf` (server-only):

1. **Spawn** two transport helis (`a3e_arr_extraction_chopper`) at the `…SpawnPos` origin + one escort
   (`a3e_arr_extraction_chopper_escort`), side `A3E_VAR_Side_Blufor`, via `BIS_fnc_spawnVehicle`
   (`:14-27`). Publishes `A3E_EvacHeli1/2/3`; names groups "Angel One/Two", "Archangel".
2. Transports get `State="Init"` and each is handed to the **`A3E_fnc_ExtractionChopper`** state machine
   (Stage 7); the escort gets a `LOITER` waypoint (radius 500) for overwatch (`:31-39`).
3. **Guard threads** (`_heloGuard`, `_extractionGuard`): sideChat flavour on damage; if both transports
   die, flip the Evac marker to a red objective ("Both birds are down!") (`:66-96`).
4. **Board wait:** `while { <not all players in boat1/boat2> } do { sleep 1 }` (`:106-108`) — blocks until
   every player is aboard, then sets `State="Evac"` (triggers departure in the state machine).
5. Sets **`A3E_Task_Exfil_Complete = true`** (`:126`), waits 35 s, then the **outcome check** (`:130`):
   - all players in boat1/boat2 → **`a3e_var_Escape_MissionComplete = true`** (→ end2 / end4).
   - else → **`a3e_var_Escape_MissionFailed_LeftBehind = true`** (→ end3).

> ⚠ **Candidate BUG-035 — board-wait can hang extraction.** The `while` at `:106` is **unbounded**: if a
> player can never board (dead body, stuck, disconnected but still counted by `A3E_fnc_GetPlayers`), the
> loop never completes, so `State` never becomes `Evac`, `Exfil_Complete` is never set, and neither
> outcome latch fires — extraction stalls silently. The `LeftBehind` path only handles *boarded-then-left*,
> not *never-boarded*. Confirm `GetPlayers` semantics for dead/DC'd players; a timeout on the board-wait
> would be the fix. (The all-unconscious feeder in `missionFlow` still covers total wipe, but not one
> stuck survivor.)

## Stage 7 — Evac vehicle behavior

`fn_ExtractionChopper.sqf` — a per-heli state machine (`while alive && !_extract`, 2 s tick):

`Init` (add approach waypoint, on-arrival sets `State="Land"`) → `Approach` (throttle down inside
300 m / 60 m) → `Land` (`land "LAND"`, wait) → `WaitForPlayers` (re-land if it drifts off the ground)
→ **`Evac`** (set by the board-wait in Stage 6: lift, `land "NONE"`, waypoint to `extractPos + evacVec`,
exit the loop). The Boat/Car variants have analogous `A3E_fnc_ExtractionBoat`/`ExtractionCar` behaviors.

## Stage 8 — Outcome → ending

The two latches set in Stage 6 feed the `fn_missionFlow.sqf` poll triggers
([P6](lifecycle-and-timeline.md#p6--mission-end)): `MissionComplete` → **end2** (clean) or **end4**
(tainted, `A3E_Warcrime_Score > 1000`); `MissionFailed_LeftBehind` → **end3** (MIA). The clean-win gate
also tests `!civilianReporting`, which is inert (RD-035).

---

## Variants (dedupe)

`fn_RunExtraction.sqf` (old/foot-fallback), `fn_RunExtractionBoat.sqf`, `fn_RunExtractionCar.sqf`,
`fn_RunExtractionHeli.sqf` share the **same skeleton** (spawn transport(s) [+escort], hand to the matching
`Extraction{Chopper,Boat,Car}` behavior, board-wait loop, `Exfil_Complete`, then the identical
`MissionComplete`-vs-`LeftBehind` check at `:126-135`). They differ in vehicle arrays
(`a3e_arr_extraction_{chopper,boat,car}[_escort]`), spawn geometry, and flavour text. Both candidate bugs
(BUG-034 discovery aside, BUG-035 board-wait) apply to **all four** variants.

## Data & config touchpoints

| Input | Source | Used for |
|-------|--------|----------|
| `A3E_Param_ExtractionSelection` | lobby/CBA param | zone-pick mode (0/1/2) |
| `a3e_arr_extractiontypes` | per-mod/island (`UnitClasses`/island) | which marker pools are eligible |
| `a3e_arr_extraction_chopper` / `_escort` / `_boat` / `_car` | per-mod `UnitClasses.sqf` | evac vehicle classnames |
| `A3E_MinComCenterDistance` | island `WorldConfig.sqf` | close/far zone thresholds (×2) |
| `A3E_*ExtractionPos*` / `*SpawnPos*` markers | **`Missions/<Island>/mission.sqm`** (editor) | evac locations (→ part b) |
| `A3E_POIs` | intel/POI system | com-center reveal (Stage 1) |
| `A3E_VAR_Side_Blufor` | faction setup | evac vehicle side |

## Findings / issues

- **BUG-034** (candidate) — extraction pools duplicate on repeated hacks (Stage 3).
- **BUG-035** (candidate) — unbounded board-wait can stall extraction with a stuck/uncounted survivor
  (Stage 6/variants).
- **Dead DRN extraction path** — `Code/Scripts/Escape/Functions.sqf:150-166` defines
  `drn_fnc_Escape_CreateExtractionPointServer` + a `drn_EscapeExtractionEventArgs`
  `addPublicVariableEventHandler`, but nothing outside that block ever sets the PV or calls the function
  (grep-confirmed). It's the **superseded DRN-era extraction**, replaced by `A3E_fnc_SelectExtractionZone`
  → `CreateExtractionPoint`. Folded into RD-031 (Scripts dead/superseded code).
- **No cleanup** of the spawned pads/bacon/evac vehicles (RD-026 pattern).
- **Magic constants / smells:** hardcoded 250 m camp-clearance, `MinComCenterDistance*2`, `<6` fallback,
  `sleep 10/35`, `flyinheight 40/60`; `_isWater` param unused in `RunExtractionHeli`; heavy `remoteExec`
  sideChat flavour; "old" fallback path retained for legacy island markers.

## Reforger port notes

- **Terminal hack** → an interactable component with a timed action (engineer speed-up as a role check),
  abort-on-move/uncon; success fires a server event.
- **Zone selection** → a server extraction manager querying pre-placed evac points (as world entities/
  config, not `allMapMarkers` string scans); fix the duplicate-append (BUG-034) by building the list once.
- **Signal** → an interaction/smoke-detection on the evac area rather than a `firedNear` on a bacon prop.
- **Vehicle run + state machine** → an AI transport behavior component (Init→Approach→Land→Board→Evac);
  add a **board-wait timeout** (BUG-035) and proper cleanup of evac entities.
- **Outcome** → server-authoritative end checks in the game-mode; drop the dead `civilianReporting` gate.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-07-02 | Claude | Initial extraction subsystem trace (locate→hack→select→signal→run→outcome, 8 stages + variants). Surfaced BUG-034/035 and the dead DRN extraction path (→ RD-031) |
