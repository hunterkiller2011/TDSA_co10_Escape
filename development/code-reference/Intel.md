# Code Reference — Intel
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Intel collection and point-of-interest reveal. One entry per source file in `Code/functions/Intel/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_RevealPOI  —  `Code/functions/Intel/fn_RevealPOI.sqf`  ·  _status: documented_
- **Purpose:** Reward collected intel by revealing N eligible points-of-interest on the map (un-hiding their location markers) and broadcasting a flavour message describing what was revealed.
- **Inputs:** `params ["_numIntel"]` (Number of POIs to reveal). Reads global `A3E_POIs` (default `[]`) — each POI element indexes `#0` (id/marker key), `#4`/`#5` (reveal-eligibility flags) and `#7` (a gating flag). Intended to run server-side (remoteExec target 2).
- **Outputs:** No return value. Side effects: updates location markers (reveals POIs) via the callee; sends `systemChat` flavour text to all clients via `remoteExec ["systemchat",0]` (`:16-37`).
- **Calls:** `A3E_fnc_UpdateLocationMarker` (`:11`) per revealed POI — resolves to `Code/functions/Server/fn_UpdateLocationMarker.sqf` (declared `functions.hpp:141`; the lowercase spelling at the call site works due to SQF case-insensitivity); `remoteExec` of `"systemchat"`.
- **Called by:** `Code/functions/Intel/fn_collectIntel.sqf:6` via `[count _intels] remoteExec ["A3E_fnc_RevealPOI", 2]` (executed on the server).
- **Processing:** Filter `A3E_POIs` to eligible-and-not-yet-revealed POIs → clamp `_numIntel` to available count → loop `_numIntel` times picking `selectRandom` and updating its marker (capturing the last marker type) → if exactly one revealed, emit a type-specific message (comm center / vehicle depot / wreck / ammo depot / mortar / generic); if more than one, emit a count message.
- **Theory of operation:** Decouples "player handed in intel" (collectIntel, runs where inventory closes) from "reveal map locations" (this, runs on server where `A3E_POIs` is authoritative), bridged by remoteExec. Markers are pre-created hidden and merely un-hidden here.
- **Whys & questions:** Q: `selectRandom _pois` can pick the same POI twice in the loop (no removal), so revealing N can reveal fewer than N distinct POIs — likely minor. Q: the single-POI message uses only the *last* iteration's marker type even though the loop ran once — fine for N=1 but the type capture is loop-order dependent.
- **Unresolved issues:** The `A3E_POIs` element schema (`#4/#5/#7`) is undocumented/magic-index — fragile. Possible duplicate-reveal due to `selectRandom` without removal.
- **Reforger port notes:** TBD — map-marker reveal would map to MapMarker UI components; remoteExec→RPC.

### a3e_fnc_addIntel  —  `Code/functions/Intel/fn_addIntel.sqf`  ·  _status: documented_
- **Purpose:** Randomly seed an enemy unit's inventory with intel items at spawn, so players can later loot intel from bodies. Implements the "where intel comes from" half of the intel loop.
- **Inputs:** `params ["_unit"]` (the just-spawned enemy). Reads globals `A3E_IntelItems` (default list of doc/phone/file classnames) and `A3E_Param_IntelChance` (default 20, percent).
- **Outputs:** No return value. Side effect: adds 1–2 random intel items into the unit's uniform/vest/backpack (or as a magazine fallback) via `addItemToUniform`/`addItemToVest`/`addItemToBackpack`/`addMagazineGlobal`.
- **Calls:** none (leaf function — only engine commands and `selectRandom`).
- **Called by:** `Code/functions/Spawning/fn_onEnemySoldierSpawn.sqf:130` — `[_unit] call A3E_fnc_AddIntel`.
- **Processing:** Roll `_chance >= random 100`; if pass, build list of available containers (uniform/vest/backpack present) → pick amount `selectRandom [1,1,1,1,2]` (≈20% chance of 2) → for each, pick a random present container and add a random intel item; default branch adds it as a magazine.
- **Theory of operation:** Intel is modelled as ordinary inventory items (magazines) on enemies so the engine's looting works for free; collectIntel later recognises these classnames. Probability-gated to keep intel scarce.
- **Whys & questions:** Q: `_chance >= random 100` means chance=20 yields ~20% — correct. Q: the `default` branch (`addMagazineGlobal`) only triggers if `selectRandom _containers` returns something other than 1/2/3, i.e. when `_containers` is empty (unit has no clothing/pack) — graceful fallback.
- **Unresolved issues:** Casing: declared `A3E_fnc_addIntel` but called as `A3E_fnc_AddIntel` (works due to A3 case-insensitive function names, but inconsistent). Intel items are added but loadout-save (serialization) may or may not preserve them — cross-check with zone serialization.
- **Reforger port notes:** TBD — would attach intel as inventory items/components on AI; chance roll stays the same conceptually.

### a3e_fnc_collectIntel  —  `Code/functions/Intel/fn_collectIntel.sqf`  ·  _status: documented_
- **Purpose:** When a player closes an inventory, detect any intel items they now hold, consume them, and trigger map POI reveals proportional to how many were collected. The "hand in intel" half of the loop.
- **Inputs:** `params ["_unit","_container"]` (from the `InventoryClosed` event handler; `_container` unused). Reads global `A3E_IntelItems` (default list) and `A3E_Param_UseIntel` (gate: 1 = enabled). Runs on the player's client.
- **Outputs:** No return value. Side effects: removes collected intel magazines from `_unit`; triggers POI reveal on the server via `[count _intels] remoteExec ["A3E_fnc_RevealPOI", 2]` (`:6`).
- **Calls:** `A3E_fnc_RevealPOI` via `remoteExec` to the server (target 2); engine `removeMagazine`.
- **Called by:** `Code/functions/Common/fn_initLocalPlayer.sqf:41` — `player addEventHandler ["InventoryClosed","_this call A3E_FNC_collectIntel;"]` (so it fires every time the player closes inventory).
- **Processing:** If `A3E_Param_UseIntel==1`: filter the player's magazines to those in `A3E_IntelItems` → remoteExec RevealPOI with the count → remove each collected intel magazine from the unit.
- **Theory of operation:** Intel items are picked up like any loot; closing inventory is the natural "you've gathered it" moment. Reveal is delegated to the server (authoritative `A3E_POIs`) via remoteExec, then the local items are consumed so they can't be handed in twice.
- **Whys & questions:** Q: fires on *every* inventory close, scanning all magazines each time — cheap but frequent. Q: removes intel even if the reveal had nothing to reveal (POIs exhausted) — intel is still consumed; acceptable.
- **Unresolved issues:** Reading `A3E_Param_UseIntel` directly (no default via getVariable) will error if the param was never set — minor robustness gap vs the `missionNamespace getVariable [...]` style used for the other params. Casing: `A3E_FNC_collectIntel` vs file `fn_collectIntel`.
- **Reforger port notes:** TBD — inventory-close hook → Enfusion inventory event; remoteExec → server RPC.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-06-30 | Claude | Documented all entries |
