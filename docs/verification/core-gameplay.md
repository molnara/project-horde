# Core gameplay verification ledger

Current checkpoint: Phase 3B T033 closure, 2026-10-03.
The corrected owner capture is complete and internally consistent; its shutdown
sidecar independently verifies normal continuation beyond 300 simulation seconds.
The owner confirms warm-up and basic controls/boundaries/kill feedback/HUD, and
reports closing this new attempt with Alt+F4 before death.
The earlier owner-observed 05:11 survival/continuation/death remains separate
evidence. SC-007's capture is now verified, while acceptance still awaits missing
source provenance. All six T033 owner checks passed: the owner confirms paced
damage from 1–2 enemies and immediate lethal damage from roughly 10+ at 100 HP,
consistent with independent enemy attacks. T033 and Phase 3B are complete.
T034 begins Phase 4 and remains unstarted; full feature acceptance is outstanding.
Constitution v1.0.0 and the approved feature documents govern this
ledger. The Phase 2 and Phase 3A sections below preserve historical observations;
the final **Phase 3B T033 closure** supersedes readiness, pending-case and
per-clause statuses. Historical empty-bootstrap results are not gameplay evidence.

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

## Phase 3B — T018–T032 implementation and technical verification

Recorded 2026-10-03 UTC (2026-10-02 evening America/Toronto). This section
supersedes the historical pending/empty-bootstrap observations above. Review
started from clean branch `001-core-gameplay-prototype`, HEAD
`b66bff16c773f477356a85b84a346141f7b906ff`; the locally recorded origin branch
points to the same checkpoint. No fetch, commit or push was performed.

### Scope, dependencies and completion

The task file labels one Phase 3 US1 section. Its completed test-authoring part
is Phase 3A, T014–T017; its remaining implementation/checkpoint part is Phase 3B,
**T018–T033 inclusive**. Phase 4 starts at T034. Completed and marked:
**T018, T019, T020, T021, T022, T023, T024, T025, T026, T027, T028, T029,
T030, T031, T032**. T033 remains unchecked: owner visual/controls/game-feel
scenarios were not performed, and reproducible steps are supplied below.
No T034–T056 implementation or completion marker changed.

| Tasks | Dependencies | Delivered |
|---|---|---|
| T018–T023, T026 | Verified T013 and authored T014–T017; actor health uses T018 | Independent health; arena and primitive scenes; planar player/pursuit; bounded following camera; explicit live registry; value-only HUD |
| T024 | Health/registry | Ready nearest-target weapon, inclusive XZ eligibility, ID ties, absolute cooldown |
| T025 | Arena/enemy/registry | Indexed fixed spawn opportunities, cap skip, one failed-opportunity notification, enriched diagnostics and partial cleanup |
| T027 | T018–T026 | Validated fresh encounter, copied tuning, sole physics driver and specified completion-time ordering; lethal abort and final commit |
| T028 | Runnable wiring | Actual target line/material flash with absolute expiry and defeat clearing |
| T029–T031 | Runnable core → capture → statistics → continuation | Profile-only generation-tagged capture; bounded raw buffers and actual output; wall/full-interval statistics; separate survival, continuation, capture and invalidity outcomes |
| T032 | Complete implementation and existing case registration | Executed all unchanged manifest cases, import/parse/main/Profile startup and foundation/infrastructure validation; ledger updated |
| T033 | Playable loop and owner graphical participation | Steps supplied; actual owner scenarios UNRUN |

The main scene now runs US1 with exactly one weapon/enemy type, original
replaceable primitives, a readable-value HUD and minimal lethal stopping.
Pause, Restart, the full Game Over overlay and repeated-attempt UI remain later
story work. Close/relaunch supplies a fresh attempt at this boundary. The
definitions, spec, plan, accepted policies and manifest remain unchanged.

### Actual commands, exit codes and raw evidence

All successful engine runs used the existing console executable selected from
persistent User GODOT_BIN, version `4.7.2.stable.official.ed1daf0bf`, through the
contained launcher after authorized registry/certificate access. The launcher
verified actual engine/editor/cache/user paths under the workspace, restored
environment values, classified diagnostics and retained raw command records.

| Executed command/check | Actual result | Status |
|---|---|---|
| `./tools/validate.ps1 -Mode All -SuiteScope Foundation`, initial sandbox attempt | Exit 1; all GODOT_BIN scopes absent/hidden, no engine launched | BLOCKED environment attempt |
| Same foundation command with authorized access, before implementation | Exit 0; import, 19 parses, 13 cases/554 assertions and empty-bootstrap startup | PASSED baseline foundation |
| `./tools/validate.ps1 -Mode All`, first implementation run | Import/33 parses exit 0; suite exit 1, 48 executed/3486 assertions, three failing checks plus diagnostic reconciliation failure; dependent startup unrun | FAILED; investigated below |
| Same full command with temporary observation instrumentation | Suite exit 1; two remaining fixture failures; source diagnostic now passes; dependent startup unrun | FAILED investigation snapshot |
| Same full command after fixture-input repairs | Exit 0; 48/48, 3490 assertions, import/33 parses/main startup passed | PASSED intermediate snapshot |
| `./tools/test-validation.ps1` | Exit 0; import/33 parses, explicit Foundation suite 13/13 with 554 assertions, normal/Profile startup, 103 infrastructure assertions and environment restoration passed | PASSED foundation/infrastructure |
| `./tools/validate.ps1 -Mode All`, profile-output/continuation snapshot | Exit 0; 48/48, 3492 assertions, both startups passed | PASSED intermediate snapshot |
| `./tools/validate.ps1 -Mode All`, final code/tests | **Exit 0; 48/48, 3498 assertions, zero pending/excluded cases. Import, all 33 script parses, normal main startup and headless Profile startup each exit 0; no unexpected errors, warnings or ambiguous diagnostics** | **PASSED technical checkpoint** |
| Actual written Profile startup output and `.outcomes.json` inspection | Short committed duration below 300, no rendered callbacks/full intervals, survival and continuation outstanding; raw and outcome files exist | PASSED lifecycle only; rendered performance UNRUN |
| `git diff --check` | Exit 0; no whitespace errors; Git reports ordinary LF→CRLF notices | PASSED |
| Required automated checks | No missing prerequisite or skipped required case in final full run | None skipped/blocked |
| Owner graphical controls/visuals/game feel and rendered five-minute attempt | Not executed | UNRUN |

Raw evidence directories under ignored `.cache/validation/`:

- Baseline foundation: `20261003T034816134-74ece360bf1d437ca8f3fd263ac6c397/`.
- Initial implementation failure: `20261003T035613213-6413087a778243a78382429e2c0ee2d0/`.
- Diagnostic investigation: `20261003T035733726-2f596867878640c0b87014972ee3531b/`.
- Repaired initial passing loop: `20261003T035929372-9a9b6d4ca1e2456a89af5bf7862245a9/`.
- Foundation/infrastructure: `20261003T040207345-771efdff2ef2448792ff1cbcf6e4814d/`.
- Profile-output checkpoint: `20261003T040340169-0322e76d6edd4dd8ab03f6a9a087af5f/`.
- Final code/test checkpoint: `20261003T040641650-7867b16438604c1eb254e02f00b665b8/`.

Each directory retains `results.json`, original streams and engine logs.
Infrastructure intentional nonzero children/timeout and the declared warning
fixture are retained separately; their expected failures are not gameplay
failures. Synthetic profile evidence lives under `.cache/profile-fixtures/`;
real Main's short headless lifecycle writes `.cache/profile/`. Neither is an
owner survival/performance attempt.

### Investigated failures; acceptance assertions preserved

1. The unpathed validator's primitive-field diagnostic source was `player
   definition`, conflicting with the authored `PlayerDefinition` diagnostic
   contract. It now uses the resource script's actual global class name as its
   fallback. Loaded resources still identify their original resource path;
   validation constraints are unchanged.
2. The selected engine received the former `0.9999999999999999` contact fixture
   argument as **exactly 1.0**. The observed deadline was also 1.0, so damage
   was correct for the delivered input. Binary subtraction constructs the
   actual predecessor (`1 - 2^-53`); analogous weapon, feedback and completion
   boundaries use binary arithmetic too. Added checks prove the before/after
   inputs actually bracket their deadline. Production still uses `>=` with
   no epsilon, and every previous behavioral assertion remains present.
3. In the former long-step fixture, an eight-second pursuit step moved two
   spawned enemies to contact. They each correctly attacked once in addition
   to the original enemy, yielding health 50 instead of the asserted 70. A
   positive validated slow movement speed isolates scheduling, retaining
   exactly the same population/weapon/contact assertions. Default-speed
   pursuit, ordered integration and multiple independent contact tests still
   execute. No source behavior was distorted to suppress legitimate contacts.

No manifest entry, required case, seed, map or expected-fault declaration changed;
no assertion was removed or weakened. Extra assertions now verify persisted
capture outcomes, source-edit isolation for the whole encounter, actual separate
continuation outcomes/timestamps and valid non-binary camera geometry. The
fixture adapter is unchanged and contains no replacement gameplay algorithm.
All temporary investigation printing was removed before final validation.

### Newly executable cases and per-clause results

All 35 formerly pending gameplay cases are now executable and passed. The
complete ID inventory remains in [tests/README.md](../../tests/README.md) and
the unchanged manifest: six `movement.*`, seven `combat.*`, thirteen
`survival.*`, nine `profile.*`. No currently registered case remains pending.
Future US2/US3 cases T034–T035/T042–T043 are not yet authored/registered; they
are outside this checkpoint.

Every PASSED entry below refers to actual cases in the final full command
above, not a blanket story/FR acceptance claim. Each retains its separate
manual obligation. Geometry/visibility, normal owner survival and rendered
performance cannot be accepted from headless evidence.

| Clause(s) | Executed case(s) / actual observation | Current result |
|---|---|---|
| FR-001.a, b, c, d, e | `movement.directions`: all directions at yaw 0/90, normalized diagonal, opposing cancellation and release stop | PASSED automated; owner UNRUN |
| FR-001.f | `movement.directions`, `movement.mouse_follow`: fixed floor Y and pitch-independent travel | PASSED automated; owner UNRUN |
| FR-002.a | `movement.mouse_follow`, `survival.order`: synchronous follow of moved player | PASSED fixture follow; rendered perimeter UNRUN |
| FR-002.b, c, d | `movement.mouse_follow`: +90 yaw, upward reduction, both limits, above-floor camera | PASSED automated; owner direction/visibility UNRUN |
| FR-002.e | No rendered perimeter visibility observation | UNRUN manual |
| FR-002.f | `movement.mouse_follow`: mouse alone leaves player position unchanged | PASSED automated; owner UNRUN |
| FR-003.a, d, e | Arena/primitive source inspected and provenance recorded; no normal-view inspection | Implemented/source reviewed; manual UNRUN; final T050 reconciliation pending |
| FR-003.b, c | `movement.containment`, `movement.pursuit`: both radii, four corners, floor and reachable contact | PASSED automated; owner perimeter UNRUN |
| FR-004.a, b | `survival.fresh`, `survival.cadence_cap`: empty start, full first interval, first three opportunities | PASSED automated; owner UNRUN |
| FR-004.c | `movement.pursuit`, `survival.order`: bounded pursuit of moved target, coincidence and unequal radii | PASSED automated; owner redirection UNRUN |
| FR-004.d, e | `movement.selection`, `survival.order`: valid insets/strict exclusion and no same-step spawn contact damage | PASSED automated; owner UNRUN |
| FR-004.f | `survival.default_custom_cap`, `survival.cadence_cap`: cap 50/200 and three full-cap skips | PASSED automated; owner cadence UNRUN |
| FR-004.g, h, i | `survival.cadence_cap`, `survival.subtick_long_step`: synchronous capacity removal, next ordinary refill, no bursts | PASSED automated; owner UNRUN |
| FR-004.j | `survival.default_custom_cap`, `survival.deadlines`: fresh interval/cap tuning changes real cadence/population | PASSED automated; owner changed-definition run UNRUN |
| FR-004.k, l, m | `survival.selection_fault`, `instantiation_fault`, `partial_fault`, `cadence_cap`: consume/count once, enrich, dispose, continue, invalidity latch; cap exempt | PASSED fault-policy fixtures; faulted attempts invalid |
| FR-005.a, b, c | `combat.targeting`, `survival.order`: nearest/tie/inside/exact/outside and new-spawn targeting | PASSED automated; owner UNRUN |
| FR-005.d, e, f, g | `combat.weapon_readiness`, `combat.targeting`, `survival.deadlines`: no-target readiness, actual damage, fresh readiness, exact completion cooldown | PASSED automated; owner UNRUN |
| FR-005.h | `combat.targeting`, `combat.registry_death`: dead/departed reassessment and exclusion | PASSED automated; owner UNRUN |
| FR-005.i | `combat.weapon_readiness`, quiet survival fixtures: configured interval/range used by actual components | PASSED automated configurations; owner changed-definition run UNRUN |
| FR-005.j | `combat.feedback`, `survival.lethal`: actual line/material/target ID, exact expiry, cleared on defeat | PASSED scene-state assertions; rendered recognizability UNRUN |
| FR-006.a, b, c, d | `combat.health`, `invalid_damage`, `registry_death`, `weapon_readiness`, `survival.fresh`: full isolated health, clamp/one death, no regeneration, copied tuning | PASSED automated; owner UNRUN |
| FR-007.a, b, c | `combat.registry_death`, `combat.targeting`, `survival.order`: immediate exclusion, no later movement/damage/contact, disposal by next frame | PASSED automated; owner disappearance UNRUN |
| FR-008.a, b, c, d, e, f, g | `combat.contact`, `movement.pursuit`: inclusive XZ, first/persistent/separated/re-entry/independent contacts and corner equality | PASSED automated; owner UNRUN |
| FR-008.h | Node3D actors have no blocking bodies; overlap is exercised in pursuit/contact/order cases | PASSED automated overlap logic/source review; owner feel UNRUN |
| FR-008.i | `combat.contact`: fresh distance 1.0 replaces default 1.2, exact/exterior eligibility changes | PASSED automated; owner changed-definition run UNRUN |
| FR-009.a, b, c | `survival.hud`, `survival.fresh`: actual labels at zero/65/fractional/6000 seconds, signal-driven health | PASSED automated; owner readability UNRUN |
| FR-009.d | HUD retained in scene; no rendered Active/inactive readability check | UNRUN manual |
| FR-009.e | `survival.lethal`: another ten simulated seconds cannot advance defeated encounter; Pause/US2 journeys not executed | PASSED minimal lethal freeze; remaining T034/T042/manual UNRUN |
| FR-010–FR-012 | Minimal US1 lethal stop tested; full defeat/restart/pause contracts deliberately deferred | Pending later phases; owner UNRUN |

Edge contracts exercised successfully by those cases: no/exact/exterior/tied
targets; reassessment/death; independent contacts and lethal short-circuit;
unblocked overlap/diagonal/insets; cap/death timing; same-step mouse before
movement; zero-coordinate selection versus absent failure position;
side-effect-free bounded sampling/farthest-corner fallback; multiple diagnostic
records counting one opportunity; partial-instance exclusion/disposal; exact
completion deadlines; no wall-stall simulation credit; invalid startup; copied
runtime tuning; sparse/full-interval profile boundaries, generation isolation,
endpoint output/buffer release, post-window failure invalidity and continued
eligible gameplay beyond 300. Restart, pause segmentation, repeated restart,
invalid restart, and exhaustive output-failure lifecycle fixtures remain their
later tasks, and no coverage for them is implied.

`survival.subtick_long_step` records **two actions in two executed 0.015625 s
steps: 64 Hz effective cadence for configured 1000 Hz intervals**. This is a
deterministic fixture, not the project's normal 60 Hz physics setting. Normal
sub-tick intervals can perform at most one action per executed 60 Hz step;
long delivered steps consume crossed spawn multiples without catch-up.

### Independent PowerShell/Godot review and outstanding manual checks

Run from the project root in an independent PowerShell session:

```powershell
& ./tools/validate.ps1 -Mode All -SuiteScope Foundation
# Expected: exit 0; 13 cases / 554 assertions; both startup checks.
& ./tools/test-validation.ps1
# Expected: exit 0; foundation and 103 infrastructure assertions.
& ./tools/validate.ps1 -Mode All
# Expected: exit 0; 48 cases / 3498 assertions, 33 parses, both startups.
& ./tools/validate.ps1 -Mode Play
# Graphical owner check; close with Alt+F4, then inspect command exit/logs.
```

Both launchers accept optional `-GodotBin <absolute existing console executable>`
when the independent session cannot discover persistent GODOT_BIN. Use the
launcher for containment; do not replace it with direct uncontained Godot/editor
invocation. Inspect the emitted validation session, streams and results as well
as `$LASTEXITCODE`. Main and each reusable scene are loaded by actual test
fixtures; both normal and Profile startup run with `--quit-after 120` iterations,
not seconds. All required source `.gd.uid` files exist; generated caches remain
ignored. No dependency, plugin or installation was introduced.

T033 owner steps (each **UNRUN** here), adapted from approved quickstart steps
1–2 to this US1 boundary:

1. Launch Play at the normal 1920×1080 view. Confirm full health/00:00, cyan
   player, orange-red enemies, contrasting flat floor and low limits. Test
   W/S/A/D separately, opposing pairs, release and equal straight/diagonal
   travel. Rotate approximately 90° and repeat. Mouse alone must not move the
   player. Sweep both vertical limits without inversion/floor crossing.
2. Traverse all edges and corners. Confirm player remains visible, both actor
   insets hold, and player/enemy/enemy overlaps never obstruct movement. Move
   to redirect enemies and inspect pursuit/contact at corners.
3. Observe three ordinary spawns, automatic attacks against eligible enemies,
   affected-target yellow line/white flash, eventual removal on kill, contact
   loss of health and continuously readable time/health. Separate/re-enter
   contact to check remaining delay. Let multiple enemies contact and confirm
   independent damage; let health reach zero and confirm the US1 loop freezes.
4. Close/relaunch for a fresh run. Pause and Restart UI are outside this
   checkpoint; quickstart's later steps 3–4 await their phases. Record every
   observation, defect and actual tuning before checking T033.

For later owner survival/profile evidence, perform a **separate 30-active-second
warm-up**, close/relaunch, pre-record actual hardware/driver/source revision and
approved render/tuning conditions, then use `./tools/validate.ps1 -Mode Profile`.
Observe one uninterrupted vulnerable attempt reaching >=300 completed simulation
seconds and its normal continuation; do not splice attempts or substitute
fixtures. Raw JSON records callbacks, enemy simulation/wall samples, summary,
conditions and distinct outcomes; the `.outcomes.json` sidecar on shutdown also
retains continuation/late-failure metadata. Output faults leave capture
outstanding. Frame sampling has a one-million-entry safety ceiling; overflow
reports incomplete capture, never qualified performance. Sparse captures have
null distributions/minimum and explicit unavailable reasons. The technical
qualification method cannot substitute for owner/conditions/feature review.

SC-001 owner/complete-clause acceptance, SC-002–SC-004 later/integrated owner
journeys, SC-006 normal 300-second survival and continuation, and SC-007 rendered
profiling remain **UNRUN**. SC-005 200-enemy/60-FPS performance remains future and
unverified; the custom-cap fixture is not a benchmark. No current unexpected
automated failure or implementation blocker remains. T033 manual participation
is outstanding; Phase 4 is deliberately not started. The extension registry
was checked before/after work and is absent. No Git commit or push was made.

### Created and modified files

Created five scenes: `scenes/arena.tscn`, `player.tscn`, `enemy.tscn`,
`camera_rig.tscn`, `hud.tscn`; modified `scenes/main.tscn`.

Created fourteen scripts and their fourteen required source `.gd.uid` files:

- `scripts/combat/health.gd`, `automatic_weapon.gd`, `attack_feedback.gd`.
- `scripts/arena/arena.gd`.
- `scripts/actors/player.gd`, `enemy.gd`.
- `scripts/camera/camera_rig.gd`.
- `scripts/run/live_registry.gd`, `enemy_spawner.gd`, `run_coordinator.gd`,
  `main.gd`, `profile_capture.gd`, `profile_statistics.gd`.
- `scripts/ui/hud.gd`.

Modified `scripts/data/definition_validator.gd` for diagnostic source identity;
`tests/unit/test_combat.gd`, `tests/integration/test_survival_loop.gd` for repaired
inputs and stronger snapshot assertions; `tests/unit/test_profile_capture.gd`
for persisted outcomes/continuation checks; `tools/validate.ps1` for contained
Profile startup; `tests/README.md`, `docs/asset-provenance.md`, this ledger and
`specs/001-core-gameplay-prototype/tasks.md`. The manifest and fixture adapter
are unchanged. Ignored `.godot/` and `.cache/` output is not part of the changes
to review or commit. Work stops at the Phase 3B boundary.

## Phase 3B owner profiling follow-up — 2026-10-03

This section supersedes earlier UNRUN survival/continuation entries and the old
one-million-entry capture description. Work remains within T017/T029–T032;
T033's full controls/visual/game-feel inventory is still partial. T034 and all
subsequent phases remain unstarted. No commit, push, installation, dependency,
asset, tuning, constitution or acceptance-criteria change was made. Existing
staged user implementation changes were preserved; this repair is unstaged.

### Owner observation and preserved original evidence

The owner independently reports one uninterrupted attempt reaching **05:11**,
normal gameplay continuation beyond **05:00**, and death at **0 HP**. This is an
owner observation, not an agent playtest or synthetic survival claim.

Original evidence retained without rewriting:

- `.cache/validation/20261003T050026839-1e32d11767e0424f8bdbd53af4abb23d/`:
  Profile stdout/stderr/engine log and original `results.json`.
- `.cache/profile/attempt-1-1-301047403.json` and `.json.outcomes.json`.

The persisted attempt records 18,000 completed physics steps,
300.000000000056 simulation seconds and **299.963089 wall seconds** at the
five-minute endpoint (`t0=0.723084`, `t1=300.686173`). Survival-window and
continuation outcomes are separately `passed`; spawn failures are zero and
acceptance invalidity is false. Post-endpoint timestamps include view at
307.300000000049, movement at 308.666666666715, spawn opportunity at
310.500000000046, weapon attack at 310.933333333379 and contact/time advancement
at 311.233333333379 simulation seconds. Together with the owner's report,
these support the observed survival, normal continuation and subsequent death.
Do not erase these observations because profiling failed. Full feature/attempt
acceptance still needs the remaining gates and recorded conditions; the owner
has not supplied warm-up, driver/source-revision and every other manual scenario
in this message, so none is inferred.

**SC-006 survival and continuation: owner-observed success, supported by runtime
metadata. SC-007: INCOMPLETE capture; acceptance OUTSTANDING.** The incomplete
profile does not qualify, and its provisional FPS/distributions are not accepted
performance results. SC-005 remains a future unverified benchmark.

### Root cause and launcher false success

The raw array contains exactly **1,000,000** strictly increasing timestamps,
with **zero equal adjacent timestamps**. First callback: 0.888095 s; last:
295.952512 s; retained callback span: 295.064417 s. Observed full-interval rate:
about **3,389 callbacks/sec** (median interval 0.264 ms). The fixed ceiling
therefore exhausted before 300 completed simulation seconds and omitted all
later callbacks: at least **4.733661 wall seconds** from the last retained
callback to the endpoint. That final gap includes missing measurements and
cannot honestly be interpreted as a measured application stall. Even exactly
3,333.33 callbacks/sec uses one million entries in 300 wall seconds; slower
simulation/stalls can make the required wall window longer still.

The implementation has one Main-owned global `frame_post_draw` connection, one
append per callback, generation guards, endpoint closure and reset between
attempts. It does not sample per enemy, viewport, physics update or statistics
pass. The required settings are VSync off and FPS uncapped. There is no source
or stored evidence of duplicate connections or cross-attempt accumulation.
Original owner evidence lacks engine frame IDs, so timestamp uniqueness alone
cannot retrospectively certify one-to-one draw identity. An independent rendered
probe below confirms one callback per engine draw with the corrected wiring and
reproduces the high uncapped rate. Godot documents this global signal after all
viewport updates: https://docs.godotengine.org/en/latest/classes/class_renderingserver.html#class-renderingserver-signal-frame-post-draw
These remain CPU-observed callbacks, not GPU/presentation FPS.

Original launcher evidence reports child exit **0**, `Outcome=PASSED`, and no
classified errors even though stderr/engine log contains `Profile capture
failure:`. The classifier recognized engine severity prefixes but ignored this
application prefix, and the launcher did not require or inspect application
capture outcomes. The engine kept running after the helper marked profiling
outstanding; successful process shutdown was incorrectly presented as successful
Profile validation.

### Scoped correction and evidence format

Replace the total-sample ceiling with a **4,096-entry PackedFloat64Array** spool:
32 KiB timestamp payload plus transient 32 KiB byte encoding. Every timestamp
is written unchanged and in order to an attempt `.json.frames.bin`; the final
tail is flushed at the unchanged endpoint. JSON contains conditions, the raw
stream descriptor/count, enemy samples, summary and separate outcomes; shutdown
writes `.json.outcomes.json`. Preserve all three artifacts. Disk grows at eight
bytes per callback, approximately 8.1 MB over 300 s at the owner's observed rate.
No sample is decimated, overwritten or omitted to meet a limit; write faults
preserve partial evidence and explicitly fail capture. Disk capacity remains a
real failure condition, not a hidden guarantee.

Read the complete stream sequentially for exact source-clock microsecond
interval frequency counts and nearest-rank percentiles. This avoids duplicating
and sorting a million raw timestamps/intervals in RAM. Distinct positive integer
intervals require k(k+1)/2 microseconds of coverage, bounding histogram growth
by measured wall duration. Preserve origin/endpoint rules, whole-window and
full-interval denominators, minimum/percentiles/stalls, partial gaps and sparse
unavailable results. Raw float64 timestamps remain exact and reproducible.
Chunk writes/flushes occur during sampling and are counted in sampler overhead
and active wall intervals. Endpoint summarization/JSON output is excluded and
labeled; no GPU timing is claimed. The plan/contracts/quickstart/tasks document
this justified change from all-writes-after-sampling without weakening SC-007.

Main records actual max FPS, VSync, physics rate and callback source, and audits
successive engine draw IDs without filtering samples. Repeats/gaps retain raw
callbacks and fault the capture. The launcher now fails on capture diagnostics,
missing/incomplete/duplicate completion receipts, missing evidence, raw length
mismatch or inconsistent manifest/outcomes. Capture faults fail even on child
exit zero; original output and failed child results are retained. Complete short
startup evidence may pass its lifecycle check with survival/continuation still
outstanding; no automatic SC-006/007 acceptance is introduced.

### Executed validation and investigated nonzero outcomes

Commands below ran with the existing approved console executable
`C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`, version
`4.7.2.stable.official.ed1daf0bf`. Authorized certificate-store access was needed;
Godot data/cache/editor/user paths and all temporary output remained under the
workspace through the launcher.

| Command/check actually executed | Actual result | Status |
|---|---|---|
| `./tools/validate.ps1 -Mode All -GodotBin C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`, sandbox attempt | Launcher exit 1; path preflight child exit 0 but Windows root certificate-store read error; import/parse/suite/startups not run | BLOCKED environment attempt; correctly reported failure |
| Same command with authorized access, first repair snapshot | Import/33 parses succeeded; suite child exit 0, 48/48 cases and 3,698 assertions succeeded; launcher exit 1 because newly broadened matcher rejected declared spawn/configuration fault-fixture text | FAILED launcher regression; narrowed matcher to Profile capture failures, preserving existing declared-fault reconciliation |
| Same full command, corrected snapshot | Exit 0; 48/48, 3,698 assertions; import/33 parses/normal and Profile headless startup passed | PASSED |
| `./tools/test-validation.ps1 -GodotBin C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe -RenderedProfileSmoke`, first run | Exit 0; Foundation 13/13, 554 assertions; import/33 parses/headless startups and 124 infrastructure assertions passed; rendered switch was not forwarded, so requested graphical probe was unrun | PASSED executed checks; rendered check UNRUN in this snapshot; forwarding fixed |
| Same infrastructure command after forwarding fix | Exit 0; Foundation 13/13, 554 assertions; import/33 parses/headless startups; **127 infrastructure assertions** and environment restoration passed; graphical Main Profile probe executed successfully | PASSED including independent rendered callback audit |
| Full `validate.ps1 -Mode All -GodotBin ...`, final settings snapshot | Exit 0; **48/48 cases, 3,698 assertions**, zero pending/excluded; import/all 33 parses/normal and Profile headless startup passed | PASSED final gameplay/capture checkpoint |
| `git diff --check` | Exit 0; ordinary LF-to-CRLF notices only | PASSED |
| Owner five-minute session after correction | Not executed by agent or owner in this follow-up | UNRUN; required for valid SC-007 evidence |

Retained repair sessions, all below `.cache/validation/`:

- Sandbox certificate failure: `20261003T051737523-40df2963fcdb4e25855013be27218586/`.
- Diagnosed matcher regression: `20261003T051751102-4aff0b41310040d8a9995e74956a67bb/`.
- Corrected full suite: `20261003T051959325-ff094d5023004502aaf134d61e5cf9c2/`.
- Infrastructure without forwarded rendered switch: `20261003T052111609-05453c62ccac4d94b99bef33fb97e444/`.
- Independent rendered/infrastructure checks: `20261003T052322559-870b0bee964d4220a426c9a60103e527/`.
- Final full settings snapshot: `20261003T052451971-06566290af1845fa9fe2b34fc820cc46/`.

The high-rate regression writes/rereads **1,050,001** synthetic callbacks over a
300-second simulated measurement window, checking every raw float64 value and
its order across all chunk boundaries/tail. It proves whole-window counting,
exact p99, one 40.25 ms injected stall, endpoint gap and bounded working buffer,
then separately proves unchanged post-endpoint buffer closure/late invalidity.
This is infrastructure evidence, never a replacement owner survival attempt.
Boundary/sparse/distribution/enemy tests compare streaming statistics to the
original reference. No manifest case or pre-existing acceptance assertion was
removed/weakened. Intentional output-directory failure, truncated stream and
sidecar failure each produced application faults while their child exited 0;
the launcher correctly retained FAILED child outcomes and the fixtures passed
by asserting those failures. Original timeout/engine-error fixtures still pass.

The graphical Main probe executed **6,000 callbacks** with draw IDs **0–5,999**,
zero repeated/skipped IDs, 2.034682 wall seconds and 5,999 full intervals at
about **3,228/sec**. Raw output has exactly 48,000 bytes. It independently
supports the uncapped-rate explanation and verifies actual sampler wiring,
chunking, receipt and artifact checks. It supplies no five-minute qualification,
manual controls/visual/game-feel acceptance or constitutional benchmark claim.

### Repeat owner profiling; remaining acceptance

**A repeat five-minute owner Profile attempt is required for SC-007.** The
missing old tail cannot be reconstructed; do not splice it with another attempt
or accept partial FPS statistics. The successful owner survival/continuation
observations above remain recorded independently.

Pre-record source revision plus current uncommitted source state, actual
hardware/driver, planned renderer/resolution/settings and tuning. Perform the
separate 30-active-second warm-up, close/relaunch with
`./tools/validate.ps1 -Mode Profile`, and complete one uninterrupted normal,
vulnerable attempt reaching >=300 simulation seconds. Continue normal movement,
view and scheduled spawning beyond 05:00 until eventual death; close normally.
Inspect launcher exit/result and all three capture artifacts. A capture fault
now returns nonzero validation even if the application exits 0. Keep all failed
attempts. SC-007 remains outstanding until a valid actual owner capture and
conditions/bottleneck review exist. Other unobserved T033 scenarios remain
outstanding; do not advance to T034 or later phases.

Modified by this follow-up: `scripts/run/profile_capture.gd`,
`profile_statistics.gd`, `main.gd`; `tests/unit/test_profile_capture.gd`;
`tools/validation_diagnostics.ps1`, `validate.ps1`, `test-validation.ps1`;
`tests/README.md`; feature `plan.md`, `tasks.md`, `quickstart.md`,
`contracts/gameplay-components.md`; this ledger. No unrelated gameplay file,
resource, asset, spec acceptance criterion or generated file was staged.

## Phase 3B independent profile artifact review — 2026-10-03

This review supersedes the preceding requirement to repeat the incomplete
five-minute capture: the owner has now supplied a successful independent repeat.
Historical failed evidence remains intact. This review changes only this tracked
documentation file. No game source, tests, launcher, resource, enemy cap, tuning,
asset, task checkbox or acceptance criterion was changed. No profiling session,
optimization, Phase 4 work, commit or push was initiated.

### Run identity and complete capture

Reviewed the actual files, not just the reported launcher outcome:

- Validation session: `.cache/validation/20261003T053413132-535f30e91ef44491999efb204ccf337e/`.
  Its `results.json`, `profile.stdout.txt`, empty `profile.stderr.txt` and
  `profile.engine.log` all support a successful rendered Profile process.
- Manifest: `.cache/profile/attempt-1-1-693766.json`.
- Lossless raw timestamps: `.cache/profile/attempt-1-1-693766.json.frames.bin`.
- Shutdown outcomes: `.cache/profile/attempt-1-1-693766.json.outcomes.json`.

The report's exact process command is
`C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --path C:\GameDev\project-horde --log-file C:\GameDev\project-horde\.cache\validation\20261003T053413132-535f30e91ef44491999efb204ccf337e\profile.engine.log -- --profile`.
It has no headless/fixed-FPS flag; child exit is **0**, outcome **PASSED**, no
timeout, and no classified errors, warnings, ambiguous records or capture faults.
Version/help/path-preflight and environment restoration also report PASSED.
The stdout contains one `HORDE_PROFILE_RESULT` receipt. The engine log records
the same receipt; `results.json` classifies one result, despite retaining both
log streams in its combined output. This is one attempt, not duplicate captures.

Receipt, report and sidecar agree on manifest/raw paths, successful capture and
survival, successful final continuation, and `acceptance_invalid=false`.
Manifest and sidecar agree on generation **1**, `t0=0.693559`, `t1=300.669297`,
**18,000 completed physics steps**, **300.000000000056 simulation seconds**,
all shared endpoint statistics, **zero spawn failures** and empty diagnostic
arrays. The binary has exactly **7,733,008 bytes = 966,626 × 8**; every decoded
little-endian float64 timestamp is finite, strictly increasing, source-clock
microseconds and inside `(t0,t1]`. There are no equal adjacent timestamps.
First/last timestamps are **0.876813 / 300.668810 seconds**.

The stored draw audit records engine frame IDs **0–966,625**, zero repeated IDs
and zero skipped IDs, consistent with the callback count. Frame IDs themselves
are aggregate audit metadata, not individually stored in the raw timestamp file.
There are **300** ordered enemy-count samples, each at its next completed
one-second simulation opportunity, with increasing wall timestamps inside the
window and counts within the unchanged cap. Top-level and summary copies agree.
Independent recomputation agrees with every reported rate, percentile, coverage,
stall count and enemy min/max/mean. The capture is technically complete; there is
no missing tail, overflow, stream-length discrepancy or cross-run mismatch.

### Measurements and SC-007 interpretation

| Measurement | Verified result |
|---|---|
| Completed simulation / measured wall duration | 300.000000000056 s / **299.975738 s** |
| Observed callbacks / full intervals | **966,626 / 966,625** |
| Whole-window CPU frame-loop average | **3,222.347 callbacks/s**, using count / entire measured wall window |
| Full-interval coverage / average | **299.791997 s / 3,224.319 intervals/s** |
| Full-interval p50 / p95 / p99 | **0.277 / 0.515 / 0.714 ms**, exact source-microsecond, empirical nearest-rank |
| Longest full interval / reciprocal minimum rate | **6.175 ms / 161.943 intervals/s** |
| Full intervals >16.67 ms / >33.33 ms | **0 / 0** |
| Initial partial boundary gap | **183.254 ms**, flagged as a startup boundary stall |
| Final partial boundary gap | **0.487 ms**, not a boundary stall |
| Total wall time outside full-interval coverage | **183.741 ms**; included in whole-window average |
| Sampled living enemies, min / mean / max | **0 / 38.136667 / 50**, 300 observations |
| Recorded sampler overhead | **2.644198 s**, approximately **0.881%** of measured wall duration |
| Endpoint engine monitors | Process **0.914 ms**, physics **0.869 ms**, **56 draw calls**, **1,839 objects**, **55,356,691 static-memory bytes** |

These are **CPU-observed `frame_post_draw` frame-loop intervals**, using a
monotonic wall clock. They are not GPU execution times, swapchain presentation
rates, monitor refresh rates or displayed FPS. The whole-window average retains
the startup boundary gap. The 161.943 minimum is the reciprocal of the longest
**full** interval, not a minimum over boundary fragments; zero full-interval
stalls does not erase the observed 183.254 ms startup gap. No synthetic frame or
GPU/display rate is assigned to that gap. The slight simulation/wall difference
does not indicate missing simulation: simulation counts completed 60 Hz steps,
while wall time is a separate ready-to-completion observation.

Instrumentation overhead includes callback/step work, chunk writes and final
flush. It excludes endpoint statistics/JSON output after sampling and is not
subtracted from measured frame intervals. The engine monitors are endpoint
observations, not five-minute distributions; physics work occurs at 60 Hz and
these values cannot be compared directly to every uncapped draw interval.

Observed limitation: startup contributes a measurable boundary delay. No
steady-state CPU frame-loop stall exceeds 16.67 ms in the recorded full
intervals. These observations do not identify a subsystem bottleneck, prove
GPU headroom or establish that no GPU bottleneck exists. GPU/presentation timing
and a subsystem cost breakdown were not instrumented; they remain unavailable
and cannot be reconstructed from CPU timestamps. No optimization is justified
solely by the capture completing.

SC-007 has **no numerical prototype FPS pass threshold**. This satisfies its
complete-capture/statistics evidence portion under the adopted CPU-observation
method; SC-007 as a whole remains **OUTSTANDING** pending the conditions below.
The **SC-005 200-enemy/60-FPS benchmark remains unverified, future scope**.
The measured cap-50 run neither establishes that benchmark nor calls for an
enemy-cap increase.

### Actual conditions and remaining provenance

The manifest records Godot **4.7.2 stable official**, hash
`ed1daf0bf001b61586d9930840f2f1394092c079`, Windows, debug build, Forward+,
**1920×1080** visible viewport, **VSync 0/off**, **max FPS 0/uncapped**,
**60 Hz physics**, and runtime tuning matching the approved defaults:
player 100 HP / speed 6 / radius 0.4 / height 1.6; enemy 30 HP / speed 3 /
radius 0.4 / height 1.2 / contact distance 1.2 / damage 10 / interval 1 s;
weapon damage 10 / range 4 / interval 0.6 s / feedback 0.12 s; spawn interval
1.5 s / cap 50; arena half-extents (20,20), floor 0, start (0,0), boundary
height 0.15; camera yaw 0 / depression 35 / limits 15–65 / distance 8 /
target height 1.2 / sensitivity 0.12 / FOV 70; schema version 1.
The rendered engine log identifies **NVIDIA GeForce RTX 3080**, Vulkan **1.4.341**.
The Vulkan version is not the installed GPU driver package/version.

Current project/scene review agrees with the planned 100% 3D scale, AA disabled,
one directional light, shadows disabled and no enabled SSAO/SSIL/glow. Those
settings are not all independently captured in the manifest; current files alone
do not prove the exact source/settings at the earlier run.

The owner explicitly confirms a **separate 30-second warm-up before Profile**.
Local read-only hardware queries at **2026-10-03 06:00:48 UTC**, after this run,
also found Windows 10 IoT Enterprise LTSC, version **10.0.19044 / build 19044**,
Intel **i7-12700KF**, **34,099,900,416 usable RAM bytes** (consistent with the
32 GB reference configuration), RTX 3080, Windows GPU driver
**32.0.16.1062**, driver date **2026-06-10**. These agree with the reference
hardware. They are review-time observations, not measurements saved at t0;
the manifest does not record exact VRAM or driver details.

The owner subsequently confirms this run used their normal development PC and
that they have not intentionally changed hardware, system performance tuning,
power settings or Godot rendering settings between validation runs. The fuller
read-only baseline below records the available hardware/driver details. This
addresses the environment documentation gap through measured current information
and owner-reported continuity; it is not a claim of settings telemetry at t0.
Still unconfirmed for this attempt: the source revision plus uncommitted source
state used before sampling.
`conditions.warmup`, `conditions.source_revision` and
`conditions.owner_acceptance` contain instructions, not completed attestations;
the owner's warm-up confirmation is recorded separately here.
Review-time HEAD is `b66bff16c773f477356a85b84a346141f7b906ff`; substantial user
implementation changes are staged. HEAD alone cannot identify this run's source
snapshot. No prior Play session is assumed to be the required warm-up.

Owner confirmation can complete omitted records if the protocol was actually
followed. Do not invent retrospective certainty or infer a successful manual
scenario from a clean process exit. No additional five-minute capture is
currently indicated by artifact integrity. If the owner confirms that a required
measurement condition was not followed, retain this evidence and repeat only
for that specific protocol gap.

### Development-PC baseline environment — collected 2026-10-03

Collected at **2026-10-03 06:03:51 UTC** using read-only local Windows commands
with authorized system access. This is baseline documentation for the normal
development PC used in validation session
`20261003T053413132-535f30e91ef44491999efb204ccf337e` and capture
`attempt-1-1-693766.json`; it does not change the profiling configuration.

| Field | Automatically observed baseline |
|---|---|
| OS edition | **Windows 10 IoT Enterprise LTSC 2021**, registry edition `IoTEnterpriseS` |
| OS version / architecture | **21H2**, **64-bit**, WMI version **10.0.19044** |
| OS build including update revision | **19044.7725** (`CurrentBuild=19044`, `UBR=7725`) |
| CPU | **12th Gen Intel Core i7-12700KF**, **12 cores / 20 logical processors** |
| Installed physical RAM | **34,359,738,368 bytes = 32 GiB**, four **8 GiB** modules |
| OS-visible usable physical RAM | **34,099,900,416 bytes**, approximately **31.76 GiB** |
| RAM speed metadata | Every module reports `Speed=3200`, `ConfiguredClockSpeed=3200`; firmware/WMI metadata, not a memory performance measurement |
| GPU | **NVIDIA GeForce RTX 3080**, confirmed by WMI, NVIDIA query and the rendered run log |
| GPU VRAM | NVIDIA reports **10,240 MiB = 10 GiB** |
| NVIDIA driver version | **610.62**, from `nvidia-smi` |
| Windows display-driver version | **32.0.16.1062**, from `Win32_VideoController` |
| Windows driver date | **2026-06-11 00:00:00 UTC** (the earlier local rendering of the same value was 2026-06-10 20:00 EDT) |

These observations match the constitution's reference OS/CPU/RAM/GPU/VRAM
configuration. The Windows and NVIDIA version strings are separately labeled;
the Vulkan **1.4.341** reported by Godot remains the API version, not the driver
package version. WMI `AdapterRAM` returned **4,293,918,720 bytes**; that field
cannot reliably represent this adapter's >4 GiB memory and is not used as the
VRAM result. The NVIDIA memory query supplies the 10 GiB value.

Commands executed successfully; the PowerShell collection and native NVIDIA
query each exited **0**:

```powershell
Get-CimInstance -ClassName Win32_ComputerSystem
Get-CimInstance -ClassName Win32_Processor
Get-CimInstance -ClassName Win32_OperatingSystem
Get-CimInstance -ClassName Win32_PhysicalMemory
Get-CimInstance -ClassName Win32_VideoController
# Registry key existence checked before reading version/build metadata:
Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
# Existing executable discovered before invocation:
& 'C:\Windows\System32\nvidia-smi.exe' --query-gpu=name,driver_version,memory.total --format=csv,noheader,nounits
```

The collection used stop-on-error handling; the NVIDIA query separately checked
its native exit code. No system configuration, power plan, performance tuning,
driver, installation, hardware or Godot setting was changed. No files outside
the workspace were written. This follow-up changes only this ledger; source,
task checkboxes and acceptance outcomes are unchanged. `git diff --check` passed
with exit 0; only the ordinary LF-to-CRLF notice was emitted. Godot tests and
profiling were not rerun for this documentation-only update.

**No additional OS/CPU/RAM/GPU-driver information is needed from the owner.**
Current queries cannot retrospectively prove the exact software/settings state
at capture time or rule out automatic system updates. The owner's statement
records no intentional changes between runs. The separate remaining source
provenance item is the Git revision and uncommitted source state used for the
capture, or confirmation that the source has remained unchanged since that run;
that cannot be established from hardware queries. No new acceptance pass or
requirement to modify/reconfigure the PC follows from this baseline collection.

### Survival window and independent continuation

The manifest is written once when the completed >=300-second window closes;
raw frame/count sampling then stops. At that point its empty continuation
evidence and `continuation_outcome="outstanding"` are **expected**. The code
continues collecting small outcome metadata and writes the final
`.outcomes.json` sidecar on shutdown. It does not rewrite the endpoint manifest.
The sidecar's duration/tick count remain the capture endpoint, not final run time.

The final sidecar and launcher receipt both say continuation **passed**. In this
same independent owner attempt the sidecar records:

| Post-endpoint observation | Completed simulation timestamp (s) |
|---|---|
| Responsive view | 327.850000000030 |
| Contact damage | 328.400000000030 |
| Movement | 328.450000000030 |
| Scheduled spawn opportunity | 328.500000000030 |
| Eligible weapon attack | 328.700000000030 |
| Time advancement / unchanged tuning and vulnerability | 329.066666666696 |

These support the required continuation clauses and also show eligible combat
beyond the endpoint. A spawn opportunity may be a successful spawn or an expected
cap-full skip; the metadata does not distinguish them, and either qualifies under
the approved contract. These timestamps are recorded observations, not necessarily
the first occurrence of each event. There is no continuation defect requiring
another owner survival run or a code repair.

**SC-006 survival-window and runtime continuation checks: VERIFIED for this
attempt.** The owner-reported independent normal profiling run, default tuning,
18,000 completed steps and zero failures support the unpaused vulnerable window.
This sidecar does not explicitly record final HP/death or shutdown reason; final
advancing time alone cannot prove death. The owner has now confirmed that they
**closed with Alt+F4 after five minutes, before death**. Consequently, this new
attempt's full **SC-006 owner journey remains OUTSTANDING** specifically for
the mandatory "until player death" clause, even though continuation passed.
The closed attempt cannot be resumed to supply that observation. A future
complete SC-006/SC-007 acceptance attempt must reach the window and continue
until death; this is a specific acceptance gap, not a capture/performance defect
and not a reason to initiate another long session during this review. The
earlier **05:11 / 0 HP** owner observation remains independently supported by
its own artifacts, as recorded above; it is not spliced into this new attempt.
Full feature acceptance and SC-007 qualification are not automatic runtime passes.

### T018–T034 and Phase 3B closure

| Tasks/check | Current assessment |
|---|---|
| T018–T023 | Implemented: independent health, arena/spawn selection, player movement, camera, pursuing/contact enemies, synchronous live registry |
| T024–T028 | Implemented: automatic targeting/cooldowns, cap-aware spawner/fault accounting, HUD, coordinated simulation/Main scene, affected-target feedback |
| T029–T031 | Implemented and exercised by this real rendered run: bounded lossless capture/statistics, separate endpoint/continuation/failure outcomes |
| T032 | Implemented and previously validated: actual case registration, automated checks and ledger; new artifact audit now passed |
| T033 | **PARTIAL / unchecked**: owner confirms controls felt fine, boundary containment, enemy kills, hit flash and working HUD; detailed remaining manual inventory below is unconfirmed |
| T034 | **UNSTARTED / unchecked; Phase 4**, US2 defeat/restart tests. It is not a Phase 3B closure task |

Owner feedback for this review: "all the controlls seemed fine", "I could not
exit the boundary walls", "I could kill enemies", "enemy flashed when hit",
and "HUD seemed to work correctly". Record these as **PASSED owner observations**
for general control feel, boundary containment, automatic kills, visible hit
flash and HUD operation. The separate survival/continuation timestamps support
normal gameplay participation and contact damage; they do not substitute for
visual judgments. No owner-reported defect arose.

T033 still requires explicit owner observations for WASD singly at initial and
90° yaw, opposing/released inputs and straight/diagonal speed; both pitch limits
and player visibility around the entire perimeter/corners; recognizable original
placeholders and free overlaps; pursuit redirection; visible yellow attack line
identifying the affected target and independent contact
cooldown behavior. The owner's kill/flash/HUD observations satisfy those basic
checks; broad control satisfaction does not individually certify every directional,
pitch and perimeter scenario. Runtime timestamps establish participation, not all these
visual/feel judgments. The reproducible four US1 owner steps in the earlier
T033 section remain applicable. Pause/restart/full Game Over overlay checks
belong to later phases and are not required to close this US1 implementation
checkpoint. SC-001–SC-004 full feature gates still await those phases; no full
feature success criterion is newly marked complete.

**Phase 3B is implemented and technically validated, but not ready to close
while T033 owner acceptance is incomplete.** The immediate owner action is to
record the remaining specific T033 observations (including any already completed)
and confirm the remaining source provenance. For unperformed scenarios, run
`./tools/validate.ps1 -Mode Play` and perform the short US1 controls/visual checks
above; close with Alt+F4 and retain the result/logs. This is not another required
five-minute profile. The mandatory death observation belongs to the later full
survival/profile acceptance gates (T053–T055); it does not block the US1 Phase 3B
checkpoint by itself. Once T033 observations are recorded and any defects resolved,
T033/Phase 3B closure can be reviewed without starting T034 or Phase 4.

### Checks executed for this documentation review

| Command/check | Actual outcome |
|---|---|
| `./.cache/phase3b-profile-audit.ps1` | **PASSED**, exit 0; 116 assertions plus examination of all 966,626 raw timestamps and all 300 enemy samples; receipt/manifest/sidecar/report consistency and independent statistics recomputation |
| Review retained `20261003T052451971-06566290af1845fa9fe2b34fc820cc46/results.json` and suite stdout | **Previously PASSED**: import, all 33 script parses, 48/48 cases with 3,698 assertions, normal and Profile startup; no pending/excluded cases. Inspected here, not rerun here |
| `Get-CimInstance` for `Win32_ComputerSystem`, `Win32_Processor`, `Win32_OperatingSystem`, `Win32_VideoController`, sandbox attempt | **BLOCKED**: all four queries returned Access denied. PowerShell still exited 0 with null fields; this was not successful hardware verification |
| Same read-only hardware queries with authorized access and stop-on-error | **PASSED**, exit 0; actual review-time hardware/driver values recorded above; no filesystem writes |
| `git diff --check`; `git diff --cached --check` | **PASSED**, each exit 0; working-copy check emitted only the ordinary LF-to-CRLF notice |
| Godot full suite/import/parse/startup in this review | **NOT RERUN**: documentation-only change; retained successful automated evidence and new artifact audit address this task |
| Another five-minute Profile session | **NOT RUN**: supplied capture is complete; no integrity or continuation reason to repeat |
| T033 owner scenarios / metadata | **PARTIAL**: warm-up/basic controls/boundary/kills/flash/HUD confirmed; detailed remaining scenarios and provenance still outstanding |

Read-only audit script/results are ignored workspace artifacts at
`.cache/phase3b-profile-audit.ps1` and `.cache/phase3b-profile-audit.json`.
The audit result records SHA-256 hashes of the three capture files and validation
report for future identification; original artifacts were not rewritten.
Source-code changes for this review: **none**. Documentation changes: this ledger
only. Existing staged user changes remain preserved and no generated evidence
was staged.

## Phase 3B T033 owner acceptance follow-up — 2026-10-03

This section records the owner's numbered checklist results and supersedes
earlier statements that its movement/camera/overlap/feedback/death observations
were unperformed. T033 remains unchecked while contact timing is inconclusive.
No gameplay source, tuning, task checkbox, profiling configuration or Phase 4
work was changed. No five-minute profile, commit or push was initiated.

| Owner checklist | Reported outcome | Evidence/remaining work |
|---|---|---|
| 1. Movement combinations and rotated controls | **PASS** | Owner confirms the supplied individual/opposing/released/diagonal and approximately 90° yaw checks |
| 2. Camera limits and perimeter visibility | **PASS** | Owner confirms supplied pitch-limit, follow/visibility and perimeter scenarios |
| 3. Pursuit and free overlap | **PASS** | Owner confirms redirection and unblocked overlapping actors |
| 4. Affected-target attack line | **PASS** | Owner confirms identifiable target line/removal; prior kill/flash observations retained |
| 5. Contact timing | **INCONCLUSIVE** | Owner reports rounding up 5+ enemies, then apparently immediate death on contact. Exact starting HP, contacting population and elapsed time were not supplied |
| 6. Complete current death sequence | **PASS** | Owner confirms zero HP, current run-ended presentation, mouse release and ten-second defeated freeze under movement/mouse/Escape input |

The death check is the existing US1 lethal stop and relaunch message; it does
not verify the future Game Over/Restart UI or repeated restart journey. Its
success also does not retrospectively change the separate profiling attempt
that the owner closed alive after five minutes.

### Contact-damage interpretation and remaining owner action

The approved FR-008/edge-case contract explicitly gives each living enemy an
immediate first contact hit and its own cooldown. Current defaults are player
**100 HP**, enemy damage **10**, contact interval **1.0 simulation second**,
inclusive XZ contact distance **1.2**. Actors can overlap. There is no shared
player damage cooldown or invulnerability period in this approved slice.

`enemy.step_contact()` checks its retained `next_contact_at`, applies one hit
and sets its next deadline to `t_end + contact_interval`. Leaving/re-entering
does not reset that deadline. The coordinator services all eligible living
enemies in spawn order during the same completed simulation step, stopping on
lethal damage. Thus simultaneous damage is **10 × eligible contacting enemies**,
clamped by remaining HP. Five ready enemies can remove **50 HP immediately**;
ten can remove **100 HP immediately**. Five can kill immediately if starting HP
is at most 50. Exactly five at full 100 HP cannot kill in one first-contact step
under these defaults; later hits from those same enemies must respect their
individual one-second deadlines, and weapon kills can reduce later damage.

The crowd observation is consistent with expected combined damage, but does
not prove that explanation without the missing HP/count/timing. It is neither
recorded as a contact-cooldown failure nor upgraded to an owner acceptance pass.

For the remaining manual check, use a fresh `./tools/validate.ps1 -Mode Play`
attempt at **100 HP**, avoid a crowd, and let **one** enemy contact the player.
Watch/report the first HP change and any further changes while that same enemy
remains alive and touching. Expected first hit: **100 → 90**; no rapid series of
hits from that one enemy, and its next hit cannot occur before another active
simulation second. The automatic weapon may kill it before a second contact
hit; report that circumstance without disabling the weapon or changing tuning.
If safely possible, leave/re-enter against that same surviving enemy and note
whether a remaining cooldown is preserved. Record HP immediately before contact,
approximate contact count and elapsed time for any unexpectedly rapid loss.

Only this contact observation remains from the numbered owner checklist.
Source provenance remains a separately recorded evidence limitation. T033/Phase
3B closure is pending; no broader owner replay or five-minute capture is requested.

### Executed technical investigation

Executed `./tools/validate.ps1 -Mode All -GodotBin C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`
using authorized access and the contained launcher. **PASSED, launcher exit 0**:
import, all **33** script parses, **48/48 cases / 3,698 assertions**, zero
pending/excluded cases, normal startup and short headless Profile startup.
Evidence: `.cache/validation/20261003T062613171-9cb83aa3f021472d812ee2c990d7a94f/`.
The Profile startup is a short lifecycle check, not a rendered owner profile.

Actual `combat.contact` execution passed **24 assertions** covering inclusive
first contact, persistent overlap, exact/before cooldown, separation/re-entry,
independent deadlines, overdue readiness and no long-gap burst. Actual
`survival.lethal` passed **17 assertions** covering the coordinated lethal stop.
These support the implementation but do not reconstruct the owner's crowd event
or substitute for the remaining manual observation.

Available owner Play reports at `20261003T061814876-c830da2f52a841b3837dc6fb97106e08/`,
`20261003T061940048-551f313b5949421cb78638d53a75dbcc/`,
`20261003T062029232-b2fb060272c9458ba526aaa885a13372/` and
`20261003T062219960-1679f392454049fcb6ff0565e21ab564/` each record Play **PASSED**,
child exit **0**, no timeout or failed report entries. These logs do not identify
which checklist observation occurred in which session or record per-hit HP.

The preceding read-only Git provenance investigation established the reflog's
capture-era base HEAD as `b66bff16c773f477356a85b84a346141f7b906ff`; Phase 3B code
has no committed history or stash snapshot. All **82** inspected tracked runtime,
test and launcher files matched the current index, with no untracked files in
those paths and no file modification time after session start
**2026-10-03 05:34:13.132 UTC**. Latest runtime source modification:
**05:24:20.564876 UTC**; index modification: **05:32:15.339028 UTC**. This supports
that base plus the staged Phase 3B implementation as the capture source candidate.
The manifest's source-revision field remains an instruction, with no source
fingerprint/snapshot. Filesystem timestamps/current index cannot conclusively
prove the exact historical uncommitted contents, so that limitation remains.

Changes in this follow-up: **documentation only**, this ledger. Existing staged
user changes are preserved; generated validation evidence remains ignored.

## Phase 3B T033 closure — 2026-10-03

The owner repeated the contact observation and reports that roughly **10+
enemies contacting together killed the player immediately from 100 HP**, while
**1–2 enemies at 100 HP produced paced damage as expected**. The owner explicitly
accepts check 5 as passed. This supersedes its earlier inconclusive status; the
original observation remains above as history.

The result agrees with the approved independent-enemy model: each ready enemy
can immediately deal 10 damage, then must wait its own one-second simulation
cooldown. Ten simultaneous eligible first hits can exhaust 100 HP. No shared
player grace period is specified. The owner observation is qualitative, with an
approximate crowd count; it does not establish exact per-hit timestamps or add
a new numerical measurement claim. Existing executed automated tests separately
cover exact contact deadlines, persistent overlap, re-entry and lethal ordering.

| Owner checklist | Final owner acceptance |
|---|---|
| 1. Movement combinations and rotated controls | **PASS** |
| 2. Camera limits and perimeter visibility | **PASS** |
| 3. Pursuit and free overlap | **PASS** |
| 4. Affected-target attack line | **PASS** |
| 5. Contact timing | **PASS**, owner retest and acceptance recorded above |
| 6. Complete current US1 death sequence | **PASS** |

Together with prior owner kill/flash/HUD observations and executed technical
validation, these complete **T033**. Its task checkbox is now checked.
**Phase 3B (T018–T033) is complete** as the playable US1 checkpoint. No remaining
T033 owner action is required. T034 and all Phase 4 work remain unstarted.

This closure does not establish full SC-001–SC-004/SC-006–SC-007 feature
acceptance, resolve the exact historical uncommitted source snapshot, turn the
closed-alive profiling attempt into an until-death journey, or establish the
future SC-005 benchmark. Those separate limitations/gates remain recorded.

Changes for closure: **documentation only**, this ledger and the feature's
`tasks.md` prerequisite/status/T033 checkbox. No gameplay/test/launcher/resource
or tuning change was needed. Existing staged changes were preserved; no commit,
push, five-minute profile or Phase 4 work was performed.

Validation: `git diff --check` **PASSED**, exit 0 (ordinary LF-to-CRLF notices
only). Godot checks were **NOT RERUN** for this documentation-only closure;
the unchanged implementation's last executed full validation remains
`.cache/validation/20261003T062613171-9cb83aa3f021472d812ee2c990d7a94f/`:
import, 33 parses, 48/48 cases / 3,698 assertions, normal and short Profile startup,
all passed with launcher exit 0. No manual observations were performed by the
agent or inferred from an engine exit code.

## Phase 4 Batch 1 — T034/T035 test authoring — 2026-10-03

Authorized scope: **T034–T035 only**, test authoring with contained validation.
Reviewed constitution v1.0.0, spec/plan/tasks/research/model/contracts/quickstart,
native manifest/runner/Context/fixture conventions, Main/coordinator and encounter
ownership/registry/spawner, HUD/input, capture/statistics and launcher diagnostic
policy before edits. Spec-quality checklist 16/16 and technical checklist 36/36
are complete; no extension hook file was present. Working tree was clean before
this batch. No gameplay, definition, scene, capture/statistics, launcher or
diagnostic-classifier behavior was changed. No commit or push was made.

Created `tests/integration/test_defeat_restart.gd` and
`tests/integration/test_restart_evidence.gd`, plus their required source UID
files generated by contained Godot import. Modified `tests/case_manifest.gd`,
`tests/run_tests.gd`, `tests/unit/test_runner_contract.gd`, `tests/README.md`, this
ledger and `specs/001-core-gameplay-prototype/tasks.md`. The README supplies the
per-case acceptance mapping and provisional construction seam.

T034 has nine actual scene/coordinator cases. Three execute against Phase 3B:
`defeat.lethal_commit` (**19 assertions**), `defeat.freeze_escape` (**614**),
`defeat.final_hud` (**9**). They establish one lethal transition/final t_end
commit, aborted later contacts/repeated notifications, 600 inactive 60 Hz steps
with attempted WASD/mouse/Escape/echo and no gameplay events, and visible final
zero health/time. The freeze is a **ten-second equivalent**, not ten real seconds
or rendered input/visual acceptance. Six authored cases await T036–T039:
`game_over_control`, `three_cycles`, `guarded_requests`,
`stale_callbacks_removal`, `invalid_restart`, `failure_isolation`. They assert
the future overlay/action/focus/intent, complete field reset/normal cadence over
three cycles, repeated/invalid/reentrant intents, synchronous removal/disposal,
stale actual connected Callables, invalid fresh definitions with no old-encounter
revival, and clean new failure counters/diagnostics. **UNRUN**, expected to fail
against missing current restart/UI APIs; no failed assertion was weakened.

T035 has seven authored integration cases: `seal_before_teardown`,
`stale_generations`, `valid_open`, `invalid_no_open`, `shutdown_fault`,
`write_fault`, `post300_death`. Assertions cover persisted raw/count evidence and
final outcomes before spawner teardown, retained generation-tagged metadata,
rejection of old frame/step/failure/continuation records, new buffers/conditions
only after valid fresh definitions, no attempt for invalid definitions, real
required-file-open failures with retained diagnostics/partial files, and intact
300-second survival/endpoint evidence after 300.125-second death while missing
continuation remains outstanding. **All seven UNREGISTERED/UNRUN until both
T039 and T040 are ready**, including the shutdown case whose underlying helper
behavior exists today. Existing Phase 3B profile tests remain required/executed.

The harness has 51 required executable cases (all original 48 plus three
regressions). A separate **non-executable authored inventory** lists the 13
deferred cases with seeds, script paths, requirement mappings, expected diagnostic
counts and task gates. Full discovery validates methods and reconciles both
inventories; missing/duplicate/unknown cases remain fatal. Only `entries()` is
selected for execution, and every required case must execute successfully.
`HORDE_CASE_DEFERRED` explicitly labels every staged case unregistered/unrun;
the summary separates 64 authored / 51 registered / 13 deferred. Deferred cases
are not passes. Harness assertions verify the gate, nonregistration and strict
missing/unregistered reconciliation. No T035 entry is executable registration.

### Commands actually executed

```powershell
./.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
./tools/validate.ps1 -Mode All -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
./tools/test-validation.ps1 -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
git diff --check
```

| Execution | Actual outcome / evidence |
|---|---|
| Spec Kit prerequisites | **PASSED**, exit 0; active feature `001-core-gameplay-prototype`, required tasks/docs available |
| Initial sandbox All | **FAILED**, launcher exit 1; version/help passed, path probe child exit 0 emitted `Failed to read the root certificate store`. Classifier correctly failed it; project import/parse/suite/startup **UNRUN**. `.cache/validation/20261003T074605884-224fe00a6eca49d8b4da75b3e7af3ef9/` |
| First approved All rerun | **FAILED**, launcher exit 1 at `parse-023`; four uninferable `:=` variables in the new evidence fixture. Fixed with explicit Dictionary/PackedFloat64Array types. Dependent suite/startups **UNRUN**. `.cache/validation/20261003T074619141-d885d18c450849bab2397076683acffa/` |
| Corrected All | **PASSED**, exit 0; containment/import/35 parses, 51/51 cases / 4,377 assertions, normal and short headless Profile startup. `.cache/validation/20261003T074735470-2d769b3495de4e9fa8344c030999d533/` |
| Infrastructure wrapper | **PASSED**, exit 0; contained import/35 parses, Foundation 13/13 / 591 assertions, 38 registered cases excluded by explicit scope, 13 deferred, both startups, **124 infrastructure assertions** and all five environment-restoration checks. Intentional failed-child/timeout/capture-fault diagnostics are retained and asserted, not unexplained failures. `.cache/validation/20261003T074936035-f8eb4dcdf4894939875be0e0bb78720c/` |
| Final All after stronger deferred assertions | **PASSED**, exit 0; actual 4.7.2 Standard engine, containment/import/all 35 parses, 51/51 required cases / **4,377 assertions**, 64 authored / 13 deferred / zero required pending / zero scope exclusions, normal and short headless Profile startup. `.cache/validation/20261003T075326402-7e7bf698fe6644c59286349a664ccad9/` |
| Whitespace check | **PASSED**, exit 0; ordinary LF-to-CRLF notices only |

Approved reruns used the same contained launcher outside sandbox certificate-store
restrictions; no certificate suppression or external file writes were added.
An attempted read of the first failed rerun's nonexistent suite log returned
nonzero because parsing had stopped before creating it; this was an inspection
mistake, not a suite execution. Subsequent optional log reads checked existence.
All generated engine/evidence output remains ignored inside the workspace.
Short Profile startup verifies sparse capture/shutdown, not owner profiling,
survival, performance or US2 completion. No rendered smoke or manual playtest ran.

### Dependencies and remaining verification

The spec requires an immediate restart guard and synchronous old-encounter
removal but leaves fresh-construction scheduling and coordinator/capture identity
unspecified. Fixtures use synchronous `request_restart()` with stable coordinator
and Main-owned capture, consistent with current seams. A different Batch 2
ownership/scheduling choice can adapt wiring/await boundaries while preserving
all acceptance assertions. New HUD node paths are intentionally unspecified;
tests find controls within the actual HUD.

T038 must reject **saved queued production Callables**, not merely disconnect
old signals. T040 must seal/write final outcomes before teardown, retain failed
attempt metadata even when next definitions are invalid, and refresh recorded
conditions for valid edited definitions. Evidence tests isolate old failures from
fresh counters without deleting old failed records.

T041 also needs exact expected capture-fault matching: the existing PowerShell
classifier marks every `Profile capture failure:` line fatal, including the
declared ProfileCapture faults in `shutdown_fault`/`write_fault`. Their native
expectations already specify source/constraint/count; future integration must
match the corresponding printed payload by case as well. Genuine engine errors
and ordinary capture failures must stay fatal. This dependency was discovered
and documented; no classifier/capture change belongs to this batch.

After owner authorization and T036–T040 implementation, T041 promotes the ready
staged entries into the required executable manifest and runs the full US2
checkpoint. Automated failure exit for actual invalid-restart application runs,
keyboard/mouse UI interaction, mouse release/recapture, readable overlays and
normal three-cycle game feel remain outstanding. Manual procedure then: launch
contained Play, die through normal contact, verify zero HP/Game Over/final time,
try WASD/mouse/Escape for ten real seconds, activate focused Restart by click,
Enter and Space across three cycles, and try rapid repeated activation. Confirm
full health/start/view/00:00, no old enemies, and a full initial spawn delay each
time. These future controls do not exist in current Phase 3B; no current replay
can establish their acceptance.

**T034 and T035 are complete as test-authoring tasks and checked accordingly.**
Their deferred behavioral assertions have not passed; T036–T041 remain unchecked,
US2/SC-002 acceptance is open, and no Batch 2 implementation was started. Stop
after Batch 1; further implementation requires the owner's authorization.
