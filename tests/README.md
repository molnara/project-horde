# Core gameplay test handoff — Phase 4 Batch 1

T014–T017 authored the tests before implementation. T018–T032 now supply the
production components and technical verification. The original 48 registered
cases remain required: 13 foundation/fixture and 35 gameplay cases (6 movement,
7 combat, 13 survival-loop, 9 profile/continuation). Batch 1 adds three executable
defeat regressions, for 51 registered cases, plus 13 explicitly deferred cases.
Actual commands/results are in the [verification ledger](../docs/verification/core-gameplay.md).
A pending case is not executed, passed or silently skipped. If a prerequisite
is missing, it is printed per ID as
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
fixtures can run before gameplay exists. Default `All` requires all 51 registered cases,
returns nonzero for any pending or failed case, and stops dependent startup checks.
Both commands exercise real main-scene startup; when the capture helper exists,
they also run a short headless `--profile` startup/shutdown. The resulting sparse
capture is diagnostic evidence, not rendered profiling or survival acceptance.
There is no engine-diagnostic suppression or reduced gameplay expectation.

Phase 3B profiling repair: `profile.bounded_late_failure` now persists and rereads
all 1,050,001 synthetic callbacks exactly, including every chunk boundary/tail,
one injected stall and an endpoint gap. Statistics cases compare streamed
results against the original array reference for boundaries, sparse captures,
distributions and enemy counts. The original 48-case inventory remains intact.
Infrastructure fixtures cover missing/incomplete/duplicate receipts, actual
output-directory failure, truncated raw evidence and failed outcomes output;
each actual capture fault fails the launcher despite engine exit zero.

For a brief independent rendered callback audit, run:

```powershell
& ./tools/test-validation.ps1 -RenderedProfileSmoke
```

The optional smoke starts graphical Main for 6,000 engine iterations and checks
one raw callback per successive engine draw ID. It proves capture wiring, not
five-minute survival, visual acceptance or SC-007 completion. Default tests stay
headless. All generated files remain in the ignored workspace cache.

Profile output now consists of a JSON manifest/summary, `.json.frames.bin` raw
stream, and `.json.outcomes.json` shutdown outcomes. Preserve all three. Read the
manifest's `frame_stream` descriptor: raw data contains little-endian float64
wall seconds in original callback order, exactly eight bytes per sample; no JSON
`frame_timestamps` array is emitted. The sampler holds at most 4,096 timestamps
and flushes every chunk without decimation or overwrite. Exact source-clock
microsecond frequency counts keep percentile calculations independent of raw
callback volume. Chunk I/O is included in sampler overhead and wall-time stalls.
Profile launcher success means complete application capture, with survival and
continuation reported separately; it never grants owner/performance acceptance.

## Coverage and prerequisites

Each ID below has a real assertion body, a fixed reported seed, a script path
and requirement mappings in `case_manifest.gd`. Some cases have several boundary
fixtures. The runner discovers every designated unit/integration script.

## Batch 1 authored coverage and registration gates

`Manifest.entries()` contains only the 51 executable cases. `staged_entries()`
is an authored inventory, not execution registration. The runner loads every
fixture, checks every declared method, and reconciles discovery against both
inventories before selecting executable cases. Unknown, duplicate, missing or
malformed cases still fail. Required cases still require successful execution.
Every staged ID prints `HORDE_CASE_DEFERRED` with its task gate and the explicit
status `authored, unregistered, unrun`. Suite results separately report
`registered=51`, `authored=64`, `deferred=13`; deferred cases do not count as passes,
pending executions or Foundation scope exclusions. No automatic method-existence
skip or expected-failure assertion is used.

| Case ID | Requirements covered | Current status / prerequisite |
|---|---|---|
| `defeat.lethal_commit` | FR-010: one health death/state transition, abort later contacts, final t_end/tick/time signal once, repeated lethal notifications | Executable Phase 3B regression |
| `defeat.freeze_escape` | FR-009/010: 600 inactive 60 Hz steps, WASD/mouse/Escape/echo, unchanged state/positions/view/health/time/ticks/IDs/deadlines/enemy health/feedback/outcomes, no spawn/attack/commit events; UI tree unpaused | Executable Phase 3B regression; ten-second equivalent, not a real-time playtest |
| `defeat.final_hud` | FR-009/010: visible zero health and final 01:05 by lethal update | Executable Phase 3B regression; does not assert future overlay |
| `defeat.game_over_control` | FR-010/011: visible Game Over/final time, exactly one labeled actionable focused Restart, hidden in Active, presentation signal reaches real restart | Deferred T036–T039 |
| `defeat.three_cycles` | FR-011/SC-002: dirty movement/view/health/time/IDs/cooldowns/population/feedback/outcomes, complete fresh state across three cycles, new ID zero/contact-ready/full-health enemies, full spawn delay and one event, unchanged definitions; normal Play has no sampler | Deferred T036–T039 |
| `defeat.guarded_requests` | FR-011: Active/Paused invalid requests/signals, immediate reentrant teardown guard, repeated activations, one generation/coordinator | Deferred T036–T039; Paused is injected as an invalid precondition, not US3 implementation |
| `defeat.stale_callbacks_removal` | FR-011: synchronous detach/registry cleanup, old signals and saved real connected Callables after restart, deferred disposal by next update | Deferred T036–T039 |
| `defeat.invalid_restart` | FR-011/configuration edge: discard old encounter, increment generation, block fresh invalid health, actionable visible diagnostics, no revival/retry/simulation | Deferred T036–T039 |
| `defeat.failure_isolation` | FR-011/spawn edge: two fault records count as one old failed opportunity; fresh counter/invalidity/diagnostics/selector reset, normal cadence | Deferred T036–T039 |
| `restart_evidence.seal_before_teardown` | T035: actual raw/count buffers closed, files and committed outcomes checked during spawner tree exit, retained once before new generation | Deferred T039–T040 |
| `restart_evidence.stale_generations` | T035: old frame/step/failure/continuation callbacks cannot modify new buffers, metadata, audit or retained attempt; new callback works | Deferred T039–T040 |
| `restart_evidence.valid_open` | T035: valid edited definitions applied before new evidence, unique path/serial, fresh buffers/counters/outcomes/conditions, old invalidity/failure evidence retained | Deferred T039–T040 |
| `restart_evidence.invalid_no_open` | T035: invalid fresh definitions publish no encounter/new buffer/serial; sealed old files/metadata survive; late frame cannot reopen capture | Deferred T039–T040 |
| `restart_evidence.shutdown_fault` | T035: real required-sidecar file-open failure in Main shutdown, outstanding capture and diagnostics, partial artifacts retained, unfinished survival never accepted | Deferred T039–T040; launcher diagnostic matching also needs T041 integration (below) |
| `restart_evidence.write_fault` | T035: real endpoint manifest file-open failure retained in old metadata/sidecar across restart; clean fresh diagnostics never rewrite old failure | Deferred T039–T040; launcher diagnostic matching also needs T041 integration (below) |
| `restart_evidence.post300_death` | SC-006/007: actual coordinator 300 crossing alive then lethal 300.125 step; endpoint manifest/time/ticks preserved; missing continuation stays outstanding, no full acceptance; old outcomes survive restart | Deferred T039–T040 |

No T035 case is registered yet, including `shutdown_fault`, whose underlying
helper/Main shutdown behavior already exists. Existing `profile.generations`,
`profile.lethal_endpoint`, `profile.bounded_late_failure` and `profile.continuation`
remain executed helper/endpoint coverage; they cannot prove new restart wiring.

Fixtures reuse native Context/F, isolated definitions, seeds 4702034/4702035,
real scenes and callbacks. Only automatic physics driving is disabled. Slow
positive enemy speed/high enemy health isolate scheduling without copying any
gameplay algorithm. Evidence fixtures inject the real Main-owned capture and
frame callback exactly as the existing integrated lethal fixture injects capture.
All fault directories/files remain under ignored `.cache/restart-evidence-fixtures/`.

The semantic contract supplies `request_restart()` and `restart_requested()`;
new HUD node paths are deliberately not assumed (controls are inspected only
inside the HUD). The synchronous fresh-run fixture seam assumes a stable
coordinator, a reused Main-owned capture helper, and fresh state on return from
`request_restart()`. The spec explicitly requires synchronous old removal and an
immediate guard, but does not fix fresh-construction scheduling or helper identity.
If Batch 2 adopts deferred construction or replaces either owner, adapt the
fixture wiring/await boundary while preserving all behavioral assertions.

Two integration details need attention in Batch 2/T041. Clearing signal
connections alone cannot reject already queued old Callables on a retained
coordinator/HUD; fixtures save and invoke the real connected callbacks. Also,
`validation_diagnostics.ps1` currently treats every `Profile capture failure:`
line as fatal even when Context declares the exact ProfileCapture fault. T041
must match these expected fault records by case/source/constraint/count (and
matching printed payload); ordinary capture failures and genuine engine errors
must remain fatal. Batch 1 leaves the classifier and capture behavior unchanged.

At T041, after T036–T040 are implemented, move ready staged entries into
`entries()`, remove their staging declarations, and update the explicit inventory
counts in `runner.prerequisites`. Then run contained All with all US2 assertions
required; no assertion relaxation or silent exclusion is permitted. T035 must
wait for both T039 and T040. The T041 checkpoint and owner acceptance remain open.

## Original Phase 3B coverage

All prerequisites in the following table are implemented. The last column
identifies their owning tasks; it does not indicate a remaining pending case.

| Task / cases | Assertions against real behavior | Component tasks |
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

## Implemented construction and observation seam

The approved contracts specify semantics. Production implements the following
construction and observation seam, so the fixture adapter needed no changes.
It remains wiring only; it contains no substitute gameplay/statistics algorithm.

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

Binary arithmetic constructs actual before/after deadline neighbours. The selected
engine received the former decimal `0.9999999999999999` contact input as exactly
1.0; added assertions now verify inputs really bracket their deadlines. The
long-step scheduling fixture uses positive slow pursuit so extra actors cannot
add unrelated contact hits during its eight-second step. All existing assertions
are retained. Added observations check written endpoint outcomes, coordinator
tuning snapshots after source edits, and actual continuation metadata with
non-binary camera geometry. No manifest, case ID, seed or requirement mapping changed.

Only geometrical/statistical comparisons allow floating representation tolerance.
Eligibility/deadline fixtures use exact comparisons with representable adjacent
values. Seeded RNG tests and scripted center/edge inputs contain no production
selection algorithm. Test cleanup releases synthetic actions, disconnects
callbacks and disposes owned scenes even after an assertion failure.

## Outstanding manual verification

The main scene now runs the US1 loop. Repeat the
[quickstart owner scenarios](../specs/001-core-gameplay-prototype/quickstart.md):
all WASD directions/opposed/released/diagonal before and after yaw rotation,
pitch extremes/perimeter traversal, overlap without blocking, readable HUD,
automatic target line/flash, independent contact damage and lethal stop.
Pause/restart journeys belong to their later phases. US1 defeat stops the loop;
close/relaunch for another attempt. Use Alt+F4 to close while the mouse is captured.
Pause and Restart controls are not yet supplied. The uninterrupted normal
300-second survival and real rendered profile remain separate owner acceptance
work; these deterministic fixtures cannot establish either.
