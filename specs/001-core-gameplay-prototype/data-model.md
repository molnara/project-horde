# Data Model: Core Gameplay Prototype

**Status**: Proposed Phase 1 model; no definitions or gameplay instances exist yet.

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
- Weapon/contact distances are independent. No requirement equates visual radii with damage range or collision overlap.

## Runtime entities and ownership

| Entity / owner | Fields | Relationships and invariants |
|---|---|---|
| Run / coordinator | state Active/Paused/GameOver; active_time float; next_spawn_at float; next_spawn_id int; run_generation int; live registry; restart guard | Owns one encounter, arena/player/camera/weapon/HUD wiring; time starts 0, spawn deadline 1.5, ID sequence fresh; gameplay only Active |
| Player / player scene | position Vector3; current_health int; copied max_health/speed; normalized input Vector2 | Exactly one per encounter; fixed floor Y; inset containment; owns independent health and one weapon |
| Enemy / enemy scene | position; current_health; copied max_health/speed/contact settings; spawn_id; next_contact_at; dead flag | Sole enemy definition; unique ID within run; ready on spawn; live registry only while health > 0; no actor blocking |
| Weapon / player component | copied range/damage/interval; next_attack_at; current feedback | Initially deadline 0 (ready); uses registry snapshot, never stores persistent target; no eligible target leaves readiness unchanged |
| Arena / arena scene | bounds and spawn sampling RNG | Supplies clamp and valid position methods; no health/combat ownership; visual floor/strips replaceable |
| Camera / camera rig | yaw; depression; target ref; pending mouse input | Starts configured view; follows player in Active only; reset input buffer on state changes; no gameplay health dependency |
| HUD / HUD scene | displayed health/max/time; state overlay; restart intent | Presentation only; cannot apply damage or advance clock; HUD stays visible in every state |
| Profile capture / diagnostic helper | frame timestamp origin; buffered intervals; enemy samples; sampling state | Optional explicit profile mode; no gameplay behavior changes; ignored raw output, documented methods |

Mutable fields belong to an instance, not a shared Resource. Health clamps to `[0, max_health]`; positive damage only. No regeneration. Dead enemies leave registry synchronously, cannot move/receive damage/attack or be selected, and their scene nodes are safely deleted by the next update.

## Eligibility and scheduling

- Squared XZ center distance `d² = dx² + dz²`; weapon eligible iff live and `d² <= range²`; contact eligible iff live and `d² <= contact_distance²`. Do not enlarge the threshold with an arbitrary epsilon. Test equality, just-inside and just-outside with representable fixtures. Exact tied squared distances choose smaller spawn_id.
- Actual attack at active time `t` advances only that attacker's deadline to `t + interval`. No-target/no-contact does not consume readiness. Re-entry never resets an active deadline. Each attacker performs at most one attack in an update.
- Spawn opportunities belong to interval multiples starting at one interval. Consume cap-full opportunities. After an update crossing deadline(s), set next spawn to the first scheduled multiple strictly after `t`; produce at most one enemy. No queued missed opportunities or death-triggered replacement.
- Spawn selection tries 16 candidates, then a deterministically selected farthest inset corner; only strictly outside contact distance is valid. A seeded RNG can be injected by tests; ordinary runs need no saved seed or persistence.
- Active physics order is defined in [component contracts](contracts/gameplay-components.md). Pause preserves all fields except presentation state/mouse capture; time/deadlines never change while paused or defeated.

## State transitions

| From | Event | To | Effect |
|---|---|---|---|
| Initial | Valid definitions, scene ready | Active | Full health, center start/view, 00:00, no enemies, fresh spawn deadline, ready weapon; capture mouse |
| Active | Escape press, no echo | Paused | Stop gameplay/camera, clear pending input, show Paused, release mouse |
| Paused | Escape press, no echo | Active | Preserve time/deadlines/health/positions/view; recapture mouse; no accumulated motion/events |
| Active | Player health reaches zero | GameOver | Latch once, freeze final time, abort later gameplay events, show Game Over/Restart; release mouse |
| GameOver | Restart activation | Active | Guard immediately, discard old encounter, increment generation, validate current definitions, recreate fresh state; capture mouse |
| GameOver | Escape | GameOver | No defeated-run resume |
| Active/Paused | Restart signal | unchanged | Ignore invalid/repeated activation |

Configuration failure is a startup/restart diagnostic outside the valid three-state gameplay model: keep simulation disabled and show actionable error; tests exit failed. Never represent invalid configuration as a valid Active run. On a restart failure, do not revive the defeated encounter.

Profile samples and acceptance records are evidence artifacts, not save-game entities. No network, database, upgrade, experience or persistence schema is introduced.
