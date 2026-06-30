# Code Reference — Zones
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Patrol/location zone activation lifecycle and group (de)serialization. One entry per source file in `Code/functions/Zones/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_DeserializeZoneGroups  —  `Code/functions/Zones/fn_DeserializeZoneGroups.sqf`  ·  _status: documented_
- **Purpose:** Re-spawn (rehydrate) the AI groups + vehicles of a zone that were previously despawned/serialized, restoring their loadout, damage, vehicle seating and AI behaviour task. The "spawn back in" half of the zone serialization lifecycle.
- **Inputs:** `params ["_zoneIndex"]` (Number). Reads global `A3E_Zones` (array of HashMaps); the per-zone `"serializedgroups"` entry must already hold serialized HashMaps produced by `a3e_fnc_SerializeZoneGroups`. Precondition: zone was serialized at least once.
- **Outputs:** No return value. Writes the zone HashMap: sets `"groups"` to the list of newly created group objects and clears `"serializedgroups"` to `[]` (`:103-104`). Side effects: creates vehicles (`createVehicle`), creates groups/units (`createGroup`/`createUnit`), moves units into vehicles, sets each group's `a3e_homeMarker` variable (`:71`).
- **Calls:** `a3e_fnc_log`; per-group restores behaviour via one of `A3E_FNC_Patrol` (also for SAD/default), `A3E_FNC_Stroll`, `A3E_FNC_Occupy`, `A3E_FNC_SeekShelter` selected by `_taskstate` (`:72-97`); `A3E_fnc_TrackGroup_Add` (`:98`).
- **Called by:** `a3e_fnc_activateZone` (`Code/functions/Zones/fn_activateZone.sqf:25`) — only on the re-activation path (zone already `initialized`).
- **Processing:** For each serialized group: rebuild vehicles from saved class/pos/dir/fuel/damage; create the group on its saved side; rebuild each unit (class/pos/dir/rank/loadout/damage) and move it into the correct driver/cargo/turret seat; restore `a3e_homeMarker`; dispatch the saved AI task; register with TrackGroup; collect into `_groups`.
- **Theory of operation:** Zones are expensive to keep live, so when players leave they are serialized to plain HashMaps and the actual units deleted; on return they are reconstructed from that data. Mirrors `a3e_fnc_SerializeZoneGroups` field-for-field.
- **Whys & questions:** Damage restore branches on whether `getAllHitPointsDamage` returned a per-hitpoint array (`count>=3`) vs scalar — mirrors the serializer. Q: deserialized units get fresh AI groups but no waypoints beyond what the task functions add — relies entirely on the task-state functions to re-establish behaviour.
- **Unresolved issues:** `case "cargo"` uses `if(count(_vehiclePosition==1))` (`:56`) — `_vehiclePosition==1` is a boolean/array comparison and `count` of it is almost certainly not the intended "is this the cargo index" check; looks like a bug (probably meant `_vehiclePosition#1 == ...` or a plain cargo move). Variables destructured via `(values _x) params (keys _x)` rely on HashMap key order matching, which is fragile. Casing: callees mix `A3E_FNC_Patrol`/`A3E_FNC_OCCUPY`.
- **Reforger port notes:** TBD — Enfusion has no `createUnit`/`getUnitLoadout`/HashMap-serialization equivalents; persistence/streaming of AI groups would need a bespoke component-based save model.

### a3e_fnc_SerializeZoneGroups  —  `Code/functions/Zones/fn_SerializeZoneGroups.sqf`  ·  _status: documented_
- **Purpose:** Snapshot all live AI groups/vehicles of a zone into plain HashMaps, then delete the actual objects — the "despawn but remember" half of the zone serialization lifecycle.
- **Inputs:** `params ["_zoneIndex"]` (Number). Reads global `A3E_Zones`; the zone's `"groups"` entry must hold live group objects and `"marker"` the home marker name.
- **Outputs:** No return value. Writes the zone HashMap: sets `"serializedgroups"` to the array of serialized HashMaps and clears `"groups"` to `[]` (`:75-76`). Side effects: deletes all units, groups, and their vehicles (`deleteVehicle`/`deleteGroup`, `:64-70`).
- **Calls:** `a3e_fnc_log`; `A3E_fnc_GetTaskState` (`:60`) to capture each group's current behaviour state.
- **Called by:** `a3e_fnc_deactivateZone` (`Code/functions/Zones/fn_deactivateZone.sqf:16`).
- **Processing:** For each non-null group: for each unit, save class/pos/dir/loadout/rank/damage; if the unit is in a vehicle not yet recorded, serialize that vehicle (class/pos/dir/fuel/damage) and record the unit's vehicle index + `assignedVehicleRole`; build a per-group HashMap with homemarker/units/vehicles/side/taskstate; then delete the live units, group, and listed vehicles.
- **Theory of operation:** Lets the mission free engine resources for unoccupied zones while preserving enough state to reconstruct them identically on return (see `a3e_fnc_DeserializeZoneGroups`). Damage is stored as a per-hitpoint array when available, else a scalar.
- **Whys & questions:** Serializing to HashMaps (rather than keeping `objNull` references) avoids leaking dead handles and is publicVariable-able if needed. Q: only `alive` units are counted before deletion (`:63`) but all `units _grp` are deleted regardless — dead bodies are intentionally cleaned up.
- **Unresolved issues:** `_vehicleList find (vehicle _x)` is computed *before* the vehicle is pushed, so `_in` is `-1` for the first occurrence and is stored as `_vehicleIndex` (`:31,50`) — the unit referencing a vehicle that was just added gets index `-1`, not its real position; this almost certainly mis-seats the first crew member on deserialize (suspected bug). Mirror-bug to the `count(_vehiclePosition==1)` issue in the deserializer.
- **Reforger port notes:** TBD — same persistence-model concern as the deserializer; Enfusion would likely use an entity-save / replication approach rather than ad-hoc HashMaps.

### a3e_fnc_activateZone  —  `Code/functions/Zones/fn_activateZone.sqf`  ·  _status: documented_
- **Purpose:** Bring a zone "live" when players enter its activation trigger: on first entry run the zone's one-time populate function; on subsequent entries deserialize the previously despawned groups. Updates the debug marker colour.
- **Inputs:** `_this select 0` → `_zoneIndex` (Number). Reads global `A3E_Zones`, and per-zone keys `"active"`, `"initialized"`, `"marker"`, `"oninit"`. Reads global `A3E_Debug` for marker alpha.
- **Outputs:** No return value. Writes zone keys `"active"=true` and (on first run) `"initialized"=true`. Side effects: sets marker colour to `ColorYellow` and alpha; invokes the zone's onInit populate function.
- **Calls:** First-time path: `[_zoneIndex] call (missionNamespace getVariable _onInit)` — **dynamic dispatch by function-name string** stored as `"oninit"` (e.g. `A3E_FNC_populateLocationZone`, `A3E_FNC_PopulateVillageZone`); these callers can't be found statically. Re-activation path: `A3E_fnc_DeserializeZoneGroups`. Also `a3e_fnc_log`.
- **Called by:** Invoked **by trigger statement string** built in `Code/functions/Zones/fn_initZone.sqf:56` (`"[%1] call A3E_FNC_activateZone;"`) and fired by the activation `EmptyDetector` trigger (`fn_initZone.sqf:58`). No direct `call` site exists in source.
- **Processing:** Guard on `!active`; set marker colour/alpha; if not yet `initialized`, call the onInit function and mark active+initialized; else deserialize and mark active.
- **Theory of operation:** Zones use larger deactivation triggers than activation triggers (see initZone) to avoid spawn/despawn oscillation; activation is idempotent via the `active` flag.
- **Unresolved issues:** `_zone` is assigned without `private` (`:4`) — leaks a global-ish variable. The onInit dispatch via `missionNamespace getVariable _onInit` is a **static-analysis blind spot**: populate functions appear to have no callers in xref because they are only reached through this string. Casing mix (`A3E_FNC_activateZone` vs `a3e_fnc_...`).
- **Whys & questions:** Q: why `time > 1` in the trigger condition (initZone) — likely to avoid activating during mission init before players exist.
- **Reforger port notes:** TBD — Enfusion streaming/triggers differ; would map to a trigger-area or distance-check component plus an explicit spawn/despawn handler.

### a3e_fnc_deactivateZone  —  `Code/functions/Zones/fn_deactivateZone.sqf`  ·  _status: documented_
- **Purpose:** Despawn a zone's groups when players leave its (larger) deactivation trigger area, serializing them for later restore, and optionally tear the zone down entirely if it was marked for deletion.
- **Inputs:** `params ["_zoneIndex"]` (Number). Reads global `A3E_Zones` and per-zone keys `"active"`, `"initialized"`, `"marker"`, `"markedfordeletion"` (default false). Reads `A3E_Debug` for marker alpha. References `_trigger` in the deletion branch (see issue below).
- **Outputs:** No return value. Writes zone key `"active"=false`. Side effects: sets marker colour `ColorRed` (or `ColorWhite` on deletion); serializes/deletes groups; in the deletion branch deletes a trigger via `deleteVehicle _trigger`.
- **Calls:** `A3E_fnc_SerializeZoneGroups` (`:16`); `a3e_fnc_log`.
- **Called by:** Invoked **by trigger statement string** built in `Code/functions/Zones/fn_initZone.sqf:57` (`"[%1] call A3E_FNC_deactivateZone;"`), fired on the deactivation `EmptyDetector` trigger's deactivation slot (`fn_initZone.sqf:73`). No direct `call` site in source.
- **Processing:** Only acts when zone is both `active` and `initialized`; recolour marker, serialize groups, set inactive; if `markedfordeletion`, delete the trigger and whiten the marker.
- **Theory of operation:** Counterpart to `activateZone`; the deactivation trigger is intentionally ~100 m larger than the activation trigger (initZone:70) to create hysteresis and prevent oscillation at the boundary.
- **Whys & questions:** Q: "markedfordeletion" is read here but the writing site (zone-cleared logic) isn't in this file — needs cross-check.
- **Unresolved issues:** `_trigger` (`:22`) is never defined in this function or passed in — `deleteVehicle _trigger` likely deletes `nil`/the wrong object; the actual trigger handles live in the zone HashMap as `"trigger"`/`"deactivationtrigger"`. Suspected bug in the deletion branch. Casing mix `A3E_fnc_*`/`A3E_FNC_*`.
- **Reforger port notes:** TBD — same trigger/streaming remap as activateZone.

### a3e_fnc_initLocationZone  —  `Code/functions/Zones/fn_initLocationZone.sqf`  ·  _status: documented_
- **Purpose:** Thin convenience wrapper around `a3e_fnc_initZone` for circular "location" zones (com centers, ammo depots, mortar sites, motor pools, roadblocks): builds the ellipse shape, fixes the populate function to `A3E_FNC_populateLocationZone`, and stamps the owning side onto the zone.
- **Inputs:** `params ["_position","_size","_side",["_type","Default"]]` — center pos, radius, side, optional type string.
- **Outputs:** Returns the new `_index` (Number) into `A3E_Zones` (`:6`). Side effect: sets the new zone's `"side"` key (`:5`).
- **Calls:** `A3E_fnc_initZone` (`:4`) with shape `[_position,0,"ELLIPSE",[_size,_size]]` and onInit name string `"A3E_FNC_populateLocationZone"`.
- **Called by:** `Code/functions/Server/fn_createAmmoDepots.sqf:94`, `fn_createComCenters.sqf:66`, `fn_createMortarSites.sqf:96`, `fn_createMotorPools.sqf:85`, `Code/functions/Server/fn_RoadBlocks.sqf:51` — each passing a distinct type and side.
- **Processing:** Compose ellipse shape → call initZone → set side → return index. (3 statements.)
- **Theory of operation:** Centralizes the common case so location-type generators don't repeat the shape/onInit boilerplate; the `"side"` key is later read by `A3E_FNC_populateLocationZone` to decide faction.
- **Whys & questions:** None notable.
- **Unresolved issues:** None observed.
- **Reforger port notes:** TBD — would become a parameterized spawn-zone factory call.

### a3e_fnc_initZone  —  `Code/functions/Zones/fn_initZone.sqf`  ·  _status: documented_
- **Purpose:** Core zone constructor: allocates a new zone slot, creates its map marker, and wires up the activation + deactivation `EmptyDetector` triggers that drive the spawn/despawn lifecycle. Returns the zone index used everywhere else.
- **Inputs:** `params ["_shape","_onInit",["_type","Default"]]` where `_shape = [pos, dir, shapeStr, [sizeX,sizeY]]` and `_onInit` is the **name string** of the populate function. Reads/initializes globals `A3E_ZoneIndex`, `A3E_Zones`, `A3E_Debug`, and `A3E_Param_EnemySpawnDistance` (default 800). Needs a player group (`a3e_fnc_getPlayerGroup`).
- **Outputs:** Returns `_zoneIndex` (Number). Side effects: increments global `A3E_ZoneIndex`; creates 1–2 markers (+ debug label) via `createMarker`; creates two triggers via `createTrigger` attached to the player group's vehicle; pushes a new zone HashMap into `A3E_Zones[_zoneIndex]` with keys trigger/deactivationtrigger/marker/zonearea/oninit/type/initialized/active.
- **Calls:** `a3e_fnc_getPlayerGroup` (`:47`). Triggers carry deferred statement strings `"[N] call A3E_FNC_activateZone;"` / `"[N] call A3E_FNC_deactivateZone;"` (`:56-58,73`) — these are the **dynamic invocations** of the activate/deactivate functions.
- **Called by:** `a3e_fnc_initLocationZone` (`Code/functions/Zones/fn_initLocationZone.sqf:4`) and `Code/functions/Spawning/fn_initVillages.sqf:3` (village zones with `A3E_FNC_PopulateVillageZone`).
- **Processing:** Bootstrap index/array → derive pos/dir/shape/size/area → create blue marker (+debug label) → read spawn distance → create activation trigger (`MEMBER PRESENT`, area = size+range, statement `this && time>1`) → create deactivation trigger (area = size+range+100, deactivation statement) → assemble zone HashMap → store → return index.
- **Theory of operation:** A zone is a marker + two nested triggers; the inner (smaller) trigger spawns content, the outer (100 m larger) trigger despawns it, giving hysteresis so players near the edge don't thrash the AI in/out. The populate function is stored by name so it can be resolved later via `missionNamespace getVariable`.
- **Whys & questions:** Q: triggers attach to `vehicle (units _playerGroup select 0)` — assumes player group #0 unit 0 exists at init time. Q: `_type` stored upper-cased but compared elsewhere — verify consistent casing in consumers.
- **Unresolved issues:** `_rectangle` is re-declared `private` twice (`:50,64`). `A3E_Zones set [_zoneIndex,...]` after `pushBack`-style index bump works only because index tracking is manual; concurrent zone creation could race. Marker name uses index so deletion/reuse must keep indices stable.
- **Reforger port notes:** TBD — Enfusion uses trigger entities / `SCR_` trigger components; the two-trigger hysteresis pattern would need an equivalent enter/exit radius design.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-06-30 | Claude | Documented all entries |
