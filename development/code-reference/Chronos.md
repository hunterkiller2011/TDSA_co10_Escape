# Code Reference — Chronos
_Last updated: 2026-06-30 (local)_ · _Status: documented_

> Recurring-task scheduler (register/run/dispatch on an interval trigger). One entry per source file in `Code/functions/Chronos/`. Fields are stubs (`_(to document)_`) until documented. See [README.md](README.md) for field definitions, the call-name caveat, and the caller index [_xref.md](_xref.md).

### a3e_fnc_Chronos_Dispatch  —  `Code/functions/Chronos/fn_Chronos_Dispatch.sqf`  ·  _status: documented_
- **Purpose:** Execute one scheduled Chronos process (the actual `call`/`spawn` of the registered function), then either remove it (one-shot timeout) or stamp its last-call time so it repeats next interval.
- **Inputs:** `param[0]` = `_process` (the 6-element process array `[function, callType, time, lastCall, isTimeout, handle]`), `param[1]` = `_index` (position in `A3E_CronProcesses`). Reads/writes global `A3E_CronProcesses`.
- **Outputs:** No return value. Side effects: runs the registered function; for `spawn` writes the new script handle back into `A3E_CronProcesses[_index][5]` (`:39`); on timeout removes the entry (`deleteAt`, `:42`), else updates `[3]` (lastCall) to `diag_tickTime` (`:44`).
- **Calls:** **Dynamic dispatch by name string** — for a STRING function it does `call compile format["call %1;",_function]` (call type) or `call compile format["_return = [] spawn %1;_return",_function]` (spawn type); for a CODE function it directly `call`/`spawn`s it. This is the mechanism by which registered names like `A3E_FNC_RoadBlocks`, `A3E_FNC_AmbientPatrols`, `A3E_fnc_updateTraps`, `A3E_FNC_TrackGroup_Update` are invoked — those callees are invisible to static xref.
- **Called by:** `a3e_fnc_chronos_run` (`Code/functions/Chronos/fn_Chronos_Run.sqf:17` for `call` type, `:20` for `spawn` type when the previous handle is done).
- **Processing:** Destructure process tuple → branch on `_callType` (call vs spawn) → branch on `typename _function` (STRING via compile, CODE direct, else warn) → store spawn handle → either delete (timeout) or refresh lastCall.
- **Theory of operation:** Separates "decide it's time to run" (Run) from "actually run + reschedule" (Dispatch). Storing the spawn handle lets Run skip a still-running spawn (overrun protection). `call compile format` is the indirection layer that turns a registered name string into an executed function.
- **Whys & questions:** Q: why store `_return` from spawn via `call compile` rather than `_return = [] spawn (missionNamespace getVariable _function)` — the `call compile` form is legacy and slower; likely historical. The local `_lastCall`/`_time`/`_handle` reads (`:8-11`) are unused after destructuring.
- **Unresolved issues:** `call compile format` on a name string is a code-injection/perf smell and a static-analysis blind spot (DEAD-CODE false positives for the registered functions). `_return` is declared `private` but for the call branch never assigned. Casing inconsistency in dispatched names (`A3E_FNC_` vs `A3E_fnc_`).
- **Reforger port notes:** TBD — Enfusion would use a typed callback/`ScriptInvoker` or method reference instead of string compilation.

### a3e_fnc_Chronos_Init  —  `Code/functions/Chronos/fn_Chronos_Init.sqf`  ·  _status: documented_
- **Purpose:** One-time server-side bootstrap of the Chronos scheduler: initialize its global state variables and create the heartbeat trigger that periodically fires `a3e_fnc_chronos_run`.
- **Inputs:** None (no params). Reads `isServer`. Lazily initializes globals `A3E_CronTimer`, `A3E_CronTime` (5 s), `A3E_CronProcesses` (`[]`), `A3E_CronTick` (true), `A3E_CronTrigger`.
- **Outputs:** No return value. Side effects: sets the above globals; creates an `EmptyDetector` trigger with interval `A3E_CronTime`, zero area, activation `NONE`, and stores it in `A3E_CronTrigger` (`:26`).
- **Calls:** none directly. The created trigger's activation statement string is `"A3E_CronTick = false; [] call a3e_fnc_chronos_run;"` — this is how `chronos_run` gets invoked on each tick (`:24`).
- **Called by:** **Engine/CBA at postInit** — registered with `postInit = 1` in `Code/include/functions.hpp:241-242` (class `Chronos_Init`). No direct `fnc_` call site (xref: "entry point", confirmed via postInit appendix).
- **Processing:** `if(isServer)` guard → nil-init each global → create heartbeat trigger with `setTriggerInterval A3E_CronTime` and the tick statement → save handle.
- **Theory of operation:** Implements the **register→run→dispatch interval-trigger model**: this Init builds the single ticking trigger; the trigger condition `A3E_CronTick` (gated true/false so only one run executes at a time) calls `chronos_run`, which scans registered processes and hands due ones to `chronos_dispatch`. Server-only because all scheduled tasks are server logic.
- **Whys & questions:** Q: an `EmptyDetector` with `NONE`/zero-area used purely as a polling timer (interval) — idiomatic A3 but unusual; a `CBA_fnc_addPerFrameHandler` would be a modern alternative. Q: `A3E_CronTimer` is set here and in Run but never actually read for gating — see Run.
- **Unresolved issues:** `A3E_CronTimer` appears vestigial (set but unused for control flow). The `A3E_CronTick` boolean gate prevents re-entry but if `chronos_run` errors before resetting `A3E_CronTick=true`, the scheduler could stall.
- **Reforger port notes:** TBD — Enfusion would replace the trigger-as-timer with a periodic system update / `GetGame().GetCallqueue().CallLater(..., repeat)`.

### a3e_fnc_Chronos_Register  —  `Code/functions/Chronos/fn_Chronos_Register.sqf`  ·  _status: documented_
- **Purpose:** Register a function (by name string or CODE) with the Chronos scheduler so it runs periodically (or once, as a timeout). The public API for adding scheduled tasks.
- **Inputs:** Params (read both via `params` and `BIS_fnc_param` defaults): `_function` (String name or CODE, default `""`), `_calltype` (`"call"`/`"spawn"`, default `"spawn"`), `_time` (interval seconds, default 1), `_isTimeout` (Bool, default false → single-shot when true). Reads/writes global `A3E_CronProcesses`.
- **Outputs:** No explicit return. Side effect: `pushBack` a 6-element process tuple `[_function,_calltype,_time,_lastCall,_isTimeout,scriptNull]` onto `A3E_CronProcesses` (`:16`), with `_lastCall = diag_tickTime`.
- **Calls:** `BIS_fnc_param` (x4) for defaulted argument parsing. Leaf otherwise (no scheduled-function execution happens here).
- **Called by:** `Code/functions/Server/fn_initServer.sqf:679-683` (registers `A3E_FNC_RoadBlocks`, `A3E_FNC_AmbientPatrols`, `A3E_FNC_MilitaryTraffic`, `A3E_FNC_CivilianCommuters`, `A3E_FNC_TrackGroup_Update`; line 678 `AmbientAISpawn` is commented out) and `Code/functions/Server/fn_initTraps.sqf:3` (`A3E_fnc_updateTraps`, call type, 5 s).
- **Processing:** `params` destructure (then immediately re-read each arg via `BIS_fnc_param` for defaults) → capture `_lastCall` → push the process record.
- **Theory of operation:** The "register" stage of register→run→dispatch: it only appends a descriptor; the heartbeat trigger (Init) drives Run, which later notices the entry is due and calls Dispatch. The handle slot starts as `scriptNull` so the first spawn is allowed.
- **Whys & questions:** Q: the function both `params[...]` and then overwrites every variable with `BIS_fnc_param` defaults — redundant; the `params` line provides no defaults so the `BIS_fnc_param` lines are the effective parser. Most server registrations omit calltype/time, so they default to `spawn` every 1 s.
- **Unresolved issues:** Double-parse (params + BIS_fnc_param) is dead/duplicated code. No de-duplication guard — registering the same function twice schedules it twice. Casing inconsistency between registered names.
- **Reforger port notes:** TBD — equivalent to adding a callback to a periodic invoker/queue; would take a typed method reference + interval.

### a3e_fnc_Chronos_Run  —  `Code/functions/Chronos/fn_Chronos_Run.sqf`  ·  _status: documented_
- **Purpose:** The per-tick scheduler scan: walk every registered process and, for any whose interval has elapsed, hand it to `chronos_dispatch` for execution. Includes overrun protection for spawn-type tasks.
- **Inputs:** None (no params). Reads/writes globals `A3E_CronProcesses`, `A3E_CronTimer`, `A3E_CronTime`.
- **Outputs:** No return value. Side effect: sets `A3E_CronTimer = diag_tickTime + A3E_CronTime` (`:3`); logs via `diag_log` when a spawn task overruns.
- **Calls:** `a3e_fnc_chronos_dispatch` (`:17` for call type, `:20` for spawn type when the previous handle `scriptDone`). `diag_log`/`format` when a spawn is still running.
- **Called by:** Invoked **by the Chronos heartbeat trigger statement string** created in `Code/functions/Chronos/fn_Chronos_Init.sqf:24` (`"... [] call a3e_fnc_chronos_run;"`). No direct `call` site in source — driven by the trigger.
- **Processing:** Update `A3E_CronTimer` → `forEach A3E_CronProcesses`: destructure tuple → if `diag_tickTime >= lastCall+time`, dispatch; for spawn tasks only dispatch when the prior script handle is done, otherwise log an overrun warning (do not re-dispatch).
- **Theory of operation:** The "run" stage of register→run→dispatch. It is the cheap due-check loop fired every `A3E_CronTime` (5 s) by the Init trigger; actual execution + rescheduling is delegated to Dispatch. Spawn overrun guard prevents stacking long-running async tasks.
- **Whys & questions:** Q: `A3E_CronTimer` is computed here but never read for control flow (gating is done via the trigger interval + per-process `lastCall+time`); it looks vestigial / leftover from an earlier polling design. Q: call-type tasks have no overrun guard (they run synchronously, blocking the tick) — long `call` tasks could stall the scheduler.
- **Unresolved issues:** `A3E_CronTimer` set-but-unused (dead variable, also set in Init). Modifying `A3E_CronProcesses` indices inside Dispatch (`deleteAt`) while Run iterates by `_foreachindex` could shift indices mid-loop if multiple timeouts fire in one tick — potential index-skew bug.
- **Reforger port notes:** TBD — would become the update body of a periodic system iterating a task list; overrun-guard maps to checking an async task's completion state.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-06-30 | Peter | Initial skeleton (10-field entry stubs, no analysis) |
| 2026-06-30 | Claude | Documented all entries |
