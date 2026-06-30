# Code Reference — ace
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> ACE integration — medical/unconscious and captive handling. One entry per source file in `Code/functions/ace/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### ace_fnc_ATCam  —  `Code/functions/ace/fn_ATCam.sqf`  ·  _status: documented_
- **Purpose:** Toggles the ATR "hindsight camera" (HSC) spectator view for an unconscious player on (case 1) or off (case 2), disabling ACE's unconscious post-process effects while it runs.
- **Inputs:** params `_case` (number: 1=start, 2=stop). Global state read/written: `newHandle` (the per-frame handler id; a global, not declared private).
- **Outputs:** No return. Globals written: `newHandle`. Side effects: enables/disables ACE unconscious PP effects (`ace_medical_effectUnconscious*`, `ace_medical_effectBlind`), toggles disabled user input, and spawns/exits the ATHSC camera. Runs on the unconscious client (invoked via remoteExec to the unit).
- **Calls:** `CBA_fnc_addPerFrameHandler` / `CBA_fnc_removePerFrameHandler`, `ace_common_fnc_setDisableUserInputStatus`, `ATHSC_fnc_createCam`, `ATHSC_fnc_exit`.
- **Called by:** remoteExec'd (target = the unit) from `ace/fn_GroundHandler.sqf:14`, `ace/fn_HandleUnconscious.sqf:16` (start, case 1) and `ace/fn_HandleUnconscious.sqf:22` (stop, case 2). Gated by `AT_Revive_Camera==1`.
- **Processing:** Case 1: register a per-frame handler that each frame force-disables ACE's unconscious CC/RB/blind effects and re-enables user input, then spawn the ATHSC camera. Case 2: spawn ATHSC exit and remove the per-frame handler stored in `newHandle`.
- **Theory of operation:** When the ATR revive camera is enabled, this replaces ACE's default blacked-out unconscious screen with the HSC spectator cam; the per-frame handler continuously suppresses ACE's PP effects so the camera view stays clear.
- **Whys & questions:** `newHandle` is a global mission var — if two players go down at once on the same machine it could be overwritten (but this runs client-locally on each downed player, so collisions are unlikely). Why a per-frame handler to suppress effects rather than setting them once? Likely because ACE re-applies them each frame.
- **Unresolved issues:** `newHandle` not declared `private`, leaking into mission namespace. Function name casing: defined/called as `ACE_fnc_ATCam` though the CfgFunctions tag is `ace` (SQF is case-insensitive, cosmetic only). Tight coupling to ATHSC (revive submodule) and ACE internal effect variable names.
- **Reforger port notes:** Tied to ACE medical + ATR HSC, neither of which exists in Reforger; the unconscious-camera concept would need a native reimplementation. TBD.

### ace_fnc_CaptiveHandle  —  `Code/functions/ace/fn_CaptiveHandle.sqf`  ·  _status: documented_
- **Purpose:** Keeps an unconscious player permanently in captive mode by re-asserting `setCaptive true` in a loop for as long as ACE considers them down, so AI ignore the helpless body.
- **Inputs:** params `_unit`. Global/unit state read: `_unit getVariable "ACE_Revive_isUnconscious"`.
- **Outputs:** No return. Side effect: repeatedly `setCaptive true` on the unit (runs on the unit's machine via remoteExec).
- **Calls:** none (leaf function; `setCaptive` is engine).
- **Called by:** `ace/fn_HandleUnconscious.sqf:8` via `remoteExec` to the unit.
- **Processing:** `while {_unit getVariable ["ACE_Revive_isUnconscious",false]} do {_unit setCaptive true;};` — a busy loop that re-applies captive until the unit is no longer flagged unconscious.
- **Theory of operation:** Comment at the call site explains it: "for whatever reason unit gets set out of captive mode here and there," so this brute-force loop re-forces captive status to stop enemy AI from shooting the downed player.
- **Whys & questions:** A tight `while` with no `sleep` is effectively a per-frame spin in scheduled SQF; why no throttle? Probably an oversight — a `sleep 0.5` would massively reduce cost while still keeping captive set.
- **Unresolved issues:** PERFORMANCE: unthrottled busy-loop calling `setCaptive` every scheduler slice while unconscious. Workaround for an unidentified root cause (ACE/engine resetting captive) rather than a fix.
- **Reforger port notes:** Captive/AI-ignore mechanic must be reimplemented natively in Reforger; this specific workaround should not be ported as-is. TBD.

### ace_fnc_GroundHandler  —  `Code/functions/ace/fn_GroundHandler.sqf`  ·  _status: documented_
- **Purpose:** Installs (case 1) or removes (case 2) a "Dammaged" event handler on a downed-but-not-yet-ACE-unconscious player, so that taking further damage while on the ground promotes them into the mission's revive-unconscious state.
- **Inputs:** params `_unit`, `_case` (1=add EH, 2=remove EH). Unit vars read: `ACE_isUnconscious`, `ACE_Revive_isUnconscious`, `ACE_Revive_UnitGroundEventID`. Global read inside EH: `AT_Revive_Camera`.
- **Outputs:** No return. Unit var written: `ACE_Revive_UnitGroundEventID` (the EH id, public). Side effects: adds/removes an event handler; inside EH may broadcast systemchat and remoteExec the ATR camera.
- **Calls:** `BIS_fnc_listPlayers`; inside the EH, `ACE_fnc_ATCam` via remoteExec. `addEventHandler`/`removeEventHandler` are engine.
- **Called by:** `ace/fn_HandleUnconscious.sqf:9` (case 1, when not yet ACE-unconscious) and `ace/fn_HandleUnconscious.sqf:12,24` (case 2, removal), all via `remoteExec` to the unit.
- **Processing:** Case 1: add a "Dammaged" EH; on fire, if the unit is ACE-unconscious but not yet revive-unconscious, set `ACE_Revive_isUnconscious=true`, remove this EH, announce "<name> is unconscious" to all, and start the ATR cam if enabled. Store the EH id. Case 2: remove the stored EH.
- **Theory of operation:** Handles the edge case where a player is incapacitated on the ground (e.g. ragdolled/prone) before ACE formally flags unconsciousness; further damage then escalates them into the revive system so they get the proper unconscious/captive/camera treatment.
- **Whys & questions:** `_unconsciousPlayers = [];` and `_players = call BIS_fnc_listPlayers;` (lines 8,10) are assigned but unused in the EH — leftover/dead. Why "Dammaged" specifically (a known engine spelling) — relies on the legacy event name.
- **Unresolved issues:** Dead locals (`_unconsciousPlayers`, `_players`) inside the EH. Casing: `ACE_fnc_GroundHandler` vs tag `ace`. Mixed null-default reads: `getVariable "ACE_Revive_isUnconscious"` without a default (line 7) can return nil and make the `!(...)` comparison unreliable if the var was never set.
- **Reforger port notes:** Depends on ACE unconscious flags and SQF event handlers; reimplement incapacitation escalation natively. TBD.

### ace_fnc_HandleUnconscious  —  `Code/functions/ace/fn_HandleUnconscious.sqf`  ·  _status: documented_
- **Purpose:** Central reactor to ACE's `ace_unconscious` event for players: on going down it sets captive, wires up the ground/escalation handlers, the wash-ashore safeguard and the revive camera; on waking it tears all that down and restores normal state.
- **Inputs:** params `_unit`, `_isDown` (bool). Unit vars read/written: `ACE_isUnconscious`, `ACE_Revive_isUnconscious`, `ACE_Revive_justWoke`. Globals read: `AT_Revive_Camera`.
- **Outputs:** No return. Unit vars written (public): `ACE_Revive_isUnconscious`, `ACE_Revive_justWoke`. Side effects: setCaptive, systemchat broadcast, multiple remoteExecs (`ACE_fnc_CaptiveHandle`, `ACE_fnc_GroundHandler`, `ACE_fnc_ATCam`), wash-ashore, and possibly forcing the unit back conscious.
- **Calls:** `BIS_fnc_listPlayers`; via `remoteExec`: `ACE_fnc_CaptiveHandle`, `ACE_fnc_GroundHandler`, `ACE_fnc_ATCam`; direct: `ATR_FNC_WashAshore`, `ace_medical_fnc_setUnconscious`.
- **Called by:** `Server/fn_initServer.sqf:46` registers it via CBA: `["ace_unconscious", {... [_unit,_isDown] spawn ACE_fnc_HandleUnconscious;}] call CBA_fnc_addEventHandler;`. It is an event-driven entry point (no direct callers).
- **Processing:** Only acts on players. If `_isDown`: setCaptive true; start the captive loop; if not yet ACE-unconscious add the ground handler (case 1); when ACE-unconscious and not yet revive-unconscious, flag revive-unconscious, start ground handler case 2, announce, run wash-ashore if downed in shallow water, and start the camera if enabled; then `sleep 10` and, if not revive-unconscious and not just-woke, force `setUnconscious false`. If `!_isDown` (waking): stop camera if it was on, clear `ACE_Revive_isUnconscious`, ground handler case 2, set `ACE_Revive_justWoke`, `sleep 3`, setCaptive false, clear just-woke.
- **Theory of operation:** Bridges ACE medical's unconscious event to the mission's bespoke revive behavior (captive immunity, drowning rescue, hindsight camera) and guards against ACE leaving a player stuck unconscious by the 10s safety timeout.
- **Whys & questions:** `_unconsciousPlayers`/`_players` (lines 2-3) are computed but unused (dead). The 10s `sleep` then forced wake is a heuristic safety net described in the comment; magic numbers (10s, 3s) are unexplained. Several reads (`getVariable "ACE_Revive_isUnconscious"`) omit defaults and may be nil.
- **Unresolved issues:** Dead locals at top. nil-default getVariable reads (lines 10,15,19,22) risk type errors before the var is ever set. Heavy use of casing `ACE_fnc_*` against the `ace` tag. Behavior depends on a chain of remoteExec'd siblings whose ordering/race-conditions (captive loop vs wake) are subtle.
- **Reforger port notes:** Entire flow is ACE-medical-specific; Reforger has its own incapacitation system, so this would be redesigned around native events rather than ported line-for-line. TBD.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-06-30 | Claude | Documented all entries |
