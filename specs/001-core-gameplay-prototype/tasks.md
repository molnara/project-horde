# Tasks: Core Gameplay Prototype

**Input**: Approved design documents in `specs/001-core-gameplay-prototype/`: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/gameplay-components.md`, `contracts/player-interface.md`, and `quickstart.md`.

**Prerequisites**: Constitution v1.0.0 and owner-approved A–G baseline. Phase 1 setup is verified in `docs/phase1-validation.md`; Phase 2 foundation and Phase 3A test authoring (T014–T017) are verified in `docs/verification/core-gameplay.md`. Phase 3B implementation/technical verification (T018–T032) and T033 owner visual/controls/game-feel acceptance are complete; the ledger records all six owner checks, including the clarified contact-damage result. Phase 4 Batch 1 test authoring (T034–T035) is complete; three current defeat regressions execute and thirteen Phase 4 cases remain explicitly unregistered/unrun. T036 onward is untouched. This checkpoint does not establish US2, full feature or performance acceptance.

**Tests**: The specification explicitly requires automated gameplay/data validation, headless engine checks, manual acceptance, and actual profiling. Use native GDScript assertions and PowerShell only. Write story fixtures before their implementation; record initial failures or missing prerequisites honestly, then require passing execution at the story checkpoint. No external test framework or blanket TDD policy is introduced.

**Organization**: Setup → minimal shared foundation → US1 (P1) → US2 (P2) → US3 (P2) → cross-cutting acceptance. Each story can be tested without the later stories; US2 and US3 require the playable US1 loop.

## Format: `[ID] [P?] [Story] Description`

- `[P]` identifies disjoint-file work that can run together after its stated prerequisites. It does not authorize spawning agents.
- `[US1]`, `[US2]`, `[US3]` map to the specification's stories; shared/polish tasks have no story label.
- All paths are relative to the repository root. Proposed concrete filenames below refine the directories approved in the plan.
- Definition constraints quoted in tasks come verbatim from `data-model.md`; implement them together, never as optional tuning advice.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish a minimal text Godot project and workspace-safe tooling, without content beyond the approved slice.

- [X] T001 Create `project.godot` and a minimal bootstrap `scenes/main.tscn` for Godot 4.7.2 Standard/GDScript with WASD actions, Escape intent, 60 Hz physics, Forward+, 1920×1080 content resolution, 100% 3D scale, AA/VSync/FPS cap disabled; preserve `.gitignore` exclusions for `.godot/` and `.cache/` and track required source UID files rather than import output.
- [X] T002 Implement engine/environment preflight in `tools/validate.ps1`: declare `-GodotBin` an optional explicit override; when omitted resolve the first nonempty GODOT_BIN in Process→User→Machine order, reject an invalid explicit override without silent fallback, check optional scopes/files before access, require an absolute existing Windows console executable, confine process APPDATA/LOCALAPPDATA/TEMP/TMP and absolute logs to workspace `.cache/`, verify actual Godot user/cache/editor paths before project execution, verify help/version against approved 4.7.2 Standard, restore present/absent environment values in `finally`, and block with diagnostics when containment/prerequisites are unverified; do not install or write global state.
- [X] T003 Extend `tools/validate.ps1` with `All`, `Play`, and `Profile` modes: `All` imports before checking every project/test `.gd` with `--check-only`, runs `res://tests/run_tests.gd`, and starts main with `--quit-after 120`; use per-command workspace logs, command/exit/outcome reporting and configurable 30 s version/help, 180 s import, 30 s per parse, 120 s suite, 30 s startup limits; terminate only the launched child on timeout, retain diagnostics, and leave interactive modes without automatic timeout.
- [X] T004 [P] Create the original-placeholder provenance ledger in `docs/asset-provenance.md` describing built-in primitive meshes/materials, intended cyan player/orange-red enemy/contrasting floor and low boundaries, replaceable visual interfaces, and no copied or third-party assets.

**Checkpoint**: Safe launcher is ready; no engine/project invocation may bypass unverified filesystem containment. Future missing scenes/tests remain explicit blocked prerequisites until supplied.

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Only resource definitions, validation and the test/evidence infrastructure shared by the slice. Gameplay components belong to US1.

- [X] T005 [P] Define typed PlayerDefinition and EnemyDefinition in `scripts/data/player_definition.gd` and `scripts/data/enemy_definition.gd`, with defaults in `resources/definitions/player.tres` (health 100, speed 6, radius 0.4, height 1.6) and `resources/definitions/enemy.tres` (health 30, speed 3, radius 0.4, height 1.2, contact distance 1.2, damage 10, interval 1); preserve constraints "Health/damage/cap are positive integers." and "Speeds, radii, heights, ranges, intervals, feedback duration, sensitivity and camera distance/target height are positive finite values."
- [X] T006 [P] Define WeaponDefinition and ArenaDefinition in `scripts/data/weapon_definition.gd` and `scripts/data/arena_definition.gd`, with `resources/definitions/weapon.tres` (range 4, damage 10, interval 0.6, feedback 0.12) and `resources/definitions/arena.tres` (half-extents 20×20, floor 0, boundary height 0.15, start 0×0); preserve "Vector/scalar fields reject NaN/infinity; floor height may be any finite value." plus the positive integer/finite constraints quoted in T005.
- [X] T007 Create `scripts/data/run_definition.gd` and `resources/definitions/run.tres` referencing exactly one of the four definitions after T005–T006, with schema 1, spawn interval 1.5, cap 50, yaw 0, depression 35/min 15/max 65, distance 8, target height 1.2, sensitivity 0.12, FOV 70; preserve "Cap validation requires a positive integer, with no hard-coded 50 ceiling." and "Definition values are read-only while playing. Changes apply on a fresh run, never retroactively."
- [X] T008 Write definition-contract cases in `tests/unit/test_definitions.gd` for defaults, missing/wrong references, unsupported schema, nonpositive/nonfinite scalars/vectors, cap type and custom 200 cap, invalid start/extents/view geometry, strict spawn bound and inclusive unequal-radius reachability, including exact boundary fixtures and resource nonmutation.
- [X] T009 Implement `scripts/data/definition_validator.gd` with actionable path/field/observed/constraint diagnostics and no silent defaults; preserve "All required references must exist and have the expected type; schema_version must be supported.", "Arena half-extents exceed both entity radii; player start lies in player-inset bounds.", "Visual boundary is low enough to preserve camera visibility.", "Contact distance must be strictly less than their half-diagonal.", "`0 < depression_min <= camera_depression <= depression_max < 90`; FOV strictly between 1° and 179°.", "Camera height at minimum depression stays above floor, and visual target lies on the player.", and "For corner contact reachability, `contact_distance² >= 2 * max(enemy_radius - player_radius, 0)²`"; combine these with T005–T007 numeric constraints and diagnose incompatible definitions without enlarging contact range.
- [X] T010 Create `tests/run_tests.gd`, `tests/case_manifest.gd`, and `tests/support/test_context.gd` as a native assertion harness with explicit case IDs/script paths/FR-edge mappings, designated-case discovery under unit/integration, manifest/discovered/executed reconciliation failing on missing/duplicate/unregistered/unexecuted/zero cases, isolated definition copies, reported fixed RNG seeds, per-case scene/callback cleanup, declared application diagnostic expectations by case/source/constraint/count, and nonzero exit on any real assertion or unexpected engine error.
- [X] T011 Implement diagnostic classification in `tools/validation_diagnostics.ps1` and integrate it into `tools/validate.ps1`: inspect recognized script/parse/runtime/resource-load severity even on exit zero, preserve original output, allow banners/progress/device information and arbitrary informational text, record warnings separately, investigate ambiguous records, and distinguish declared expected application faults from unexpected engine exceptions without broad suppression.
- [X] T012 Add and execute infrastructure fixtures in `tools/test-validation.ps1` and `tests/unit/test_runner_contract.gd` for explicit executable override precedence/invalid-override rejection, omitted override with Process→User→Machine first-nonempty discovery and absent/inaccessible scopes, unchanged executable validation/containment, harmless/error diagnostic formats from the selected executable, genuine zero-exit errors, expected application faults, warnings, child timeout/cleanup/environment restoration, and empty/duplicate/missing/unregistered/unexecuted cases; retain failed-subcommand diagnostics and actual outcomes in `docs/verification/core-gameplay.md` after T010–T011.
- [X] T013 Establish the per-FR-clause/edge-case acceptance ledger in `docs/verification/core-gameplay.md` with actual commands, observations, passed/failed/skipped/blocked/unrun statuses, outstanding checks, and SC-001–004/006–007 gates; execute the contained import/parse/definition/infrastructure checks available after T001–T012 and record missing story checks as unrun, without claiming playable startup or feature acceptance.

**Checkpoint**: Definitions and infrastructure executed successfully, or documented blockers resolved before story implementation. No general progression, navigation, pooling, services or benchmark framework.

## Phase 3: User Story 1 — Survive in the arena (Priority: P1) — MVP

**Goal**: Deliver a directly runnable integrated movement/camera/spawn/pursuit/automatic-combat/health/HUD loop, plus the capture needed to verify the actual five-minute run. Minimal lethal stopping protects the loop; the defeat/restart UI is US2.

**Independent Test**: Fresh run has full health, zero enemies/time and initial view; WASD follows yaw at equal straight/diagonal speed, boundaries contain freely overlapping actors, enemies spawn/pursue, nearest eligible targets take automatic damage, contact reduces independent health, and HUD follows completed simulation time. No pause/restart is required. Full US1 acceptance additionally needs the owner's uninterrupted 300-second survival and continuation/profile evidence; the initial playable checkpoint alone does not satisfy those gates.

### Tests for User Story 1

- [X] T014 [P] [US1] Write real-component movement/camera/arena cases in `tests/unit/test_movement_arena.gd` for each/opposing/released/diagonal input before and after 90° yaw, pitch-independent fixed Y, same-step mouse yaw, bounded depression/follow, both actor insets and corner containment, 16-candidate spawn/farthest-corner fallback, strict contact exclusion, explicit selection Dictionary success/failure including valid Vector3.ZERO when eligible versus absent failure position, required diagnostic payload and no arena instantiation/scheduling/accounting side effects, overshoot/coincidence and unequal-radius reachable corners (FR-001–004).
- [X] T015 [P] [US1] Write real-component health/registry/weapon/contact cases in `tests/unit/test_combat.gd` for fresh independent health and resource immutability, nonlethal/excess/invalid damage, no regeneration, one death and synchronous removal, dead/departed exclusion, nearest/earliest-ID ties, exact/inside/outside XZ ranges, readiness/no target, first contact, persistent overlap, separation/re-entry, independent contacts and actual feedback expiry (FR-005–008).
- [X] T016 [P] [US1] Write coordinator/scene cases in `tests/integration/test_survival_loop.gd` for three initial spawn opportunities, cap and three skips, no death-triggered refill, next-cadence refill/default 50/custom cap, completion-time deadlines before/at/after and positive sub-tick intervals, long simulated step without bursts, wall stall without simulation credit, mouse→movement→pursuit→spawn→weapon→contacts order, lethal short-circuit/one final commit, HUD 0/65 s and health, startup failures and spawn fault consumption/count/partial cleanup/invalidity; assert unsuccessful selection never reads a position or instantiates an enemy, multiple diagnostics still consume/count one failed opportunity, enriched diagnostic fields are reported, partial instances never enter the registry and are disposed, next ordinary cadence continues without catch-up and cap skips neither select nor increment failures (FR-001–009).
- [X] T017 [P] [US1] Write profile/statistics/continuation cases in `tests/unit/test_profile_capture.gd` for generation isolation, t0/t1 inclusion, whole-window versus full-interval FPS, boundary stalls, zero/one/two callbacks, p50/p95/p99/max/minimum and stall counts, count samples, exact 300-step-completion endpoint including lethal endpoint, eligible attacks/spawns across 300, unchanged tuning, bounded endpoint buffer and late failure invalidity; assert actual helper/component behavior, not duplicate gameplay algorithms.

### Implementation for User Story 1

- [X] T018 [P] [US1] Implement composable health in `scripts/combat/health.gd`: copy configured maximum into each instance, preserve "Health clamps to `[0, max_health]`; positive damage only." and "No regeneration.", return applied damage, signal health changes synchronously and death once, reject invalid damage with diagnostics, and never mutate shared definitions.
- [X] T019 [P] [US1] Implement flat arena containment/spawn selection in `scripts/arena/arena.gd` and original geometry in `scenes/arena.tscn`: preserve "Spawn selection tries 16 candidates, then a deterministically selected farthest inset corner; only strictly outside contact distance is valid.", inject RNG for fixtures, return the `choose_spawn()` Dictionary contract from `contracts/gameplay-components.md` (Boolean success, valid Vector3 position only on success, empty success diagnostics/nonempty failure diagnostics with stage/source/field/observed/constraint/cause; no sentinel coordinates), leave instantiation/opportunity management/failure accounting to the spawner and coordinator, and keep radius-inset containment separate from combat/physical blocking.
- [X] T020 [P] [US1] Implement player input/movement in `scripts/actors/player.gd` and `scenes/player.tscn` with cyan primitive visuals, normalized/opposing/release-aware yaw-only XZ motion, fixed floor Y, injected arena and health interface, copied tuning and no autonomous gameplay process callbacks (FR-001/003/006).
- [X] T021 [P] [US1] Implement camera in `scripts/camera/camera_rig.gd` and `scenes/camera_rig.tscn` with yaw/pitch pivots, configured distance/FOV/target height, horizontal motion in the same direction and upward motion reducing depression, bounded 15–65° default view, synchronous follow, queued Active mouse motion/reset methods and injected player reference (FR-002).
- [X] T022 [P] [US1] Implement enemy scene/behavior in `scripts/actors/enemy.gd` and `scenes/enemy.tscn` with orange-red primitives, copied tuning/independent health, bounded `min(speed * delta, remaining XZ distance)` pursuit of the already moved player, coincidence no-motion and arena inset, no physical blocking; preserve "ready on spawn" contact state and persistent `next_contact_at` with inclusive squared XZ threshold, one actual attack per step and no re-entry reset (FR-004/006–008).
- [X] T023 [P] [US1] Implement `scripts/run/live_registry.gd` with explicit add/remove/living-in-spawn-order interfaces, unique per-run IDs, immediate death exclusion before deferred deletion, no unrelated tree/group search, and safe snapshots for targeting/contacts; preserve "live registry only while health > 0" (FR-005/007/008).
- [X] T024 [US1] Implement `scripts/combat/automatic_weapon.gd` after health/registry interfaces: fresh `next_attack_at = 0`, no persistent target, inclusive squared XZ range/no epsilon, nearest then earliest spawn-ID tie, no-target unchanged readiness, actual damage/signal once per ready step, deadline `t_end + interval`, and feedback payload identifying actual affected target (FR-005/007).
- [X] T025 [US1] Implement `scripts/run/enemy_spawner.gd` using arena/enemy/registry after T019/T022/T023: indexed fixed multiples beginning at one interval, due comparisons against t_end, cap skip consumption/no backlog/no immediate refill, at most one attempt and next multiple strictly after t_end, configurable cap without 50 ceiling; inspect `choose_spawn()` success before reading position, never instantiate on selection failure, and publish only fully configured enemies. Own failed-opportunity handling: consume once, enrich/report actionable diagnostics with run_generation/opportunity_index/scheduled_at/t_end, notify the coordinator once to increment its per-run failure counter and latch acceptance invalidity regardless of diagnostic count, exclude/dispose partial instances when applicable, and continue simulation at ordinary cadence without retry/catch-up. Full-cap skips do not invoke selection or count as failures (FR-004).
- [X] T026 [P] [US1] Implement HUD value presentation in `scripts/ui/hud.gd` and `scenes/hud.tscn` with readable current/max health and floor(active_time) MM:SS, minutes beyond two digits, signal-driven updates by the next update and a visible resource/field configuration failure message; presentation cannot advance time or apply damage (FR-009).
- [X] T027 [US1] Implement `scripts/run/run_coordinator.gd`, `scripts/run/main.gd`, and wire `scenes/main.tscn` after T018–T026: validate then create one fresh encounter, zero time/step count/IDs/population/failures and full spawn delay; own only coordinated 60 Hz gameplay steps ordered intent→t_end→mouse/yaw→player→camera→pursuit→spawn→weapon→spawn-ordered contacts→commit/HUD; preserve "gameplay only Active", latch lethal stop/abort later contacts/commit t_end once, count/latch acceptance-invalid spawn failures while continuing, and disable simulation on invalid configuration with explicit wiring and no autoload.
- [X] T028 [US1] Implement attack line/target flash in `scripts/combat/attack_feedback.gd`, wiring via `scripts/run/main.gd` to player/enemy visuals: actual attack completion plus configured duration gives absolute expiry, no extra same-step aging/damage, affected enemy identifiable, cleared feedback on defeat and replaceable visuals (FR-005).
- [X] T029 [US1] Implement bounded generation-tagged attempt lifecycle in `scripts/run/profile_capture.gd`, wired/owned/disposed by `scripts/run/main.gd` only in Profile mode: open after valid ready encounter before first step, close after endpoint combat/commit at >=300 or earlier defeat, spool lossless bounded raw chunks to ignored `.cache/` and flush the final tail after sampling per the Phase 3B correction in plan.md, retain only outcome/continuation/failure metadata afterward, reject stale generations, preserve unsuccessful evidence on shutdown, and report required-output/capture failures as outstanding; normal Play has no sampler.
- [X] T030 [US1] Implement profile measurements in `scripts/run/profile_statistics.gd` and connect `scripts/run/profile_capture.gd`: monotonic W=t1−t0, callbacks in (t0,t1]/W, separate wholly contained full intervals/coverage/FPS, reciprocal longest-interval minimum FPS and p50/p95/p99/max ms/>16.67/>33.33 ms stalls, initial/final partial gaps and sparse-sample unavailable reasons, one-second completed-simulation enemy min/max/mean with simulation/wall timestamps, available engine monitors and overhead; label CPU-observed frame-loop timing accurately (SC-007).
- [X] T031 [US1] Add separate survival-window/continuation/capture/acceptance-invalid outcomes in `scripts/run/run_coordinator.gd` and `scripts/run/profile_capture.gd`: 300 completed seconds never ends/changes gameplay or grants full acceptance; track later time/responsive view/motion/unchanged tuning/vulnerability/next scheduled spawn opportunity, retain successful window if later death prevents continuation, leave unobserved clauses outstanding, and latch unexpected failures even after buffer closure; require all relevant evidence and zero failures for full attempt qualification (SC-006/007).
- [X] T032 [US1] Register US1 cases in `tests/case_manifest.gd`, execute `tools/validate.ps1 -Mode All` through the verified engine environment, fix real implementation failures and record exact commands/results/effective sub-tick cadence and each FR-001–009/edge result in `docs/verification/core-gameplay.md`; verify scene startup, runtime resource independence and expected application fault diagnostics without suppressing engine errors.
- [X] T033 [US1] Execute and document US1 manual scenarios from `specs/001-core-gameplay-prototype/quickstart.md` in `docs/verification/core-gameplay.md`: WASD/90° yaw/diagonals/release, full perimeter/vertical limits/player visibility, recognizable original primitives, free overlaps, redirecting pursuit, automatic hit/kill target feedback and contact/HUD health/time; supply owner steps and record unperformed visual/controls/game-feel checks as outstanding.

Phase 3B owner-test follow-up and closure: the frame-ceiling correction and
automated capture/launcher checks are complete; the independent owner capture
is verified. All six T033 owner checks passed, including paced damage from 1–2
enemies and expected immediate lethal damage from roughly 10+ enemies at 100 HP.
Phase 3B (T018–T033) is complete. Historical source-snapshot limitations and
full SC-006/SC-007 acceptance remain separately documented in the ledger.
That closure did not initiate Phase 4. The subsequently authorized Batch 1
completed T034–T035 test authoring only; T036 and later work remain unstarted.

**Checkpoint**: Demonstrate and technically validate the P1 playable slice before US2. Five-minute owner survival and actual profiling can be performed once this slice is ready, but remain pending until recorded in T053–T055; they are never implied by fixtures or scene startup.

## Phase 4: User Story 2 — Try again after defeat (Priority: P2)

**Goal**: Recognizable Game Over and exactly one clean restart in the same application.

**Independent Test**: From US1, take lethal damage, wait ten seconds attempting input/Escape, then complete three defeat/restart cycles. Each new run restores health/view/position/time/population/IDs/failure counter and event readiness, without duplicate encounters; pause is unnecessary.

### Tests for User Story 2

- [X] T034 [P] [US2] Write actual scene/coordinator cases in `tests/integration/test_defeat_restart.gd` for one lethal transition/final t_end commit, ten-second-equivalent defeated freeze/no Escape resume, final HUD/overlay, full reset of every runtime field and three cycles, repeated/invalid restart signals/old callbacks, synchronous removal, discarded old encounter on invalid restart data and fresh-run failure-counter isolation (FR-010/011). Authoring complete; three Phase 3B regressions execute, six US2 cases await T036–T039 and T041 registration/verification.
- [X] T035 [P] [US2] Write evidence lifecycle cases in `tests/integration/test_restart_evidence.gd` for sealing old buffers/outcomes before teardown, rejecting old generation callbacks, opening only after valid fresh definitions, capture shutdown/write failure diagnostics and survival-window preservation after post-300 death; register only after T039–T040 implementation is ready. Authoring complete; all seven cases remain in the non-executable staged inventory until T039–T040, with T041 required for registration/verification and exact declared capture-fault diagnostic matching.

### Implementation for User Story 2

- [ ] T036 [US2] Complete GameOver intent/state presentation in `scripts/run/run_coordinator.gd`: latch once on zero health, retain final committed t_end/health, block all later movement/camera/spawn/attack/damage/time and Escape resume, clear pending input/feedback and release mouse while allowing UI processing (FR-010).
- [ ] T037 [US2] Add Game Over/final time/clearly labeled Restart to `scenes/hud.tscn` and `scripts/ui/hud.gd`, retaining readable health/time; focus Restart initially and support click/Enter/Space with presentation-only `restart_requested` signal, absent in Active (FR-010/011).
- [ ] T038 [US2] Implement guarded `request_restart` in `scripts/run/run_coordinator.gd` and encounter rebuilding in `scripts/run/main.gd`: accept only GameOver, guard immediately, disconnect/dispose old encounter, increment generation then validate current definitions, restore independent fresh health/view/position/clock/steps/IDs/empty registry/full spawn delay/ready weapon/failure counter, recapture mouse, and ignore repeat/stale/Active intents (FR-011).
- [ ] T039 [US2] Implement invalid-restart failure in `scripts/run/main.gd` and `scripts/ui/hud.gd`: discard defeated encounter, keep simulation disabled, display actionable resource/field/constraint diagnostics, retain nonzero automated failure status, and document correction/relaunch without adding retry UI.
- [ ] T040 [US2] Integrate defeat/restart/shutdown capture lifecycle in `scripts/run/profile_capture.gd` and `scripts/run/main.gd`: seal/write/retain old generation evidence before teardown, new buffers only after valid setup, preserve distinct survival/continuation/capture/invalidity outcomes, reject stale callbacks and ensure counter reset does not erase prior failed-attempt records.
- [ ] T041 [US2] Register US2 fixtures in `tests/case_manifest.gd`, execute contained `tools/validate.ps1 -Mode All`, and record commands/outcomes plus manual ten-second GameOver input/Escape and three repeated defeat/restart cycles with keyboard/mouse activation in `docs/verification/core-gameplay.md`; unperformed owner checks remain outstanding (SC-002).

**Checkpoint**: US1+US2 run in one application with clean successive attempts and retained evidence. US3 is not required for this journey.

## Phase 5: User Story 3 — Pause during combat (Priority: P2)

**Goal**: Escape freezes and resumes the living encounter with preserved delays and no catch-up.

**Independent Test**: Pause both during contact and between scheduled events; wait ten real seconds while trying WASD/mouse/held Escape, compare unchanged gameplay/view/health/time/remaining deadlines, then resume without a view jump or early/burst event. The test does not require restarting.

### Tests for User Story 3

- [ ] T042 [P] [US3] Write component/coordinator cases in `tests/integration/test_pause_resume.gd` for Active↔Paused discrete non-echo Escape, unchanged positions/view/health/completed time/step count/all deadlines/feedback, no spawn/attacks/damage, preserved remaining delays at resume/no catch-up, cleared inactive mouse input, HUD visibility, ignored restart while Paused and no GameOver resume (FR-012).
- [ ] T043 [P] [US3] Write capture segmentation cases in `tests/integration/test_pause_profile.gd` for segment close/reopen on pause/resume without inactive wall-time intervals, preserved generations/outcomes, paused time never credited toward 300, and diagnostic segmented attempts never qualifying as uninterrupted owner survival/profile evidence (SC-003/006/007).

### Implementation for User Story 3

- [ ] T044 [US3] Implement Escape intents and Active/Paused gating in `scripts/run/run_coordinator.gd`: once per non-echo press before simulation, preserve all encounter/deadline fields on pause and resume, leave SceneTree UI running, no gameplay/camera callbacks while inactive, and prevent GameOver resume/restart while Paused (FR-012).
- [ ] T045 [US3] Wire input capture/transition clearing in `scripts/run/main.gd` and `scripts/camera/camera_rig.gd`: capture only Active, release in Paused/GameOver, clear pending motion on every transition and ignore inactive WASD/mouse accumulation; resume uses remaining delays and current view, not reset/catch-up (FR-012).
- [ ] T046 [US3] Add readable Paused/Escape to resume overlay in `scenes/hud.tscn` and `scripts/ui/hud.gd`; keep HUD health/time visible, Restart hidden and absolute feedback deadlines frozen with the simulation clock (FR-009/012).
- [ ] T047 [US3] Integrate diagnostic pause segments in `scripts/run/profile_capture.gd`: close active segment at pause, reopen an origin on resume without bridging wall-time gaps, record interruption/nonqualification, preserve bounded buffers/outcomes and unchanged gameplay state; uninterrupted acceptance still requires one clean attempt.
- [ ] T048 [US3] Register US3 cases in `tests/case_manifest.gd`, execute contained `tools/validate.ps1 -Mode All`, and record actual commands/results plus ten-real-second pauses during contact and between events with held Escape/WASD/mouse, frozen values and preserved-delay resume in `docs/verification/core-gameplay.md`; report unperformed owner checks as outstanding (SC-003).

**Checkpoint**: All three stories are technically validated and independently exercisable against US1. Controls/visuals and full owner acceptance still require actual recorded playtests.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Complete reproducible documentation and integrated prototype acceptance; optimize only measured present problems.

- [ ] T049 Reconcile `specs/001-core-gameplay-prototype/quickstart.md` with implemented files/modes/commands, exact default tuning, controls, containment prerequisites/timeouts/overrides/error policy, actual test manifest/coverage and manual procedures; distinguish implemented behavior from unverified acceptance and keep SC-005 explicitly future/unverified.
- [ ] T050 [P] Reconcile `docs/asset-provenance.md` against every actual mesh/material/font/audio source and visual replacement interface; record license/source for any unavoidable third-party item and remove undocumented or distinctive copied content without adding production art.
- [ ] T051 Execute clean reproducible contained import, every-script parse, complete manifest-reconciled suite and main startup using `tools/validate.ps1 -Mode All`, including `tools/test-validation.ps1`; inspect logs/exit codes, investigate every unexpected failure, verify source UID tracking/generated exclusions and record exact results and unresolved blockers in `docs/verification/core-gameplay.md`.
- [ ] T052 Have the product owner execute the integrated controls/boundaries/HUD/kill/contact/pause/resume/defeat/restart journey in `specs/001-core-gameplay-prototype/quickstart.md` without developer intervention; record observations for each FR clause/edge and SC-002–004 in `docs/verification/core-gameplay.md`, leaving unavailable owner participation/controls/visual/game-feel checks outstanding rather than substituting headless evidence.
- [ ] T053 Pre-record actual engine/OS/GPU/driver/hardware/source revision/tuning and plan deviations in `docs/verification/prototype-profile.md` before `tools/validate.ps1 -Mode Profile`: standalone debug/no editor or debugger, Forward+ 1920×1080/100% scale, AA/VSync/frame cap/shadows/SSAO/SSIL/glow off, one directional light, 60 Hz physics; perform a separate 30-active-second warm-up, retain unsuccessful attempts and restart cleanly with normal vulnerability/default cap 50 unless changed tuning is explicitly recorded.
- [ ] T054 Have the owner perform one uninterrupted normal Profile attempt reaching >=300 completed physics simulation seconds alive and continue it normally; in `docs/verification/core-gameplay.md` record actual simulation/tick/wall endpoint, normal spawning/pursuit/combat/vulnerability, later advancing time/responsive movement/view/unchanged tuning and a later scheduled spawn opportunity with timestamps, attacks when eligible and zero unexpected spawn failures throughout continuation; preserve partial window success after later death without claiming unobserved continuation or splicing attempts (SC-006).
- [ ] T055 Summarize actual T054 raw workspace `.cache/` capture in `docs/verification/prototype-profile.md` with whole-window wall FPS, full-interval distribution/minimum/coverage/stalls, partial-boundary gaps, enemy counts/timestamps, available monitors/overhead/bottlenecks, actual conditions/deviations and unavailable reasons; separate survival/continuation/capture/invalidity outcomes, retain failed attempts, and claim neither a new numerical prototype threshold nor 200-enemy/60-FPS compliance (SC-007).
- [ ] T056 Review `docs/verification/core-gameplay.md` and `docs/verification/prototype-profile.md` against every FR-001–012 clause/edge and SC-001–004/006–007 plus constitution v1.0.0; resolve observed in-scope issues in their owning files, rerun affected technical/manual/profile checks after tuning or behavior changes, and mark feature acceptance only with executed evidence for all prototype gates; preserve outstanding checks/SC-005 future status and make no automatic Git commit.

## Dependencies & Execution Order

### Phase dependencies

1. Setup T001–T004 precedes foundational T005–T013. T002 containment is mandatory before **any** engine invocation, including infrastructure fixtures.
2. T005 and T006 can run together; T007 then T008–T009 establish valid definitions. T010 requires case contracts, but test fixture execution waits for its components. T011 integrates into T003; T012 follows T010–T011. T013 is the shared readiness gate.
3. US1 starts after T013. Its test authoring T014–T017 can proceed together. T018–T023 and T026 can proceed together after tests/interfaces are established; T020/T022 consume the approved health contract and must wait for T018 before execution/integration. T024 depends on T018/T023; T025 on T019/T022/T023; T027 on all core implementations. T028 follows T027. T029 follows runnable core wiring; T030 follows capture; T031 follows capture/statistics; T032–T033 validate the complete increment.
4. US2 follows the validated playable US1 checkpoint. Tests T034/T035 are disjoint; T036–T040 are sequential to avoid overlapping coordinator/Main/HUD/capture writes. T041 validates the increment.
5. US3 follows US2 in this delivery order because it edits the same shared files. It logically needs only US1 and its test journey never requires defeat/restart. T042/T043 are disjoint; T044–T047 are sequential; T048 validates the increment.
6. Final reconciliation T049/T050 can run together after all stories. T051 precedes owner integrated acceptance T052; T053 precedes qualifying T054; T055 uses that actual attempt's capture. T056 reviews every required evidence gate; missing owner evidence is unfinished acceptance, not a successful task.

### User story dependency graph

```text
Setup → Foundation → US1 playable checkpoint → US2 → US3 → Integrated acceptance
                        │                       (US3 logically requires US1)
                        └→ five-minute owner/profile evidence T053–T055
```

US1 is the MVP demonstration. US2 adds repeat attempts; US3 adds interruption. All require their own executed technical and manual checkpoint. US1 full acceptance retains its five-minute/profile obligations even if later stories have not yet shipped. SC-005 benchmark implementation is deliberately outside this task list.

### Parallel opportunities and examples

Parallelism means disjoint files after prerequisites; finish each batch before tasks consuming its interfaces. Test discovery/manifest registration and shared Main/coordinator/HUD modifications have a single writer.

| Story/phase | Parallel example | Gate before next work |
|---|---|---|
| Setup | T004 provenance alongside T001–T003 project/launcher work | Safe launch before engine use |
| Foundation | T005 player/enemy definitions with T006 weapon/arena definitions | Both before T007 |
| US1 tests | T014 movement, T015 combat, T016 coordinator, T017 profile fixture authoring | Register/run after components exist; no false initial pass |
| US1 components | T018 health, T019 arena, T020 player, T021 camera, T022 enemy, T023 registry, T026 HUD | Established contracts first; health before player/enemy execution; all before coordinator integration |
| US2 | T034 defeat/restart fixtures with T035 evidence fixtures | Shared lifecycle implementation remains sequential |
| US3 | T042 pause fixtures with T043 profile-segment fixtures | Shared transition implementation remains sequential |
| Polish | T049 quickstart reconciliation with T050 provenance audit | Both before final checks/review |

## Implementation Strategy

### MVP first

Complete setup/foundation and US1, run headless checks and demonstrate the integrated arena loop. Keep initial tuning explicitly unverified until playtested. Validate this playable checkpoint before adding defeat/restart; do not build speculative systems or substitute five-minute fixtures for owner survival evidence.

### Incremental delivery

Add US2 and validate three clean cycles, then US3 and validate preserved pause/resume. Recheck earlier behavior when shared files change. Technical validation belongs to Codex; owner visual/control/game-feel and survival participation is necessary for those acceptance criteria. If owner participation or safe engine launch is unavailable, continue independent authorized work and report the remaining checks honestly.

### Verification and completion

Run proportional checks at each story checkpoint, then the final required suite and actual owner profile. Investigate failures before marking a task complete. T054/T055 require one real normal attempt, recorded separately from diagnostic/fault/paused fixtures. Full prototype acceptance requires all SC-001–004/006–007 evidence, zero unexpected spawn failures in the qualifying attempt, required continuation/capture, and recorded manual outcomes. No automatic commit, external installation/cache writes, production assets, progression or 200-enemy benchmark is authorized by this task-generation operation.
