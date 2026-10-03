# Quickstart and Validation: Core Gameplay Prototype

**Status**: Future project validation guide. Project, launcher and test runner are not yet implemented. The environment/version preflight below was executed on 2026-10-02; project validation commands remain unrun. No gameplay, visual or performance acceptance is claimed.

## Prerequisites and safe launch

- Windows reference platform/hardware in [plan.md](plan.md); record actual conditions and deviations.
- Persistent user-scope `GODOT_BIN` resolves to an existing Godot console executable, verified as Windows PE subsystem 3. Its `--headless --version` output was `4.7.2.stable.official.ed1daf0bf`, exit 0. Use the environment variable rather than a machine-specific path in tracked instructions; no installation is needed. Do not global-configure or download export templates as part of planning.
- This running process has not inherited `GODOT_BIN`. Resolve process scope first, then persistent User and Machine scopes if absent. Sandbox isolation may hide registry-backed scope; report inaccessible/missing values explicitly, and use an authorized read outside isolation or an explicitly supplied path. Do not write persistent environment settings.
- Implementation has supplied `project.godot`, main scene, definition resources, tests and `tools/validate.ps1`. Before accessing optional files/environment variables, check existence and handle absence explicitly.
- Launcher modes below are a planned interface. `-GodotBin` is required; `-Mode` accepts `All`, `Play`, `Profile`. Modes return nonzero on unavailable prerequisite or failed required check.
- Before engine/editor use, launcher confines process APPDATA/LOCALAPPDATA/TEMP/TMP and logs/raw output to ignored workspace `.cache/` paths; checks resolved absolute paths and verifies actual engine user-data/cache/editor locations. Restore existing or absent env values in `finally`. If containment is unverified, stop before launching the project and report blocked. Explicit approval is needed only for identified unavoidable writes outside the workspace.
- Engine version must match approved 4.7.2 Standard. The launcher's initial help/version/path preflight must itself use the contained process environment. Do not assume a `--user-data-dir` flag exists.

## Commands after implementation

Run from repository root. Resolve the existing console executable from `GODOT_BIN`; this does not change the persistent variable. The example requires access to the scope containing the value.

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

Run import before script checks so registered classes/UIDs resolve. Record each command, exit code, relevant diagnostics and outcome. Unexpected nonzero results require identifying the failing subcommand/cause/effect. A zero exit does not excuse script errors in logs. `--check-only` is parsing, not gameplay testing. Runner should assert actual instantiated component/scene behavior rather than duplicate production algorithms.

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
| Approved timing/failure policy | Completed simulation time unchanged by a wall-clock stall/pause; selection/instantiation fault consumes opportunity, increments counter, no catch-up, invalid acceptance; cap skip is not a failure; counter reset isolated to new run | Separate simulation/wall durations; zero unexpected spawn failures in accepted attempt; correct invalid data and relaunch, with no in-application retry |

Record every FR acceptance clause and listed edge case separately in `docs/verification/core-gameplay.md`, with command/scenario, actual observation, outcome and outstanding work. A coverage table alone is not completion evidence.

## Reproducible owner playtest

1. Start normal run with documented tuning: no enemies, full health, 00:00, initial view. Use WASD singly and opposed, release input, compare straight/diagonal travel away from walls. Rotate yaw 90° and repeat; pitch must not move vertically. Traverse entire boundary, hold vertical look to both limits and identify all entities/limits.
2. Observe first spawn after 1.5 active seconds and subsequent cadence. Move to a different location and witness pursuit redirect. Witness at least one automatic hit/kill and recognizable target feedback; deliberately contact enemies for health loss. Move through overlaps and along boundaries.
3. Pause with Escape during contact, noting health/time/position/view and instrumented remaining delays. Wait ten real seconds while trying WASD/mouse and holding Escape. Compare unchanged values; press Escape again, verify preserved delays and no catch-up. Repeat between spawn/attack opportunities.
4. Take lethal damage. Verify zero health, Game Over, final time and Restart. Wait ten seconds trying movement/mouse/Escape; no changes. Restart and confirm fresh health/view/position/time/population/timing. Perform three defeat/restart cycles and attempt repeated Restart activation; retain one encounter only.
5. Start a clean dedicated SC-006 attempt with the accepted tuning. Survive at least 300 active seconds uninterrupted, with normal spawning, pursuit, attacks and vulnerability. Continue past five minutes to verify no timed ending. Failed attempts do not count; record them and adjust data tuning if needed, then rerun affected checks and record the new definition set.

SC-004 requires owner completion of the integrated controls/combat/pause/restart journey without developer intervention. Headless checks or Codex assertions cannot replace it. SC-001–004/006–007 are prototype gates; SC-005 remains unverified future work.

## Actual five-minute profile (SC-007)

Use exact preselected [plan conditions](plan.md#measurement-conditions-fixed-before-profiling): reference hardware, standalone debug, Forward+, 1920×1080, 100% scale, AA/VSync/frame cap/shadows/SSAO/SSIL/glow off, one directional light, 60 Hz physics. Record actual engine/OS/driver/hardware, source revision, all tuning and deviations before sampling.

Warm up 30 active seconds in a separate attempt, restart cleanly, then sample the owner's actual uninterrupted first 300 active seconds from run start. Include normal startup frames. Keep vulnerability enabled and default cap 50 unless explicitly documented accepted tuning differs. No pause, concatenation of attempts or disabled enemies. Continue beyond 300 s to prove normal continuation.

The qualifying window ends after at least 300 completed, unpaused physics simulation seconds, never after merely 300 wall-clock seconds. Record completed simulation duration and actual monotonic wall-clock duration separately; active-play stalls remain in wall-time evidence. Buffer monotonic rendered-frame intervals and one-second enemy counts. Compute average actual FPS from counted frame intervals divided by their measured wall-time duration, not simulation seconds; report minimum instantaneous FPS as reciprocal maximum full interval, p50/p95/p99/max frame ms, count of intervals >16.67 and >33.33 ms, enemy count min/max/mean, and observed stalls/bottlenecks. Exact first/last partial-interval treatment remains proposal E in the plan. Omit inactive wall time and reset sampling origin after pause in diagnostic runs. Label measurements as CPU-observed frame-loop intervals, not GPU time; document unavailable metrics and instrumentation overhead. Built-in monitor/profiler diagnosis belongs in a separate run when needed.

Record `spawn_failure_count` and any selection/instantiation diagnostics. Any unexpected spawn failure invalidates that acceptance attempt even if gameplay continues beyond 300 simulation seconds; retain its evidence as invalid, not successful. Cap-full skips are expected and are not failures. Invalid configuration blocks simulation; correct the definition and relaunch. No in-application configuration retry is required.

Write raw logs/CSV inside ignored `.cache/`; summarize methods/conditions/results in `docs/verification/prototype-profile.md`, including unsuccessful attempts. No numerical SC-007 pass threshold is introduced. A cap-50 profile does not satisfy 200-enemy/60 FPS SC-005; do not build or claim that benchmark in this milestone.

## Pending technical procedure proposals

[Plan proposals A–G](plan.md#proposed-resolutions-for-remaining-technical-gaps) supply concrete lifecycle, update-order, timing, pursuit, frame-boundary, continuation-evidence and suite/timeout resolutions. They remain pending review and do not establish adopted test commands or acceptance changes. After approval, propagate those details into the contracts/model and this procedure, then reevaluate the corresponding technical checklist items. Implementing the runner/cases and executing evidence remain separate later work.

## Outcome reporting (current)

Report **passed**, **failed**, **skipped**, **blocked**, and **unrun** checks distinctly. Environment recheck passed: persistent `GODOT_BIN` file resolution, Windows console subsystem verification, and `--headless --version` (exit 0). Project loading/parsing/tests/startup, owner playtesting and profiling are **unrun**: project, launcher and tests are not implemented yet. Project/editor filesystem confinement remains unverified; engine availability is no longer a blocker. Do not mark the feature complete while any prototype acceptance criterion is unverified.
