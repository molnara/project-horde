# Core gameplay verification ledger

Phase 2 (T005–T013), 2026-10-02 America/Toronto. Foundation readiness is
established; gameplay and prototype acceptance are outstanding. Constitution
v1.0.0 and the approved `001-core-gameplay-prototype` documents govern this ledger.
The bootstrap main scene remains an empty Node3D. A successful bootstrap startup
does not demonstrate a playable encounter.

## Reproduce the foundation checks

Run from the project root, using the existing approved console executable:

```powershell
& ./tools/validate.ps1 -Mode All
& ./tools/test-validation.ps1
# Either command accepts an optional -GodotBin <absolute console executable>.
```

`test-validation.ps1` runs the same All checks, then infrastructure fixtures.
It tests real absent/present process environment restoration and restores the
caller's original environment even on failure. Fixtures run only after actual
Godot paths have been verified. No external package, installation, global
configuration, asset or Git commit is introduced.

Limits remain 30 s version/help/path preflight, 180 s import, 30 s per parse,
120 s suite and 30 s bootstrap startup. An intentionally sleeping fixture uses
a one-second limit. Interactive Play/Profile have no timeout; Profile remains
blocked until its US1 capture helper exists. Unexpected timeout/failure requires
investigation and an explicit limit override, never an automatic retry loop.

## Definition and harness interfaces

Five typed Resource classes and five text `.tres` assets contain the exact
approved defaults in the data model. RunDefinition holds one Resource reference
for each subordinate definition; this permits actionable wrong-subtype authoring
diagnostics. Validation establishes precise types before gameplay may use them.
Health/damage/cap exports are typed integers. `is_positive_integer(Variant)` also
rejects integral floats, fractional values, strings, booleans, null and nonfinite
values without coercion. There is no cap ceiling; 200 validates.

`DefinitionValidator.validate(run_definition) -> Array[String]` returns an empty
array on success or JSON diagnostic strings containing source, field, observed,
constraint and cause. It does not print, repair values or mutate resources.
Unpathed fixture copies identify their logical definition; loaded authoring
resources identify their resource path. Invalid geometry never increases contact
range. Low visual boundaries must remain below the camera target height;
rendered perimeter visibility still needs playtesting.

Definitions contain tuning only. Runtime components must copy tuning on each
fresh run in their owning story tasks; mutable health, IDs and deadlines must
never be added to these Resources. Phase 2 tests prove isolated copies and pure
validation, not the future runtime snapshot behavior.

`tests/case_manifest.gd` registers explicit IDs, paths, requirement/edge mappings,
fixed seeds and expected application diagnostics. Only `test_*.gd` beneath
unit/integration are designated case files; support files are excluded and an
absent integration directory is expected until story cases arrive. Every case
must reach `ctx.done()` and execute at least one assertion. Runner reconciliation
rejects zero/missing/duplicate/unregistered/unexecuted cases and wrong paths.
Contexts provide independent definition copies, seeded RNG, owned-node teardown
and tracked signal disconnection. Cases finish cleanup before the next case.

The native runner observes engine errors with a thread-safe built-in
[Logger](https://docs.godotengine.org/en/stable/classes/class_logger.html), without
intercepting original engine output. Real engine errors make suite exit nonzero;
the launcher independently inspects streams and engine logs, including exit-zero
failures. Warnings are recorded separately. Ambiguous severity records require
investigation. Banners, progress/device output and ordinary informational text
containing the word error are allowed.

Expected application faults use `HORDE_CASE_BEGIN`, `HORDE_APP_DIAGNOSTIC`,
`HORDE_CASE_END` and `HORDE_SUITE_END` records. Only suite checks permit these
declarations. Each fault must match one open case's source/constraint and exact
declared count, and the case/suite must complete successfully. Real engine
severity is never excused by an application declaration. Faulted gameplay
attempts remain invalid for owner acceptance when those components are supplied.

## Executed evidence

The final omitted-override command selected persistent User GODOT_BIN after
Process scope was absent. Explicit override was independently executed in earlier
runs, and scope fixtures cover first-nonempty Process/User/Machine selection,
absent and inaccessible scopes, no read beyond selection and invalid-override
rejection. Only process-scoped environment values were modified.

Final raw session:
`.cache/validation/20261003T022501137-0deb4db82dbe47fd8454ab72deb3a3c9/`.
`results.json` retains exact absolute commands, exits, classifications and original
output references. `verified-paths.json` records the observed Godot paths.
`infrastructure-fixtures.json` and `infrastructure-child-results.json` preserve
fixture assertions and original intentional failed-child results separately.
These files are ignored local evidence; the summary here is tracked.

| Actual command/check | Outcome | Observation |
|---|---|---|
| `.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` | PASSED, exit 0 | Correct absolute feature directory and design documents |
| Requirements-quality checklist scan | PASSED | requirements 16/16; technical 36/36; markers unchanged |
| `tools/test-validation.ps1` (omitted override) | PASSED, aggregate exit 0 | All foundation checks and infrastructure assertions completed |
| Contained `--headless --version` and `--headless --help` | PASSED, exits 0 | `4.7.2.stable.official.ed1daf0bf`; required switches present; Standard confirmed |
| Isolated editor-path `--import` preflight | PASSED, exit 0 | User/data/config/cache/editor paths inside `.cache/`; editor project path inside isolated probe |
| Real project `--headless --path <workspace> --import` | PASSED, exit 0 | Source classes/resources imported without engine errors |
| `--script <each source/test .gd> --check-only` | PASSED, 12 exits 0 | Every project/test GDScript parsed, including the Logger helper |
| `--script res://tests/run_tests.gd` | PASSED, exit 0 | 11 required/discovered/executed cases; 539 assertions; no unexpected engine errors |
| `--quit-after 120` bootstrap | PASSED, exit 0 | Empty main scene loads; no playable startup claim |
| Infrastructure fixtures | PASSED | 103 assertions, actual selected-engine formats and subprocess outcomes |
| Caller environment comparison after launcher | PASSED | APPDATA/LOCALAPPDATA/TMP present values restored; TEMP and GODOT_BIN remained absent |
| Process environment records in `results.json` | PASSED | Exact present/absent/value restoration checked in launcher finally |
| PowerShell `Parser.ParseFile` on all three tools | PASSED | Zero syntax errors |
| `git check-ignore .cache/probe .godot/probe` | PASSED, exit 0 | Both generated roots ignored |
| Source `.gd.uid` inspection | PASSED | One required source UID per script; none ignored |
| `git diff --check` | PASSED, exit 0 | No whitespace errors |

Native seeds: definitions `4702001`; runner contracts `4702012`; isolated RNG
fixture `123`. Current case observations:

| Case ID | Actual observation | Status |
|---|---|---|
| definitions.defaults | Every configured default; custom cap 200 | PASSED |
| definitions.references | Missing/wrong run and four references; unsupported schema | PASSED |
| definitions.numbers | All positive fields, integer predicate, zero/negative/NaN/infinities, finite negative floor/yaw, sub-tick interval | PASSED |
| definitions.vectors | Both components of start/extents reject nonfinite values; nonpositive extents | PASSED |
| definitions.geometry | Radius equality rejected; start equality accepted and exterior rejected; tall boundary rejected | PASSED |
| definitions.camera | Inclusive depression endpoints; strict FOV endpoints; target bounds; positive camera height and overflow rejection | PASSED |
| definitions.boundaries | Exact 3–4–5 inset spawn upper bound rejected; just-inside accepted; inclusive unequal-radius lower bound accepted and just-outside rejected; incompatible bounds rejected | PASSED |
| definitions.nonmutation | Validation leaves invalid copies untouched; shared defaults unchanged | PASSED |
| runner.reconciliation | Complete/zero/duplicate/missing/unregistered/unexecuted/wrong-path cases and discovery | PASSED |
| runner.context | Independent copies, RNG repeatability, actual node disposal and external signal disconnection, completion tracking | PASSED |
| runner.diagnostics | Exact application expectation; missing/excess/wrong case/source/constraint/duplicate declarations | PASSED |

Intentional child failures are expected fixture evidence, not passing engine
commands. Every original FAILED child stays FAILED in its child-results file:

| Child | Actual result | Fixture conclusion |
|---|---|---|
| fixture-info | Exit 0, informational output | PASSED acceptance |
| fixture-warning | Exit 0, one warning | PASSED warning recording |
| fixture-zero-error | FAILED despite exit 0, genuine `ERROR:` | PASSED detection |
| fixture-error-monitor | FAILED, exit 1; one real engine error observed by native Logger | PASSED nonzero engine-error handling |
| fixture-assertion | FAILED, exit 1; real context assertion failure | PASSED nonzero assertion handling |
| fixture-parse | FAILED, exit 1; selected-engine Parse Error | PASSED detection |
| fixture-runtime | FAILED despite exit 0; real invalid-index SCRIPT ERROR | PASSED detection |
| fixture-resource | FAILED despite exit 0; deliberately missing resource | PASSED resource-load detection |
| fixture-timeout | FAILED, exit -1 after 1 s; wrapper PID 8268 and engine PID 22808 no longer alive | PASSED timeout, retained output and child cleanup |
| fixture-runner-empty/duplicate/missing/unregistered/unexecuted | Each FAILED, exit 1, real manifest reconciliation errors | PASSED incomplete-suite rejection |

Timeout PIDs are session-specific; the retained output/result is authoritative.
No unrelated process was terminated.

## Investigated failures and corrections

- One initial parallel read could not start because the sandbox helper could
  not apply deny-read ACLs. The sequential read succeeded; no file changed.
- Sandboxed Godot path preflight emitted `ERROR: Failed to read the root
  certificate store` despite exit 0. The launcher failed and did not execute
  the real project. An approved execution outside sandbox isolation resolved
  certificate access while preserving all workspace containment checks.
  Evidence: `20261003T021315203-02e51083d3f24feca15b790f40bba593`.
- Initial native suite failed its support-directory exclusion assertion. The
  generic directory discovery accepted support files. Discovery now explicitly
  restricts its root to unit/integration. The failure was retained at
  `20261003T021507732-0a556c53a5dc4e0fac0f76938c5c1b4a`; later suites passed.
- Initial scope-reader fixture failed: its closure did not capture the engine
  value from the caller's script scope. A local scope-value dictionary corrected
  the fixture. The launcher correctly blocked rather than continuing with an
  unverified selection. Evidence: `20261003T022014265-68876bf536fc452db5cc41de4a2d10d9`.
- PowerShell 7.6.6 preserved empty variables when `$null` was passed to the
  environment setter. The earlier absence fixture therefore did not prove
  actual absence. Both fixture setup and launcher restoration now remove a
  present process Env entry explicitly, and the final check confirmed absent
  TEMP remained absent. No persistent environment setting was changed.

## Per-clause gameplay acceptance

All rows below are **UNRUN**: their real components/scenes and owner tests belong
to T014 onward. Definition tests are prerequisites only. The verification column
names the future automated task or reproducible quickstart scenario; no listed
scenario has been performed. Update each row with its actual command/scenario,
observation and outcome when executed, rather than marking an entire FR passed
from one case. Manual steps refer to the approved quickstart's numbered owner
playtest. Every row has the same current observation: gameplay not implemented.

| Clause | Observable obligation | Verification when available | Status |
|---|---|---|---|
| FR-001.a | W forward, S backward, A left, D right before yaw change | T014; manual step 1 | UNRUN |
| FR-001.b | All directions follow 90-degree camera yaw | T014; manual step 1 | UNRUN |
| FR-001.c | Equal straight/diagonal speed and travel | T014; manual step 1 | UNRUN |
| FR-001.d | Opposing axes cancel | T014; manual step 1 | UNRUN |
| FR-001.e | Released input stops movement | T014; manual step 1 | UNRUN |
| FR-001.f | Pitch independent XZ motion with fixed Y | T014; manual step 1 | UNRUN |
| FR-002.a | Camera follows during traversal and perimeter movement | T014; manual step 1 | UNRUN |
| FR-002.b | Horizontal mouse rotates in same direction | T014; manual step 1 | UNRUN |
| FR-002.c | Upward mouse reduces depression; vertical look works | T014; manual step 1 | UNRUN |
| FR-002.d | Both look limits prevent inversion/floor crossing | T014; manual step 1 | UNRUN |
| FR-002.e | Player visible throughout arena/perimeter | Manual step 1 at normal view | UNRUN |
| FR-002.f | Mouse alone causes no player travel | T014; manual step 1 | UNRUN |
| FR-003.a | One flat small arena and visible boundaries | Manual step 1 | UNRUN |
| FR-003.b | Player radius-inset containment at edges/corners | T014; manual step 1 | UNRUN |
| FR-003.c | Enemy radius-inset containment at edges/corners | T014; manual steps 1–2 | UNRUN |
| FR-003.d | Original replaceable primitive geometry/provenance | T050; manual step 1 | UNRUN |
| FR-003.e | Player/enemy/floor/limits visually distinguishable | Manual step 1 | UNRUN |
| FR-004.a | Exactly one enemy type; first spawn after full interval | T016; manual step 2 | UNRUN |
| FR-004.b | Three consecutive opportunities each produce one enemy | T016; manual step 2 | UNRUN |
| FR-004.c | Pursuit follows moved player and reaches contact | T014/T016; manual step 2 | UNRUN |
| FR-004.d | Every spawn inside inset and strictly outside contact | T014/T016; manual step 2 | UNRUN |
| FR-004.e | No immediate contact damage at spawn | T016; manual step 2 | UNRUN |
| FR-004.f | Default cap 50 reached; three full-cap skips | T016; manual cadence scenario | UNRUN |
| FR-004.g | Death between opportunities does not refill immediately | T016; manual cadence scenario | UNRUN |
| FR-004.h | Below-cap refill at next ordinary opportunity only | T016; manual cadence scenario | UNRUN |
| FR-004.i | No queued/catch-up bursts or scaling/waves | T016; manual cadence scenario | UNRUN |
| FR-004.j | Fresh interval/cap tuning changes actual behavior | T016; manual changed-definition run | UNRUN |
| FR-004.k | Selection/instantiation faults consume/count once and diagnose | T016 fault injection | UNRUN |
| FR-004.l | Faulted runs continue ordinary cadence and are invalid | T016 fault injection | UNRUN |
| FR-004.m | Cap skips do not select or count as faults | T016 fault injection | UNRUN |
| FR-005.a | Exactly one automatic weapon; nearest living target only | T015; manual step 2 | UNRUN |
| FR-005.b | Equal-distance tie chooses earliest spawn ID | T015 tie fixture | UNRUN |
| FR-005.c | Exact range eligible, beyond range ineligible | T015 range fixtures | UNRUN |
| FR-005.d | No target means no attack/damage or readiness consumption | T015 no-target fixture | UNRUN |
| FR-005.e | Configured positive damage applied once per attack | T015; manual step 2 | UNRUN |
| FR-005.f | Actual attacks have configured interval and no early trigger | T015 deadlines | UNRUN |
| FR-005.g | Fresh weapon ready; eligible target attacked by next update | T015 readiness | UNRUN |
| FR-005.h | Eligibility reassessed; dead/departed targets excluded | T015 lifecycle | UNRUN |
| FR-005.i | Fresh range/interval changes eligibility/cadence | T015; manual changed-definition run | UNRUN |
| FR-005.j | Visible attack line/target flash identifies affected enemy | T015 expiry; manual step 2 | UNRUN |
| FR-006.a | Fresh player/enemy full configured health | T015; manual step 1 | UNRUN |
| FR-006.b | Independent health and unchanged shared tuning | T015 instance isolation | UNRUN |
| FR-006.c | Nonlethal/excess damage subtracts and clamps zero | T015 damage fixtures | UNRUN |
| FR-006.d | Waiting does not regenerate | T015; manual step 2 | UNRUN |
| FR-007.a | Enemy zero health causes one death/removal by next update | T015; manual step 2 | UNRUN |
| FR-007.b | Dead enemy cannot move, be targeted or receive damage | T015 lifecycle | UNRUN |
| FR-007.c | Former enemy position is no damage source | T015 lifecycle | UNRUN |
| FR-008.a | Inclusive squared XZ contact, independent of Y/overlap | T015 contact fixtures | UNRUN |
| FR-008.b | First eligible contact gives configured damage immediately | T015; manual step 2 | UNRUN |
| FR-008.c | Exact threshold damages; exterior does not | T015 boundaries | UNRUN |
| FR-008.d | Persistent contact respects per-enemy interval | T015; manual step 2 | UNRUN |
| FR-008.e | Separation stops damage | T015 separation | UNRUN |
| FR-008.f | Re-entry never resets/bypasses remaining delay | T015 re-entry | UNRUN |
| FR-008.g | Two contacting enemies contribute independently | T015; manual contact scenario | UNRUN |
| FR-008.h | Contact does not physically block overlapping actors | T014/T015; manual step 2 | UNRUN |
| FR-008.i | Fresh contact-distance tuning changes actual eligibility | T015; manual changed-definition run | UNRUN |
| FR-009.a | Fresh HUD full current/max health and 00:00 | T016; manual step 1 | UNRUN |
| FR-009.b | 65 active seconds reads 01:05 within one second | T016; manual HUD scenario | UNRUN |
| FR-009.c | Damage updates health by next gameplay update | T016; manual step 2 | UNRUN |
| FR-009.d | HUD readable and remains visible inactive | Manual steps 1, 3–4 | UNRUN |
| FR-009.e | Ten paused/defeated seconds do not advance health/time | T034/T042; manual steps 3–4 | UNRUN |
| FR-010.a | Lethal damage displays zero health, Game Over/final time | T034; manual step 4 | UNRUN |
| FR-010.b | Actionable mouse/keyboard Restart offered by next update | T034; manual step 4 | UNRUN |
| FR-010.c | Movement/view/spawn/attack/damage/time freeze on defeat | T034; manual step 4 for ten seconds | UNRUN |
| FR-010.d | Escape cannot resume defeat | T034; manual step 4 | UNRUN |
| FR-011.a | Restart creates exactly one active run in same application | T034; manual step 4 | UNRUN |
| FR-011.b | Full health, start position/view, zero time/population | T034; manual step 4 | UNRUN |
| FR-011.c | Weapon ready and full first-spawn interval restored | T034; manual step 4 | UNRUN |
| FR-011.d | Three cycles avoid duplicate events/carried damage | T034; manual step 4 | UNRUN |
| FR-011.e | Repeated activation guards against duplicate encounters | T034; manual step 4 | UNRUN |
| FR-012.a | Escape toggles once per alive press; echo ignored | T042; manual step 3 | UNRUN |
| FR-012.b | Visible Pause indication; HUD persists | T042; manual step 3 | UNRUN |
| FR-012.c | Pause freezes movement/view/spawn/attack/damage/time | T042; manual step 3 for ten seconds | UNRUN |
| FR-012.d | Remaining delays preserved between events and contact | T042; manual step 3 | UNRUN |
| FR-012.e | Resume preserves state without catch-up or input jump | T042; manual step 3 | UNRUN |

## Specified edge cases and cross-cutting contracts

| Edge/contract | Required future observation | Verification | Status |
|---|---|---|---|
| No enemy in range | No attack/damage; other gameplay continues | T015/T016 | UNRUN |
| Exact/beyond weapon range | Inclusive equality; no exterior target | T015 | UNRUN |
| Exact/beyond contact threshold | Inclusive equality; exterior safe | T015 | UNRUN |
| Tied targets | Earliest spawn wins | T015 | UNRUN |
| Target dies/leaves range | Reassess; removed enemy receives no damage | T015 | UNRUN |
| Multiple contacts | Independent readiness; health nonnegative; Game Over once | T015/T034 | UNRUN |
| Persistent overlap | No blocking or per-frame extra damage; bounds hold | T014/T015 | UNRUN |
| Cap/death between opportunities | Skip without backlog; next-cadence refill only | T016 | UNRUN |
| Lethal coincident event | Abort later events; final t_end committed once | T016/T034 | UNRUN |
| Pause between attacks/spawns | Preserve remaining delays, no missed work | T042 | UNRUN |
| Escape during defeat | No defeated-run resume | T034 | UNRUN |
| Repeated Restart | One fresh run and event stream | T034 | UNRUN |
| Diagonal/boundary contact | No speed advantage or containment escape | T014 | UNRUN |
| Unexpected spawn fault | Consume/report/count once; continue, invalid attempt; cap skip exempt | T016 | UNRUN |
| Same-step mouse/WASD | Movement uses newly consumed yaw | T014/T016 | UNRUN |
| Spawn selection result | Valid Vector3.ZERO distinguished from absent failure position | T014/T016 | UNRUN |
| Selection side effects | No arena scheduling/accounting/instantiation | T014/T016 | UNRUN |
| Partial instantiation | Never published; disposed before next ordinary cadence | T016 | UNRUN |
| Completion-time deadlines | Before/at/after t_end; no early-trigger epsilon | T015/T016 | UNRUN |
| Sub-tick intervals and long steps | At most one action/step; no catch-up; effective cadence recorded | T016 | UNRUN |
| Wall stall | No unexecuted simulation credit | T016/T017 | UNRUN |
| Invalid startup/restart | Simulation disabled; visible field diagnostic; no revived encounter | T016/T034 | UNRUN |
| Runtime tuning snapshot | Fresh-run copies; existing run unchanged by shared edits | T015/T016/T034 | UNRUN |
| Profile lifecycle/boundaries | Generation isolation, sparse samples, partial gaps, bounded buffers, output failures | T017/T035/T043 | UNRUN |
| 300-second continuation | Same tuning/vulnerability, continued eligible deadlines; no timed ending | T017/T031 | UNRUN |
| Post-window death/fault | Preserve survival observations; continuation outstanding or acceptance invalid | T035 | UNRUN |

## Success gates and outstanding manual verification

| Gate | Current observation | Status |
|---|---|---|
| SC-001 | Ledger established; real FR/edge results above outstanding | UNRUN |
| SC-002 | Three owner defeat/restart cycles require US1/US2 | UNRUN |
| SC-003 | Ten real seconds paused during combat/between events require US3 | UNRUN |
| SC-004 | Owner controls/boundaries/HUD/kill/contact/pause/restart journey unavailable | UNRUN |
| SC-006 survival window | No actual owner 300-completed-simulation-second attempt | UNRUN |
| SC-006 continuation | No later advancing clock, response or scheduled opportunity observed | UNRUN |
| SC-007 capture/performance | Profile helper and actual rendered owner run not implemented/executed | UNRUN |
| SC-005 future benchmark | No representative 200-enemy measurement; constitutional 60 FPS target unchanged | UNRUN, future scope |
| Graphical foundation/Play | Empty bootstrap only; graphical launch not performed | UNRUN |
| Profile launch | Required US1 helper absent | BLOCKED |

There are no skipped required foundation checks in the final run. The absent
integration directory is an explicitly expected prerequisite state, not evidence
of integration coverage. Gameplay manual steps are deferred until their scenes
exist: follow quickstart steps 1–4 for controls/visuals/game feel and step 5 with
the approved profile procedure for survival/continuation/capture. Keep those
outcomes separate; neither headless tests nor reaching 300 alone grants feature
acceptance. Phase 3 may begin from this verified foundation.

## Phase 3A — T014–T017 test authoring, 2026-10-02

This section supersedes the Phase 2 test-inventory/readiness observations above.
The existing FR/edge/success ledger remains valid: **gameplay assertions and
owner acceptance have not executed**. The integration directory now exists and
contains authored cases; directory presence does not establish gameplay coverage.
T014–T017 deliverables are test authoring/fixtures/registration, completed here.
T018 onward remains unchecked and unimplemented. No production script, scene,
definition, asset or project setting changed. No commits or pushes were made.

The [test handoff](../../tests/README.md) lists all new IDs, boundary fixtures,
component prerequisites, provisional constructor/observation seams and future
manual steps. There are 48 required registered cases: 13 foundation/fixture cases
that execute now and 35 pending gameplay cases (6 movement, 7 combat, 13
survival-loop, 9 profile/continuation). Each has a concrete assertion body against
real production components, fixed seed, explicit prerequisites, path and FR/edge
mapping. Helpers supply wiring/scripted randomness/fault inputs only. They do not
implement movement, combat, scheduling, statistics or a substitute encounter.

Missing production files are detected before loading, reported per case, and
remain **unexecuted** for strict manifest reconciliation. The default suite
therefore returns exit 1. It cannot grant a pass to a pending case. Once files
exist, their cases automatically become runnable; malformed scripts/interfaces,
real assertions and engine errors still fail. `-SuiteScope Foundation` is an
explicit independent check, with full authoring/discovery reconciliation before
selecting its subset. It is not full-suite or feature acceptance.

### Actual commands and results

Commands ran at the project root with the approved existing console executable
supplied via `-GodotBin`; no installed software/global configuration was changed.
Machine-specific executable paths are retained only in ignored raw logs.

| Executed command/check | Actual result | Status |
|---|---|---|
| `./tools/validate.ps1 -Mode All -SuiteScope Foundation` in sandbox | Exit 1; Process/User/Machine GODOT_BIN absent/hidden, no engine launched | BLOCKED environment attempt |
| Same command with authorized registry access outside isolation | Exit 0; engine/help/path checks, import, all 19 parses, then 12 initial foundation cases and bootstrap startup passed before the final fixture additions | PASSED intermediate snapshot |
| `./tools/test-validation.ps1 -GodotBin <approved console path>` in sandbox | Exit 1; path preflight child exit 0 still emitted `ERROR: Failed to read the root certificate store.`; classifier correctly failed; project checks unrun in this attempt | FAILED environment attempt |
| Same infrastructure command outside isolation, final snapshot | Exit 0; Godot `4.7.2.stable.official.ed1daf0bf`, verified actual workspace-contained paths, import and all 19 script parses passed | PASSED |
| Native suite invoked by final infrastructure command with `--foundation-only` | Exit 0; 13/13 executed, 554 assertions, 48 authored, 35 explicitly excluded by scope; zero suite warnings | PASSED foundation only |
| Bootstrap main invoked by final infrastructure command with `--quit-after 120` | Exit 0, no recognized engine/script errors; still an empty bootstrap | PASSED bootstrap only |
| Final infrastructure fixtures | 103 assertions passed, including intentional failed children/one-second timeout and genuine exit-zero error classification; environment restoration checks passed | PASSED |
| `./tools/validate.ps1 -GodotBin <approved console path> -Mode All`, final snapshot | Preflight/import/all 19 parses passed; native full suite exit 1: 13 cases executed/554 assertions, 35 explicit pending records, 35 unexecuted-case failures, `passed=false`, zero suite warnings | FAILED full suite; expected component blockers |
| Startup after failed strict full suite | Launcher halts dependent work after suite failure; bootstrap independently ran above | UNRUN in full command |
| Gameplay case assertions | Missing real health/arena/actor/camera/registry/weapon/spawner/HUD/coordinator/feedback/profile components; no fake pass | BLOCKED / UNRUN |
| Controls/visuals/game feel, uninterrupted owner survival, actual rendered profiling | No playable gameplay exists yet | UNRUN |
| Required foundation checks | None skipped in final limited run | No skipped required checks |

The root-certificate-store failure was investigated in captured diagnostics and
resolved by the authorized run outside sandbox isolation. It was not suppressed
or accepted as a successful zero-exit check. The final full-suite nonzero is
specifically caused by required pending/unexecuted cases, not an unexpected
engine exception. Its launcher records the suite and propagated launcher failure
separately; both refer to that one unmet gameplay prerequisite condition.

Raw evidence (ignored, workspace-relative):

- Final passing infrastructure/import/parse/foundation/startup:
  `.cache/validation/20261003T031505741-1bc5f61cb3674792a45914870063eece/`.
- Final strict full-suite pending failure:
  `.cache/validation/20261003T031713260-6e240c1b75fb46a894c0a4de1e35370d/`.
- Sandbox certificate-store attempt:
  `.cache/validation/20261003T030752776-b5e3e29628604399abf3c2573aad8916/`.

Each session retains exact child command/exit/outcome, original streams, engine
logs, results and environment restoration. Infrastructure expected failed child
results are retained separately with fixture assertions. The deliberate warning
fixture was recorded; there were no warnings in the final native suite.

### Changed files and Phase 3B readiness

- Added `tests/unit/test_movement_arena.gd`, `test_combat.gd`,
  `test_profile_capture.gd`, and `tests/integration/test_survival_loop.gd`.
- Added `tests/support/gameplay_fixture.gd`, `scripted_rng.gd`, `spawn_faults.gd`;
  all seven new scripts have required source `.gd.uid` files.
- Updated `tests/case_manifest.gd`, `tests/run_tests.gd`,
  `tests/support/test_context.gd`, `tests/unit/test_runner_contract.gd` for
  registration, explicit pending/scoping, fixture verification and input cleanup.
- Updated `tools/validate.ps1`, `tools/test-validation.ps1` for the explicit
  independent foundation suite; diagnostic failure expectations are unchanged.
- Added `tests/README.md`; updated this ledger and the feature's `tasks.md`
  completion markers for T014–T017 only.

Ready for Phase 3B **implementation** from T018: executable foundations and
parseable registered tests are established. Full gameplay validation is blocked
until the corresponding T018–T031 components/wiring exist. Constructor/property/
node/statistics-result names in the adapter are documented provisional choices;
reconcile those seams to actual components without weakening behavioral bounds
or adding algorithms to the test helper. Run default full validation as components
arrive and require executed passing story cases before the US1 checkpoint.
Manual SC gates and the 200-enemy performance target remain unverified. The
extension registry was checked before/after implementation and is absent, so no
extension hook was registered or dispatched. Work stops after T017.
