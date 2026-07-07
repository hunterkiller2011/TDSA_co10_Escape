# Self-Hosted Mission Statistics Backend — Design Proposal

_Last updated: 2026-07-03 (local)_ · _Status: proposal (not yet implemented)_

> Capture co10_Escape session statistics into an **owner-controlled, long-running database** for
> mission-history tracking — instead of (or in addition to) the current external `co10esc.anzp.de`
> endpoint. Written to serve both the **live Arma 3 mission** and the **Reforger port** (design the schema
> once, target it from both).
>
> Source code: [`Code/functions/Statistics/`](../../Code/functions/Statistics/) — see the per-function
> reference in [code-reference/Statistics.md](../code-reference/Statistics.md). Related open question:
> **Q-016** (does the send fire on a dedicated server?). Related bug: **BUG-022** (duplicate `server=` param).

## How the current system works

All statistics are sent as an HTTP **GET**, using a hack: `htmlLoad` on a **hidden `RscHTML` UI control**
(no extension required). The data rides in the **URL query string**. Everything is gated on
`A3E_Param_SendStatistics == 1`.

| Call | File | Endpoint | Query params |
|------|------|----------|--------------|
| Session start | `fn_StartSession.sqf` | `co10esc.anzp.de/api/session/startsession?` | `uid`, `server`, `missionVersion`, `build`, `players`, `mod`, `terrain` |
| Session end | `fn_EndSession.sqf` | `co10esc.anzp.de/api/session/endsession?` | `uid`, `kills`, `revives`, `end` (outcome) |
| Liveness ping | `fn_PingStatistics.sqf` | `escape.anzp.de/track.php?` | `event=ping`, `players`, `server` |

- **Session correlation:** `A3E_SessionGUID` = `hashValue(serverName) + "-" + hashValue(systemTimeUTC)`,
  set in `StartSession` and reused by `EndSession` — this ties a start + end into **one mission record**.
- **Outcome:** `end=<_endtype>` is passed by the ending logic (the `fn_missionFlow` endings — clean win /
  MIA / tainted win / loss; see [lifecycle-and-timeline.md](architecture/lifecycle-and-timeline.md) P6).
- **Already tracked but *not* sent** (available to enrich the payload): `A3E_Kill_Count`,
  `A3E_Revive_Count` (these two *are* sent), plus the war-crime score, per-session kill/death/time in the
  `Statistics/` functions (`SaveStatistics`/`ParseStatistics`/`WriteStatisticsToBriefing`).

## Goal

An owner-hosted endpoint + database that records **one row per mission** (plus optional liveness pings and,
later, per-player detail), queryable for long-running history: which islands/mods get played, win/loss
rates, session length, kills/revives, player counts, etc.

## Options

### Option A — Redirect the URL (simplest, least-invasive)
1. Change `_baseURL` in `StartSession` + `EndSession` (and the URL in `PingStatistics`) to your host,
   e.g. `https://stats.mydomain/api/session/`.
2. Stand up an endpoint (PHP / Node / Python-Flask / etc.) that parses the query params and writes them to
   a DB (Postgres / MySQL / SQLite). The `uid` (GUID) keys start↔end together.
3. Enrich by appending more params to the URL and widening the schema.

**Pros:** tiny code change; no server extensions. **Cons:** inherits the `htmlLoad` limitations below.

### Option B — Extension-based (robust; works on dedicated)
Replace `htmlLoad` with `callExtension` to an HTTP extension (POST to your API) or a DB extension
(`extDB3` / `inidbi2` writing straight to a database).

**Pros:** works headless; supports POST, auth, large payloads. **Cons:** deploy + maintain a `.dll`/`.so`
on the server; more moving parts.

### Option C — Log-scraping (simplest infra; fully decoupled)
`diag_log` a structured (JSON) stats line at session start/end; an external process tails the server
`.rpt` and ingests it into your DB.

**Pros:** no in-game networking; works everywhere incl. dedicated; zero coupling. **Cons:** external
tailer to run; slight delay; parse robustness.

## Caveats / dependencies

- ⚠ **Q-016 — dedicated-server send:** the GET fires from a **UI control** (`htmlLoad`), which very likely
  does **not** work on a headless/dedicated server (no display). **Verify first** whether stats fire at all
  on the target server. If dedicated and they don't fire, **Option A cannot send** — use **B** or **C**.
  Also confirm *which machine* runs `StartSession`/`EndSession` (needs a UI, so a client/host).
- **GET-only / URL-length / no auth:** query-string only, no POST body, unauthenticated. For an
  internet-facing endpoint add a **token** param + **HTTPS**, and validate server-side.
- **BUG-022:** `StartSession` appends `&server=` twice (same value) — harmless, but clean it up when editing.

## Starter schema (adjust to taste)

```sql
CREATE TABLE sessions (
  uid            TEXT PRIMARY KEY,      -- A3E_SessionGUID
  server         TEXT,
  mod            TEXT,
  terrain        TEXT,
  mission_version TEXT,
  build          TEXT,                  -- git commit hash (EscapeBuild)
  players_start  INTEGER,
  players_end    INTEGER,
  kills          INTEGER,
  revives        INTEGER,
  outcome        TEXT,                  -- end=<_endtype>
  started_at     TIMESTAMPTZ,
  ended_at       TIMESTAMPTZ
);

CREATE TABLE session_pings (           -- optional, from PingStatistics
  uid        TEXT,
  ts         TIMESTAMPTZ,
  players    INTEGER
);

-- Future (needs payload enrichment): per-player detail
CREATE TABLE session_players (
  uid          TEXT,
  player_uid   TEXT,
  name         TEXT,
  kills        INTEGER,
  deaths       INTEGER,
  revives_given INTEGER
);
```

## Reforger port

Enfusion has proper backend/networking, so the port should use a **real HTTP client / game-backend
service**, not the `htmlLoad` hack. Design the DB schema now (via Option A/C on Arma 3) and have the port
**target the same schema** → continuous mission history across the port.

## Recommendation

- **Short-term (Arma 3):** Option A if stats fire on your server setup (**verify Q-016 first**). If a
  dedicated server blocks `htmlLoad`, use **Option C** (log-scraping) as the easy robust fallback, or
  **Option B** for real-time/authenticated sends.
- **Design the schema now**, shared with the port.
- Roll BUG-022's cleanup into whatever edit touches `StartSession`.

## Open items

- **Q-016** — confirm whether `htmlLoad` sends fire on the target (dedicated?) server. Blocks Option A.
- Decide enrichment scope (per-player detail requires widening the payload beyond the current params).
- Decide hosting/auth (token + HTTPS) if the endpoint is internet-facing.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-07-03 | Claude | Initial proposal — current stats mechanism (htmlLoad GET), Options A/B/C, starter schema, Q-016 dependency, port angle (from the BUG-022 stats-subsystem review) |
