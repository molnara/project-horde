# Quickstart and Validation: Core Gameplay Prototype

**Reconciled:** 2026-10-03, DX-001 Batch 1 acceptance-method amendment following
T049 and T051. Gameplay, launcher and native tests are implemented through Phase 5.
This documentation amendment is not a new engine validation, owner playtest or
profiling session. Historical T049 audit descriptions below retain that scope.

## Implementation and evidence status

| Status | Evidence and limits |
|---|---|
| Implemented | One flat arena, WASD/mouse camera, one pursuing enemy type, automatic weapon, health/HUD, defeat/restart and pause/resume; contained All/Play/Profile launcher and native tests |
| Previously verified | T051 complete: 82/82 cases, 5,843 assertions, 37 script parses, clean import, normal/Profile startup and 146 infrastructure assertions; approved Standard `4.7.2.stable.official.ed1daf0bf`; not rerun by DX-001 Batch 1 |
| Owner-reported story acceptance | T033, T041 and T048 are closed; Phase 4/SC-002 and Phase 5/SC-003 acceptance is recorded separately from automated tests |
| Historical survival/profile | Prior owner observations and corrected cap-50 capture remain in the ledger. Historical source-snapshot provenance and full SC-006/SC-007 qualification remain unresolved; those results do not certify the current integrated build |
| Current Phase 6 | T051/T052 complete per the T052 closure ledger. T053 procedure prepared; actual warm-up/clean relaunch pending. T054–T056 remain open; SC-006/007 qualification outstanding |
| SC-005 | **Future/unverified: 200 representative active enemies at 60 FPS.** Neither the cap-50 baseline nor a synthetic configurable-cap test establishes it |

See [the verification ledger](../../docs/verification/core-gameplay.md), especially
its Phase 3B T033, Phase 4 T041 and Phase 5 Batch 3 closure sections. Earlier
unrun/deferred ledger statements are historical. The introductions in `spec.md`,
`plan.md` and contracts still describe the planning stage; use production sources,
completed tasks and closure evidence for implementation status. Their approved
requirements remain applicable. Those introductions are outside this batch's edits.

Implemented paths, relative to the repository root:

| Paths | Role |
|---|---|
| `project.godot`, `scenes/main.tscn`, `scripts/run/main.gd` | Main entry point, encounter creation/rebuild, input capture and Profile-only capture ownership |
| `scripts/run/run_coordinator.gd`, `scripts/run/enemy_spawner.gd`, `scripts/run/live_registry.gd` | Ordered Active simulation, indexed spawning, live population and generation/state lifecycle |
| `scenes/arena.tscn`, `scenes/player.tscn`, `scenes/enemy.tscn`, `scenes/camera_rig.tscn`, `scenes/hud.tscn` | Reusable arena/actor/view/UI scenes, composed by the coordinator |
| `scripts/arena/`, `scripts/actors/`, `scripts/camera/`, `scripts/combat/`, `scripts/ui/` | Containment, movement/contact, camera, health/weapon/feedback and HUD |
| `scripts/data/`, `resources/definitions/` | Definition classes, validation and five tuning resources |
| `scripts/run/profile_capture.gd`, `scripts/run/profile_statistics.gd` | Bounded raw capture, segment/attempt evidence and statistics |
| `tests/run_tests.gd`, `tests/case_manifest.gd`, `tests/unit/`, `tests/integration/`, `tests/support/` | Native runner, manifest, actual component/scene cases and isolated helpers |
| `tools/validate.ps1`, `tools/validation_diagnostics.ps1`, `tools/test-validation.ps1` | Contained launcher, diagnostic classification and infrastructure fixtures |
| `docs/asset-provenance.md`, `tests/README.md`, `docs/verification/core-gameplay.md` | Asset audit, detailed coverage and executed evidence |

There are 20 production and 17 test/support `.gd` files, six scenes and five
definition resources. The [T053 profiling runbook](../../docs/verification/prototype-profile.md)
now supplies pre-recorded conditions, exact warm-up/measured commands, source
retention and artifact interpretation. It contains preparation, not T054/T055 results.

## Current defaults from production

Main preloads `resources/definitions/run.tres`, which references the four
subordinate resources below. Values were checked against those production files,
`scripts/data/*_definition.gd` and runtime consumers, not assumed from the spec.
Fresh valid runs copy definitions into independent runtime ownership. In-memory
source edits affect a subsequent run; disk edits require a new process to reliably
reload resources. No tuning editor UI exists.

| Source resource | Exact authored fields and values |
|---|---|
| `resources/definitions/player.tres` | `max_health = 100`; `movement_speed = 6.0` m/s; `visual_radius = 0.4` m; `visual_height = 1.6` m |
| `resources/definitions/enemy.tres` | `max_health = 30`; `movement_speed = 3.0` m/s; `visual_radius = 0.4` m; `visual_height = 1.2` m; `contact_distance = 1.2` m; `contact_damage = 10`; `contact_interval = 1.0` active s |
| `resources/definitions/weapon.tres` | `range = 4.0` m; `damage = 10`; `attack_interval = 0.6` active s; `feedback_duration = 0.12` active s |
| `resources/definitions/arena.tres` | `half_extents_xz = Vector2(20, 20)` (40 × 40 m); `floor_y = 0.0`; `boundary_visual_height = 0.15` m; `player_start_xz = Vector2(0, 0)` |
| `resources/definitions/run.tres` | `schema_version = 1`; `spawn_interval = 1.5` active s; `max_live_enemies = 50`; `camera_yaw = 0.0`°; `camera_depression = 35.0`°; `depression_min = 15.0`°; `depression_max = 65.0`°; `camera_distance = 8.0` m; `camera_target_height = 1.2` m; `mouse_sensitivity = 0.12`° per delivered `InputEventMouseMotion.relative` unit; `camera_fov = 70.0`° |

At the default 1920×1080 window mouse relative units correspond to viewport
pixels. Stretching can transform them; production consumes `relative`, not
`screen_relative`. The older planning wording does not establish resolution
independent physical sensitivity.

`project.godot` configures Forward+, 1920×1080 viewport, `canvas_items` stretch,
100% 3D scale, 60 physics ticks/s, `run/max_fps = 0` (uncapped), VSync off,
MSAA/screen-space AA/TAA off. `scenes/main.tscn` supplies one directional light
with shadows off and a flat-color Environment; SSAO/SSIL/glow are not enabled.
Reference: Windows 10 IoT Enterprise LTSC 2021, i7-12700KF, 32 GB RAM, RTX 3080
10 GB. Record actual hardware/driver/OS and deviations before acceptance.

First spawn waits 1.5 active seconds; later deadlines are fixed interval multiples.
Cap-full opportunities are consumed, with no immediate refill on death or backlog.
Selection tries 16 inset candidates then a farthest inset corner strictly outside
contact range. Weapon/contact start ready and each attack at most once per step;
actual damage advances that attacker's deadline. Inclusive XZ center distances
determine eligibility; tied targets choose earliest living spawn ID. Contact
cooldowns survive separation. Three default weapon hits kill a full-health enemy.
Multiple ready contacts can kill in one update; no healing, blocking or grace period.

Only completed Active physics steps advance time. Each step uses its completion
time for all deadlines, in mouse → player → camera → pursuit → spawn → weapon →
spawn-ordered contacts order, then commits time/HUD/evidence. Weapon kills exclude
that enemy from contact; lethal player damage aborts later contacts and commits
the final step once. Normal deadline servicing is within one executed 60 Hz tick
(about 16.67 ms simulation time). Positive sub-tick tuning and long simulated
steps permit at most one action per attacker/spawn phase; no catch-up burst.
Wall stalls add no unsimulated survival. Reaching 300 creates no victory/change.

## Prerequisites and contained commands

Use Windows PowerShell and an existing **Godot 4.7.2 Standard official stable
Windows console .exe** (PE subsystem 3). Forward+ interactive play requires a
working compatible graphics driver. No C#, packages, export templates, editor
session or production plugin is needed. Do not install or change persistent
configuration as part of these instructions.

Run from the repository root:

```powershell
Set-Location 'C:\GameDev\project-horde'
./tools/validate.ps1 -Mode All
./tools/validate.ps1 -Mode All -InfrastructureFixtures
./tools/test-validation.ps1
./tools/validate.ps1 -Mode Play
```

These are later validation/acceptance procedures, not commands executed in T049.
`All -InfrastructureFixtures` runs the full suite plus infrastructure. The
separate `test-validation.ps1` wrapper deliberately runs **Foundation scope
(13 cases)** plus infrastructure, checking restoration with initially absent TEMP.
It does not replace full All. Play/Profile do not import or run tests first:
run All successfully before interactive use on a clean checkout or after code edits.

Selection order is explicit `-GodotBin` → ignored workspace
`.cache/godot-bin.txt` → first nonempty `GODOT_BIN` in Process → User → Machine
scope, reporting absence/empty values. Inaccessible scope blocks discovery;
sandbox registry isolation can hide persistent values. Supply an existing
absolute console path when needed, without changing environment configuration:

```powershell
$GodotBin = 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
if (-not (Test-Path -LiteralPath $GodotBin -PathType Leaf)) {
    throw 'Supply the existing approved console executable on this machine.'
}
./tools/validate.ps1 -Mode All -InfrastructureFixtures -GodotBin $GodotBin
./tools/test-validation.ps1 -GodotBin $GodotBin
./tools/validate.ps1 -Mode Play -GodotBin $GodotBin
```

That is the previously validated reference installation, not a required path
on every machine. All modes/wrappers accept `-GodotBin`; an empty/invalid selected
override blocks, with no fallback. The launcher rechecks absolute path/existence,
PE console format, advertised flags, official stable 4.7.2 version and non-Mono
Standard editor capability.

After a successful explicit validation, optionally remember that approved path
for fresh sessions in this workspace only. The file contains one unquoted absolute
console path; no registry, PATH or persistent environment changes are needed:

```powershell
# From the workspace root, after All above succeeds. Preserve an existing selection.
if (-not (Test-Path -LiteralPath './.cache/godot-bin.txt')) {
    Set-Content -LiteralPath './.cache/godot-bin.txt' -Value $GodotBin -Encoding UTF8
}
./tools/validate.ps1 -Mode All -InfrastructureFixtures
```

The launcher checks selection-file containment/reparse ancestors before reading
it and revalidates the executable every run. Missing file uses environment discovery;
empty, unreadable or invalid local selection blocks without fallback. Explicit
`-GodotBin` takes precedence even when the local selection is broken. Keep the file
ignored; deleting local caches requires selecting the engine again.

Before any engine command, the launcher redirects process APPDATA/LOCALAPPDATA/
TEMP/TMP to unique ignored `.cache/validation/<session>/` directories. An isolated
compatibility-renderer probe checks actual Godot user/data/config/cache and editor
paths and writes `verified-paths.json`; project user-directory policy must match.
No game project executes before containment passes. Reparse-point escapes and
self-contained engine markers with external editor data block execution. Project
imports go to workspace `.godot/`; Profile output goes to `.cache/profile/`.
Logs, preflight fixtures and temporary output stay in `.cache/`. Existing or
absent process variables are restored in `finally`, with results recorded.
Do not launch Godot directly to bypass containment.

Missing prerequisites/unverified containment are **BLOCKED** (launcher exit 1).
A historical sandbox certificate-store error failed preflight despite child exit
0; the ledger records the authorized retry outside isolation with containment
preserved. If repeated, retain diagnostics and use the applicable execution
approval mechanism; do not suppress the error or change certificates.

Supported retry: retain the FAILED session and identify the failed subcommand
(usually `paths`), its child exit and original streams/log. Request approval through
the execution environment to run the **same launcher command** outside isolation,
then run it only after approval. The fresh retry must pass version/help and actual
path containment again before any real-project command. It creates separate evidence
and does not erase the first failure. Certificate text in either streams or the
engine log fails even at exit zero; dependent checks are explicitly UNRUN.
If approval or that execution route is unavailable, record retry BLOCKED and dependent
checks UNRUN. Do not run the binary directly, disable certificate verification,
self-elevate, silently retry, change global certificate stores or create external markers.

All executes these commands with a separate absolute `--log-file` each:

| Check | Actual engine argument shape | Default limit / override |
|---|---|---|
| Version/help | `--headless --version`, `--headless --help` | 30 s each / `-PreflightTimeoutSeconds` |
| Actual paths | `--headless --path <session-preflight> --import` | 30 s / `-PreflightTimeoutSeconds` |
| Project import/load | `--headless --path <root> --import` | 180 s / `-ImportTimeoutSeconds` |
| Every script parse | `--headless --path <root> --script <absolute-file.gd> --check-only` | 30 s per file / `-ParseTimeoutSeconds` |
| Native suite | `--headless --path <root> --script res://tests/run_tests.gd` | 120 s / `-SuiteTimeoutSeconds` |
| Normal startup | `--headless --path <root> --quit-after 120` | 30 s / `-StartupTimeoutSeconds` |
| Profile startup | Same startup arguments plus `-- --profile` | 30 s / `-StartupTimeoutSeconds` |

Import precedes parsing for class/UID resolution. Startup's 120 counts engine
iterations, not seconds. Parsing is not gameplay testing; short headless Profile
startup checks output/lifecycle, not rendered FPS/owner survival. Play uses
`--path <root>`; Profile adds `-- --profile`. Both wait for window closure with
**no automatic timeout**.

Timeout parameters accept 1–86400 seconds. Explicit retry example after diagnosing
a suite timeout: `./tools/validate.ps1 -Mode All -SuiteTimeoutSeconds 240`.
Timeout fails and terminates only the launched child; output/restoration remain
required. Infrastructure children have their own limits, including intentional
timeout; suite overrides do not change them. `-SuiteScope Foundation` excludes
gameplay execution after full authored discovery. `-RenderedProfileSmoke` adds
an optional short rendered lifecycle fixture only with `-InfrastructureFixtures`
(or the wrapper); it is not a five-minute session or performance acceptance.

Sessions retain `results.json` with exact commands/exits/outcomes and stdout,
stderr and engine logs. Infrastructure adds `infrastructure-fixtures.json` and
`infrastructure-child-results.json`. Nonzero exit, failed/empty/incomplete suite,
timeout, genuine script/parse/runtime/resource-load errors or ambiguous severity
records mean **FAILED**, even at exit zero. Dependent checks stop and are UNRUN.
Banners/progress/device information are informational. Warnings are recorded
separately; investigate criterion violations. Declared fixture faults match exact
case/source/constraint/count and assert failed encounter state; unexpected engine
errors remain failures. Play spawn failures continue simulation but invalidate
acceptance; Play exit alone does not establish a valid attempt. Profile requires
one completion receipt and intact stream/manifest/outcomes for every retained
attempt and sealed segment; missing output fails even at child exit zero.

## Actual manifest and automated coverage

`tests/case_manifest.gd` registers all 88 authored cases; `staged_entries()`
is empty. `ready_after` describes implemented prerequisites, not deferral.
The runner discovers `test_*.gd` in `tests/unit/` and `tests/integration/`
(five unit and six integration files), reconciles IDs/script paths/methods and executed IDs, uses fixed
reported seeds, requires positive assertions and explicit completion, and fails
missing/duplicate/unknown/zero/unexecuted cases. Support helpers are not case files.
Fixtures instantiate actual components/scenes with independent definitions and
cleanup. Controlled input/delta/timestamp/fault overrides are diagnostic, not
normal owner acceptance.

| Case file under tests/ | Cases / seed | Coverage |
|---|---|---|
| `unit/test_definitions.gd` | 8 / 4702001 | References/defaults, numeric/vector/geometry/camera validation, boundaries, nonmutation |
| `unit/test_runner_contract.gd` | 5 / 4702012 or 4702014 | Reconciliation, context, diagnostic declarations, prerequisites/scope and fixture seams |
| `unit/test_movement_arena.gd` | 6 / 4702014 | FR-001–004 direction/yaw/pitch/follow, inset limits, bounded selection/fallback/failure, pursuit/reachability |
| `unit/test_combat.gd` | 7 / 4702015 | FR-005–008 independent health, invalid damage, death exclusion, nearest/ties/range, weapon/contact deadlines, feedback |
| `integration/test_survival_loop.gd` | 13 / 4702016 | Fresh wiring, cap/cadence, completion deadlines/sub-tick/stalls/order/lethal commit, HUD, startup/selection/factory/partial faults |
| `unit/test_profile_capture.gd` | 9 / 4702017 | SC-006/007 boundaries/sparse data/distributions/generations/counts/endpoint/lethal/continuation/bounded late failures |
| `integration/test_defeat_restart.gd` | 9 / 4702034 | FR-010/011 result/freeze/HUD, restart controls, three cycles, repeated/stale guards, invalid restart/failure isolation |
| `integration/test_restart_evidence.gd` | 7 / 4702035 | Seal before teardown, stale generations, valid/invalid opening, shutdown/write faults, post-300 survival preservation |
| `integration/test_pause_resume.gd` | 10 / 4702042 | FR-012 Escape/inactive callbacks/frozen encounter, remaining delays, discarded input/HUD, terminal defeat |
| `integration/test_pause_profile.gd` | 8 / 4702043 | Segment flush/origin/gap exclusion, same attempt/outcomes, paused endpoint, retained diagnostics, interruption before/after 300 |
| `integration/test_technical_acceptance.gd` | 6 / 4702052 | Automatic 65-active-second HUD, two ten-real-second pauses, ten-real-second defeated freeze and three same-application input restarts, configurable eligibility and physical mapped input |

T048 previously passed 48 Phase 3B/foundation cases (3,719 assertions), 16 Phase 4
(984), and 18 Phase 5 (1,140): **82 / 5,843** total. Infrastructure's 146 assertions
are separate. This audit checks source inventory and prior evidence, without
rerunning those tests. See [tests/README.md](../../tests/README.md) for case details
and [component contracts](contracts/gameplay-components.md) for obligations.

## Proportionate validation — DX-001 Batch 5

Use the same approved contained Godot route for each command:

```powershell
# Fast: routine regression, 84 cases; four duration protocols remain pending.
./tools/validate.ps1 -Mode All -SuiteScope Fast
# Targeted: example for movement/combat/survival seams, 26 cases.
./tools/validate.ps1 -Mode All -SuiteScope Targeted -CaseGroups movement,combat,survival
# Full: complete required technical scope, all 88 cases and infrastructure.
./tools/validate.ps1 -Mode All -InfrastructureFixtures -SuiteTimeoutSeconds 240
```

All tiers import, parse every script, reconcile the complete authored manifest,
run their selected cases, and check normal/Profile headless startup. Fast omits
only `technical.hud_clock/pause_contact/pause_between/three_cycles`; Targeted
reports every omitted ID. Neither establishes omitted acceptance. Foundation is
still the limited 13-case harness scope, not gameplay acceptance. Infrastructure
is excluded unless requested. Missing prerequisites, failed/genuine errors,
blocked setup and dependent unrun checks remain explicit in evidence.

Select groups using the [impact table and exact group inventory](../../tests/README.md#dx-001-batch-5-execution-workflow).
Full is mandatory for integrated acceptance/final feature or release review,
shared lifecycle/scheduling/input changes, runner/manifest/selection/diagnostics/
launcher changes, uncertain cross-subsystem impact or wider regression recovery.
Targeted `technical` includes all six protocols; use a 240-second suite limit.
Do not shorten the 65-active-second clock, ten-real-second inactive waits or
three same-application restart cycles. Run Full after final executable edits;
repeat only for new executable changes, failures or unresolved evidence.
Documentation-only changes use static checks. Record exact commands, revision/
diff, impact, receipt paths, costs and executed/excluded/pending/blocked/failed/
unrun statuses. [Batch 5 results](../../docs/verification/dx-001-batch5.md) provide
measured examples, not performance guarantees. All manual owner steps below
remain necessary; DX-001 does not close T052 or prototype acceptance.

## Controls and Phase 6 owner journey (T052 — feedback received, closure open)

| Input | Implemented result |
|---|---|
| W/S/A/D | Camera-yaw-relative planar movement; opposing axes cancel, diagonals normalize, release stops |
| Mouse | Horizontal motion rotates yaw; upward/downward reduces/increases depression within 15–65°; synchronous follow, no smoothing/zoom |
| Escape press | Active ↔ Paused while alive; release/repress required, held/echo duplicates ignored; no Game Over resume |
| Restart click, Enter/keypad Enter or Space | Game Over only; focused button requests exactly one fresh run |
| Alt+F4 / window close | Close application; Profile shutdown writes outcomes/receipt |

No manual fire, jump, sprint, controller or settings UI exists. Pointer is
captured in Active and released in Paused/Game Over. Pause freezes encounter,
health/time/view/feedback and remaining delays while UI continues. Transitions
clear queued mouse and release movement actions: press movement afresh on resume.
Restart is hidden in Active/Paused. Defeat clears feedback and stops gameplay;
health/time, Game Over, final time and Restart remain visible. Restart rebuilds
one encounter with 100 health, center/initial view, 00:00, no old enemies, zero
IDs/failures, ready weapon/contacts and full spawn delay. Invalid startup/restart
shows diagnostics and disables simulation; failed restart discards the old
encounter. Correct definitions and relaunch; no configuration retry UI exists.

T051 has passed. Under the approved [spec acceptance methods](spec.md#acceptance-methods--dx-001-batch-1-approved-2026-10-03),
technical proof and human experience contribute separate evidence. Record actual
revision, machine/settings and results in the ledger; do not copy historical
environment details into a new run. Prior story acceptance and aggregate owner
feedback are retained, without assuming unreported action coverage or independence.

The owner journey in contained Play with documented tuning remains reproducible:

1. Use all WASD directions, rotate the view and traverse the arena/perimeter.
   Assess physical control usability, release response, camera visibility/limits,
   responsiveness, identifiable player/enemies/floor/boundaries and game feel.
2. Observe spawning and redirecting pursuit. Witness automatic hit feedback and
   a kill; take contact damage. Assess whether line/flash, target, damage and
   health/time are observable and readable during ordinary play.
3. Pause/resume during combat. Assess the Paused indication, frozen presentation,
   released/recaptured pointer, resumed input/view and encounter responsiveness.
   Check visible HUD, hidden Restart and no apparent camera jump or event burst.
4. Take lethal damage, recognize Game Over/final time and use documented Restart.
   Assess focus, actionable control and the fresh encounter presentation.
5. Record actions actually completed, observable results, control/presentation/
   responsiveness/feel concerns, omissions and whether developer intervention
   occurred. SC-004 still requires this entire named action set independently
   performed by the actual owner. Automated checks cannot substitute for it.

Codex's technical reconciliation retains the full original protocol below.
Reproducible automation may establish it without duplicate manual measurements;
if automation is insufficient, use the missing portion of this protocol as a
human fallback and report it separately from the usability journey.

| Required technical protocol (unchanged behavior/counts/durations) | Evidence obligation |
|---|---|
| Each/opposed/released input, equal-duration straight/diagonal travel, repeat after 90° yaw; pitch/fixed Y, mouse-only, actor inset/corner containment | Real-component movement/camera/arena checks; human visibility/usability above |
| First spawn at 1.5 active seconds, three ordinary opportunities with capacity, configured cap/skips/refill; redirecting pursuit | Reconcile actual cadence/containment/definition fixtures; retain all FR-004 cap and three-skip criteria |
| Nearest/tied/at/beyond-range eligibility, feedback, independent health, ready contacts with 10 damage and 1.0-second default interval, separation/re-entry/no regeneration | Map combat/health/feedback checks to every clause; all tuning remains unchanged |
| HUD after 65 completed active seconds: 01:05 within one displayed second; next-update health, fresh and inactive displays | Actual HUD value assertions; owner readability is separate |
| Contact pause and separate between-event pause: ten real seconds each, trying WASD/mouse/held Escape, frozen health/time/positions/view/feedback/deadlines, resume with preserved delays and no early/burst events | Measured monotonic elapsed duration plus exercised state/input checks; synthetic gaps/ticks alone are insufficient; repeated pause/resume coverage retained |
| Game Over: ten real seconds trying WASD/mouse/Escape, frozen encounter/final values, no resume | Measured inactive-duration/input evidence plus defeat invariants |
| Three consecutive run→defeat→restart cycles in one application, click/Enter/Space across cycles, repeated activation guards, fresh values/full spawn delay/no old actors or duplicate events | Automated integrated application/input evidence or human execution; isolated fixture resets alone cannot claim the entire protocol |

For each claimed clause record check ID/command, revision, conditions/tuning,
output path and actual passed/failed/skipped/blocked/unrun result. Existing
deterministic checks cover many invariants; Batch 1 did not establish their
complete real-duration/input coverage. The executed Batch 3 audit/results live in the
[Batch 3 clause map](../../docs/verification/dx-001-batch3.md). Reproduce its full
native checks with `./tools/validate.ps1 -Mode All -InfrastructureFixtures -SuiteTimeoutSeconds 240`
through the documented approval-mediated contained route. The per-run watchdog
allows the unchanged 65-active-second and three ten-real-second checks; launcher
defaults and acceptance thresholds are unchanged. T052 remains open pending
sufficient combined evidence.
Failures, missing independent participation and unverified clauses stay
outstanding. Later tuning/behavior corrections require affected checks rerun.
No forced fixtures or UI are added by DX-001 Batch 1; see the
[DX-001 handoff](../../docs/development/dx-001-autonomous-qa.md).

## Profiling preparation and execution (T053 prepared; owner execution pending)

Start with the [owner procedure and session record](../../docs/verification/prototype-profile.md#start-the-owner-session-after-review).
T053 documentation is prepared. Its actual 30-active-second warm-up and clean
relaunch remain pending; T054–T056 are unrun in this batch. The method below is
unchanged. T051/T052 are complete per the current task/ledger closure records;
earlier T052-open notes above describe historical checkpoints.

Use [fixed plan conditions](plan.md#measurement-conditions-fixed-before-profiling):
standalone debug without editor/debugger, Forward+ 1920×1080, 100% scale,
AA/VSync/frame cap/shadows/SSAO/SSIL/glow off, one directional light, 60 Hz physics.
Before a later authorized session, complete the session record in
`docs/verification/prototype-profile.md` with actual engine/OS/GPU/driver/hardware, Git revision, clean/diff state,
all tuning, conditions and deviations. Retain a reproducible source snapshot;
historical capture provenance is still unresolved. Main records engine/OS/debug/
renderer/viewport/cap/VSync/physics/tuning, but `source_revision`, `warmup` and
`owner_acceptance` are instructions, not verified metadata. Driver and warm-up
are not automatically established.

```powershell
git rev-parse HEAD
git status --short
./tools/validate.ps1 -Mode Profile
# Supply -GodotBin $GodotBin if discovery is unavailable.
```

Profile uses the same gameplay with sampling, no cheats/disabled combat. Warm up
**30 active seconds in a separate attempt**, then close/relaunch for a clean
measured attempt from zero (there is no living-run Restart). Keep vulnerability
and default cap 50 unless accepted different tuning is recorded. Retain failures.
The owner reaches >=300 completed uninterrupted physics seconds alive, then
observes advancing time, responsive movement/view, unchanged tuning/vulnerability
and a later scheduled spawn opportunity (success or expected full-cap skip) in
the same attempt. Record simulation timestamps and attacks when eligible;
no forced post-endpoint attack is required without eligibility. Play continues
normally until defeat; record that observation for full survival review. Preserve
valid alive-window success if later death prevents some continuation observations,
leaving them outstanding. Never splice attempts or infer acceptance from 05:00.

Main samples `RenderingServer.frame_post_draw` with monotonic CPU wall time,
audits successive engine draw IDs and owns one helper only in Profile. Normal
Play has no sampler. Counts are sampled at one-second completed-simulation
opportunities with both clocks. Each active segment writes an `attempt-*.json`
manifest and `.json.frames.bin` lossless little-endian float64 stream to
`.cache/profile/`; shutdown writes `.json.outcomes.json` and emits
`HORDE_PROFILE_RESULT`. All retained attempts/segments are checked by the launcher.
Working buffers use 4,096 timestamps (32 KiB payload plus temporary encoding),
flush during capture and at endpoint/defeat/pause, and release raw/count buffers
after closure. Endpoint closure follows combat and the committed step reaching
`active_time >= 300`, never a wall timer or rounded HUD.

For an uninterrupted window t0 is ready encounter wall time before its first
step, t1 the endpoint wall time, W = t1 − t0. Report simulation duration, tick
count and W separately. Whole-window observed FPS is callbacks in (t0,t1] / W,
including startup/boundary stalls. Separately report full successive intervals
wholly within [t0,t1], their count/coverage and count/sum(intervals) FPS. From full
intervals report reciprocal-longest-interval minimum FPS, empirical nearest-rank
p50/p95/p99/max frame ms and >16.67/>33.33 ms stalls. Use the complete raw stream
and exact source-microsecond frequencies without decimation. Report initial/final
partial gaps; do not invent prorated frames. Without full intervals, minimum/
distributions remain unavailable with reasons; two callbacks yielding one full
interval suffice for interval statistics.

Report count min/max/mean/timestamps, callback audit and sampler overhead
(callback/step/chunk writes/final flush; excludes endpoint statistics/JSON).
Available endpoint monitors: process/physics seconds, static memory, object count
and draw calls. These are CPU frame-loop statistics and snapshots, not GPU
presentation/timing or per-system bottleneck attribution. Unestablished GPU metrics
or bottleneck causes must remain unavailable/unverified.

Pause closes a segment; resume opens a new wall origin without bridging inactive
time. `segments`, `active_capture_duration` and monotonic `interrupted` preserve
history. **Any pause, including after 300, disqualifies the full uninterrupted
attempt.** Later pause never reopens the sealed endpoint stream. Defeat/restart/
shutdown seal and retain outcomes; fresh counters cannot erase old failures.
Report survival-window, continuation, capture, interruption and invalidity
separately. Unexpected spawn failures consume/count/report one opportunity and
invalidate the whole attempt, including continuation; cap-full skips do not.
Required capture/output failures leave profiling outstanding and fail the launcher
even at engine exit zero. `qualifies_attempt()` is only a technical candidate
check; conditions/source provenance/owner evidence still require verification.

Summarize raw evidence, boundaries, conditions/deviations, partial/failed attempts
and unavailable metrics in the future profile report; record FR/SC observations
in the gameplay ledger. No numerical prototype FPS threshold is introduced.
**SC-005 remains future/unverified** and requires its own representative 200-enemy
scenario and measurement plan. Never extrapolate the cap-50 baseline.

## Batch 1 audit and outcomes

T049 checks files, parameters, resource values, references, case inventory and
prior evidence against repository source. The companion
[asset audit](../../docs/asset-provenance.md) records runtime mesh creation,
materials, inherited font and replacement constraints. No executable asset,
gameplay, tuning, expectation or profiling semantics changed. Full engine
validation, integrated owner acceptance and a new five-minute session are
**UNRUN in this batch**, reserved for later tasks. Distinguish passed/failed/
skipped/blocked/unrun; do not promote historical evidence to new acceptance.
