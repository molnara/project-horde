# Phase 3A test handoff

T014–T017 author tests; they do not implement T018 or any later component.
The required manifest now contains 48 cases: 13 executable foundation/fixture
cases and 35 gameplay cases pending production prerequisites. All seven new
scripts can import and parse now. A pending case is not executed, passed or
silently skipped. Missing prerequisites are printed per ID as
`HORDE_CASE_PENDING` and still fail required execution reconciliation.
Presence is checked on every run; no permanent skip marker must be removed.
A present but broken component produces a real assertion/engine failure.

Use the workspace-contained launcher, never a direct uncontained engine call:

```powershell
& ./tools/validate.ps1 -Mode All -SuiteScope Foundation
& ./tools/test-validation.ps1
& ./tools/validate.ps1 -Mode All
```

An optional `-GodotBin` absolute console path is supported by both launchers.
`Foundation` is an explicit limited suite, not gameplay acceptance. It still
discovers/reconciles the entire manifest before selecting its 13 cases. The
infrastructure wrapper uses that scope so its diagnostic/timeout/environment
fixtures can run before gameplay exists. Default `All` requires all 48 cases,
returns nonzero with pending gameplay, and stops dependent startup checks.
Bootstrap startup is independently exercised by the foundation command.
There is no engine-diagnostic suppression or reduced gameplay expectation.

## Coverage and prerequisites

Each ID below has a real assertion body, a fixed reported seed, a script path
and requirement mappings in `case_manifest.gd`. Some cases have several boundary
fixtures. The runner discovers every designated unit/integration script.

| Task / cases | Assertions against real behavior | Pending until |
|---|---|---|
| T014 `movement.directions` | W/S/A/D, opposing axes, release, straight/diagonal displacement at yaw 0/90, fixed floor Y | T019–T022 scenes |
| T014 `movement.mouse_follow` | right/up motion, same-step yaw, pitch-independent speed, depression bounds, synchronous follow, distance/FOV, above-floor camera | T019–T022 scenes |
| T014 `movement.containment` | both radii, all four corners, fixed configured floor/interior coordinates | T019–T022 scenes |
| T014 `movement.selection` | 16 rejected candidates, deterministic farthest-corner fallback, eligible zero success, strictly outside contact at exact/inside/outside fixtures, no new arena children | T019–T022 scenes |
| T014 `movement.selection_failure` | false discriminator, absent position, nonempty actionable payload, input observations, resource nonmutation | T019–T022 scenes |
| T014 `movement.pursuit` | overshoot/coincidence, XZ pursuit, equal/unequal radii, actual corner contact including inclusive feasibility equality | T019–T022 scenes |
| T015 `combat.health`, `combat.invalid_damage` | independent fresh health, nonlethal/excess loss, synchronous signals, one death, invalid input rejection without mutation | T018 health |
| T015 `combat.registry_death` | spawn order, synchronous removal, dead movement/contact exclusion, departed exclusion, deferred disposal, copied tuning | T018–T024, T028 dependencies |
| T015 `combat.targeting` | nearest target, earliest-ID tie, XZ exact/inside/outside range, dead/departed reassessment | T018–T024, T028 dependencies |
| T015 `combat.weapon_readiness` | initially ready/no-target preservation, before/at deadline, one hit after long gap, no regeneration | T018–T024, T028 dependencies |
| T015 `combat.contact` | XZ inclusive boundary, immediate first hit, persistent overlap, separation/re-entry, independent cooldowns, long gap | T018–T024, T028 dependencies |
| T015 `combat.feedback` | actual line/target material flash, target identity, absolute before/at expiry, restored material, no damage from presentation | T028 feedback and actors |
| T016 `survival.fresh` | real Main wiring, full health/view, zero clock/ticks/IDs/population/failures, full spawn delay, no normal-Play sampler | T027 core wiring |
| T016 `survival.cadence_cap`, `survival.default_custom_cap` | first three opportunities, three skips, no cap selection/failures, no death refill, next cadence, default 50 and configured 200 | T027 core wiring |
| T016 `survival.deadlines`, `survival.subtick_long_step` | completion-time before/at/after for spawn/weapon/contact, positive sub-tick cadence, no bursts/crossed backlog | T027 core wiring |
| T016 `survival.wall_stall` | real short wall wait does not award simulated time, next delivered delta only | T027 core wiring |
| T016 `survival.order`, `survival.lethal` | actual input→yaw→movement→follow→pursuit→selection→new-target weapon→contact, weapon kill excludes contact, spawn-order lethal abort, one final commit, cleared feedback | T027–T028 wiring |
| T016 `survival.hud`, `survival.startup_failure` | real labels at 0/65/fractional/6000 seconds, signal-wired health, invalid startup creates no encounter and shows diagnostic | T026–T027 wiring |
| T016 `survival.selection_fault` | absent failure position never read, factory never invoked, two records count once, enriched fields, no retry, next normal cadence, invalidity latch | T025–T027 wiring |
| T016 `survival.instantiation_fault`, `survival.partial_fault` | null factory/configuration failure, no partial publication, disposal, one consumed/counting failure | T025–T027 wiring |
| T017 `profile.boundaries`, `profile.sparse`, `profile.distribution` | t0 exclusion/t1 inclusion, full-window and full-interval denominators, boundary gaps/stalls, zero/one/two callbacks, percentiles/minimum/max/stall counts, enemy statistics | T030 actual statistics helper |
| T017 `profile.generations`, `profile.count_samples` | old attempt retention, stale frame/count/failure rejection, fresh buffers/counter, one-second completed samples with both timestamps | T029–T030 helpers |
| T017 `profile.endpoint`, `profile.lethal_endpoint` | wall time never closes window, completed >=300 endpoint, final ticks/time, separate survival/continuation/capture, actual written output, actual coordinator lethal endpoint | T029–T031 wiring |
| T017 `profile.bounded_late_failure`, `profile.continuation` | raw buffers released/not growing, late failure invalidity, unchanged tuning/vulnerability, time/view/movement and eligible attacks/spawns across 300 | T029–T031 wiring |

The two new immediately executable harness cases are `runner.prerequisites`
and `runner.fixtures`. They verify presence detection, strict unexecuted-case
failure, explicit scope, scripted sample counters/zero coordinates, multi-record
failure without a position, null/partial factories, cleanup and independent
case metadata. Passing these checks proves the test inputs and runner behavior,
not any missing gameplay algorithm.

## Construction and observation seam for Phase 3B

The approved contracts specify semantics, with GDScript construction details
left to implementation. These fixtures choose the following narrow provisional
seam. It is test wiring, not production code or an amendment to the contracts.
When components ship, reconcile constructor/property/node names in the fixture
adapter if their equivalent production interface differs; retain every behavioral
assertion. Never implement gameplay/statistics inside the adapter to satisfy a test.

- Arena/player scenes use `configure(subordinate_definition)`; enemy uses
  `configure(enemy_definition, spawn_id)` and exposes independent `health`.
  Health uses `configure(maximum)`, `current_health`, `max_health` and a
  `diagnostic(Dictionary)` signal for invalid amounts. Weapon/feedback use
  `configure(weapon_definition)`. All approved step methods retain their meanings.
- Camera yaw/depression are degrees. `queue_mouse(Vector2)` records input for
  the coordinator; `apply_mouse` applies it. `pending_mouse` is observable.
  Rig origin is the target-height pivot; camera node is `Yaw/Pitch/Camera3D`.
- Main accepts `run_definition` **before entering the tree**, wires/starts one
  encounter, and exposes `coordinator`. Fixture disables only its automatic
  physics driver, supplies seeded spawner `rng`, and calls real `step(delta)`.
  Components must not autonomously advance gameplay. Coordinator exposes model
  state/time/IDs/failures and its explicit player/camera/arena/registry/spawner/
  weapon/HUD/feedback/profile references. State observations use the semantic
  names `Active` and `GameOver`; invalid startup has `simulation_enabled=false`,
  no player/spawner, retained `configuration_diagnostics` and a usable error HUD.
- The spawner's injected `selection_callable` and `enemy_factory` are narrow
  dependency seams. Default callables use the real arena and real creation;
  `run.create_enemy` supplies the normal factory for restoration. Fault fixtures
  replace only these inputs. All cadence/cleanup/counter logic stays production.
  Spawner emits `diagnostic(Dictionary)`. Context serializes declared faults,
  matching exact case/source/constraint/count; no engine exception is expected.
- Invalid damage diagnostics use source `Health`, constraint `positive integer
  damage` (eight records). Spawn selection uses `fixture/arena`, `strictly outside
  contact distance` (two records); factory faults use `EnemySpawner`, `fully
  configured enemy before registry publication` (one record). Startup uses the
  existing validator's `PlayerDefinition`, `positive integer` (one record).
- HUD labels are `Health`, `Time`, `ConfigurationError`. Enemy visual material
  is `Visual.material_override`. Feedback has a visible `Line`, `target_spawn_id`,
  `expires_at`, `show_attack(t_end, attacker_position, target)` and `present(time)`.
- Statistics `summarize(t0, t1, frame_seconds, enemy_samples)` returns fields
  asserted in the statistics cases. Timestamps are monotonic seconds. The fixture
  chooses empirical **nearest-rank** percentiles; this is a documented algorithm
  choice, not an added performance threshold. No full interval yields null
  minimum/percentiles and an explicit unavailable reason. Adjacent timestamps
  are retained for boundary explanation only.
- Capture uses `configure(absolute_workspace_output_directory)`,
  `open_attempt(generation, t0)`, `record_frame(generation, wall_seconds)`,
  `record_step(generation, committed_time, ticks, wall_seconds, count, alive)` and
  `record_spawn_failure(generation, diagnostic)`. It exposes the model's buffers,
  generation/counter/outcomes plus endpoint duration/ticks/path. Endpoint recording
  must flush **real** evidence and release raw buffers. The integrated lethal test
  injects this actual helper into the real coordinator. This controlled test
  injection does not imply a normal-Play sampler or qualifying owner profile.

Only geometrical/statistical comparisons allow floating representation tolerance.
Eligibility/deadline fixtures use exact comparisons with representable adjacent
values. Seeded RNG tests and scripted center/edge inputs contain no production
selection algorithm. Test cleanup releases synthetic actions, disconnects
callbacks and disposes owned scenes even after an assertion failure.

## Outstanding manual verification

There is no playable scene yet. After Phase 3B implementation, repeat the
[quickstart owner scenarios](../specs/001-core-gameplay-prototype/quickstart.md):
all WASD directions/opposed/released/diagonal before and after yaw rotation,
pitch extremes/perimeter traversal, overlap without blocking, readable HUD,
automatic target line/flash, independent contact damage and lethal stop.
Pause/restart journeys belong to their later phases. The uninterrupted normal
300-second survival and real rendered profile remain separate owner acceptance
work; these deterministic fixtures cannot establish either.
