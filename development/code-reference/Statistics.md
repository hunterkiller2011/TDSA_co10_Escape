# Code Reference — Statistics
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Session logging and the external statistics API. One entry per source file in `Code/functions/Statistics/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_EndSession  —  `Code/functions/Statistics/fn_EndSession.sqf`  ·  _status: documented_
- **Purpose:** Reports the end of a play session to the external stats API, sending the outcome code, kill count, and revive count for the current session GUID (`fn_EndSession.sqf:21-25`).
- **Inputs:** Param `_endtype` (mission-end code string, e.g. "end2"/"end4"). Reads global `A3E_Param_SendStatistics` (gate), `missionConfigFile` fields (EscapeIsland/Mod/Version/Release/Build), and missionNamespace vars `A3E_SessionGUID`, `A3E_Revive_Count`, `A3E_Kill_Count`. Precondition: a session was started so `A3E_SessionGUID` exists (else falls back to a placeholder GUID, `fn_EndSession.sqf:13`).
- **Outputs:** No return. Side effect: fires an HTTP GET to `http://co10esc.anzp.de/api/session/endsession?...` (`fn_EndSession.sqf:18-33`). No globals written.
- **Calls:** `BIS_fnc_listPlayers`. External API via the hidden-`RscHTML`-control `htmlLoad` trick (creates a `DummyLayer`/`RscTitleDisplayEmpty` UI, an `RscHTML` control, then `htmlLoad _uri`). No `callExtension`; no `remoteExec`.
- **Called by:** `Code/functions/Server/fn_endMissionServer.sqf:2` — `[_end] call A3E_fnc_EndSession;` (single caller; runs at mission end).
- **Processing:** Guarded by `A3E_Param_SendStatistics == 1`. Gathers config/session metadata, builds the query URI (uid, kills, revives, end), then loads it via a throwaway HTML control which is immediately closed.
- **Theory of operation:** The "End" step of the Start→Ping→Save→End session lifecycle: StartSession registered the GUID with the API; EndSession closes that record out with the final kills/revives/outcome.
- **Whys & questions:** Why load the URL through an invisible `RscHTML` control rather than a proper HTTP request? Likely because SQF has no native HTTP client, so `htmlLoad` on a hidden control is the classic fire-and-forget GET hack. Several metadata vars (`_island`, `_mod`, `_version`, `_release`, `_build`, `_players`, `_servername`) are computed but never used in the URI (`fn_EndSession.sqf:6-12`).
- **Unresolved issues:** No response handling, retry, or error checking on the network call — fire-and-forget only. Dead/unused locals (see above). Privacy: sends `serverName`? (not in this URI, but computed) and a session GUID derived from serverName+time; no player-identifying data in the endsession URI. The `htmlLoad` call runs on whatever machine executes the function (server, since caller is server-side) — an Arma HTML control on a dedicated headless server may not actually issue the request; verify it fires on dedicated servers.
- **Reforger port notes:** Reforger has proper `RestApi`/HTTP request classes (`RestCallback`), so the `htmlLoad`-control hack should be replaced with a real async REST GET/POST. TBD on where the GUID/counters live in the Reforger game-mode state.

### a3e_fnc_LoadStatistics  —  `Code/functions/Statistics/fn_LoadStatistics.sqf`  ·  _status: documented_
- **Purpose:** Loads the persisted per-profile statistics history, formats it into HTML text, and broadcasts it to all clients' briefing diaries (`fn_LoadStatistics.sqf:1-7`).
- **Inputs:** No params. Reads `profileNamespace` vars `A3E_Statistics_Version` (default -1) and `A3E_Statistics` (default `[]`).
- **Outputs:** No return. Side effect: `remoteExec` of the formatted text to `A3E_fnc_WriteStatisticsToBriefing` on all machines (target 0, persistent JIP flag true) (`fn_LoadStatistics.sqf:7`).
- **Calls:** `A3E_fnc_parseStatistics` (formats stats → HTML), then `remoteExec ["A3E_fnc_WriteStatisticsToBriefing", 0, true]`. No direct API call.
- **Called by:** `Code/functions/Server/fn_initServer.sqf:51` — `[] spawn A3E_fnc_LoadStatistics;` (server init, single caller).
- **Processing:** Reads locally-stored statistics array, calls the parser to produce a human-readable HTML summary, then remote-executes the briefing writer everywhere (JIP-persistent so late joiners also get it).
- **Theory of operation:** This is the read/display side of the *local* profile statistics (distinct from the external API lifecycle) — surfaces the server's historical escape record into every player's in-game diary at session start.
- **Whys & questions:** `_statisticsVersion` is read but unused (`fn_LoadStatistics.sqf:1`) — presumably a placeholder for a future schema-migration check. Not gated by `A3E_Param_SendStatistics`, so local briefing stats display regardless of the external-API opt-in.
- **Unresolved issues:** `_statisticsVersion` dead read. No versioning/migration actually performed despite the version var existing. Relies on `profileNamespace` persistence surviving across sessions.
- **Reforger port notes:** `profileNamespace` and `saveProfileNamespace` have no direct Reforger equivalent; persistence would move to a Reforger save/config or backend store. The `remoteExec`-to-briefing pattern maps to Reforger RPC + a notification/journal UI. TBD.

### a3e_fnc_ParseStatistics  —  `Code/functions/Statistics/fn_ParseStatistics.sqf`  ·  _status: documented_
- **Purpose:** Aggregates the stored per-session statistics array into a formatted HTML summary string (games played, escaped/failed, longest/shortest, prison/map/comcenter/exfil milestones, war-crimes, per-terrain wins) (`fn_ParseStatistics.sqf:52-82`).
- **Inputs:** Param `_statistics` — array of session records; each record is `[version, mod, island, endType, players, time, prisonComplete, mapFound, comHacked, exfilReached]` (indices used at `fn_ParseStatistics.sqf:20-49`; layout matches what SaveStatistics pushes). Reads `missionConfigFile >> "EscapeIsland"` for the current terrain.
- **Outputs:** Returns the HTML `_statisticText` string (`fn_ParseStatistics.sqf:82`). No globals written; pure function otherwise.
- **Calls:** none (leaf function) — only `getText`, `format`, `round`, `foreach`.
- **Called by:** `Code/functions/Statistics/fn_LoadStatistics.sqf:5`; `Code/functions/Statistics/fn_SaveStatistics.sqf:19`.
- **Processing:** Iterates all records tallying counters; treats `endType` in `["end2","end4"]` as an escape/win (end4 additionally counts as civilians-killed / court-martialed); tracks longest/shortest winning time, prison-escape, map-found, com-hacked, "reached-heli-but-failed" (index 9), and current-terrain wins; builds the HTML with conditional lines.
- **Theory of operation:** The formatter used by both the load-time briefing display and the save-time end summary — the single place that turns raw session tuples into player-facing prose.
- **Whys & questions:** Index 9 (`_x select 9`) is read as the "reached helicopters but failed" flag, but SaveStatistics pushes only 10 elements (indices 0–9) where index 9 is `A3E_Task_Exfil_Complete`; combined with `!_won` this counts "exfil-complete but not a win" — see Unresolved. German var name `_kurzvormklo` ("kurz vorm Klo" ≈ "just before the toilet/finish"). "end2" vs "end4" semantics are hard-coded here (no shared constant).
- **Unresolved issues:** Semantic coupling: the meaning of each tuple index is duplicated between SaveStatistics (writer) and this parser (reader) with no shared schema — brittle if the record layout changes. `_shortest` sentinel is 0, so a legitimately 0-second escape would never register as shortest. Potential type mismatch if older stored records have a different arity.
- **Reforger port notes:** Straightforward to port as a pure aggregation over a typed struct; replace the positional tuple with a named struct/class in Reforger. HTML output would become a formatted UI string. TBD on localization of the German-flavored strings.

### a3e_fnc_PingStatistics  —  `Code/functions/Statistics/fn_PingStatistics.sqf`  ·  _status: documented_
- **Purpose:** Sends a lightweight "heartbeat"/keepalive to a legacy tracking endpoint reporting current player count and server name (`fn_PingStatistics.sqf:7`).
- **Inputs:** No params. Reads `serverName`. Calls `A3E_fnc_getPlayers` for the player count.
- **Outputs:** No return. Side effect: HTTP GET to `http://escape.anzp.de/track.php?event=ping&players=<n>&server=<serverName>` via the hidden-`RscHTML` `htmlLoad` trick (`fn_PingStatistics.sqf:1-9`).
- **Calls:** `A3E_fnc_getPlayers` (player list). External API via `htmlLoad` on a throwaway `RscHTML` control. No `remoteExec`, no `callExtension`.
- **Called by:** _No `fnc_` references found in `_xref.md` (`## Statistics` → PingStatistics: "entry point or dead code; verify")._ Appears to be dead code — no caller in the tree.
- **Processing:** Creates the invisible HTML control, builds the ping URI with live player count and server name, loads it, closes the display.
- **Theory of operation:** Intended as a periodic liveness ping to the older `escape.anzp.de/track.php` endpoint — distinct host from the newer `co10esc.anzp.de/api` used by Start/End session. Not wired into any lifecycle currently.
- **Whys & questions:** Why a *different* host/endpoint (`escape.anzp.de/track.php`) than Start/EndSession's `co10esc.anzp.de/api`? Suggests this is a leftover from an older stats system. Not gated by `A3E_Param_SendStatistics`, unlike Start/EndSession — inconsistent (moot while it has no caller).
- **Unresolved issues:** Almost certainly dead code (no callers). Sends `serverName` unescaped into a URL (spaces/special chars would break the GET). No opt-in gate. If ever re-enabled it would leak server name to a legacy host without honoring `A3E_Param_SendStatistics`.
- **Reforger port notes:** Drop unless a heartbeat is wanted; if kept, consolidate onto the single REST API and gate on the send-statistics setting. TBD.

### a3e_fnc_SaveStatistics  —  `Code/functions/Statistics/fn_SaveStatistics.sqf`  ·  _status: documented_
- **Purpose:** Appends the just-finished session's record to the persistent per-profile statistics array and saves it, once per mission end (`fn_SaveStatistics.sqf:5-20`).
- **Inputs:** Param `_endType` (outcome code). Reads globals `A3E_EndStatisticsCollected` (idempotency guard), `missionConfigFile` (EscapeIsland/Mod/Version/Release), `profileNamespace` `A3E_Statistics_Version`/`A3E_Statistics`, mission task-complete flags `A3E_Task_Prison_Complete`, `A3E_Task_Map_Complete`, `A3E_Task_ComCenter_Complete`, `A3E_Task_Exfil_Complete`, and `time`.
- **Outputs:** No return. Writes `A3E_EndStatisticsCollected=true`, updates `profileNamespace >> A3E_Statistics`, sets missionNamespace `A3E_EndStatistics` (broadcast, `true`) to the parsed HTML, and calls `saveProfileNamespace` (`fn_SaveStatistics.sqf:8,18-20`).
- **Calls:** `BIS_fnc_listPlayers`, `A3E_fnc_parseStatistics`, `saveProfileNamespace`. No external API call. No `remoteExec` (uses the broadcast flag on `setVariable`).
- **Called by:** `Code/functions/Server/fn_endMissionServer.sqf:3` — `[_end] call A3E_fnc_SaveStatistics;` (single caller).
- **Processing:** Guards against double-collection via `A3E_EndStatisticsCollected`; pushes `[version,mod,island,endType,playerCount,time,prison,map,com,exfil]` onto the stored array; persists to profile; and pre-computes/broadcasts the end-of-mission summary text.
- **Theory of operation:** The "Save" step — records the local, persistent history that LoadStatistics/ParseStatistics later display; independent of the external API (which is handled by Start/EndSession).
- **Whys & questions:** The record tuple layout must stay in lockstep with ParseStatistics' index reads (see that entry). `_statisticsVersion` read but unused here too (`fn_SaveStatistics.sqf:13`) — no schema stamped into the record.
- **Unresolved issues:** No version tag written into the record despite reading `A3E_Statistics_Version`, so future migrations can't tell record age. Positional-tuple coupling with the parser is fragile. `time` is mission time (seconds since mission start), used by the parser as "escape duration" — correct only if measured from session start.
- **Reforger port notes:** Replace `profileNamespace`/`saveProfileNamespace` with Reforger persistence; replace the broadcast `setVariable` with an RPC. Use a typed struct instead of the positional array. TBD.

### a3e_fnc_StartSession  —  `Code/functions/Statistics/fn_StartSession.sqf`  ·  _status: documented_
- **Purpose:** Generates a session GUID and registers the start of a session with the external stats API (`fn_StartSession.sqf:1-45`).
- **Inputs:** No params. Reads `A3E_Param_SendStatistics` (gate), `missionConfigFile` (EscapeIsland/Mod/Version/Release/Build), `serverName`, `systemTimeUTC`. Local `_fnc_guid` builds the id from `hashValue(serverName)+"-"+hashValue(systemTimeUTC)`.
- **Outputs:** Writes missionNamespace `A3E_SessionGUID` (`fn_StartSession.sqf:21`). Side effect: HTTP GET to `http://co10esc.anzp.de/api/session/startsession?...` via the hidden-`RscHTML` `htmlLoad` trick (`fn_StartSession.sqf:25-45`).
- **Calls:** `BIS_fnc_listPlayers`, `hashValue`. External API via `htmlLoad` on a throwaway `RscHTML` control. No `remoteExec`, no `callExtension`.
- **Called by:** `Code/functions/Statistics/fn_StartStatistics.sqf:1` — `[] call A3E_fnc_StartSession;` (thin wrapper; the wrapper is the entry point invoked from init).
- **Processing:** Guarded by `A3E_Param_SendStatistics == 1`. Defaults empty `serverName` to "Local", computes GUID, stores it, builds the startsession URI (uid, server, missionVersion, build, players, mod, terrain) and loads it.
- **Theory of operation:** The "Start" step of the Start→Ping→Save→End lifecycle: mints the GUID that EndSession later uses to close the record.
- **Whys & questions:** The `server` query param is added twice (`&server=`+`_servername` at lines 30 and 32) — redundant/likely a copy-paste bug. `_release` computed but unused. GUID uses `hashValue` of serverName+UTC time, so collisions are possible if two servers with identical names start in the same tick (unlikely but not guaranteed unique).
- **Unresolved issues:** Duplicate `server=` param. `_players`/`_release` partly unused. `serverName` (and thus server identity) is sent to the external API — privacy-relevant. Same `htmlLoad`-on-dedicated-server viability question as EndSession. No error/response handling.
- **Reforger port notes:** Use Reforger's REST client for the POST/GET; generate a proper UUID; store the session id in game-mode state. TBD.

### a3e_fnc_StartStatistics  —  `Code/functions/Statistics/fn_StartStatistics.sqf`  ·  _status: documented_
- **Purpose:** One-line entry-point wrapper that kicks off external session tracking by calling `A3E_fnc_StartSession` (`fn_StartStatistics.sqf:1`).
- **Inputs:** No params, no globals read directly (the gate lives in StartSession).
- **Outputs:** None directly; delegates all side effects to StartSession.
- **Calls:** `A3E_fnc_StartSession`.
- **Called by:** `Code/functions/Server/fn_initServer.sqf:445` — `[] call A3E_fnc_startStatistics;` (server init).
- **Processing:** Immediately forwards to StartSession.
- **Theory of operation:** Indirection layer between server init and the session-start logic — likely a stable public name so init doesn't call the implementation directly.
- **Whys & questions:** Why keep a pass-through wrapper instead of calling StartSession from init? Historical/naming stability; possibly once did more.
- **Unresolved issues:** Trivial pass-through — candidate to inline during a port. Casing note: called as `A3E_fnc_startStatistics` (lowercase s) at the call site vs file `fn_StartStatistics`; Arma function names are case-insensitive so this resolves, but the inconsistency is worth normalizing.
- **Reforger port notes:** Inline into the session-start call in the Reforger init flow. TBD.

### a3e_fnc_WriteStatisticsToBriefing  —  `Code/functions/Statistics/fn_WriteStatisticsToBriefing.sqf`  ·  _status: documented_
- **Purpose:** Client-side helper that writes the statistics summary text into the player's in-game diary/briefing under a "Statistics" record (`fn_WriteStatisticsToBriefing.sqf:1-5`).
- **Inputs:** Param `_statistics` (HTML/text summary; defaults to the literal `"Error - No params received"` if missing). Reads `player`, `isDedicated`.
- **Outputs:** No return. Side effect: `player createDiaryRecord ["Diary", ["Statistics", _statistics]]` on non-dedicated machines (`fn_WriteStatisticsToBriefing.sqf:4`).
- **Calls:** none (leaf function) — `createDiaryRecord`, `waitUntil`.
- **Called by:** `Code/functions/Statistics/fn_LoadStatistics.sqf:7` via `remoteExec [..., 0, true]` (broadcast to all clients, JIP-persistent). Runs on each client.
- **Processing:** Skips on dedicated servers (`!isDedicated`), waits until `player` is non-null, then adds a diary record titled "Statistics".
- **Theory of operation:** The display sink for LoadStatistics — turns the server-broadcast summary into a per-client briefing entry.
- **Whys & questions:** Default param string suggests it's sometimes invoked with no args (defensive). JIP `true` on the remoteExec means late joiners re-run it, hence the `waitUntil !isNull player` guard.
- **Unresolved issues:** No sanitization of `_statistics` before injecting into the diary (it's already HTML from the parser). If `player` never resolves (spectator?), the `waitUntil` could hang the spawned thread — but it runs in the remoteExec context so low risk.
- **Reforger port notes:** Reforger has no `createDiaryRecord`; map to a journal/notification/UI panel. Replace `remoteExec` with an RPC to owning clients. TBD.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-07-01 | Claude | Documented all entries |
