# Code Reference — Debug
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Logging, group tracking, and debug markers. One entry per source file in `Code/functions/Debug/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_DebugMsg  —  `Code/functions/Debug/fn_DebugMsg.sqf`  ·  _status: documented_
- **Purpose:** Lightweight debug-gated logging shim: forwards a message to the full logging pipeline only when debug mode is on.
- **Inputs:** params `_msg` (string, default `"Empty message"`). Global state read: `missionNamespace getVariable "A3E_Debug"` (bool, default false). No preconditions.
- **Outputs:** No return value. Side effect: indirectly logs via `a3e_fnc_Log` (system chat + .rpt + in-memory log) only when `A3E_Debug` is true.
- **Calls:** `a3e_fnc_Log` (`fn_DebugMsg.sqf:3`). Leaf otherwise.
- **Called by:** Widely used across the codebase as a convenience logger — e.g. `Spawning/fn_activatePatrolZone.sqf:2`, `Spawning/fn_deactivatePatrolZone.sqf:39,48`, `Server/fn_initServer.sqf:3,20,24,36`, and all of `DRN/fn_SearchChopper.sqf`. Several call sites are commented out (e.g. `AI/fn_SetTaskState.sqf:7`, `Server/fn_initPlayer.sqf:8`).
- **Processing:** If `A3E_Debug` is set, call `a3e_fnc_Log` with the single message string; otherwise no-op.
- **Theory of operation:** Provides a one-argument logging entry point (no type/data array) that self-suppresses unless debug is enabled, so debug spam costs nothing in production.
- **Whys & questions:** Exists so callers can sprinkle cheap debug lines. Note callers mix `call` and `spawn` invocation; `spawn` is unnecessary here since the body is synchronous.
- **Unresolved issues:** Casing inconsistency across call sites (`a3e_fnc_debugmsg` vs `A3E_fnc_DebugMsg`) — harmless in SQF but worth normalizing. Overlaps in role with `a3e_fnc_Log`; the only added value is the `A3E_Debug` gate.
- **Reforger port notes:** Debug-only convenience wrapper; fold into a single logging utility on port.

### a3e_fnc_TrackGroup  —  `Code/functions/Debug/fn_TrackGroup.sqf`  ·  _status: documented_
- **Purpose:** Per-group debug loop that keeps a map marker (icon + task-state text) following a group's leader. Currently disabled.
- **Inputs:** `_this select 0` → `_group` (read via `bis_fnc_param`). Global state read: `A3E_Debug`. Group var read/written: `a3e_debug_positionMarker`.
- **Outputs:** No return. Side effects (when enabled): creates/updates/deletes a map marker; sets group var `a3e_debug_positionMarker`.
- **Calls:** `a3e_fnc_getSideColor`, `a3e_fnc_GetTaskState`, `bis_fnc_param`.
- **Called by:** `Spawning/fn_activatePatrolZone.sqf:58,80` via `[_grp] spawn A3E_fnc_TrackGroup`.
- **Processing:** `if(true) exitWith {};` at `fn_TrackGroup.sqf:4` short-circuits the entire body — function returns immediately and never runs. Below that (dead): create a `mil_dot` marker colored by side, then loop every 5s repositioning the marker and updating text to the group's task state; on group death set "KIA" and clean up.
- **Theory of operation:** Was the original single-group tracker; superseded by the centralized `TrackGroup_Add`/`TrackGroup_Update` pair driven by Chronos.
- **Whys & questions:** Why keep two callers spawning a function that immediately exits? Likely left in place during the refactor to the Add/Update model.
- **Unresolved issues:** DEAD CODE — the unconditional `if(true) exitWith {}` makes everything after it unreachable; the two call sites are effectively no-ops. Reads bare global `A3E_Debug` (not via getVariable) which would error if undefined, but is gated out by the early exit.
- **Reforger port notes:** Debug-only and disabled; drop on port.

### a3e_fnc_TrackGroup_Add  —  `Code/functions/Debug/fn_TrackGroup_Add.sqf`  ·  _status: documented_
- **Purpose:** Registers a group for debug map tracking by creating its position marker and a (hidden) line marker, then appending an entry to the global tracked-groups list.
- **Inputs:** params `_group`. Global state read: `A3E_Debug` (via getVariable), `a3e_var_LineMarkerNo`, `A3E_Debug_TrackedGroups`.
- **Outputs:** No return. Globals written: lazily inits `A3E_Debug_TrackedGroups`; increments `a3e_var_LineMarkerNo`; appends `[_group,_marker,_linemarker,[]]` to `A3E_Debug_TrackedGroups`. Side effects: creates a `mil_dot` ICON marker (side-colored) and a transparent RECTANGLE line marker.
- **Calls:** `a3e_fnc_log` (`fn_TrackGroup_Add.sqf:10`). Leaf otherwise.
- **Called by:** Spawn paths register newly created groups — `Spawning/fn_AmbientPatrols.sqf:59`, `Spawning/fn_CivilianCommuters.sqf:63`, `Spawning/fn_MilitaryTraffic.sqf:60`, `Spawning/fn_onCivilianGroupSpawn.sqf:3`, `Spawning/fn_onEnemyGroupSpawn.sqf:3`, `Spawning/fn_populateVillageZone.sqf:49,67`, `Zones/fn_DeserializeZoneGroups.sqf:98`.
- **Processing:** Early-exit if `A3E_Debug` is false. Init list if nil. Log the addition. Pick marker color from side (west=Blue, east=Red, civilian=White, resistance=Green, else Black). Create ICON marker at leader pos. Create an alpha-0 rectangle line marker. Append the 4-tuple record.
- **Theory of operation:** Half of the centralized tracker: this populates `A3E_Debug_TrackedGroups`; `TrackGroup_Update` (Chronos-driven) walks the list each tick to reposition markers and draw waypoint lines.
- **Whys & questions:** Uses `setMarkerShapeLocal`/`...Local` for the icon but the non-local `setMarkerShape`/`setMarkerColor` for the line marker — inconsistent locality (line marker is global, icon is client-local).
- **Unresolved issues:** Local vs global marker inconsistency between the two markers in this function. Marker name uniqueness relies on `str _group`; if a group is re-added after partial cleanup, `createMarker` could collide. Mixed casing at call sites (`A3E_fnc_TrackGroup_Add`).
- **Reforger port notes:** Debug-only visualization; optional in port.

### a3e_fnc_TrackGroup_Update  —  `Code/functions/Debug/fn_TrackGroup_Update.sqf`  ·  _status: documented_
- **Purpose:** Periodic refresh of all tracked-group debug markers: repositions leader markers, sets task-state/unit-count text, redraws waypoint lines, and recreates per-unit dot markers. Also tears everything down when debug is turned off.
- **Inputs:** No params. Global state read/written: `A3E_Debug_TrackedGroups` (the 4-tuple list), `A3E_Debug`.
- **Outputs:** No return. Globals written: rebuilds `A3E_Debug_TrackedGroups` (pruning dead/null groups) or clears it to `[]`. Side effects: creates/moves/deletes many markers each invocation.
- **Calls:** `a3e_fnc_GetTaskState`, `A3E_FNC_DrawMapLine` (`fn_TrackGroup_Update.sqf:45`). Leaf otherwise.
- **Called by:** Registered with the Chronos scheduler — `Server/fn_initServer.sqf:683` `["A3E_FNC_TrackGroup_Update"] call A3E_FNC_Chronos_Register;`. No direct callers; fires periodically.
- **Processing:** If `A3E_Debug` false → delete all markers for every tracked group and reset list, exit. Otherwise iterate: delete prior per-unit markers; if group not null, compute task-state text + unit count, choose icon type by leader vehicle (Tank→b_armor, Car→b_motor_inf, else b_inf), reposition marker, draw a line to waypoint 1 if >1 waypoint (else hide line), recreate a red dot marker per unit, and keep the record only if the group still has units. Replace the global list with the surviving entries.
- **Theory of operation:** Second half of the centralized tracker; runs on the Chronos tick so a single periodic pass maintains all group visuals instead of one spawned loop per group.
- **Whys & questions:** Recreating every per-unit marker each tick (delete + create) is simple but churny; relies on consistent naming for cleanup.
- **Unresolved issues:** `_text` and `_unitmarkers` (line 8 exit branch) are used without being declared `private` in some branches (relies on outer scope) — minor scoping smell. Per-tick marker churn is inefficient at scale. Marker-name collisions possible if groups overlap names. Debug-only but still scheduled via Chronos regardless (gated internally by `A3E_Debug`).
- **Reforger port notes:** Debug-only; the Chronos registration would be dropped or gated in port.

### a3e_fnc_drawMapLine  —  `Code/functions/Debug/fn_drawMapLine.sqf`  ·  _status: documented_
- **Purpose:** Draws a yellow polyline map marker between two positions (creating the marker if not supplied), for visualizing group→waypoint links.
- **Inputs:** `_this`: [0]=`_startpos` (pos, default `[0,0]`), [1]=`_endpos` (pos, default `[0,0]`), [2]=`_marker` (string, default `"noMarker"`); all read via `bis_fnc_param`. Global state read/written: `a3e_var_LineMarkerNo`.
- **Outputs:** Returns the marker name (`_marker` at `fn_drawMapLine.sqf:27`). Globals written: increments `a3e_var_LineMarkerNo` when auto-creating. Side effects: creates a local POLYLINE marker (yellow) or reuses the passed-in one and sets its polyline points.
- **Calls:** `bis_fnc_param`. Leaf otherwise.
- **Called by:** `Debug/fn_TrackGroup_Update.sqf:45` (passing the group's pre-made line marker). Only one caller.
- **Processing:** Parse start/end/marker. If marker is `"noMarker"`, init/increment `a3e_var_LineMarkerNo`, build a `LineMarker%1` name and create the marker. Set shape POLYLINE (local), color yellow (local), then `setMarkerPolyline` from start to end. Return marker name.
- **Theory of operation:** Reusable line-drawing helper; the large commented block (rectangle-rotation approach, lines 6-11/23/26) is a prior implementation that drew a rotated rectangle before POLYLINE markers were used.
- **Whys & questions:** Color is hardcoded yellow; the single caller already created its own line marker, so the auto-create branch is effectively unused in practice.
- **Unresolved issues:** Large blocks of dead commented-out code. The auto-create path (`"noMarker"`) appears to have no live caller. Marker shape/color are Local but `setMarkerPolyline` is global — locality mix.
- **Reforger port notes:** Debug-only visualization helper; TBD whether map-line debugging is reproduced in port.

### a3e_fnc_getDebugMessages  —  `Code/functions/Debug/fn_getDebugMessages.sqf`  ·  _status: documented_
- **Purpose:** Returns up to the most recent 25 entries from the in-memory `A3E_DebugLog`, optionally filtered by message type.
- **Inputs:** params `_filter` (string or array, default `""`). Global state read: `A3E_DebugLog` (array of `[_types,_msg,time,_data]` records, lazily inited).
- **Outputs:** Returns an array of up to 25 matching log records (newest first). No globals written (other than init of `A3E_DebugLog` if nil). No side effects.
- **Calls:** none (leaf function).
- **Called by:** `Debug/fn_startDebugView.sqf:8` to populate the debug dialog list box. Only one caller.
- **Processing:** Init log if nil. Normalize `_filter` (note: the `if(_filter == "STRING")` branch at line 11 is buggy — see below). Iterate the log newest→oldest; an entry matches if no filter is set or any of its types is in `_filter`; collect matches; stop at 25.
- **Theory of operation:** Read side of the ring-buffer debug log written by `logMessage`; feeds the in-game `A3E_DebugView` dialog.
- **Whys & questions:** Why compare `_filter == "STRING"` (line 11)? It looks intended to be `_filter isEqualType "STRING"` (a type check). As written it compares the value to the literal string "STRING", which is essentially never true, so the normalization block is dead.
- **Unresolved issues:** BUG/dead code at line 11: `if(_filter == "STRING")` is almost certainly meant to be `isEqualType`; the intended string→array normalization never runs, so passing a plain string filter would break the `_x in _filter` membership test (it would match substrings/characters instead of whole types).
- **Reforger port notes:** Debug-only dialog backing; TBD.

### a3e_fnc_log  —  `Code/functions/Debug/fn_log.sqf`  ·  _status: documented_
- **Purpose:** Public logging entry point: broadcasts a log message (with type tags and optional data) to every machine so each appends to its local `A3E_DebugLog`.
- **Inputs:** params `_msg` (string, default "No Message"), `_types` (string or array, default "General"), `_data` (array, default `[]`). No global state read directly here.
- **Outputs:** No return. Side effect: `remoteExec` of `a3e_fnc_logMessage` to all clients (`0`), JIP=false.
- **Calls:** `a3e_fnc_logMessage` via `remoteExec` (`fn_log.sqf:4`). Leaf otherwise.
- **Called by:** Heavily used everywhere for structured logging — e.g. all `AI/fn_Extraction*.sqf`, `Server/fn_RoadBlocks.sqf` (many), `Spawning/fn_AmbientPatrols.sqf`/`fn_CivilianCommuters.sqf`/`fn_MilitaryTraffic.sqf`, `Zones/*`, `Templates/fn_LoadTemplates.sqf`, plus `Debug/fn_DebugMsg.sqf:3` and `Debug/fn_TrackGroup_Add.sqf:10`.
- **Processing:** Spawns a thread that waits until `time>1` (so the mission has initialized) and then `remoteExec`s `a3e_fnc_logMessage` to all machines with the message/types/data.
- **Theory of operation:** Decouples the caller from broadcast timing/distribution: the `time>1` gate avoids logging before the mission is ready; remoteExec to `0` ensures every machine records the entry for its own debug view/.rpt.
- **Whys & questions:** Why broadcast every log to all clients rather than just the server's view? Likely so any connected admin can open the debug dialog and see logs. The per-call `spawn` adds a scheduled thread per log line, which can be heavy under high log volume.
- **Unresolved issues:** Per-message `spawn` + `waitUntil` is relatively expensive for a hot logging path. Broadcasting all logs network-wide could be noisy/bandwidth-heavy on busy servers.
- **Reforger port notes:** Core logging API; in Reforger replace with a proper logging/RPC mechanism. TBD.

### a3e_fnc_logMessage  —  `Code/functions/Debug/fn_logMessage.sqf`  ·  _status: documented_
- **Purpose:** Local sink that records a log entry into the in-memory `A3E_DebugLog` ring buffer and, depending on the debug flag and filter, echoes it to system chat and the .rpt.
- **Inputs:** params `_msg` (string), `_types` (string/array, default "General"), `_data` (array, default `[]`). Global state read: `A3E_DebugLog`, `A3E_MaxLogMessages` (default 100), `A3E_DebugLogFilter` (default `[]`), `A3E_Debug` (default false).
- **Outputs:** No return. Globals written: appends `[_types,_msg,time,_data]` to `A3E_DebugLog`; trims oldest when over `A3E_MaxLogMessages`. Side effects (conditional): `a3e_fnc_systemChat` and `a3e_fnc_rptLog`.
- **Calls:** `a3e_fnc_systemChat` (`fn_logMessage.sqf:22`), `a3e_fnc_rptLog` (`fn_logMessage.sqf:23`).
- **Called by:** `Debug/fn_log.sqf:4` via `remoteExec` (the only caller; runs on every machine).
- **Processing:** Init log if nil; trim front if over max. Normalize `_types` to array. Append the record. Then decide whether to surface it: if `A3E_Debug` on and message type NOT in the filter, OR `A3E_Debug` off and message type IS in the filter, push to system chat and .rpt.
- **Theory of operation:** Implements the ring buffer plus an inclusive/exclusive filter: when debugging globally, the filter acts as a mute list; when not debugging, the filter acts as an allow-list (so specific categories can still be surfaced in production).
- **Whys & questions:** The dual-mode filter semantics (mute-list when on, allow-list when off) are clever but non-obvious; easy to misconfigure. `A3E_MaxLogMessages` default 100 vs the 25-message read window in `getDebugMessages`.
- **Unresolved issues:** Comparison `count A3E_DebugLog > max` then a single `deleteAt 0` means the buffer can sit one element over the cap; minor. Filter inversion semantics are a footgun.
- **Reforger port notes:** Core local log sink; reimplement buffer + filtering in port. TBD.

### a3e_fnc_rptLog  —  `Code/functions/Debug/fn_rptLog.sqf`  ·  _status: documented_
- **Purpose:** Thin wrapper around `diag_log` that writes a prefixed line to the Arma .rpt file.
- **Inputs:** params `_msg` (string, required). No global state read.
- **Outputs:** No return. Side effect: `diag_log("Escape Diaglog: " + _msg)`.
- **Calls:** none (leaf function; `diag_log` is engine).
- **Called by:** `Common/fn_loadLocalClasses.sqf:3,74,79`, `Server/fn_parameterInit.sqf:12,18,30,32,39`, and `Debug/fn_logMessage.sqf:23`. Used both as `[...]`-array and bare-string call forms.
- **Processing:** Concatenate the fixed prefix with `_msg` and emit via `diag_log`.
- **Theory of operation:** Centralizes the .rpt prefix so Escape log lines are greppable in server logs.
- **Whys & questions:** Some callers pass a string and some pass `[string]`; `params["_msg"]` reads index 0 of the array form but a bare string also satisfies `params` (treats string as `_msg`), so both work — but it's inconsistent.
- **Unresolved issues:** Call-site inconsistency (array vs bare string). Otherwise trivial.
- **Reforger port notes:** Map to Reforger's `Print`/logging facility. TBD.

### a3e_fnc_startDebugView  —  `Code/functions/Debug/fn_startDebugView.sqf`  ·  _status: documented_
- **Purpose:** Opens the `A3E_DebugView` dialog and fills its list box with the most recent debug log messages.
- **Inputs:** No params. Implicit: the `A3E_DebugView` dialog resource and list box control id `630002` must exist. Reads log via `getDebugMessages`.
- **Outputs:** No return value of note. Side effect: creates a dialog (client UI) and populates list box `630002`.
- **Calls:** `a3e_fnc_getDebugMessages` (`fn_startDebugView.sqf:8`); engine UI (`createDialog`, `lbClear`, `lbAdd`).
- **Called by:** No `fnc_` references found in the xref — likely a manual/entry-point function invoked by an admin (e.g. via debug console or an action) rather than from code. Verify against any keybind/action definitions.
- **Processing:** `disableSerialization`. Create the dialog; if successful, clear list box 630002, fetch messages via `getDebugMessages`, add each as `"<types> : <msg>"`, then idle-loop (`sleep 0.01`) while the dialog is open.
- **Theory of operation:** Provides an in-game viewer over the `A3E_DebugLog` buffer maintained by `logMessage`.
- **Whys & questions:** The list is populated once at open and then the loop only keeps the function alive — it does not refresh while open. Was live-refresh intended? The commented `_menu` line suggests the UI was experimented with.
- **Unresolved issues:** Apparent dead/orphan entry point (no code callers). List does not auto-update. Hardcoded control id `630002` couples it to the dialog layout.
- **Reforger port notes:** Debug-only UI; likely dropped or replaced by a native debug panel in port.

### a3e_fnc_unit_debug_marker  —  `Code/functions/Debug/fn_unit_debug_marker.sqf`  ·  _status: documented_
- **Purpose:** Legacy DRN-style debug loop that places a side-colored map marker on the leader of every group in the mission, refreshing once per second.
- **Inputs:** No params. Reads `allGroups` and each group's `side`.
- **Outputs:** No return. Side effects: creates/deletes debug markers on all clients via DRN helpers each cycle.
- **Calls:** `drn_fnc_CL_DeleteDebugMarkerAllClients`, `drn_fnc_CL_SetDebugMarkerAllClients` (DRN legacy library).
- **Called by:** No `fnc_` references found in the xref — appears to be unused/dead or a manually-launched debug script. Verify.
- **Processing:** Infinite `while{true}`: delete all previous debug markers, reset, then for each group in `allGroups` build a name `drn_debugMarker<side><n>`, pick a color by side (west=Blue, east=Red, civilian=White, resistance=Yellow), set a `mil_dot` marker at the leader via the DRN all-clients helper, `sleep 0.01` per group, then `sleep 1` per cycle.
- **Theory of operation:** Predecessor to the `TrackGroup_Add`/`TrackGroup_Update` system; uses the DRN broadcast-marker helpers to show all groups at once.
- **Whys & questions:** Superseded by the A3E TrackGroup tracker. Why keep both? Likely legacy leftover from the DRN heritage.
- **Unresolved issues:** Likely DEAD CODE (no callers). No `A3E_Debug` gate, so if ever started it would run unconditionally and broadcast markers for every group every second (expensive). Depends on the legacy DRN library.
- **Reforger port notes:** Debug-only and legacy; drop on port.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-06-30 | Claude | Documented all entries |
