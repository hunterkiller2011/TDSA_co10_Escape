# Code Reference — Init & Includes
_Last updated: 2026-06-30 (local)_ · _Status: skeleton_

> Entry points, the initialization chain, and the include/config files that define how the mission is
> wired together. One entry per file. Fields are stubs (`_(to document)_`) until documented. See
> [README.md](README.md) for field definitions and [_xref.md](_xref.md) for callers.

### `Code/description.ext`  ·  _status: stub_
- **Purpose:** _(to document — mission config; CfgFunctions include; CBA PreInit event handler wiring; EscapeBuild)_
- **Inputs:** _(to document)_
- **Outputs:** _(to document)_
- **Calls:** _(to document)_
- **Called by:** _(to document — engine, at mission load)_
- **Processing:** _(to document)_
- **Theory of operation:** _(to document)_
- **Whys & questions:** _(to document)_
- **Unresolved issues:** _(to document)_
- **Reforger port notes:** _(to document)_

### `Code/XEH_preInit.sqf`  ·  _status: stub_
- **Purpose:** _(to document — creates CBA settings from mission parameters)_
- **Inputs:** _(to document)_
- **Outputs:** _(to document)_
- **Calls:** _(to document)_
- **Called by:** _(to document — CfgFunctions PreInit EH in description.ext)_
- **Processing:** _(to document)_
- **Theory of operation:** _(to document)_
- **Whys & questions:** _(to document)_
- **Unresolved issues:** _(to document)_
- **Reforger port notes:** _(to document)_

### `Code/functions/Common/fn_bootstrapEscape.sqf`  ·  _status: stub_
- **Purpose:** _(to document — postInit; compiles config.sqf + per-island configs; spawns missionFlow/initServer/initLocalPlayer)_
- **Inputs:** _(to document)_
- **Outputs:** _(to document)_
- **Calls:** _(to document)_
- **Called by:** _(to document — CfgFunctions postInit=1)_
- **Processing:** _(to document)_
- **Theory of operation:** _(to document)_
- **Whys & questions:** _(to document)_
- **Unresolved issues:** _(to document)_
- **Reforger port notes:** _(to document)_

### `Code/functions/Server/fn_initServer.sqf`  ·  _status: stub_
- **Purpose:** _(to document — server main: templates, factions, zones, prison/COM/ammo/mortar/crash, extraction, search leader, Chronos registration)_
- **Inputs:** _(to document)_
- **Outputs:** _(to document)_
- **Calls:** _(to document)_
- **Called by:** _(to document — spawned by fn_bootstrapEscape on server)_
- **Processing:** _(to document — 697 lines; break into sections)_
- **Theory of operation:** _(to document)_
- **Whys & questions:** _(to document)_
- **Unresolved issues:** _(to document)_
- **Reforger port notes:** _(to document)_

### `Code/include/functions.hpp`  ·  _status: stub_
- **Purpose:** _(to document — CfgFunctions declarations for the A3E / drn / ace tags)_
- **Inputs:** _(to document)_
- **Outputs:** _(to document)_
- **Calls:** _(to document)_
- **Called by:** _(to document — #included by description.ext)_
- **Processing:** _(to document)_
- **Theory of operation:** _(to document)_
- **Whys & questions:** _(to document)_
- **Unresolved issues:** _(to document)_
- **Reforger port notes:** _(to document)_

### `Code/include/params.hpp`  ·  _status: stub_
- **Purpose:** _(to document — mission parameters exposed in-game and as CBA settings)_
- **Inputs:** _(to document)_
- **Outputs:** _(to document)_
- **Calls:** _(to document)_
- **Called by:** _(to document — #included by description.ext)_
- **Processing:** _(to document)_
- **Theory of operation:** _(to document)_
- **Whys & questions:** _(to document)_
- **Unresolved issues:** _(to document)_
- **Reforger port notes:** _(to document)_

### `Code/include/defines.hpp`  ·  _status: stub_
- **Purpose:** _(to document — preprocessor #defines, including BUILD = `{* COMMIT *}`)_
- **Inputs:** _(to document)_
- **Outputs:** _(to document)_
- **Calls:** _(to document)_
- **Called by:** _(to document — #included across config/description)_
- **Processing:** _(to document)_
- **Theory of operation:** _(to document)_
- **Whys & questions:** _(to document)_
- **Unresolved issues:** _(to document)_
- **Reforger port notes:** _(to document)_

### `Code/config.sqf`  ·  _status: stub_
- **Purpose:** _(to document — runtime config variables: a3e_var_* search/patrol/debug/artillery/etc.)_
- **Inputs:** _(to document)_
- **Outputs:** _(to document)_
- **Calls:** _(to document)_
- **Called by:** _(to document — compiled by fn_bootstrapEscape)_
- **Processing:** _(to document)_
- **Theory of operation:** _(to document)_
- **Whys & questions:** _(to document)_
- **Unresolved issues:** _(to document)_
- **Reforger port notes:** _(to document)_

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field file stubs, no analysis) |
