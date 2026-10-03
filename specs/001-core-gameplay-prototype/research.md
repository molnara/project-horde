# Research: Core Gameplay Prototype

**Date**: 2026-10-02 | **Scope**: Phase 0 design research, not implementation evidence.

Research was delegated into engine/composition/validation and gameplay scheduling/profiling investigations, then consolidated against the spec and constitution. This records prior research; the technical review below distinguishes subsequent approved policies from pending technical proposals. Defaults remain initial tuning requiring playtesting. Official stable documentation was consulted during prior planning; verify the selected binary's behavior and CLI help before use.

## 1. Stack and dependencies

**Decision**: Retain Godot 4.7.2 Standard Edition and typed GDScript. Built-in nodes/resources, a small native test runner, and PowerShell suffice.

**Rationale**: Matches the approved stack and the one-arena scope. Official archive confirms the release exists. Environment recheck on 2026-10-02 verified persistent user-scope `GODOT_BIN` points to an existing Windows console executable (PE subsystem 3); `--headless --version` returned `4.7.2.stable.official.ed1daf0bf` with exit 0. Initial missing-executable assumptions are superseded. Process scope remains absent in this running session; persistent user scope was visible outside the sandbox but hidden by sandbox registry isolation. Read process scope first and fall back to persistent user/machine scope when absent; diagnose inaccessible scope rather than assuming no installation. No persistent environment value was modified.

**Alternatives considered**: C# or another engine violates the baseline; external test/navigation/plugins add unnecessary setup and maintenance. Do not install or change global configuration during this phase.

**Source**: [Godot release archive](https://godotengine.org/download/archive/4.7.2-stable/).

## 2. Movement and containment

**Decision**: Use Node3D actors with `Input.get_vector` transformed by camera yaw only, fixed Y, and speed × physics delta. Normalize/limit combined input; opposing keys cancel. Arena exposes a shared center-clamping function with entity-radius inset; no actor collision bodies or contact Areas are needed.

**Rationale**: This is a flat obstacle-free world with explicitly nonblocking actors. Combat uses squared XZ distances independently of movement. Separate containment permits future movement changes without rewriting attacks. Godot's input vector is length-limited; using yaw avoids pitch-dependent speed/vertical motion.

**Alternatives considered**: CharacterBody3D/static wall collisions add physics to an analytically bounded plane; navigation meshes and separation solve absent obstacles/crowd requirements. Full pitched basis needs projection and renormalization.

**Source**: [Input.get_vector](https://docs.godotengine.org/en/stable/classes/class_input.html#class-input-method-get-vector). The choice of Node3D containment is a project design inference.

## 3. Camera and placeholders

**Decision**: A yaw pivot and pitch pivot own a fixed-offset Camera3D: target height 1.2 m, distance 8 m, depression 15–65°, initial 35°, yaw 0°, sensitivity 0.12°/screen pixel, FOV 70°. Player is at viewport center below the pivot. Input uses screen-relative motion; upward motion reduces depression. Follow synchronously, with no smoothing or zoom. Low boundary strips and an open arena avoid occlusion; geometry is not a camera collision system.

**Rationale**: At the shallowest view the camera height is 1.2 + 8 sin(15°), safely above the floor. No roof/interior obstacle/tall wall requires camera collision in this slice. Bounds and visibility still need manual acceptance at every perimeter point. Use cyan player, orange/red enemies, muted floor and contrasting boundary strips, plus a short line and target flash for attacks.

**Alternatives considered**: SpringArm3D is the built-in choice when geometry can occlude the camera, but unnecessary with this geometry contract; custom collision, smoothing and production art add scope. If visibility fails, adjust primitive dimensions/camera tuning before adding complexity.

**Sources**: [Mouse screen_relative](https://docs.godotengine.org/en/stable/classes/class_inputeventmousemotion.html#class-inputeventmousemotion-property-screen-relative), [built-in spring arm](https://docs.godotengine.org/en/stable/tutorials/3d/spring_arm.html).

## 4. Ownership and configuration

**Decision**: Main coordinator injects definitions and narrow references into reusable scenes/components. Text Resource definitions are read-only; fresh runs copy scalar tuning into runtime ownership. Health, deadlines and spawn IDs never reside in shared definitions. Startup validation blocks invalid configuration with file/field/expected-value diagnostics and visible failure text.

**Rationale**: Resource loading may return shared objects. Explicit wiring avoids hidden scene-tree dependencies and reset coupling. Five small definitions correspond to player/enemy/weapon/arena/run responsibilities, without a general content framework.

**Alternatives considered**: Hardcoded tuning fails configurable acceptance; mutable shared Resources cause cross-instance health/readiness corruption; a gameplay autoload complicates clean restart.

**Sources**: [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html), [scene organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html).

## 5. Active-time scheduling and lifecycle

**Decision**: One 60 Hz coordinator update: state input → derive step scheduling time → move player/enemies → scheduled spawn → weapon → enemy contacts in spawn order → commit completed simulation time and present. Immediately latch Game Over on zero player health and short-circuit later gameplay. Completed, unpaused physics time determines survival; no unexecuted stall time is credited. Absolute simulation-time deadlines govern weapon/contact attacks; only a successful attack advances its deadline to now + interval. No target/contact leaves a ready attacker ready. Camera/feedback phase placement is a pending proposal, not settled by this abbreviated sequence.

**Rationale**: Preserves delays on pause and separation. Stable spawn IDs resolve equal distances and multiple contact order. Remove dead enemies from the registry synchronously before deferred node deletion. Defeat stops camera and simulation; Restart only from Game Over replaces the encounter once, resetting input/view, IDs, health, clock and deadlines.

**Alternatives considered**: Independent Timer callbacks create ordering races; wall-clock cooldowns continue during pause; resetting cooldown on re-entry permits extra damage. SceneTree pause is unnecessary: explicitly gate the coordinator and camera while UI still processes.

## 6. Spawning and target selection

**Decision**: First spawn at one full interval, one enemy per scheduled opportunity when below cap. Cap-full opportunities are consumed. On an exceptional update crossing multiple deadlines, service at most one opportunity and advance to the first cadence deadline strictly after current active time; no burst/backlog. Use up to 16 uniform samples inside inset arena bounds, then a farthest inset corner fallback strictly outside contact range. Validate geometry/contact relationships first.

**Rationale**: Bounded sampling cannot hang. A rectangular arena always has an inset corner at least its inset half-diagonal from any valid player position; require contact distance smaller than that half-diagonal. O(N) living-registry targeting by `(squared XZ distance, spawn_id)` is sufficient at default cap 50. Cap remains configurable for a later separate 200 benchmark.

**Alternatives considered**: Unbounded retries can hang; immediate replacement/catch-up spawning violates cap behavior; pooling/spatial indexing lacks measured need. Normal cadence tests use updates shorter than the interval; stall tests explicitly exercise the no-burst policy.

## 7. Initial tuning

**Subsequent owner-approved failure policy**: Unexpected spawn selection/instantiation failure consumes the scheduled opportunity, emits diagnostics and increments the per-run failure counter. Simulation continues at ordinary cadence with no catch-up, but the acceptance attempt is invalid. Full-cap skips are expected and do not increment failures. Invalid definitions instead disable simulation; recovery by correcting data and relaunching is sufficient, with no in-application retry. See [component contracts §Failure contract](contracts/gameplay-components.md#failure-contract) and [data model §Eligibility and scheduling](data-model.md#eligibility-and-scheduling) for planned interfaces/state.

**Decision**: Use the positive values in [data-model.md](data-model.md): 40 m square arena, 6 m/s player, 3 m/s enemy, 1.5 s spawn, cap 50, 4 m weapon range, 10 damage/0.6 s, enemy 30 health, contact 1.2 m with 10 damage/1 s, player 100 health.

**Rationale**: Faster player supports kiting; three weapon hits per kill leave pressure and make attacks visible. Independent contact deadlines preserve vulnerability. No claim that these numbers already permit a five-minute survival run.

**Alternatives considered**: Invulnerability, disabled contacts or a five-minute victory trigger would invalidate acceptance. Tune only definition values after measured playtests and record the exact accepted values.

## 8. Validation and safe engine launching

**Decision**: Native SceneTree assertion runner plus import, each-script `--check-only`, scene startup and manual scenarios. Runner exits nonzero on failures. Inspect engine diagnostics even when exit is zero. Headless results cannot prove controls, visuals or rendered performance.

**Rationale**: Built-in CLI supports these operations without a test plugin; `--check-only` applies to the supplied script and does not replace gameplay/startup checks. `--quit-after` counts iterations, not elapsed seconds.

**Alternatives considered**: `--test` is engine-internal test support, not this project's suite. Smoked startup alone misses edge cases. No unverified `--user-data-dir` option is assumed.

**Source**: [Command-line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html).

**Decision**: Future launcher confines process-scoped APPDATA, LOCALAPPDATA, TEMP and TMP to absolute workspace `.cache/` directories and supplies an absolute workspace log path; restore prior environment values in `finally`, explicitly handling absent variables. Verify actual engine user-data/cache/editor paths before import/editor/project execution. No persistent environment changes. All raw output stays ignored.

**Rationale**: Godot's documented Windows defaults can write outside the workspace. Environment redirection is a project inference and must be verified against this executable. A self-contained marker is safe only beside a binary already inside the workspace. Do not create a marker in an external installation. If confinement cannot be verified, engine launch is blocked pending an approved solution or explicit approval for named external paths.

**Alternatives considered**: A custom user-directory name changes a directory name under the OS user-data root, not containment. Global env/config changes violate the workspace rule. No wrapper installs software or downloads templates.

**Source**: [Godot data paths and self-contained mode](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html).

## 9. Profiling

**Decision**: Fix SC-007 conditions in plan/quickstart before running; measure the owner's actual uninterrupted five-minute run with normal vulnerability and cap 50. Buffer monotonic frame-loop intervals, sample enemy counts, and write output after sampling. Separate diagnostic profiler runs from acceptance sampling.

**Rationale**: Average FPS alone conceals stalls. Frame-time distribution and reciprocal worst interval convey observed extremes, while methods/overhead delimit claims. No headless performance result or 50-enemy run establishes SC-005.

**Alternatives considered**: Sampling only physics delta reports simulation cadence; smoothed FPS loses distributions; concatenating failed runs or excluding ordinary startup effects misrepresents SC-006/007. No premature optimization or benchmark harness.

## Remaining prerequisites and risks

### Technical review follow-up — 2026-10-02

The product owner approved the simulation-time survival clock, continue-but-invalidate spawn failure policy, and relaunch-only configuration recovery. Profiling uses separately recorded actual wall-clock duration/FPS and retains active stalls. These decisions supersede earlier unresolved policy questions. [Plan §Proposed resolutions for remaining technical gaps](plan.md#proposed-resolutions-for-remaining-technical-gaps) contains pending proposals for diagnostic lifecycle, camera/feedback phases, tick quantization, bounded pursuit/reachability validation, sample boundaries, continuation evidence, and suite/timeouts. These are not adopted decisions or executed research; technical checklist items remain open where their resolution still depends on proposal review.

- Engine location/version check passed. Re-resolve `GODOT_BIN` in each validation session; verify filesystem confinement before project/editor execution. The version-only invocation establishes no project/cache-path confinement or gameplay acceptance.
- Implement planned launcher/tests/instrumentation; current docs do not claim they exist.
- Floating deadline/range boundaries and lethal-event order require focused automated fixtures.
- Manual visibility, five-minute survivability and measured bottlenecks remain unverified.
- The three product-policy clarifications are resolved. Remaining technical proposals require review; no scope/governance change is proposed. No gameplay or validation implementation is authorized by this documentation follow-up.
