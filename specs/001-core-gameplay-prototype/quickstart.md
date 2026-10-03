# Quickstart and Validation: Core Gameplay Prototype

**Status**: Future project validation guide. Project, launcher and test runner are not yet implemented. The environment/version preflight below was executed on 2026-10-02; project validation commands remain unrun. No gameplay, visual or performance acceptance is claimed.

## Prerequisites and safe launch

- Windows reference platform/hardware in [plan.md](plan.md); record actual conditions and deviations.
- Persistent user-scope `GODOT_BIN` resolves to an existing Godot console executable, verified as Windows PE subsystem 3. Its `--headless --version` output was `4.7.2.stable.official.ed1daf0bf`, exit 0. Use the environment variable rather than a machine-specific path in tracked instructions; no installation is needed. Do not global-configure or download export templates as part of planning.
- This running process has not inherited `GODOT_BIN`. Resolve process scope first, then persistent User and Machine scopes if absent. Sandbox isolation may hide registry-backed scope; report inaccessible/missing values explicitly, and use an authorized read outside isolation or an explicitly supplied path. Do not write persistent environment settings.
- Before executing project checks, require implementation to have supplied `project.godot`, main scene, definition resources, tests and `tools/validate.ps1`; they do not exist yet. Before accessing optional files/environment variables, check existence and handle absence explicitly.
- Launcher modes below are a planned interface. `-GodotBin` is an optional explicit override; when omitted, the launcher resolves the first nonempty `GODOT_BIN` value in Process → User → Machine order. Validate the selected executable using all existing path, console-subsystem, version and containment checks; an invalid explicit override is a diagnostic failure, not a reason to fall back silently. `-Mode` accepts `All`, `Play`, `Profile`. Modes return nonzero on unavailable prerequisite or failed required check.
- Before engine/editor use, launcher confines process APPDATA/LOCALAPPDATA/TEMP/TMP and logs/raw output to ignored workspace `.cache/` paths; checks resolved absolute paths and verifies actual engine user-data/cache/editor locations. Restore existing or absent env values in `finally`. If containment is unverified, stop before launching the project and report blocked. Explicit approval is needed only for identified unavoidable writes outside the workspace.
- Engine version must match approved 4.7.2 Standard. The launcher's initial help/version/path preflight must itself use the contained process environment. Do not assume a `--user-data-dir` flag exists.

## Commands after implementation

Run from repository root. Resolve the existing console executable from `GODOT_BIN`; this does not change the persistent variable. The example requires access to the scope containing the value.

The example below resolves and passes an explicit override. Omitting `-GodotBin` from the launcher invocation uses the same Process → User → Machine discovery inside the launcher; all validation, diagnostics, workspace containment and environment restoration requirements still apply.

```powershell
$ProjectRoot = 'C:\GameDev\project-horde'
$GodotBin = [Environment]::GetEnvironmentVariable('GODOT_BIN', 'Process')
if ([string]::IsNullOrWhiteSpace($GodotBin)) { $GodotBin = [Environment]::GetEnvironmentVariable('GODOT_BIN', 'User') }
if ([string]::IsNullOrWhiteSpace($GodotBin)) { $GodotBin = [Environment]::GetEnvironmentVariable('GODOT_BIN', 'Machine') }
if ([string]::IsNullOrWhiteSpace($GodotBin)) { throw 'GODOT_BIN is absent or inaccessible in this session; resolve its persistent scope or supply a verified console path.' }
if (-not [System.IO.Path]::IsPathRooted($GodotBin)) { throw 'GODOT_BIN must be an absolute executable path.' }
if (-not (Test-Path -LiteralPath $GodotBin -PathType Leaf)) { throw 'GODOT_BIN does not point to an existing executable file.' }
if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot 'tools\validate.ps1') -PathType Leaf)) { throw 'Validation launcher is not implemented yet.' }
& (Join-Path $ProjectRoot 'tools\validate.ps1') -GodotBin $GodotBin -Mode All
```

`All` should execute these underlying commands in the verified contained process environment, with a separate absolute workspace `--log-file` per check:

| Check | Engine command shape | Expected result |
|---|---|---|
| Version | `--headless --version` | Approved 4.7.2 Standard; otherwise blocked; environment recheck passed with `4.7.2.stable.official.ed1daf0bf` |
| Import/load | `--headless --path <absolute-root> --import` | Successful clean import; no missing scenes/resources or parse errors |
| Script parsing | `--headless --path <absolute-root> --script <absolute-script> --check-only` for each project/test `.gd` | No script errors; check every file, not only runner |
| Automated cases | `--headless --path <absolute-root> --script res://tests/run_tests.gd` | Assertions summarized; exit zero only if every required case passed |
| Main startup | `--headless --path <absolute-root> --quit-after 120` | Main loads and valid run advances without errors; 120 iterations, not seconds |

Run import before script checks so registered classes/UIDs resolve. Record each command, exit code, relevant diagnostics and outcome. Unexpected nonzero results require identifying the failing subcommand/cause/effect. A zero exit does not excuse genuine script/runtime errors in logs; ordinary banners, progress/device information and normal stdout/stderr do not fail a check. `--check-only` is parsing, not gameplay testing. Runner should assert actual instantiated component/scene behavior rather than duplicate production algorithms.

Interactive run and actual profile, after `All` passes:

```powershell
& (Join-Path $ProjectRoot 'tools\validate.ps1') -GodotBin $GodotBin -Mode Play
& (Join-Path $ProjectRoot 'tools\validate.ps1') -GodotBin $GodotBin -Mode Profile
```

`Play` launches the normal main scene; `Profile` launches the same gameplay/settings with buffered diagnostic sampling, no cheats or disabled combat. GUI execution follows applicable runtime approval rules. No editor/export-template dependency is needed for standalone debug play.

## Automated coverage and manual acceptance

Use [data-model.md](data-model.md) for tuning/invariants and [contracts](contracts/gameplay-components.md) for event order. Small test fixtures may override definitions or place actors, but owner acceptance uses recorded normal tuning.

| Requirements | Automated cases | Manual evidence |
|---|---|---|
| FR-001–003 | Direction/opposing/diagonal vectors before/after yaw, pitch independence, containment for both actors | All keys, diagonal speed, release, mouse yaw/pitch, entire perimeter, visibility/colors; move freely through enemies |
| FR-004 | First deadline, three normal opportunities, full cap and three skipped opportunities, no immediate refill, next cadence refill, default 50/custom cap, spawn outside threshold, fallback | Ongoing spawning/pursuit redirects to moved player; flat arena containment |
| FR-005 | No target, nearer target, exact tie/earliest ID, at/inside/outside range, fresh readiness, attack interval, dead/departed target excluded | Automatic hit/kill and feedback identifies target; altered range/cadence observable |
| FR-006–008 | Full independent health, nonlethal/excess damage, one death, dead ineligible, exact contact boundary, immediate contact, persistent interval, separation/re-entry cooldown, independent contacts, lethal short-circuit | Take damage, overlapping movement remains free, sustained contact cadence, no healing |
| FR-009 | Time formatting at 0/65 s, health signal presentation, inactive clock | HUD health/time readable; 65 s reads 01:05 within one displayed second |
| FR-010–011 | Freeze on defeat, Escape cannot resume, reset all fields, three cycles, repeat restart guard/old callback absence | Game Over shows final time and Restart; three defeat/restart cycles in one application |
| FR-012 | Pause preserves positions/view/health/clock/deadlines; no attacks/spawns; resume remaining delays; echo ignored | Ten-second pause during combat and between events while attempting input; no catch-up/jump |
| Invalid data | Missing/wrong definitions; nonfinite/nonpositive values; cap type; invalid geometry/camera | Actionable visible failure; no active broken encounter |
| Approved timing/failure policy | All deadlines at t_end before/at/after readiness; sub-tick cadence; completed time unchanged by a wall stall/pause; spawn faults consume/count/no catch-up; cap skip is not failure; restart counter isolation | Separate simulation/wall duration; zero unexpected spawn failures; correct invalid data and relaunch |
| Adopted A–G evidence | Same-step mouse yaw, bounded pursuit/unequal-radius reachability, generation-isolated buffers, full/partial sampling boundaries, continuation across 300, post-window death preserving survival result, manifest completeness, empty suite/timeouts, genuine-error versus informational-log fixtures | Post-300 responsiveness and next ordinary spawn opportunity; separate survival/continuation/capture results, no automatic acceptance at 300 |

Record every FR acceptance clause and listed edge case separately in `docs/verification/core-gameplay.md`, with command/scenario, actual observation, outcome and outstanding work. A coverage table alone is not completion evidence.

## Reproducible owner playtest

1. Start normal run with documented tuning: no enemies, full health, 00:00, initial view. Use WASD singly and opposed, release input, compare straight/diagonal travel away from walls. Rotate yaw 90° and repeat; pitch must not move vertically. Traverse entire boundary, hold vertical look to both limits and identify all entities/limits.
2. Observe first spawn after 1.5 active seconds and subsequent cadence. Move to a different location and witness pursuit redirect. Witness at least one automatic hit/kill and recognizable target feedback; deliberately contact enemies for health loss. Move through overlaps and along boundaries.
3. Pause with Escape during contact, noting health/time/position/view and instrumented remaining delays. Wait ten real seconds while trying WASD/mouse and holding Escape. Compare unchanged values; press Escape again, verify preserved delays and no catch-up. Repeat between spawn/attack opportunities.
4. Take lethal damage. Verify zero health, Game Over, final time and Restart. Wait ten seconds trying movement/mouse/Escape; no changes. Restart and confirm fresh health/view/position/time/population/timing. Perform three defeat/restart cycles and attempt repeated Restart activation; retain one encounter only.
5. Start a clean dedicated SC-006 attempt with recorded normal tuning. Complete at least 300 unpaused physics simulation seconds alive, with normal spawning, pursuit, attacks and vulnerability. Record the survival-window outcome separately from continuation and profile-capture outcomes. Beyond the endpoint, observe advancing completed time, responsive movement/view, unchanged tuning/vulnerability and a subsequent scheduled spawn opportunity (successful or expected full-cap skip). Record owner attacks when eligible; deterministic crossing fixtures demonstrate eligible weapon/contact continuation without forcing extra owner-run attacks. If later death prevents all continuation observations, retain valid survival-window/profile evidence and mark the unobserved continuation clauses outstanding; do not claim full SC-006 or splice attempts. Any unexpected spawn failure invalidates acceptance, including during continuation. Record unsuccessful attempts and any changed tuning, rerunning affected checks.

SC-004 requires owner completion of the integrated controls/combat/pause/restart journey without developer intervention. Headless checks or Codex assertions cannot replace it. SC-001–004/006–007 are prototype gates; SC-005 remains unverified future work.

## Actual five-minute profile (SC-007)

Use exact preselected [plan conditions](plan.md#measurement-conditions-fixed-before-profiling): reference hardware, standalone debug, Forward+, 1920×1080, 100% scale, AA/VSync/frame cap/shadows/SSAO/SSIL/glow off, one directional light, 60 Hz physics. Record actual engine/OS/driver/hardware, source revision, all tuning and deviations before sampling.

Warm up 30 active seconds in a separate attempt, restart cleanly, then sample the owner's actual uninterrupted first 300 active seconds from run start. Include normal startup frames. Keep vulnerability enabled and default cap 50 unless explicitly documented accepted tuning differs. No pause, concatenation of attempts or disabled enemies. Continue beyond 300 s to prove normal continuation.

The qualifying window is based on completed, unpaused simulation, with the same completion-time deadline semantics as all gameplay timing: see [component contracts](contracts/gameplay-components.md#timing-and-restart-guarantees). Do not substitute wall-clock duration for survival.

Let `t0` be monotonic wall time when the fresh validated Active encounter is ready, before its first simulated step. Let `t1` be wall time at completion of the first executed step with committed `active_time >= 300`; record exact simulation duration, completed tick count and whole-window wall duration `W = t1 - t0`. The endpoint is determined after that step's combat/result, never by wall time or the rounded HUD. A lethal result is not automatically successful survival.

Count observed frame-loop callbacks with timestamps in `(t0, t1]`; whole-window average actual frame-loop FPS is `callback_count / W`. This includes all active wall time, including startup and boundary stalls. Separately report full successive frame intervals wholly contained in `[t0,t1]`: their coverage duration, interval count and `interval_count / sum(interval_seconds)` as full-interval FPS. The first timestamp alone is not a full interval; never invent prorated frames.

Use full intervals for minimum instantaneous FPS (reciprocal maximum interval), p50/p95/p99/max frame ms and >16.67/>33.33 ms stall counts. Separately report initial/final partial wall segments and their stall durations so excluded interval fragments cannot conceal active stalls. Retain adjacent boundary timestamps only to describe those boundaries; do not include out-of-window work in the average. If no full interval exists, report whole-window count/duration plus the uncovered wall segment, and mark full-interval distributions/minimum unavailable with reasons and outstanding verification. Two callbacks yielding one full interval suffice to compute those statistics; do not silently drop sparse samples.

Sample live-registry enemy counts at one-second completed-simulation opportunities, carrying both simulation and wall timestamps; report observed min/max/mean. Diagnostic paused runs use separate segments excluding inactive time; the qualifying owner run is uninterrupted. Label samples as CPU-observed frame-loop timing, not GPU presentation/timing; report available CPU/physics/render monitors, instrumentation overhead and unavailable metrics. Warm-up is 30 active seconds in a separate attempt; record all preselected conditions, actual tuning, source revision and deviations. No numerical prototype FPS threshold or future benchmark compliance is inferred.

Main creates/wires one capture helper only in Profile mode and owns its disposal; the coordinator explicitly opens/closes generation-tagged attempts. Normal Play has no frame sampler, but retains the per-run spawn-failure counter. Keep the helper independent of gameplay behavior and reject stale-generation samples/callbacks.

During capture, spool every frame timestamp losslessly in bounded 4,096-entry float64 chunks under ignored workspace `.cache/`, counting chunk I/O as sampler overhead. At 300 completed simulation seconds, close the five-minute frame/count stream, flush its final tail and write the JSON manifest/summary after sampling; keep only attempt/continuation/failure metadata afterward so unlimited survival does not create an unlimited frame buffer. Compute exact source-microsecond interval frequencies from the complete raw stream without dropping samples; see plan.md, Phase 3B profiling correction. Required stream/manifest/outcomes failures leave profiling outstanding and fail the launcher even at engine exit zero. Close diagnostic segments on pause and reopen the origin on resume without bridging inactive wall time. Defeat closes any unfinished segment. Before restart teardown, retain/seal the old attempt and its actual outcomes; open fresh buffers only after new definitions validate. On shutdown, Main writes remaining evidence then disposes the helper. Required-output write/capture failures leave profiling outstanding and are reported, never silently successful.

Record separately: survival-window outcome, continuation outcome, profile-capture outcome, and acceptance invalidity from unexpected spawn failures. Reaching 300 seconds is not full attempt acceptance. A 300-second window completed alive with normal tuning can retain successful survival evidence if later death prevents continuation observations. Full attempt acceptance requires that survival evidence, all required continuation evidence, successfully captured required profiling evidence, and zero unexpected spawn failures throughout the attempt, including continuation. Any unavailable required verification remains outstanding; recording its absence alone does not satisfy it. Later spawn failures update the attempt's invalidity even if its five-minute buffer is already closed. Feature acceptance additionally requires all prototype gates, not just this attempt. No worker, singleton, save system or new UI is introduced.

Record `spawn_failure_count` and actionable selection/instantiation diagnostics. Cap-full skips are expected and do not increment failures. Invalid configuration blocks simulation; correct definitions and relaunch without in-application retry. Fault-injection fixtures may correctly pass their assertions while their encounter remains invalid for owner acceptance.

Write raw logs/CSV under ignored `.cache/`; summarize methods, boundary coverage, preselected/actual conditions, outcomes and deviations in `docs/verification/prototype-profile.md`. Include unsuccessful/invalid/partial attempts. No numerical SC-007 threshold is introduced; a cap-50 run does not satisfy SC-005 or require its benchmark harness.

## Deterministic suite and validation outcomes

Use the native assertion runner with one explicit manifest of required case IDs, case-script paths and FR/edge-case mappings. Enumerate designated case files under `tests/unit/` and `tests/integration/`, distinguish runner/support helpers explicitly, and reconcile manifest/discovery/executed IDs: missing, duplicate, unregistered, unexecuted or zero cases fail. Use isolated definition copies, fixed reported RNG seeds, real component/scene assertions and scene/callback cleanup per case. Include deadline before/at/after checks at step completion, sub-tick intervals, pursuit/radius boundary cases, simultaneous mouse/movement, failure-counter isolation, continuation crossing and profile reset/boundaries.

Failure means failed assertions, nonzero process exit, genuine script/parse/runtime/resource-load errors, incomplete execution, or timeout. Inspect recognized diagnostic severity/records even on exit zero; do not fail merely because stdout/stderr is nonempty or contains an arbitrary word such as “error.” Engine banners, progress, renderer/device information and normal logs are informational. Record warnings separately; escalate only warnings that demonstrate violation of a required criterion, with a stated reason. Preserve original diagnostics and command/exit/outcome. Validate the classifier with failure records and harmless-output fixtures for the approved executable's format; ambiguous diagnostics require explicit investigation, never an unsupported pass.

Expected application-level configuration/spawn diagnostics in fault-injection cases are matched by declared case/source/constraint/count and asserted along with the required state/counter; they do not turn that correctly asserted fixture into a failed suite. Genuine unexpected engine/script exceptions remain failures. The deliberately faulted gameplay attempt remains invalid for owner acceptance. No broad engine-error suppression or informational-output failure rule is allowed.

The contained PowerShell launcher has explicit configurable noninteractive limits: version/help 30 s, clean import 180 s, each-script parse 30 s, complete suite 120 s, main startup 30 s. A timeout fails and terminates only its launched child; preserve diagnostics and restore environment in `finally`. Missing prerequisites/unverified confinement are blocked. Document overrides and rerun rather than silently extending a hanging check. Interactive Play/Profile has no automated timeout. These are operational limits, not gameplay/performance gates; no external test dependency is required.

## Evidence and continuation records

Separate the completed 300-second survival window from continuation verification. In the same normal owner attempt, record committed simulation time above 300, responsive movement/view, unchanged tuning/vulnerability and at least one later scheduled spawn opportunity (successful or expected full-cap skip). Record their simulation timestamps. Do not require a post-endpoint owner attack when no target is eligible; deterministic fixtures spanning 300 must demonstrate unchanged state/tuning and continued eligible weapon/contact scheduling, and owner attacks are recorded when eligibility occurs. No fixed additional survival duration, cheats or forced owner-run fixture is added.

If death occurs after valid completion of the survival window but before all continuation observations, preserve the successful survival-window result and any captured five-minute profile; mark the unobserved continuation clauses outstanding. Do not concatenate attempts or claim full SC-006/attempt acceptance. An unexpected spawn failure invalidates acceptance even if survival or profile observations have been collected; preserve those observations honestly. GameOver naturally ending a later run does not itself invalidate earlier survival evidence.

Record each FR/edge-case result and separate survival, continuation, profile-capture and acceptance-invalidity outcomes in `docs/verification/core-gameplay.md` / `prototype-profile.md`. Required unobserved continuation or capture verification remains outstanding even if the survival-window result is passed. All A–G procedures are approved design, not executed acceptance.

## Outcome reporting (current)

Report **passed**, **failed**, **skipped**, **blocked**, and **unrun** checks distinctly. Environment recheck passed: persistent `GODOT_BIN` file resolution, Windows console subsystem verification, and `--headless --version` (exit 0). Project loading/parsing/tests/startup, owner playtesting and profiling are **unrun**: project, launcher and tests are not implemented yet. Project/editor filesystem confinement remains unverified; engine availability is no longer a blocker. Do not mark the feature complete while any prototype acceptance criterion is unverified.
