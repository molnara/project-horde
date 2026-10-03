# Implementation Plan: Core Gameplay Prototype

**Branch**: `001-core-gameplay-prototype` | **Date**: 2026-10-02 | **Spec**: [spec.md](spec.md)

**Input**: `specs/001-core-gameplay-prototype/spec.md`, its clarified product policies and owner-approved A–G technical baseline.

**Status**: Technical planning baseline approved with owner refinements incorporated. A–G are adopted design decisions; requirements-quality review is complete. Gameplay, tooling, tests and measurements remain unimplemented/unrun. This operation generates no tasks; task generation is the separate next phase.

## Summary

Build one directly playable flat arena in Godot 4.7.2 Standard Edition using typed GDScript, original primitive meshes, and text scenes/resources. A run coordinator composes player, camera, arena, spawner, automatic weapon, enemy registry, and HUD. One active-time clock provides deterministic spawn, weapon, and independent enemy-contact timing. Entities move on XZ without blocking one another; containment remains separate from combat. Immutable definitions provide tuning; each entity owns its mutable health and deadlines.

Deliver the P1 movement/camera/spawn/combat/HUD loop first, then defeat/restart and pause/resume, followed by complete acceptance evidence and the actual five-minute survival profile. No save system, progression, additional content, third-party plugins, production assets, or benchmark harness is included.

## Technical Context

**Language/Version**: Typed GDScript; Godot 4.7.2 Standard Edition, no C#.

**Primary Dependencies**: Godot built-ins only: Node3D, Camera3D, MeshInstance3D, Resource, CanvasLayer/Control, signals, InputMap, SceneTree, FileAccess, and built-in monitors/profiler. PowerShell for workspace-contained validation. No package or extension required.

**Storage**: Diffable `.gd`, `.tscn`, `.tres`, `project.godot`; read-only definitions; memory-only run state. Generated validation/profile output in ignored `.cache/`; summarized evidence and provenance in `docs/`.

**Testing**: Native headless GDScript assertion runner with nonzero failure exit; engine import, per-script parse and scene startup; manual controls/visual/playfeel acceptance; real rendered five-minute profiling. Environment recheck on 2026-10-02 verified persistent user-scope `GODOT_BIN` resolves to an existing Windows console executable (PE subsystem 3). Executing that binary with `--headless --version` returned `4.7.2.stable.official.ed1daf0bf`, exit 0, matching the approved engine version. The current process has not inherited the variable; use process scope first, then persistent user/machine scope when absent. Sandbox registry access may hide persistent scope; report that limitation explicitly. No Godot project exists yet, so project import, parsing, tests and startup remain unrun. No installation is needed or authorized by this plan.

**Target Platform**: Windows 10 IoT Enterprise LTSC 2021, keyboard/mouse; reference i7-12700KF, 32 GB RAM, RTX 3080 10 GB VRAM. Supplied hardware/OS reference, not locally verified.

**Project Type**: Offline single-player third-person 3D desktop game.

**Performance Goals**: SC-007 records actual five-minute playtest performance without a numerical prototype pass threshold. SC-005 remains 60 FPS with 200 representative active enemies, approximately 16.67 ms/frame; future benchmark, explicitly unverified, not a prototype acceptance gate.

**Constraints**: One weapon/type/flat arena; original placeholders; independent definitions/state; inclusive XZ eligibility; spawn-order ties; no entity blocking; workspace-contained writes; no gameplay implementation during planning.

**Scale/Scope**: One player; zero initial enemies; configurable live cap default 50 with no hard-coded upper limit preventing future 200-enemy testing; fixed spawning; unlimited survival until death; three run states with HUD overlays.

**Research topics**: Active clock/order, cooldown persistence, cap scheduling, safe spawning, containment, camera conventions, tuning validation, test harness, workspace-safe launch and profile protocol. Owner-approved policies and adopted technical decisions are recorded below and in [technical.md](checklists/technical.md). Defaults are in [data-model.md](data-model.md). Engine location and version were verified during the recorded prior preflight; project/tooling implementation and filesystem confinement remain validation prerequisites. The completed technical checklist establishes documentation readiness only, not executed acceptance.

## Constitution Check

See [technical.md](checklists/technical.md) for the final 36-item requirements-quality review. Design PASS is supported by the reconciled A–G baseline and does not establish working gameplay, executed acceptance or performance compliance. No constitutional exception is proposed.

Pre-research review used spec and constitution v1.0.0; post-design review uses these artifacts. PASS means design compliance, not gameplay acceptance.

| Principle | Pre-research | Post-design evidence/result |
|---|---|---|
| I Modular Architecture | PASS | PASS: explicit coordinator wiring, narrow component methods/signals, no global singleton or unrelated tree searches |
| II Data-Driven Gameplay | PASS | PASS: validated Resource definitions; separate instance health and deadlines |
| III Reusable Scenes/Resources | PASS | PASS: composable player/enemy/camera/HUD; one maintained enemy behavior; read-only definitions |
| IV Horde Performance | PASS | PASS: bounded O(N) targeting/contact, actual profile protocol, future target preserved; no unmeasured pooling |
| V Automated Validation | PASS | PASS: import/parse/tests/startup plus manual controls and profile; runtime checks currently unrun |
| VI Explicit Acceptance | PASS | PASS: existing FR/SC mapped to boundary fixtures and reproducible manual checks |
| VII Playable Vertical Slices | PASS | PASS: integrated P1 before dependent P2; foundations limited to slice |
| VIII Placeholder Assets First | PASS | PASS: original primitives and simple feedback; provenance ledger required |
| IX Necessary Complexity | PASS | PASS: built-ins/native runner; no plugin, service, navigation mesh, projectile/crowd framework |
| X Version-Control-Friendly Content | PASS | PASS: text assets, required UID files tracked, generated cache/raw output excluded |
| XI Accurate Documentation | PASS | PASS: planned files/commands explicitly labeled; implementation updates evidence/provenance |
| XII Honest Reporting | PASS | PASS: passed/failed/skipped/blocked/unrun outcomes; diagnostics inspected with exit codes |
| XIII Workspace Boundaries | PASS | PASS: process path isolation and actual-path verification before engine/editor use |
| XIV Original Creative Identity | PASS | PASS: original geometry/colors, no copied distinctive content |

No violations or constitutional exceptions proposed. Spec's future-benchmark distinction preserves the target without establishing compliance.

## Project Structure

### Documentation (this feature)

```text
specs/001-core-gameplay-prototype/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── gameplay-components.md
│   └── player-interface.md
├── checklists/requirements.md
└── tasks.md                  # next phase; not generated by this command
```

### Source Code (repository root)

Proposed paths; no gameplay scaffolding created during planning.

```text
project.godot
scenes/
├── main.tscn
├── arena.tscn
├── player.tscn
├── enemy.tscn
├── camera_rig.tscn
└── hud.tscn
scripts/
├── run/                      # coordinator, schedule, live registry
├── actors/                   # player input/movement, enemy pursuit
├── combat/                   # health, automatic weapon
├── arena/                    # containment, valid spawning
├── camera/                   # yaw/pitch, following
├── ui/                       # HUD and overlay intent
└── data/                     # definition classes, validation
resources/definitions/        # player, enemy, weapon, arena, run .tres
tests/
├── run_tests.gd
├── unit/
└── integration/
tools/validate.ps1            # engine/path checks and validation modes
docs/
├── asset-provenance.md
└── verification/
    ├── core-gameplay.md
    └── prototype-profile.md
.cache/                      # ignored paths/logs/raw profile data
```

**Structure Decision**: One root Godot project; reusable scenes and explicit responsibility boundaries. Preserve `.specify/`, `.agents/`, spec and checklist. Contracts describe game/UI boundaries, not a network service.

## Phase 0 — Research outcome

[research.md](research.md) records official documentation, decisions, alternatives and environmental limits. One coordinator-driven 60 Hz physics update and active-time deadlines replace independent timers. Node3D planar movement plus an arena containment function meets this obstacle-free nonblocking slice. No pooling/spatial partitioning before measured need.

## Phase 1 — Design outcome

- [data-model.md](data-model.md): exact default tuning, definitions, validation, ownership and transitions.
- [contracts/gameplay-components.md](contracts/gameplay-components.md): dependency injection, ordering, events and failure behavior.
- [contracts/player-interface.md](contracts/player-interface.md): controls, camera, HUD and overlays.
- [quickstart.md](quickstart.md): future runnable validation modes, acceptance mapping, manual scenarios and profiling.

### Delivery order for task generation

1. Minimal project, validated resources, original primitive scenes and safe validation launcher; prove import/parse/startup.
2. Runnable P1: movement/camera/containment, spawning/pursuit, health/weapon/contact, HUD. Test exact tuning/distance/timing boundaries with small fixtures.
3. P2 defeat/restart: lethal short-circuit, immediate registry removal, fresh conditions and repeat activation guard.
4. P2 pause/resume: preserve clock/deadlines/view, reject echoed input, manage mouse capture.
5. Verify all FR/edge cases, three restart cycles, owner playtest and five uninterrupted active minutes; profile that actual run. Unavailable checks remain outstanding.

### Measurement conditions fixed before profiling

SC-007 uses reference Windows/hardware above; record actual OS/GPU/driver/engine and deviations. Standalone debug game without editor/debugger, Forward+ renderer, 1920×1080 content resolution, 100% 3D scale, MSAA/FXAA/TAA off, VSync off, uncapped FPS, one directional light, shadows/SSAO/SSIL/glow off. Physics 60 Hz. Record resource values and source revision.

Warm up for 30 active seconds in a separate attempt, then begin a clean fresh run. Sample the actual SC-006 run from active time zero through 300 seconds, including normal startup effects. No pause during that attempt; continue beyond five minutes to prove no timed ending. Failed attempts are retained, never spliced into success.

Let `t0` be monotonic wall time when the fresh validated Active encounter is ready, before its first simulated step. Let `t1` be wall time at completion of the first executed step with committed `active_time >= 300`; record exact simulation duration, completed tick count and whole-window wall duration `W = t1 - t0`. The endpoint is determined after that step's combat/result, never by wall time or the rounded HUD. A lethal result is not automatically successful survival.

Count observed frame-loop callbacks with timestamps in `(t0, t1]`; whole-window average actual frame-loop FPS is `callback_count / W`. This includes all active wall time, including startup and boundary stalls. Separately report full successive frame intervals wholly contained in `[t0,t1]`: their coverage duration, interval count and `interval_count / sum(interval_seconds)` as full-interval FPS. The first timestamp alone is not a full interval; never invent prorated frames.

Use full intervals for minimum instantaneous FPS (reciprocal maximum interval), p50/p95/p99/max frame ms and >16.67/>33.33 ms stall counts. Separately report initial/final partial wall segments and their stall durations so excluded interval fragments cannot conceal active stalls. Retain adjacent boundary timestamps only to describe those boundaries; do not include out-of-window work in the average. If no full interval exists, report whole-window count/duration plus the uncovered wall segment, and mark full-interval distributions/minimum unavailable with reasons and outstanding verification. Two callbacks yielding one full interval suffice to compute those statistics; do not silently drop sparse samples.

Sample live-registry enemy counts at one-second completed-simulation opportunities, carrying both simulation and wall timestamps; report observed min/max/mean. Diagnostic paused runs use separate segments excluding inactive time; the qualifying owner run is uninterrupted. Label samples as CPU-observed frame-loop timing, not GPU presentation/timing; report available CPU/physics/render monitors, instrumentation overhead and unavailable metrics. Warm-up is 30 active seconds in a separate attempt; record all preselected conditions, actual tuning, source revision and deviations. No numerical prototype FPS threshold or future benchmark compliance is inferred.

Buffer/write raw evidence under ignored `.cache/` using the lossless bounded chunk strategy below; summarize conditions/method/results in `docs/verification/prototype-profile.md`, and retain unsuccessful attempts. A separate profiler diagnosis run may investigate bottlenecks. SC-005 still requires its future representative 200-enemy scenario/build/settings/warm-up/sampling plan; no benchmark implementation or result is claimed.

**Phase 3B profiling correction — 2026-10-03:** The owner run exhausted the
one-million-entry buffer at about 3,389 callbacks/sec under the required uncapped
settings. Bound working memory rather than total evidence: spool every ordered
float64 wall timestamp in 4,096-entry chunks (32 KiB timestamp payload plus a
32 KiB temporary byte encoding) into an attempt-specific `.frames.bin` inside
ignored `.cache/`. Flush the final tail at the unchanged completed-simulation
endpoint, then write the JSON manifest/summary and shutdown outcomes. Chunk I/O
runs during capture; include it in sampler overhead and measured wall intervals.
This deliberately corrects the former all-writes-after-sampling implementation
choice without changing any acceptance gate, scenario, FPS setting or sample
selection. Disk use scales at eight bytes per callback (about 8.1 MB for 300 s at
the owner's observed rate). Write/read/flush/count faults preserve partial
evidence, diagnose incomplete capture and fail validation, never qualify it.

Compute endpoint statistics by sequentially reading raw timestamps. Use exact
source-clock microsecond interval frequency counts and empirical nearest-rank
percentiles; no decimation, rolling overwrite, millisecond bins or approximate
quantiles. Raw float64 timestamps remain unchanged. With positive integer
microsecond intervals totaling U microseconds, k distinct values require at least
k(k+1)/2 <= U, bounding histogram growth by measured duration rather than callback
volume (under 24,495 distinct intervals in 300 wall seconds). Preserve all
whole-window, boundary-gap, stall and sparse-evidence semantics. Audit callback
counts against successive `Engine.get_frames_drawn()` IDs; retain and report any
repeat/gap. The launcher requires a successful application completion receipt,
manifest, raw-stream byte count and outcomes sidecar. Short startup capture
success remains distinct from owner survival and SC-007 acceptance.

## Approved technical review decisions — 2026-10-02

References below: S = [specification](spec.md), D = [data model](data-model.md), G = [gameplay component contracts](contracts/gameplay-components.md), I = [player interface](contracts/player-interface.md), Q = [quickstart](quickstart.md). They describe planned behavior; none establishes implementation or executed verification.

The product owner resolved three policies, recorded in S §Clarifications / §Scope and Validation Constraints and G §Failure contract:

1. SC-006 ends its qualifying window only after 300 completed, unpaused physics simulation seconds. Stalls/pauses never credit unsimulated survival time. Scheduling remains simulation-based; profiling records monotonic wall-clock duration and actual FPS separately.
2. Unexpected spawn selection/instantiation failure consumes the opportunity, reports diagnostics and increments the run failure counter while simulation continues. There is no catch-up. Any such failure invalidates that acceptance attempt, including its SC-006/007 qualification. Full-cap skips are expected, not failures. Retain failed-run evidence; reset the counter only for a fresh run. Fault-injection fixtures assert this policy without qualifying their faulted encounter as owner acceptance.
3. Invalid startup/restart configuration blocks simulation with actionable diagnostics. Failed restart discards the defeated encounter. Correct data and relaunch; no in-application retry is required.

These resolve the owner policy questions without revising constitution v1.0.0, its performance target, milestone scope or initial tuning. The owner subsequently approved A–G with lifecycle, timing, continuation and diagnostic refinements; the adopted baseline follows. Codex owns documentation reconciliation and later technical verification. This operation does not authorize implementation or tasks.

## Adopted technical resolutions — A–G

**Approved by the product owner, 2026-10-02.** These decisions supersede the former pending proposals and incorporate the subsequent review recommendations/refinements. Gameplay remains planned. The complete operative contracts are in the data model, component/player interfaces and quickstart; this section records rationale and scope.

### A. Profile lifecycle — CHK001 / CHK020

Main creates/wires one capture helper only in Profile mode and owns its disposal; the coordinator explicitly opens/closes generation-tagged attempts. Normal Play has no frame sampler, but retains the per-run spawn-failure counter. Keep the helper independent of gameplay behavior and reject stale-generation samples/callbacks.

During capture, spool every frame timestamp losslessly in bounded 4,096-entry float64 chunks under ignored workspace `.cache/`, counting chunk I/O as sampler overhead. At 300 completed simulation seconds, close the five-minute frame/count stream, flush its final tail and write the JSON manifest/summary after sampling; keep only attempt/continuation/failure metadata afterward so unlimited survival does not create an unlimited frame buffer. Compute exact source-microsecond interval frequencies from the complete raw stream without dropping samples; see plan.md, Phase 3B profiling correction. Required stream/manifest/outcomes failures leave profiling outstanding and fail the launcher even at engine exit zero. Close diagnostic segments on pause and reopen the origin on resume without bridging inactive wall time. Defeat closes any unfinished segment. Before restart teardown, retain/seal the old attempt and its actual outcomes; open fresh buffers only after new definitions validate. On shutdown, Main writes remaining evidence then disposes the helper. Required-output write/capture failures leave profiling outstanding and are reported, never silently successful.

Record separately: survival-window outcome, continuation outcome, profile-capture outcome, and acceptance invalidity from unexpected spawn failures. Reaching 300 seconds is not full attempt acceptance. A 300-second window completed alive with normal tuning can retain successful survival evidence if later death prevents continuation observations. Full attempt acceptance requires that survival evidence, all required continuation evidence, successfully captured required profiling evidence, and zero unexpected spawn failures throughout the attempt, including continuation. Any unavailable required verification remains outstanding; recording its absence alone does not satisfy it. Later spawn failures update the attempt's invalidity even if its five-minute buffer is already closed. Feature acceptance additionally requires all prototype gates, not just this attempt. No worker, singleton, save system or new UI is introduced.

### B. One coordinated update — CHK003 / CHK034

One coordinator performs state intent → compute completion timestamp → consume active mouse input/apply yaw/pitch → player movement → camera follow → enemy pursuit → due spawn → weapon → contacts in spawn order → commit completed time → feedback/HUD/evidence presentation. Components own their behavior and receive narrow references; actors/camera/weapon do not independently advance gameplay in process callbacks. Use the updated yaw for same-step WASD. Feedback expires at attack completion time plus configured duration, freezes on pause and clears on defeat. Lethal damage aborts later gameplay; publish the already determined final step timestamp without another simulation advance. SceneTree stays processing for UI; inactive updates handle only state/overlay intents and clear pending input on transitions.

### C. Completion-time deadlines — CHK006

At the beginning of an Active physics step, let `t_begin = active_time` (the last completed step) and `t_end = t_begin + delta`, where delta is the duration actually simulated by that step. **All spawn, weapon and contact deadlines are evaluated against completion time `t_end`, never `t_begin`**, after movement and in the documented order. These events are logically timestamped at `t_end`; commit `active_time = t_end` once the step finishes, including a deliberately short-circuited lethal step. No wall-clock stall duration is injected into delta. A paused/inactive update contributes no simulation time.

Use `t_end >= deadline` with no early-trigger epsilon. Spawn deadlines are integer opportunity indices multiplied by the configured interval; service the currently pending indexed opportunity at most once, then consume any other crossed opportunities without attempting them and advance to the first multiple strictly greater than `t_end`. A cap skip or unexpected failure consumes the opportunity; crossed opportunities never accumulate. Weapon/contact deadlines advance only after an actual attack to `t_end + interval`; no eligible target/contact preserves readiness. Each attacker performs at most one attack per step.

“Immediately” is the first eligible contact phase; “next gameplay update” is no later than the next executed Active step. At normal 60 Hz, deadline servicing is late by at most one physics tick (approximately 16.67 ms) in simulation time, not a wall-time latency guarantee. Positive sub-tick intervals remain valid but are serviced at most once per step; report effective cadence. Consecutive attacks are never closer than the configured interval. Persistent overlap never bypasses readiness even if a deliberately small interval permits one attack each tick. Floating comparison just below a deadline waits until the next step; use representable before/at/after fixtures. HUD rounding never determines readiness or the 300-second endpoint.

### D. Bounded pursuit — CHK024

Take the XZ vector to the already moved player; advance by `min(speed * delta, remaining_distance)` then apply existing radius-inset arena containment. Coincidence produces no motion. Validate `contact_distance² >= 2 * max(enemy_radius - player_radius, 0)²` together with the existing strict spawn half-diagonal bound. This preserves FR-004 contact reachability at player-inset corners with unequal radii and diagnoses incompatible definitions without enlarging contact or changing default tuning. Test equality/unequal-radius/corner reachability. No physical blocking, navigation or separation is added.

### E. Whole-window wall-time evidence — CHK027

Let `t0` be monotonic wall time when the fresh validated Active encounter is ready, before its first simulated step. Let `t1` be wall time at completion of the first executed step with committed `active_time >= 300`; record exact simulation duration, completed tick count and whole-window wall duration `W = t1 - t0`. The endpoint is determined after that step's combat/result, never by wall time or the rounded HUD. A lethal result is not automatically successful survival.

Count observed frame-loop callbacks with timestamps in `(t0, t1]`; whole-window average actual frame-loop FPS is `callback_count / W`. This includes all active wall time, including startup and boundary stalls. Separately report full successive frame intervals wholly contained in `[t0,t1]`: their coverage duration, interval count and `interval_count / sum(interval_seconds)` as full-interval FPS. The first timestamp alone is not a full interval; never invent prorated frames.

Use full intervals for minimum instantaneous FPS (reciprocal maximum interval), p50/p95/p99/max frame ms and >16.67/>33.33 ms stall counts. Separately report initial/final partial wall segments and their stall durations so excluded interval fragments cannot conceal active stalls. Retain adjacent boundary timestamps only to describe those boundaries; do not include out-of-window work in the average. If no full interval exists, report whole-window count/duration plus the uncovered wall segment, and mark full-interval distributions/minimum unavailable with reasons and outstanding verification. Two callbacks yielding one full interval suffice to compute those statistics; do not silently drop sparse samples.

Sample live-registry enemy counts at one-second completed-simulation opportunities, carrying both simulation and wall timestamps; report observed min/max/mean. Diagnostic paused runs use separate segments excluding inactive time; the qualifying owner run is uninterrupted. Label samples as CPU-observed frame-loop timing, not GPU presentation/timing; report available CPU/physics/render monitors, instrumentation overhead and unavailable metrics. Warm-up is 30 active seconds in a separate attempt; record all preselected conditions, actual tuning, source revision and deviations. No numerical prototype FPS threshold or future benchmark compliance is inferred.

### F. Separate survival and continuation outcomes — CHK016

Separate the completed 300-second survival window from continuation verification. In the same normal owner attempt, record committed simulation time above 300, responsive movement/view, unchanged tuning/vulnerability and at least one later scheduled spawn opportunity (successful or expected full-cap skip). Record their simulation timestamps. Do not require a post-endpoint owner attack when no target is eligible; deterministic fixtures spanning 300 must demonstrate unchanged state/tuning and continued eligible weapon/contact scheduling, and owner attacks are recorded when eligibility occurs. No fixed additional survival duration, cheats or forced owner-run fixture is added.

If death occurs after valid completion of the survival window but before all continuation observations, preserve the successful survival-window result and any captured five-minute profile; mark the unobserved continuation clauses outstanding. Do not concatenate attempts or claim full SC-006/attempt acceptance. An unexpected spawn failure invalidates acceptance even if survival or profile observations have been collected; preserve those observations honestly. GameOver naturally ending a later run does not itself invalidate earlier survival evidence.

### G. Deterministic suite and diagnostic classification — CHK032 / CHK033

Use the native assertion runner with one explicit manifest of required case IDs, case-script paths and FR/edge-case mappings. Enumerate designated case files under `tests/unit/` and `tests/integration/`, distinguish runner/support helpers explicitly, and reconcile manifest/discovery/executed IDs: missing, duplicate, unregistered, unexecuted or zero cases fail. Use isolated definition copies, fixed reported RNG seeds, real component/scene assertions and scene/callback cleanup per case. Include deadline before/at/after checks at step completion, sub-tick intervals, pursuit/radius boundary cases, simultaneous mouse/movement, failure-counter isolation, continuation crossing and profile reset/boundaries.

Failure means failed assertions, nonzero process exit, genuine script/parse/runtime/resource-load errors, incomplete execution, or timeout. Inspect recognized diagnostic severity/records even on exit zero; do not fail merely because stdout/stderr is nonempty or contains an arbitrary word such as “error.” Engine banners, progress, renderer/device information and normal logs are informational. Record warnings separately; escalate only warnings that demonstrate violation of a required criterion, with a stated reason. Preserve original diagnostics and command/exit/outcome. Validate the classifier with failure records and harmless-output fixtures for the approved executable's format; ambiguous diagnostics require explicit investigation, never an unsupported pass.

Expected application-level configuration/spawn diagnostics in fault-injection cases are matched by declared case/source/constraint/count and asserted along with the required state/counter; they do not turn that correctly asserted fixture into a failed suite. Genuine unexpected engine/script exceptions remain failures. The deliberately faulted gameplay attempt remains invalid for owner acceptance. No broad engine-error suppression or informational-output failure rule is allowed.

The contained PowerShell launcher has explicit configurable noninteractive limits: version/help 30 s, clean import 180 s, each-script parse 30 s, complete suite 120 s, main startup 30 s. A timeout fails and terminates only its launched child; preserve diagnostics and restore environment in `finally`. Missing prerequisites/unverified confinement are blocked. Document overrides and rerun rather than silently extending a hanging check. Interactive Play/Profile has no automated timeout. These are operational limits, not gameplay/performance gates; no external test dependency is required.

### Final review and scope boundaries

All seven resolutions and owner refinements are propagated across specification, research, model, interfaces and quickstart. No outstanding product-policy or architectural approval is required for task generation. Runtime implementation/validation, confinement proof, initial tuning balance, owner controls/visual/game-feel acceptance and actual profiling remain later verification work. Preserve all FR-001–FR-012, the existing milestone scope and constitution v1.0.0. No new dependency, speculative subsystem or task file is introduced by this review.

## Complexity Tracking (unchanged)

None. No violations or added dependencies requiring justification.
