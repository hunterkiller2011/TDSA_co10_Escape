# Security & Privacy
_Last updated: 2026-07-01 (local)_ · _Status: active (partial)_

> Auth, secrets, and data handling. Data-collection facts below are derived from the Statistics code
> review (Sprint 4); other sections remain skeleton.

## Data collected

**External session telemetry** (opt-in via the `A3E_Param_SendStatistics` parameter; `1` = on) is sent to
`co10esc.anzp.de` at session start/end. Payload (in the request URI): a session GUID derived from
`hashValue(serverName) + hashValue(systemTimeUTC)`, the `serverName`, mission version/build, mod,
terrain/island, player count, and end-of-session outcome/timing. **No player names or per-player PII** appear
in the URIs. **Local profile statistics** (kills/deaths/times) are stored client-side in `profileNamespace`
and are not transmitted. _(Source: code-reference/Statistics.md.)_

> Caveat: the dead `PingStatistics` function (no callers) would send `serverName` + live player count to a
> legacy host **without** honoring the opt-in — flag if ever re-enabled (see risks-tech-debt RD-020).

## External services

- `http://co10esc.anzp.de/api/session/` — external statistics API (session start/end). Transport is a
  fire-and-forget `htmlLoad` on a hidden `RscHTML` control (no error handling); may not fire on headless
  servers (open question Q-016).
- `http://co10esc.anzp.de/api` — base statistics endpoint (also referenced in the README).
- `escape.anzp.de/track.php` — legacy ping host, referenced only by the dead `PingStatistics`.

## Server / mission-config hardening

Findings from `Code/description.ext` (code review, Sprint 5) — dev-friendly defaults to review before a
public release (tracked as risks-tech-debt RD-021):
- `enableDebugConsole = 1` (`:40`) and `allowFunctionsRecompile = 1` (`:41`) ship enabled.
- `CfgRemoteExec.Functions mode = 2` (`:104`) ignores the whitelist (only `a3e_fnc_initPlayer` is explicitly listed).
- `allowedHTMLLoadURIs` (`:212+`) includes a dev endpoint `http://localhost:5093/api/session*` and plain-HTTP
  (cleartext) statistics endpoints.

## Secrets handling

_(to write — no secrets in repo; where any keys/tokens live)_

## Privacy considerations

_(to write — player identifiers, opt-out)_

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton |
| 2026-07-01 | Claude | Filled Data collected + External services from Statistics code review (Sprint 4) |
| 2026-07-02 | Claude | Added Server/mission-config hardening from description.ext review (Sprint 5) |
