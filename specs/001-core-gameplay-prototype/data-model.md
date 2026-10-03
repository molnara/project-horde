# Data Model: Core Gameplay Prototype

**Status**: Approved Phase 1 design baseline with A–G owner refinements; definitions and gameplay instances remain unimplemented.

## Definition resources

Custom Resource classes in `scripts/data/`, text `.tres` defaults in `resources/definitions/`. One versioned definition set (`schema_version = 1`) is validated before a run; RunDefinition references exactly one of each subordinate definition. Definition values are read-only while playing. Changes apply on a fresh run, never retroactively. Distances are meters, times active seconds, angles degrees, health/damage integers.

| Definition | Fields and initial defaults |
|---|---|
| PlayerDefinition | max_health 100; movement_speed 6.0; visual_radius 0.4; visual_height 1.6 |
| EnemyDefinition | max_health 30; movement_speed 3.0; visual_radius 0.4; visual_height 1.2; contact_distance 1.2; contact_damage 10; contact_interval 1.0 |
| WeaponDefinition | range 4.0; damage 10; attack_interval 0.6; feedback_duration 0.12 |
| ArenaDefinition | half_extents_xz (20.0, 20.0); floor_y 0.0; boundary_visual_height 0.15; player_start_xz (0.0, 0.0) |
| RunDefinition | schema_version 1; references to the four definitions above; spawn_interval 1.5; max_live_enemies 50; camera_yaw 0.0; camera_depression 35.0; depression_min 15.0; depression_max 65.0; camera_distance 8.0; camera_target_height 1.2; mouse_sensitivity 0.12; camera_fov 70.0 |

Initial tuning is not a verified balance result. For the accepted SC-006 run record every actual value, including any changed defaults. Cap validation requires a positive integer, with no hard-coded 50 ceiling.

### Definition validation

- All required references must exist and have the expected type; schema_version must be supported. Diagnostics identify resource path, field, observed value, and required constraint. Fail before starting simulation; never silently fall back to broken gameplay.
- Health/damage/cap are positive integers. Speeds, radii, heights, ranges, intervals, feedback duration, sensitivity and camera distance/target height are positive finite values. Vector/scalar fields reject NaN/infinity; floor height may be any finite value.
- Arena half-extents exceed both entity radii; player start lies in player-inset bounds. Visual boundary is low enough to preserve camera visibility.
- Let enemy spawn inset half-extents be `(half_x - enemy_radius, half_z - enemy_radius)`. Contact distance must be strictly less than their half-diagonal. This guarantees at least one inset corner strictly outside contact distance for any player position, including the center; sampling still checks the chosen position.
- `0 < depression_min <= camera_depression <= depression_max < 90`; FOV strictly between 1° and 179°. Camera height at minimum depression stays above floor, and visual target lies on the player. Chosen 15–65° limits avoid inversion/floor crossing.
- For corner contact reachability, `contact_distance² >= 2 * max(enemy_radius - player_radius, 0)²`; combine this inclusive lower bound with the strict spawn half-diagonal upper bound. Diagnose incompatible definitions with resource/field/constraint values; never silently enlarge contact range. Equal default radii satisfy this condition.
- Weapon/contact distances are independent. This feasibility bound does not redefine contact as collision overlap or require contact distance to equal visual radii.

## Runtime entities and ownership

| Entity / owner | Fields | Relationships and invariants |
|---|---|---|
| Run / coordinator | state Active/Paused/GameOver; active_time float; completed_step_count int; next_spawn_index int; next_spawn_at float; next_spawn_id int; run_generation int; spawn_failure_count int; acceptance_invalid bool; live registry; restart guard | Owns one encounter, arena/player/camera/weapon/HUD wiring; time starts 0, spawn deadline 1.5, ID sequence fresh; gameplay only Active |
| Player / player scene | position Vector3; current_health int; copied max_health/speed; normalized input Vector2 | Exactly one per encounter; fixed floor Y; inset containment; owns independent health and one weapon |
| Enemy / enemy scene | position; current_health; copied max_health/speed/contact settings; spawn_id; next_contact_at; dead flag | Sole enemy definition; unique ID within run; ready on spawn; live registry only while health > 0; no actor blocking |
| Weapon / player component | copied range/damage/interval; next_attack_at; current feedback | Initially deadline 0 (ready); uses registry snapshot, never stores persistent target; no eligible target leaves readiness unchanged |
| Arena / arena scene | bounds and spawn sampling RNG | Supplies clamp and valid position methods; no health/combat ownership; visual floor/strips replaceable |
| Camera / camera rig | yaw; depression; target ref; pending mouse input | Starts configured view; follows player in Active only; reset input buffer on state changes; no gameplay health dependency |
| HUD / HUD scene | displayed health/max/time; state overlay; restart intent | Presentation only; cannot apply damage or advance clock; HUD stays visible in every state |
| Profile capture / Main-owned helper | run_generation; segment origin; frame timestamps/count; enemy samples; survival_window_outcome; continuation_outcome; profile_capture_outcome; failure metadata | Profile mode only; coordinator opens/closes attempts; no acceptance merely at 300; buffer closes at endpoint/defeat, retained evidence before teardown; stale-generation records rejected |

Mutable fields belong to an instance, not a shared Resource. Health clamps to `[0, max_health]`; positive damage only. No regeneration. Dead enemies leave registry synchronously, cannot move/receive damage/attack or be selected, and their scene nodes are safely deleted by the next update.

## Eligibility and scheduling

Approved technical-review invariants: `active_time` counts only completed Active physics steps. Wall-clock stalls add no unsimulated survival time; profiling keeps a separate monotonic elapsed-wall clock. The coordinator owns `spawn_failure_count`, initially zero for each run, and a latched acceptance-invalid flag when that count becomes positive. Unexpected selection/instantiation failure consumes the due opportunity, increments the count once for that attempted spawn, and reports stage/cause/run generation/scheduled opportunity without halting simulation or retrying. Full-cap skips consume the opportunity but do not increment failures. Publish an enemy to the live registry only after successful instantiation/configuration; discard partial instances on failure so capacity and combat cannot observe a broken spawn. Detailed implementation is deferred.

- Squared XZ center distance `d² = dx² + dz²`; weapon eligible iff live and `d² <= range²`; contact eligible iff live and `d² <= contact_distance²`. Do not enlarge the threshold with an arbitrary epsilon. Test equality, just-inside and just-outside with representable fixtures. Exact tied squared distances choose smaller spawn_id.
- Actual attack at completion time `t_end` advances only that attacker's deadline to `t_end + interval`. No-target/no-contact does not consume readiness. Re-entry never resets an active deadline. Each attacker performs at most one attack in an update.
- Spawn opportunities belong to interval multiples starting at one interval. Consume cap-full opportunities. After an update crossing deadline(s), set next spawn to the first scheduled multiple strictly after `t_end`; produce at most one enemy. No queued missed opportunities or death-triggered replacement.
- Spawn selection tries 16 candidates, then a deterministically selected farthest inset corner; only strictly outside contact distance is valid. A seeded RNG can be injected by tests; ordinary runs need no saved seed or persistence.
- Pursuit travels `min(speed * delta, remaining XZ distance)` toward the already moved player, then applies radius-inset containment; coincidence does not move. This prevents overshoot without blocking actors.
- Active physics order is defined in [component contracts](contracts/gameplay-components.md). Pause preserves gameplay fields except presentation state/mouse capture; completed time/deadlines stay frozen after the pause/defeat transition completes. Diagnostic segment/buffer bookkeeping may change without advancing gameplay.

### Completion-time deadline semantics

At the beginning of an Active physics step, let `t_begin = active_time` (the last completed step) and `t_end = t_begin + delta`, where delta is the duration actually simulated by that step. **All spawn, weapon and contact deadlines are evaluated against completion time `t_end`, never `t_begin`**, after movement and in the documented order. These events are logically timestamped at `t_end`; commit `active_time = t_end` once the step finishes, including a deliberately short-circuited lethal step. No wall-clock stall duration is injected into delta. A paused/inactive update contributes no simulation time.

Use `t_end >= deadline` with no early-trigger epsilon. Spawn deadlines are integer opportunity indices multiplied by the configured interval; service the currently pending indexed opportunity at most once, then consume any other crossed opportunities without attempting them and advance to the first multiple strictly greater than `t_end`. A cap skip or unexpected failure consumes the opportunity; crossed opportunities never accumulate. Weapon/contact deadlines advance only after an actual attack to `t_end + interval`; no eligible target/contact preserves readiness. Each attacker performs at most one attack per step.

“Immediately” is the first eligible contact phase; “next gameplay update” is no later than the next executed Active step. At normal 60 Hz, deadline servicing is late by at most one physics tick (approximately 16.67 ms) in simulation time, not a wall-time latency guarantee. Positive sub-tick intervals remain valid but are serviced at most once per step; report effective cadence. Consecutive attacks are never closer than the configured interval. Persistent overlap never bypasses readiness even if a deliberately small interval permits one attack each tick. Floating comparison just below a deadline waits until the next step; use representable before/at/after fixtures. HUD rounding never determines readiness or the 300-second endpoint.

### Profile and attempt evidence ownership

Main creates/wires one capture helper only in Profile mode and owns its disposal; the coordinator explicitly opens/closes generation-tagged attempts. Normal Play has no frame sampler, but retains the per-run spawn-failure counter. Keep the helper independent of gameplay behavior and reject stale-generation samples/callbacks.

At 300 completed simulation seconds, close the five-minute frame/count buffer and write it after sampling under ignored workspace `.cache/`; keep only attempt/continuation/failure metadata afterward so unlimited survival does not create an unlimited frame buffer. Close diagnostic segments on pause and reopen the origin on resume without bridging inactive wall time. Defeat closes any unfinished segment. Before restart teardown, retain/seal the old attempt and its actual outcomes; open fresh buffers only after new definitions validate. On shutdown, Main writes remaining evidence then disposes the helper. Required-output write/capture failures leave profiling outstanding and are reported, never silently successful.

Record separately: survival-window outcome, continuation outcome, profile-capture outcome, and acceptance invalidity from unexpected spawn failures. Reaching 300 seconds is not full attempt acceptance. A 300-second window completed alive with normal tuning can retain successful survival evidence if later death prevents continuation observations. Full attempt acceptance requires that survival evidence, all required continuation evidence, successfully captured required profiling evidence, and zero unexpected spawn failures throughout the attempt, including continuation. Any unavailable required verification remains outstanding; recording its absence alone does not satisfy it. Later spawn failures update the attempt's invalidity even if its five-minute buffer is already closed. Feature acceptance additionally requires all prototype gates, not just this attempt. No worker, singleton, save system or new UI is introduced.

## State transitions

| From | Event | To | Effect |
|---|---|---|---|
| Initial | Valid definitions, scene ready | Active | Full health, center start/view, 00:00, no enemies, fresh spawn deadline, ready weapon; capture mouse |
| Active | Escape press, no echo | Paused | Stop gameplay/camera, clear pending input, show Paused, release mouse |
| Paused | Escape press, no echo | Active | Preserve time/deadlines/health/positions/view; recapture mouse; no accumulated motion/events |
| Active | Player health reaches zero | GameOver | Latch once with final t_end, abort later gameplay events, commit that completed step once, show Game Over/Restart; release mouse |
| GameOver | Restart activation | Active | Guard immediately, discard old encounter, increment generation, validate current definitions, recreate fresh state; capture mouse |
| GameOver | Escape | GameOver | No defeated-run resume |
| Active/Paused | Restart signal | unchanged | Ignore invalid/repeated activation |

Configuration failure is a startup/restart diagnostic outside the valid three-state gameplay model: keep simulation disabled and show actionable error; tests exit failed. Never represent invalid configuration as a valid Active run. On a restart failure, do not revive the defeated encounter.

Correct the invalid definition and relaunch the application to recover. No in-application configuration retry is required. Fresh valid runs reset the spawn-failure counter; a reset does not erase the previous attempt's failed acceptance record.

Profile samples and acceptance records are evidence artifacts, not save-game entities. No network, database, upgrade, experience or persistence schema is introduced.
