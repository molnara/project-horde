# Implementation Plan: Core Gameplay Prototype

**Branch**: `001-core-gameplay-prototype` | **Date**: 2026-10-02 | **Spec**: [spec.md](spec.md)

**Input**: `specs/001-core-gameplay-prototype/spec.md`, including its five clarification decisions.

**Status**: Phase 0 research and initial Phase 1 design documented. The three owner-approved technical-review decisions below are incorporated; remaining technical resolutions are proposals pending review. Gameplay, tooling, tests, and measurements are not implemented or executed. Task generation is not authorized by this review.

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

**Research topics**: Active clock/order, cooldown persistence, cap scheduling, safe spawning, containment, camera conventions, tuning validation, test harness, workspace-safe launch and profile protocol. Owner-approved policies and remaining technical proposals are distinguished below and in [technical.md](checklists/technical.md). Defaults are in [data-model.md](data-model.md). Engine location and version were verified during the recorded prior preflight; project/tooling implementation and filesystem confinement remain validation prerequisites. Pending proposals mean technical design review is not complete.

## Constitution Check

The earlier design PASS entries below are not a claim that all technical checklist questions are closed. See [technical.md](checklists/technical.md) for the current item-by-item review and the proposal set below for remaining documentation gaps. No constitutional exception is proposed.

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

Capture rendered-frame monotonic wall-time intervals and enemy counts. Compute actual average FPS using the measured wall-time duration of the counted frame intervals, never by dividing frame count by 300 simulation seconds. Record completed simulation duration and actual elapsed wall-clock duration separately, retaining active-play stalls. Report 1000 / maximum full frame interval in milliseconds for minimum instantaneous FPS; p50/p95/p99/max full frame times, >16.67 ms and >33.33 ms frame counts; one-second enemy-count min/max/mean and observed stalls. Initialize/reset the sampling origin at run start/resume to exclude paused intervals. Physics delta/smoothed FPS alone cannot establish distributions. Exact endpoint and partial-interval handling is proposed below, not yet settled.

Label frame-loop samples as CPU-observed timing, not GPU measurements. Capture built-in CPU/physics/render monitors where available; diagnose bottlenecks with a separate built-in-profiler run if needed and report overhead/missing GPU metrics. Buffer samples, write raw data inside ignored `.cache/`, summarize in `docs/verification/prototype-profile.md`. No new numerical acceptance threshold. Future SC-005 needs its own 200-enemy scenario/build/settings/warm-up/sampling plan; no benchmark implementation or result here.

## Approved technical review decisions — 2026-10-02

References below: S = [specification](spec.md), D = [data model](data-model.md), G = [gameplay component contracts](contracts/gameplay-components.md), I = [player interface](contracts/player-interface.md), Q = [quickstart](quickstart.md). They describe planned behavior; none establishes implementation or executed verification.

The product owner resolved three policies, recorded in S §Clarifications / §Scope and Validation Constraints and G §Failure contract:

1. SC-006 ends its qualifying window only after 300 completed, unpaused physics simulation seconds. Stalls/pauses never credit unsimulated survival time. Scheduling remains simulation-based; profiling records monotonic wall-clock duration and actual FPS separately.
2. Unexpected spawn selection/instantiation failure consumes the opportunity, reports diagnostics and increments the run failure counter while simulation continues. There is no catch-up. Any such failure invalidates that acceptance attempt, including its SC-006/007 qualification. Full-cap skips are expected, not failures. Retain failed-run evidence; reset the counter only for a fresh run. Fault-injection fixtures assert this policy without qualifying their faulted encounter as owner acceptance.
3. Invalid startup/restart configuration blocks simulation with actionable diagnostics. Failed restart discards the defeated encounter. Correct data and relaunch; no in-application retry is required.

These resolve the owner policy questions without revising the constitution, its performance target, milestone scope, or initial tuning. Codex owns documentation reconciliation and later technical verification; the product owner owns approval of the following pending proposal set. Nothing here authorizes implementation or tasks.

## Proposed resolutions for remaining technical gaps

**Status: proposals pending review, not adopted contracts.** The existing approved design remains authoritative until these proposals are accepted and propagated into D/G/I/Q. Keeping a proposal documented does not satisfy its checklist item. The proposals add no dependency, gameplay feature, settings screen, retry UI, crowd system, or benchmark harness.

### A. Profile lifecycle — CHK001 / CHK020

Main creates and wires one diagnostic capture helper only in Profile mode; the coordinator explicitly opens/closes attempts through its narrow interface. Attempt buffers, frame origin, counts and failure diagnostics carry `run_generation`. Before restart teardown, seal the prior attempt as successful, unsuccessful or invalid and retain its buffered/raw evidence under ignored workspace `.cache/`; start fresh buffers only after new definitions validate. Defeat closes active sampling, pause closes the current wall-time segment, and resume opens a new origin without bridging the pause. Stale-generation samples/callbacks are rejected. Main disposes the helper on application shutdown after writing buffered output; normal Play creates no sampler. Failure to write required evidence is reported and leaves verification outstanding, never silently successful. No background worker, singleton or persistence system is needed.

### B. One coordinated update — CHK003 / CHK034

Use coordinator-owned physics work; actors/camera/weapon do not independently advance gameplay in `_process` or `_physics_process`. Input handling only records discrete state intents and accumulates active mouse motion. At each update: handle state intents first; if still Active, compute step scheduling time, consume queued mouse motion once and apply bounded yaw/pitch; read movement with that updated yaw; move player; follow its new position; move enemies; consume due spawn; weapon; contacts in spawn order; commit completed time; expire/present feedback and HUD. Feedback uses absolute simulation-time expiration (`attack_time + duration`) so newly emitted feedback is not shortened by another delta subtraction. Lethal contact retains the completed tick's final time, clears feedback, then presents GameOver without later gameplay work. Inactive updates process overlay/resume/restart intents only, with camera and feedback clocks unchanged. UI keeps ordinary processing because SceneTree itself is not paused. Transition input clearing prevents queued motion from affecting resume/restart. This explicitly chooses same-update mouse yaw for simultaneous WASD.

### C. Tick-quantized timing — CHK006

Use one 60 Hz simulation clock; compare actual simulation time to deadlines with `>=`, never an early-trigger epsilon. Compute spawn deadlines from an integer opportunity index times the configured interval, and select the first strictly future opportunity after servicing at most one due attempt. Weapon/contact deadlines remain actual attack time plus configured interval. “Immediately” means the first eligible contact phase; “next gameplay update” means no later than the next executed Active physics step. With normal fixed steps, late servicing is bounded by one tick (approximately 16.67 ms) in simulation time; no real-time latency bound is implied during stalls. Positive intervals below a tick remain valid but can yield at most one action per executed update: cadence is never faster than the configured interval, and lost opportunities are not backlogged. A small contact interval may intentionally permit one attack per tick; overlap alone never bypasses its deadline. Record effective cadence for such tuning rather than adding a new minimum interval or rejecting it. Deadline tests use representable values immediately before/at/after readiness; if floating rounding places a deadline just above the clock, wait for the next tick. HUD/300-second endpoint comparisons use the completed clock, not rounded display seconds.

### D. Bounded pursuit — CHK024

For each enemy, take the XZ vector to the already moved player and advance by `min(speed * delta, remaining_distance)` in that direction, then apply existing radius-inset arena containment. At coincidence do nothing. This prevents passing through the target or oscillating on large delivered deltas and reaches the nearest feasible contained position. For rectangular shared bounds and unequal radii, propose validating `contact_distance² >= 2 * max(enemy_radius - player_radius, 0)²`: the greatest nearest-feasible enemy-center distance to a contained player is at a player-inset corner. Combine this with the existing strict spawn half-diagonal bound. Diagnose incompatible definitions rather than silently enlarging contact range. Test the radius-equality, unequal-radius, and exact-contact boundary cases. This proposed validation expresses existing FR-004 contact reachability with current containment; it is pending review, not an adopted new tuning restriction. No blocking or separation is introduced.

### E. Wall-time sampling boundaries — CHK027

Let `t0` be monotonic time when a valid fresh Active encounter is ready, before its first executed tick; let `t1` be time at completion of the first tick whose completed simulation clock is >=300. Record exact completed simulation time (including any tick rounding), `t1-t0` wall duration, and tick count. Neither a stalled wall-clock timer nor the rounded HUD can close the qualifying window. Frame-loop timestamps before `t0` and after `t1` may be retained only to describe boundary intervals. Report complete successive rendered-frame intervals wholly within `[t0,t1]`; average actual frame-loop FPS is the number of those intervals divided by their summed wall duration. Record that full-interval coverage duration alongside total run-wall duration. Do not count the first timestamp as a completed interval. Record start/end partial wall segments separately, including their duration/stalls, but exclude them from full-frame FPS/distribution statistics; do not invent prorated frames. Record zero/insufficient full intervals as unavailable with verification outstanding. Report all full-interval distributions/stalls plus boundary gaps, so no active stall is hidden. Enemy counts are sampled at one-second completed-simulation opportunities with their wall/simulation timestamps and live-registry counts. Pauses are excluded by separate diagnostic segments; an owner SC-006 attempt remains uninterrupted. CPU-observed frame-loop timestamps do not prove GPU presentation timing.

### F. Observable continuation — CHK016

After the qualifying endpoint, record the completed clock advancing above 300, owner movement/view input remaining responsive, at least one subsequent scheduled spawn opportunity (successful or expected cap skip), and a ready automatic attack with an eligible living target under normal tuning. Record their simulation timestamps and unchanged tuning/vulnerability; any unexpected spawn failure invalidates the acceptance attempt, including during this continuation check. Use an automated fixture spanning 300 to assert that the coordinator does not change state/tuning at that crossing, plus manual evidence from the accepted owner attempt. This proposes observable existing behaviors, not another fixed survival duration, victory condition or invulnerability. If death prevents collecting the evidence, record continuation verification outstanding rather than claim it passed.

### G. Deterministic suite and bounded checks — CHK032 / CHK033

Use a small explicit test manifest in the native runner listing required case IDs, script paths and FR/edge-case mappings; enumerate test case scripts and compare against the manifest so missing, duplicate, unregistered or unexecuted cases fail. No external test framework or reflection layer is needed. All randomized fixtures inject and report a fixed seed; fixture data is isolated from the normal Resource set, and every case disposes its encounter/callbacks before the next. Assert real instantiated component/scene behavior, not copied algorithms. Include fault-injected spawn selection/instantiation failures, expected cap skips, stalled wall time with unchanged simulation credit, and restart-counter isolation.

The runner fails on zero executed cases, missing expected cases, assertion failures or runtime diagnostics. The PowerShell launcher checks engine logs even on exit zero, applies explicit wall-time limits to noninteractive checks (proposed defaults: version/help 30 seconds, clean import 180 seconds, each-script parsing 30 seconds, complete test suite 120 seconds, startup 30 seconds), terminates only the child process it launched on timeout, restores environment in finally, and preserves contained diagnostics. An elapsed timeout is failed, not passed; missing prerequisites or unverified confinement are blocked. Interactive Play/Profile have no automated timeout. Document any override and rerun with it rather than silently extend a hanging check. These limits constrain tooling, not game performance acceptance.

### Remaining approval and scope boundaries

Review proposals A–G as one technical design set, or amend individual proposals. C explicitly settles sub-tick cadence and B settles simultaneous mouse/movement order; E/F settle evidence boundaries; G settles test-runner limits. D includes a concrete radius/contact reachability validation proposal; its additional definition constraint is not adopted until reviewed. There are no remaining unanswered product-policy questions from the three approved decisions. Approval of the proposed technical set and its subsequent propagation/review remain outstanding. No change to default tuning is proposed.

## Complexity Tracking (unchanged)

None. No violations or added dependencies requiring justification.
