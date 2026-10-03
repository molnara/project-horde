# Core gameplay verification ledger

Current checkpoint: Phase 5 Batch 3 final validation / T048 closure, 2026-10-03.
All 82 required native cases pass with 5,843 assertions, including all 18 US3
cases with 1,140 assertions and zero deferrals. Phase 3B remains 48/48 with 3,719
assertions; Phase 4 remains 16/16 with 984 assertions. Final contained validation
passes import, all 37 script parses, normal/Profile startup and 146 infrastructure
assertions without unexpected warnings. The owner reports all six Phase 5 manual
acceptance groups passed; T042–T048 and US3/SC-003 are complete. See **Phase 5
Batch 3 — T048 final validation and owner acceptance closure** below for fresh
automated results and separately attributed owner observations. That section
supersedes earlier Phase 5 owner-unrun/closure-pending statuses. Prior owner
acceptance is preserved; full feature/performance acceptance remains separate.
No production changes, new five-minute profile, staging, commit or push in Batch 3.

Previous Phase 3B checkpoint, retained independently:
The corrected owner capture is complete and internally consistent; its shutdown
sidecar independently verifies normal continuation beyond 300 simulation seconds.
The owner confirms warm-up and basic controls/boundaries/kill feedback/HUD, and
reports closing this new attempt with Alt+F4 before death.
The earlier owner-observed 05:11 survival/continuation/death remains separate
evidence. SC-007's capture is now verified, while acceptance still awaits missing
source provenance. All six T033 owner checks passed: the owner confirms paced
damage from 1–2 enemies and immediate lethal damage from roughly 10+ at 100 HP,
consistent with independent enemy attacks. T033 and Phase 3B are complete.
Phase 4 T034–T041 is now complete; full feature
acceptance is outstanding.
Constitution v1.0.0 and the approved feature documents govern this
ledger. The Phase 2 and Phase 3A sections below preserve historical observations;
the **Phase 3B T033 closure** supersedes earlier US1 statuses, and the final
**Phase 4 T041 owner acceptance closure** section supersedes earlier US2
readiness/deferral and owner-unrun statuses.
Historical empty-bootstrap results are not gameplay evidence.

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

## Phase 4 Batch 2 — T036–T040 implementation and automated evidence (2026-10-03)

The owner authorized this batch, including promotion of dependency-ready tests
and contained automated validation. T036–T040 are implemented and checked in
`tasks.md`. T041 remains unchecked: its automated portion was authorized here,
but its owner controls/visual/game-feel acceptance has not run. Stop at Batch 2.
No specifications, constitution, checklist markers or T034/T035 assertions were
changed. Initial working tree was clean. No commit or push was made.

### Implementation and lifecycle decisions

- T036: GameOver latches once, clears pending camera motion and hit feedback,
  short-circuits later contacts, and commits the lethal step's t_end/tick/HUD
  exactly once. Subsequent coordinator steps and inactive mouse/Escape intents
  cannot change gameplay; the UI tree keeps processing. Out-of-step death uses
  the already committed clock, with no extra simulated duration.
- T037: HUD presents Game Over, final survival time and one focused Restart
  button. Health/time remain above the dim overlay. Click, non-echo Enter/keypad
  Enter and Space emit the presentation-only restart intent. The control is
  absent in Active; both UI disabling and the coordinator guard latch immediately.
- T038: Main and coordinator retain their identities. Each valid restart creates
  fresh arena/player/health/camera/registry/spawner/weapon/feedback/HUD nodes and
  copied validated definitions. The registry is cleared and nodes leave the tree
  synchronously before request_restart returns; queue_free disposes them after
  signal dispatch. Generation increments once after old teardown, before fresh
  validation. All encounter listeners bind their originating generation, including
  health/death/spawn/feedback/restart and Main's production frame listener. Saved
  queued Callables therefore remain harmless after disconnection. A reentrant
  request inside the lethal step defers construction until that final commit;
  its guard latches immediately and no duplicate request can enter.
- T039: Invalid restart still discards the defeated encounter, consumes the next
  generation, publishes only a diagnostic HUD and disables simulation. Main
  retains failure_status=1; a real headless application exits 1. Native intentional
  fault fixtures keep running to assert the diagnostics. Interactive correction
  requires editing the definition and relaunching; no retry UI is added.
- T040: Main reuses one Profile-only capture helper. Before teardown it seals
  raw buffers, flushes final tails, writes outcomes and retains old metadata once.
  Valid fresh definitions/ready nodes precede new paths/buffers/conditions; invalid
  restart opens nothing. Old generations and retired attempts cannot mutate
  evidence. Post-300 death preserves the original endpoint manifest/timing and
  valid survival, with missing continuation still outstanding. Fresh counters do
  not erase failed-attempt records: Profile retains metadata/files and normal
  Play retains coordinator attempt metadata without adding a sampler.
- Profile retirement does not print an application-completion receipt. Shutdown
  prints one receipt containing retained attempts; the launcher verifies every
  current/retired raw byte count, manifest and outcomes sidecar. A previous capture
  fault remains a failure even if fresh capture succeeds. Defeats remain normal
  unsuccessful survival attempts, distinct from incomplete capture.
- The existing native manifest/discovery/execution contract stays strict. All
  thirteen staged entries were promoted after T036–T040 readiness. Harness
  registration assertions now require 64 registered/16 Phase 4/zero staged cases;
  foundation-only explicitly excludes all 51 gameplay cases. No behavioral
  acceptance test was weakened or made optional.
- Required launcher integration matches printed intentional ProfileCapture faults
  to exactly one declared case/source/constraint/count and all five payload
  fields. Stream/log copies are reconciled without multiplying counts; extra or
  log-only faults remain fatal. Ordinary capture faults and engine exceptions
  remain failures. The additional infrastructure cases exercise these boundaries.

### Commands actually executed and outcomes

```powershell
./.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
./tools/validate.ps1 -Mode All -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
./tools/test-validation.ps1 -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
./tools/validate.ps1 -Mode All -InfrastructureFixtures -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
git diff --check
```

| Execution | Actual result / evidence under workspace `.cache/validation/` |
|---|---|
| Spec Kit prerequisites/checklists | PASSED, exit 0; active feature resolved; requirements 16 checked/0 unchecked, technical 36/0; no extensions.yml/hooks present |
| Initial sandbox All | FAILED, launcher exit 1 at path probe despite child exit 0: Windows root certificate store access failed. Import/parse/suite/startups UNRUN. `20261003T134421769-d13ae3ab06bc4fd198dfc479ee1fc51f` |
| First approved All rerun | FAILED at launcher suite classification, exit 1; all 35 parses and native 64/64 / 4,703 assertions passed, but intentional capture faults were matched before parsing declared case records. Corrected classifier ordering; dependent startups UNRUN. `20261003T134438708-c0a847e9e6654bc28b56d0ac5838f32b` |
| Corrected All | PASSED, exit 0; containment/import/35 parses, 64/64 / 4,703 assertions, normal and short headless Profile startups. `20261003T134912421-6f2e88d326fe4e1ab157c9d50bcd3dd3` |
| Infrastructure wrapper | PASSED, exit 0; import/35 parses, Foundation 13/13 / 575 assertions, 51 explicit scope exclusions, zero deferrals, both startups, 142 infrastructure assertions plus all five wrapper environment-restoration checks. `20261003T134941957-25590b92c77c4f89a48f04b821ec1445` |
| Wrapper after launcher receipt-loop cleanup | PASSED, exit 0; same 13/13 / 575 Foundation assertions and 142 infrastructure assertions, all five wrapper environment-restoration checks. `20261003T135254695-19efa52b4ac449f7bbf0ead993e6b9b9` |
| Final All + infrastructure (including log-only fault regression) | PASSED, exit 0; actual Godot 4.7.2 Standard `ed1daf0bf`, verified workspace paths/import/35 parses, **64/64 cases / 4,703 assertions**, 64 authored/registered, **zero deferred/pending/excluded**, both startups and **143 infrastructure assertions**. `20261003T135407690-84051e53f4dd4280a226382c2d7b7f4d` |
| Whitespace/scope/source-artifact audit | PASSED, exit 0; `git diff --check`; only authorized source/docs modified, generated output ignored; unchanged authored Phase 4 fixtures/specification/constitution/checklists |

Approved reruns used the same contained launcher outside the sandbox certificate
restriction. No certificate suppression, installation, global configuration or
external writes were added. All output remains in the ignored project cache.

Infrastructure intentionally executes failing children for real engine exceptions,
parse/resource faults, assertions, incomplete capture, runner reconciliation and
an owned-child timeout. Each expected failure is asserted and retained in
`infrastructure-child-results.json`; these are not unresolved validation failures.
The new `fixture-invalid-restart-app` launches an actual scene without --script,
asserts retained ConfigurationError/status/no encounter/no retry and exits **1**.
The wrapper explicitly expects that result. Additional real GDScript fixtures
execute **8 controls/reentrant/normal-Play-retention assertions**, **7 production
Profile restart/saved-frame-Callable assertions**, and **2 invalid-app assertions**
(17 total, separate from the 4,703 native-suite/143 infrastructure counts).
No rendered smoke, manual playtest or fresh qualifying owner profile ran here.
A failed partial tasks.md patch had no side effects and was replaced by targeted
edits; it was an editing operation, not a test result.

### All sixteen authored Phase 4 cases — registered and passing

| Required case | Assertions | Result |
|---|---:|---|
| defeat.lethal_commit | 19 | PASSED |
| defeat.freeze_escape | 614 | PASSED (600 inactive ticks, ten-second equivalent) |
| defeat.final_hud | 9 | PASSED |
| defeat.game_over_control | 15 | PASSED |
| defeat.three_cycles | 104 | PASSED |
| defeat.guarded_requests | 14 | PASSED |
| defeat.stale_callbacks_removal | 16 | PASSED |
| defeat.invalid_restart | 20 | PASSED (one declared PlayerDefinition fault) |
| defeat.failure_isolation | 13 | PASSED (two records, one failed opportunity) |
| restart_evidence.seal_before_teardown | 32 | PASSED |
| restart_evidence.stale_generations | 23 | PASSED |
| restart_evidence.valid_open | 19 | PASSED |
| restart_evidence.invalid_no_open | 19 | PASSED (one declared PlayerDefinition fault) |
| restart_evidence.shutdown_fault | 16 | PASSED (one exact declared capture fault) |
| restart_evidence.write_fault | 23 | PASSED (one exact declared capture fault) |
| restart_evidence.post300_death | 28 | PASSED |
| **Total** | **984** | **16/16, zero deferred** |

### Batch 2 clause status and owner handoff (historical checkpoint)

FR-010.a–d and FR-011.a–e: automated behavior PASSED through the above real scenes
and callbacks plus real input/application fixtures. Visual legibility, physical
keyboard/mouse feel, release/recapture and normal-play pacing remain owner UNRUN.
SC-002 remains outstanding until the owner completes three normal defeat/restart
cycles. The earlier Phase 3B evidence remains intact; these fixtures do not renew
SC-006/007 owner profiling or resolve its recorded historical source provenance.
US3 pause/resume and later acceptance phases are UNRUN and outside Batch 2.
No new unresolved implementation issue requires an owner design decision.

Recommended T041 owner steps, after separate authorization:

1. Launch `./tools/validate.ps1 -Mode Play` through the contained launcher. Move
   and rotate normally, take lethal contact damage, and check zero health,
   readable Game Over/final time, focused Restart and a released mouse.
2. Wait ten real seconds trying WASD, mouse rotation and Escape/held Escape.
   Check unchanged player/enemies/view/health/time and no spawns/attacks/feedback.
3. Complete three normal defeat/restart cycles using mouse click, Enter and
   Space. Try rapid repeated/held activation. Each cycle must produce one run,
   full health, initial position/view, 00:00, no old enemies or feedback, a ready
   weapon, recaptured mouse and one full first-spawn interval before normal cadence.
4. If reviewing Profile mode separately, preserve the JSON manifest, raw stream
   and outcomes sidecar for each generation and the single shutdown receipt.
   Check failed attempts remain separate; shutdown should preserve unfinished
   evidence. No splicing or fresh acceptance claim is implied by this check.

T041 is deliberately not marked complete; no final owner acceptance was performed.

## Phase 4 T041 owner acceptance closure (2026-10-03)

**Evidence source:** the product owner's confirmation in this session:
“Phase 4 owner acceptance testing passed.” The owner explicitly requested T041
completion. This confirms the previously supplied Phase 4 acceptance procedure;
the manual results below are owner-reported, not playtests executed by Codex.
No additional per-cycle timestamps, measured durations or profiling artifacts
were supplied or inferred.

| Manual acceptance check | Requirement | Owner-reported result |
|---|---|---|
| Normal lethal contact shows zero health, readable Game Over/final time and actionable focused Restart; mouse releases | FR-009/010 | PASSED |
| Ten-second defeated-state check with WASD, mouse and Escape: gameplay/view/health/time remain frozen; Escape cannot resume | FR-010 | PASSED |
| Three consecutive defeat/restart cycles in one application using mouse, Enter and Space | FR-011 / SC-002 | PASSED |
| Each restart restores full health, initial position/view, 00:00, no old enemies/feedback, ready weapon, mouse capture and a full initial spawn delay | FR-011 | PASSED |
| Repeated/held activation leaves one encounter with normal cadence and no carried-over damage or duplicate events | FR-011 | PASSED |

**Completion:** all eight Phase 4 tasks **T034–T041 are complete**. T041 combines
the previously executed registration/automated validation with this owner manual
acceptance. FR-010/FR-011 and SC-002 are accepted for this phase. This section
supersedes the historical Batch 1/Batch 2 owner-unrun and T041-incomplete statuses.

The existing technical evidence remains **64/64 native cases / 4,703 assertions**,
including **16/16 Phase 4 cases / 984 assertions**, zero deferrals, 35 script
parses, both startups and 143 infrastructure assertions. This closure changes
only the ledger, task status and test README; no gameplay code changed and no
Godot suite was rerun. Phase 5 and full feature/performance acceptance remain
outside this request; existing profiling/source-provenance limitations are
unchanged. No new unresolved Phase 4 issue was reported by the owner.

Final repository checks: `git status --short`, `git diff --check`,
`git diff --cached --check` and staged-path inspection. The diff checks passed;
all 13 Phase 4 source/documentation changes are unstaged, with no staged files
and therefore no staged generated profiling/validation artifacts. Workspace
`.cache/` and `.godot/` output remains ignored. Phase 4 is ready for commit upon
explicit authorization; no staging, commit or push was performed.

## Phase 5 Batch 1 — T042–T043 test foundation (2026-10-03)

The owner authorized only test authoring on `001-core-gameplay-prototype`.
Initial working tree was clean. **T042/T043 are complete as authoring tasks**;
their checkboxes are checked. T044–T048 remain unchecked, production gameplay
and scenes are unchanged, and no commit/push was made. No new owner playtest,
rendered smoke or qualifying survival/profile evidence was performed.

### Authored coverage and honest registration

Created `tests/integration/test_pause_resume.gd` (10 cases) and
`tests/integration/test_pause_profile.gd` (8 cases), with necessary source UIDs.
All 18 bodies use actual components, deterministic fixture inputs and existing
Context/F/Phase 4 lifecycle helpers. No mock pause or scheduling/statistics
implementation is added. Fixed reported seeds are 4702042 and 4702043.

Only **`pause.game_over_escape`** is executable now: real lethal contact followed
by Escape press/echo/release and mouse input leaves the defeated encounter and
final result unchanged, emits no gameplay/resume signals and queues no mouse
motion. It passed **22 assertions**. It is a defeat regression, not evidence that
Active/Paused handling exists.

The other **17 cases are intentionally deferred: authored, unregistered, unrun**.
Nine pause cases await T044–T046; all eight profile cases await T044/T045/T047.
The pre-existing staged inventory emits each dependency as `HORDE_CASE_DEFERRED`
and reconciles every declared method before selecting scope. None was promoted
on file presence alone or represented as passing. Registered execution is now
65 cases; full authored discovery is 82. Strict missing/duplicate/unknown/zero/
unexecuted required-case handling is unchanged. Only inventory expectations in
`runner.prerequisites` changed, with its 27 assertions retained. The runner's
comment now refers to staged story cases; execution logic is untouched.

| Authoring task / cases | Coverage awaiting Batch 2 |
|---|---|
| T042 `escape_edges` | Three discrete Active↔Paused press pairs; echo/release/unrelated key rejected; pause prevents simulation in that step; encounter identity retained |
| T042 `freeze_combat`, `inactive_callbacks` | Real contact/hit/feedback, 600 inactive ticks plus actual tree frames; frozen actors/camera transform/health/completed time/ticks/IDs/all deadlines/line/flash; no commit/spawn/attack/damage/feedback signals; saved production health/death/spawn/feedback callbacks harmless; UI tree remains running |
| T042 `spawn_delay`, `weapon_delay`, `contact_delays` | Actual earned binary-exact deadlines before/at/after resume; fixed spawn cadence, actual weapon cooldown, two staggered independent contacts; no early/reset/burst events |
| T042 `feedback_delay`, `mouse_discard` | Actual line/target flash expires only at preserved active deadline; pending Active mouse cleared on pause, inactive motion discarded, released WASD has no backlog, no resumed view jump, fresh motion works once |
| T042 `hud_restart` | Visible Paused/Escape to resume plus health/time; Restart hidden; repeated coordinator/HUD restart intents ignored; overlay removed on resume |
| T043 `close_segment`, `resume_origin` | Actual Main/coordinator transition closes capture at pause wall instant, flushes final raw tail/releases buffers, rejects inactive capture; real new origin/callback on resume; no new attempt/generation or gameplay mutation |
| T043 `exclude_gap` | Deterministic [0,1] and [11,12] windows exclude ten paused seconds; per-segment FPS/full intervals/raw files; active partial boundary stalls remain; separate engine draw audits ignore paused draw IDs |
| T043 `preserve_attempt`, `paused_endpoint` | Repeated segments preserve conditions/generation/outcomes/time/ticks; 299.75 paused cannot earn survival/steps, only completed resumed simulation reaches 300 without ending play |
| T043 `nonqualification` | Otherwise-complete synthetic segmented evidence rejected; clean technical control eligible; output/survival/continuation observations remain distinct and interruption persists to disk |
| T043 `retained_diagnostics`, `post_endpoint_pause` | Defeat/shutdown/retirement preserve segments/raw/count summaries/earlier spawn failure/outcomes; fresh generation resets only its own state, stale samples rejected; post-endpoint pause never reopens/rewrites window or erases earlier survival observations |

Detailed per-case inventory and provisional test adapter are in `tests/README.md`.
These bodies sufficiently cover the **automatable** T044–T047 requirements.
Coverage is authored, not executed behavioural acceptance. Existing Phase 3B
and all 16 Phase 4 behavioural assertions were preserved and rerun successfully.

### Commands actually executed and outcomes

```powershell
./.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
./tools/validate.ps1 -Mode All -InfrastructureFixtures -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
./tools/test-validation.ps1 -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
git diff --check
git diff --cached --check
git status --short --branch
```

The All command ran three times: initial sandbox attempt, approved rerun with
the fixture mistake, then corrected approved rerun. The wrapper ran once outside
the known sandbox certificate restriction. No containment/certificate checks
were suppressed; writes stayed in ignored workspace `.cache/`/`.godot/` output.
Both checklists were read only: requirements 16/16 and technical 36/36 checked.
`.specify/extensions.yml` was absent, so no pre/post implementation hooks exist.

| Execution | Actual result / evidence under `.cache/validation/` |
|---|---|
| Spec Kit prerequisites | PASSED, exit 0; correct branch/feature/tasks resolved |
| Initial sandbox All | FAILED, exit 1 at `paths` despite Godot child exit 0: `Failed to read the root certificate store.` Dependent import/parse/suite/startup/infrastructure UNRUN. `20261003T143240485-c9017019248b4d78a3ee0a5631decc5e` |
| First approved All | FAILED, suite exit 1. Import and all 37 script parses passed; existing 64 cases/4,703 assertions passed. New case failed because F.observe supports 0–2 arguments and attack_feedback has three. New case executed 24 assertions, suite 4,727, with one failed assertion. Dependent startups/infrastructure UNRUN. `20261003T143255013-9b5f46deaaca449eb4952e140da880d7` |
| Corrected approved All + infrastructure | PASSED, exit 0. Actual Godot 4.7.2 Standard `ed1daf0bf`; containment/import/37 parses, **65/65 registered cases / 4,725 assertions**; 82 authored, **17 deferred**, zero pending/excluded; both headless startups; **143 infrastructure assertions**. `20261003T143345993-c1f14d495c4a4e70bf8e6866d39e873c` |
| Final infrastructure wrapper | PASSED, exit 0; containment/import/**37 final-source parses** including the added segment draw-audit assertions; Foundation **13/13 / 575 assertions**, 52 explicitly excluded gameplay cases, 17 deferred, zero pending; both startups; **143 infrastructure assertions** and all **five environment-restoration checks**. `20261003T143509010-5a2204d5acc44b15bdc37dd43a076b47` |
| Whitespace/scope audit | PASSED: `git diff --check` and `git diff --cached --check`; only tests, test inventory/comment, README, tasks and this ledger changed; no staged files or production changes |

The fixture mistake was corrected locally using a Context-owned three-argument
callback; no shared helper or production behaviour changed. Final profile
draw-audit additions are inside deferred cases and were parsed/discovered by the
wrapper; their assertions remain UNRUN. The default registered assertions were
unchanged after the passing All run.

| Existing registered coverage | Cases passed | Actual assertions |
|---|---:|---:|
| Foundation/Phase 3B | 48/48 | 3,719 |
| Phase 4 defeat/restart/evidence | 16/16 | 984 |
| Existing subtotal | **64/64** | **4,703** |
| Newly executed US3 defeat regression | **1/1** | **22** |
| Registered total | **65/65** | **4,725** |
| New implementation-dependent US3 cases | **0/17 executed; 17 deferred** | **UNRUN** |

Infrastructure deliberately executes failing children for engine exceptions,
parse/resource/assertion faults, timeout, reconciliation and the invalid-restart
application. Those observed failures are expected and asserted in retained
`infrastructure-child-results.json`; there is no unresolved infrastructure failure.
Its real controls/reentrant/Play-retention/Profile-restart/invalid-app fixtures
also retained their 17 native assertions, separate from the 143 infrastructure
and 4,725 registered-suite counts.

Two read-only inspection mistakes had no side effects: searching the absent
optional `.codex` directory, and requesting `suite.stdout.log` instead of the
actual `suite.stdout.txt`. The latter PowerShell Get-Content error did not cause
the compound inspection command to exit nonzero; evidence was then enumerated
and read from the actual paths. No missing evidence was counted as a test pass.
A failed partial-line documentation patch was atomic and replaced by exact-line
edits; it was an editing failure, not a test result.

### Batch 2 risks, boundaries and outstanding verification

1. The specs define segmentation semantics but not concrete signatures/metadata.
   Fixtures provisionally use synchronous `toggle_pause()`,
   `close_segment(generation, wall_seconds)`, `open_segment(generation, wall_seconds)`
   and metadata `segments`/`interrupted`/`active_capture_duration`. Segment records
   preserve existing t0/t1/summary/raw descriptors. These are documented test
   seams, not new approved production interfaces. Adapt only wiring/observation
   helpers if T047 chooses another concrete format; keep behavioural assertions.
2. Pause closure must not be confused with defeat/300 closure: preserve
   survival/continuation/failure state, reset only segment origin and interval/
   draw continuity, flush final tails, and never reopen the endpoint buffer.
   Per-segment sample paths/counts must stay coherent for the launcher receipt.
   No capture/classifier changes belong to Batch 1.
3. Later interruption is conservatively flagged as nonqualifying for full
   uninterrupted-attempt evidence even after 300, while prior successful
   survival/profile observations remain intact. The spec distinguishes first
   300 seconds from continuation but does not expressly define post-endpoint
   Pause qualification; review this interpretation in Batch 2.
4. The 600-step freeze is a deterministic ten-second equivalent; the helper's
   exact ten-second wall gap is synthetic. Neither establishes SC-003's actual
   ten-real-second owner check or SC-006/007 owner performance/survival evidence.
   Actual mouse capture/release, overlay legibility and physical controls/game
   feel remain UNRUN and require rendered owner review.

After T044–T047 and separate authorization, launch contained Play and pause during
normal contact combat, record health/time/positions/view/feedback, wait ten real
seconds while holding Escape and trying WASD/mouse, then press Escape again.
Confirm a readable Paused/Escape to resume overlay, visible health/time, hidden
Restart, released/recaptured mouse, unchanged encounter and original remaining
delays without a jump or catch-up. Repeat between spawn/weapon/contact deadlines.
Escape from Game Over must remain inert. Promote the seventeen staged cases only
when dependencies are ready and execute them for T048; deferral is not acceptance.

Final tree: branch `001-core-gameplay-prototype`, six tracked files modified
(`tasks.md`, ledger, test README, manifest, runner comment, runner contract) and
four new source files (two integration scripts plus UIDs), all unstaged. Generated
output remains ignored. **Stop at Batch 1; await owner review and authorization.**

## Phase 5 Batch 2 — pause/resume implementation and automated evidence

**Date:** 2026-10-03. **Scope:** T044–T047 only, authorized implementation and
registration/automated verification of Batch 1 cases. T048 is unchecked; owner
pause closure and subsequent phases were not begun. Branch:
`001-core-gameplay-prototype`. Parent revision:
`b447cafa7c349181709866ad1b22c838122aee35`. Initial working tree was clean.
Constitution v1.0.0 and existing spec/plan/model/contracts/tasks/quickstart were
reviewed. Requirements checklist 16/16 and technical checklist 36/36 are checked;
no checklist markers changed. `.specify/extensions.yml` is absent, so no pre/post
implementation hooks apply. No dependencies, assets, tuning or engine changes.

### Completed tasks and changed files

| Task | Implementation |
|---|---|
| T044 | `scripts/run/run_coordinator.gd`: latched discrete Escape intents, pre-simulation transitions, Active callback gating, preserved encounter/deadlines, retained interruption provenance |
| T045 | `scripts/run/main.gd`, `scripts/camera/camera_rig.gd`: Active-only capture/input, transition motion clearing, inactive camera input rejection; coordinator clears movement action state at transitions |
| T046 | `scenes/hud.tscn`, `scripts/ui/hud.gd`: Paused / Escape to resume overlay behind readable health/time HUD; Game Over and Restart remain exclusive to defeat |
| T047 | `scripts/run/profile_capture.gd`: same-attempt segments, raw-tail sealing, fresh origins/audits, active-duration accounting, persistent interruption exclusion, retained outcomes/diagnostics |

Supporting changes: `tests/case_manifest.gd` requires all 18 US3 cases;
`tests/unit/test_runner_contract.gd` asserts 82 required cases, 18 US3 and zero
staged entries; both US3 integration scripts retain and strengthen acceptance
coverage; `tests/README.md` documents the implemented seam and owner limitations.
`tools/validate.ps1` validates every segment and sidecar provenance;
`tools/test-validation.ps1` exercises a real segmented application and rejects a
missing earlier stream. Both tools retain deeper JSON metadata without truncation.
Only T044–T047 markers changed in `tasks.md`; this ledger records evidence.

### Lifecycle, deadlines and inactive input

The coordinator captures Escape in `_input`, rejecting echoes and duplicate
presses while held; release rearms the latch. Every accepted discrete press is
queued, including multiple press/release pairs before one tick. `step` services
those transitions before camera/movement/spawn/weapon/contact processing.
`toggle_pause()` also provides the synchronous contract seam. A pause intent
prevents that step from advancing completed simulation time or its step count.
Paused steps and saved inactive encounter callbacks produce no gameplay changes.
Game Over remains terminal; Escape cannot resume it and Paused cannot Restart.
The SceneTree remains unpaused, keeping UI processing available.

Pause/resume neither reconstructs actors nor rewrites the active clock, spawn
index/deadline, weapon cooldown, per-enemy contact cooldowns, feedback expiry,
health or camera orientation. All deadlines already use completed active time.
Because inactive wall time never enters that clock, remaining delays are preserved
without subtracting wall time, resetting schedules or replaying missed events.
Resumed executed steps use the existing completion-time rules and normal cadence.

Pending Active mouse motion is cleared on pause; Paused/Game Over motion is
ignored by Main and rejected by the camera queue. Resume clears again without
resetting yaw/depression/follow position. Movement actions are released at the
transition so inactive held action state is not replayed. Fresh Active input
works normally. Main captures the pointer only while Active and releases it in
Paused/Game Over; headless checks cannot establish physical pointer behaviour.

### Resolved Batch 1 profiling seams and qualification

Production adopts `close_segment(generation, wall_seconds)` and
`open_segment(generation, wall_seconds)`. `_metadata()` exposes `segments`,
`interrupted` and `active_capture_duration`. Closed records contain `t0`, `t1`,
`evidence_path`, existing `summary` statistics and `frame_stream` path/count/format.
Each segment has a distinct manifest/raw stream. Pause flushes its final tail and
clears raw/count RAM buffers. Resume creates a new wall origin and draw audit,
without bridging inactive intervals or treating paused draws as missing callbacks.
Closed active wall durations are summed separately from completed simulation time.
The exact [0,1]/[11,12] fixture records two active seconds, excluding the ten-second
pause while retaining each segment's active boundary stalls.

Generation, attempt serial, conditions, outcomes, sampling cadence and earlier
spawn/capture diagnostics survive segmentation. Frame chunks remain bounded to
4,096 float64 timestamps; enemy-count samples are released per closed segment.
Metadata contains paths/summaries, without retained raw arrays. Defeat/shutdown
seal unfinished capture; restart retains the old attempt once and resets only
fresh-attempt state. Stale generations cannot close, reopen or sample a new attempt.
Required-output failures remain explicit and cannot become successful evidence.
The launcher checks every sealed manifest/raw descriptor, not only the latest
stream; its deliberate missing-earlier-stream fixture fails at engine exit zero.

**Interruption after 300 is resolved:** `interrupted` is monotonic within the
attempt, even if raw capture already ended. Later pause never reopens or rewrites
the sealed five-minute window. Successful survival/continuation/capture observations
are retained, while `qualifies_attempt()` rejects the interrupted full attempt.
Shutdown persists that flag in outcomes and the application receipt. A strengthened
post-endpoint case starts with otherwise-complete eligible synthetic evidence,
then proves interruption alone disqualifies it, preserving all successful outcomes
and sealed artifacts. Thus no segmented or later-interrupted attempt qualifies as
uninterrupted SC-003/006/007 owner evidence; acceptance still requires one clean
attempt with independently verified normal tuning, continuation and owner evidence.

### Executed validation and investigation

All engine checks use the existing contained launcher and approved Standard
`4.7.2.stable.official.ed1daf0bf`. Writable APPDATA/LOCALAPPDATA/TEMP/TMP and actual
Godot/editor paths were verified inside `.cache/`; environment restoration passed.
Exact final command:

```powershell
./tools/validate.ps1 -Mode All -InfrastructureFixtures -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
```

PowerShell output was retained at `.cache/batch2-final-validation.log`. Final
session: `.cache/validation/20261003T150625756-b5e4d83192604869b3d42d40335836f2/`.
`results.json` retains every exact engine command/exit/result; suite stdout and
`infrastructure-fixtures.json` / `infrastructure-child-results.json` retain counts,
original diagnostics and deliberate failing children. Output is ignored, uncommitted.

| Final check | Actual result |
|---|---|
| Launcher / version / required help / path containment | PASSED, launcher exit 0; approved engine and contained paths verified |
| Project import/load | PASSED, engine exit 0 |
| Every source/test GDScript `--script <absolute file> --check-only` | PASSED, 37/37, each exit 0 |
| Full native suite | PASSED, 82 required/registered/authored/executed, 5,843 assertions; zero deferred/pending/excluded; exit 0 |
| Phase 3B / foundation regression | PASSED, 48/48 cases, 3,719 assertions |
| Phase 4 defeat/restart/evidence regression | PASSED, 16/16 cases, 984 assertions |
| US3 pause/resume and profiling | PASSED, 18/18 cases, 1,140 assertions |
| Normal startup `--headless --path C:\GameDev\project-horde --quit-after 120` | PASSED, exit 0 |
| Profile startup: same engine arguments plus `-- --profile` | PASSED, exit 0; diagnostic capture receipt/raw stream/manifests/sidecar validated |
| Existing infrastructure plus segmented evidence checks | PASSED, 146/146 infrastructure assertions; real lifecycle fixtures additionally execute 26 native assertions (17 existing, 4 in the intact segment application and 5 in the deliberate-loss application, including its deletion precondition) |
| Environment restoration | PASSED for all four variables |
| Warnings | Zero in required import/parse/suite/startups; only deliberate `fixture-warning` emits `WARNING: HORDE fixture warning`; no JSON depth/truncation warning remains |

Per-case US3 assertions: game_over_escape 22, escape_edges 49, freeze_combat 622,
inactive_callbacks 10, spawn_delay 16, weapon_delay 20, contact_delays 24,
feedback_delay 17, mouse_discard 33, hud_restart 13; close_segment 31,
resume_origin 23, exclude_gap 57, preserve_attempt 36, paused_endpoint 23,
nonqualification 35, retained_diagnostics 61, post_endpoint_pause 48.

Earlier commands/results are retained honestly:

- `./tools/validate.ps1 -Mode All`: BLOCKED, exit 1 before any engine launch;
  sandbox-visible GODOT_BIN was absent in Process/User/Machine scopes.
- `./tools/validate.ps1 -Mode All -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'`
  in sandbox: version/help passed; path preflight emitted the Windows certificate-store
  read error despite child exit 0. Launcher exit 1 stopped dependent checks.
  Retried outside the sandbox through the approved escalation mechanism, preserving
  launcher containment. No engine-error filtering or certificate changes were made.
- Same explicit All command outside sandbox, sessions `20261003T145310202-1b565039fdd448ae81b0bd8008fd4bd6`
  and `20261003T145427694-4fedfcb8b2524269960e59ae118cf588`: import/37 parses
  passed; full 82-case suite failed two assertions at 5,807 assertions, exit 1.
  Startups were UNRUN because the launcher stopped at the failed suite.
- All/InfrastructureFixtures command, session `20261003T150030831-71888f73ac0445fdb3743266d48fdf3c`:
  82 cases / 5,816 assertions, one persistence assertion failed; dependent startups
  and infrastructure were UNRUN. The production mouse behaviour was already correct.
- Investigation found two observation defects in the authored tests. Viewport
  `push_input` transformed synthetic relative motion from the 64-pixel headless
  window to the 1920-pixel stretched viewport (10 became 300). The helper now
  passes viewport-local coordinates; the original camera assertion remains.
  Godot JSON parses numbers as floats and nested Dictionary equality is type-sensitive.
  Persistence assertions now compare **every** field against its expected JSON
  representation, without dropped fields or new tolerance; split assertions improve
  failure attribution. No acceptance requirement or production tuning was weakened.
- Sessions `20261003T150305761-654e27233d0c4a8396c5fde30c533f72` and
  `20261003T150445320-8dde2b8c62034795a96dc064a39af903`: suite passed 82/82,
  5,818 assertions, both startups and 146 infrastructure assertions passed.
  The former emitted a results-JSON depth warning; increasing serialization depth
  preserved segment receipts and removed it. Final rerun adds stronger stale-API and
  otherwise-complete post-300 qualification assertions, producing 5,843 assertions.

An atomic partial-line patch failed before editing and was reapplied correctly.
One evidence inspection requested absent `infrastructure-results.json`; the actual
`infrastructure-fixtures.json` and `infrastructure-child-results.json` were then
enumerated and read. No absent evidence or failed inspection was counted as a pass.
The earlier progress update overstated script count as 39; actual executed final
source/test parses are **37**. Intentional infrastructure failures (including missing
segment, engine faults, incomplete capture and timeout) are expected and asserted,
not unresolved regressions.

### Outstanding owner acceptance and review boundary

Interactive owner checks are **UNRUN** for this batch. In contained Play
(`./tools/validate.ps1 -Mode Play -GodotBin '<approved console executable>'`), pause
once during contact and once between spawn/weapon/contact opportunities. Note
health/time/positions/view/feedback, wait ten **real** seconds while trying WASD,
mouse and held Escape, then release/repress Escape. Verify frozen values, readable
Paused/Escape instruction with health/time visible and Restart absent, released
pointer, recapture on resume, preserved remaining delays, no jump/early/burst event.
Confirm fresh movement/view input works and Game Over Escape remains inert.
Physical key/capture behaviour, overlay contrast and game feel require owner review;
600 delivered ticks and synthetic wall gaps are automated evidence only.

No interactive or new five-minute profiling session was performed or warranted.
Previously recorded owner survival/profile evidence remains separate; these
fixtures claim no new SC-006/007 acceptance and no 200-enemy/60-FPS benchmark.
T048 and T049–T056 remain unchanged and incomplete. Stop after Batch 2 for review.

Final tree: 15 tracked files modified, all unstaged; no untracked deliverables,
no generated validation/profile artifacts tracked, no Git commit or push.
`git diff --check` passed (exit 0); final source line endings normalized to the
repository's CRLF convention to remove Git's LF conversion notices.

## Phase 5 Batch 3 — T048 final validation and owner acceptance closure

**Closure recorded:** 2026-10-03. **Scope:** T048 only. Branch:
`001-core-gameplay-prototype`; validated source revision:
`ea73096ed0a6dd0efe49c0d54e7ccd264ed3d591`
(`feat(gameplay): implement Phase 5 pause and resume lifecycle`). Initial working
tree was clean. The owner reports T042–T047 were committed/pushed and all six
preliminary manual groups completed successfully. This closure records that
confirmation alongside a fresh automated run; Codex did not perform those manual
playtests. Constitution v1.0.0 and the existing Phase 5 spec/plan/contracts/tasks
and independent test were reviewed. Read-only checklists passed 16/16 and 36/36;
no extension hooks file exists.

### Registration and final automated evidence

The existing manifest already registers every authored US3 case: ten `pause.*`
(including `game_over_escape`) and eight `pause_profile.*`, each using its real
integration script and fixed seed 4702042/4702043. `entries()` includes both the
Game Over regression and `pause_entries()`; `staged_entries()` returns an empty
array. `ready_after` fields describe implemented prerequisites and do not defer
these registered entries. The runner reconciled authored methods, registered
IDs and executed IDs, with 82 in each inventory and zero deferred/pending/excluded
cases. All Phase 3B and Phase 4 cases remain required and were executed.
No manifest, assertions, production scripts/scenes, configuration or assets changed.

Exact successful command, from `C:\GameDev\project-horde`:

```powershell
./tools/validate.ps1 -Mode All -InfrastructureFixtures -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
```

**Result:** launcher exit 0, 49/49 recorded checks passed. Approved Godot Standard
version `4.7.2.stable.official.ed1daf0bf`; verified writable user/editor/cache/temp
paths remained inside workspace `.cache/`, and all four environment variables
were restored. Output: `.cache/batch3-final-validation.log`. Final evidence:
`.cache/validation/20261003T152808972-6f432766b8e1416886c2d57a3e37f153/`.
`results.json` retains exact per-child commands/exits, `suite.stdout.txt` the native
case records, and `infrastructure-fixtures.json` / `infrastructure-child-results.json`
the fixture outcomes and deliberately failing children. These generated files stay
ignored and untracked.

| Executed check | Actual result |
|---|---|
| Version / help / path preflight | PASSED, each child exit 0; approved Standard version and actual containment verified |
| Project import/load | PASSED, child exit 0 |
| All source/test GDScript `--script <absolute file> --check-only` | PASSED, 37/37, each child exit 0 |
| Complete native suite | PASSED, 82/82 cases, 5,843 assertions, child exit 0; zero deferred/pending/excluded |
| Phase 3B / foundation regression | PASSED, 48/48 cases, 3,719 assertions |
| Phase 4 defeat/restart/evidence regression | PASSED, 16/16 cases, 984 assertions |
| US3 pause/resume/profiling integration | PASSED, 18/18 cases, 1,140 assertions |
| Normal startup `--headless --path C:\GameDev\project-horde --quit-after 120` | PASSED, child exit 0 |
| Profile startup, same arguments plus `-- --profile` | PASSED, child exit 0; required receipt/stream/manifest/outcomes checked |
| Infrastructure fixtures | PASSED, 146/146 assertions, including segmented application receipt and missing-earlier-stream rejection |
| APPDATA / LOCALAPPDATA / TEMP / TMP restoration | PASSED, four checks |
| Unexpected warnings / errors | None in final required checks; only intentional `fixture-warning` emitted `WARNING: HORDE fixture warning` |

Fresh per-case US3 assertion counts match Batch 2: game_over_escape 22,
escape_edges 49, freeze_combat 622, inactive_callbacks 10, spawn_delay 16,
weapon_delay 20, contact_delays 24, feedback_delay 17, mouse_discard 33,
hud_restart 13; close_segment 31, resume_origin 23, exclude_gap 57,
preserve_attempt 36, paused_endpoint 23, nonqualification 35,
retained_diagnostics 61, post_endpoint_pause 48.

The first command, `./tools/validate.ps1 -Mode All -InfrastructureFixtures`, was
**BLOCKED**, exit 1 before engine launch: sandbox registry isolation exposed no
GODOT_BIN in Process/User/Machine scopes. The explicit approved console override
and authorized execution outside the sandbox resolved it while retaining launcher
write containment. No installation, global configuration or diagnostic suppression
was used. Expected infrastructure fault/timeout/missing-output children were
observed and asserted; they are not unresolved regressions. No other failed,
skipped, blocked or unrun required Phase 5 automated check remains.

### Owner-reported manual acceptance — separate evidence

**Source:** the product owner's Batch 3 request explicitly states all six
preliminary acceptance groups completed successfully. **Outcome:** PASSED for
all six groups, as reported by the owner. The confirmation supplies manual
acceptance of the existing documented procedures; no new manual run was performed
by Codex. Specific execution times, measured coordinates/health values, stopwatch
traces, screenshots and a per-test machine report were not supplied and are not
invented here.

| Group | Owner-reported result | Requirement coverage of the completed group |
|---|---|---|
| 1. Basic pause and HUD | PASSED — owner reported | Active/Paused indication and resume instructions; visible frozen health/time; pause presentation distinct from defeat (FR-009/012, T046) |
| 2. Freeze during enemy contact | PASSED — owner reported | Contact pause protocol, unchanged encounter/view/health/time with no inactive combat; ten-real-second criterion from the existing procedure (FR-012, SC-003) |
| 3. Preserved scheduled-event delays | PASSED — owner reported | Between-event pause protocol and resume with remaining spawn/weapon/contact delays, without early/catch-up events (FR-012, SC-003) |
| 4. Mouse and keyboard input handling | PASSED — owner reported | Held Escape handling, inactive WASD/mouse, release/recapture and no resumed camera jump (T044/T045, player-interface contract) |
| 5. Repeated pause/resume cycles | PASSED — owner reported | Repeatable living-encounter transitions with preserved state and delays (FR-012) |
| 6. Phase 4 Game Over/restart regression | PASSED — owner reported | Defeat remains terminal to Escape; existing Game Over presentation/restart remains usable (FR-010/011, prior US2 acceptance preserved) |

The ten-real-second contact and between-event procedures are specified in
`tasks.md`'s Phase 5 independent test, FR-012 acceptance and quickstart step 3.
The owner's report of successful completion of the prescribed groups is the
manual evidence for that criterion; deterministic 600-tick/synthetic wall-gap
fixtures are recorded separately and do not substitute for it. No additional
unreported timings, cycle counts or input measurements are claimed.

### T042–T048 requirements reconciliation and closure

| Tasks / criteria | Closure evidence |
|---|---|
| T042 / T044 — discrete Escape and inactive gameplay | Required `pause.*` cases pass, including held press/echo/release, pre-step gating, frozen callbacks and terminal defeat; owner groups 2/4/5/6 passed |
| T045 — capture, transition clearing and preserved view | `pause.mouse_discard` and freeze/edge cases pass; owner group 4 passed |
| T046 / FR-009 — readable pause HUD and unavailable Restart | `pause.hud_restart` and freeze cases pass; owner group 1 passed |
| FR-012 / US3 acceptance scenarios / independent test / SC-003 | Freeze and spawn/weapon/contact/feedback delay cases pass; owner groups 1–5 passed, covering contact and between-event pauses plus preserved-delay resume |
| T043 / T047 — profiling segments and interruption qualification | All eight `pause_profile.*` cases pass, including exact pause-gap exclusion, bounded buffers, stale generations, retained diagnostics and otherwise-complete post-300 nonqualification; launcher validates every segment |
| T048 — registration, final tooling, ledger and owner acceptance | All 18 cases required, no deferrals; fresh full All/infrastructure run passed; six owner groups recorded separately; README and ledger reconciled |

**T048 is complete; T042–T048 and Phase 5/US3 are closed. SC-003 is passed on the
combined automated and owner-reported evidence.** No genuine regression was found,
so production scope was not expanded. Pause testing establishes SC-003; interrupted
profile attempts remain diagnostic and cannot qualify as uninterrupted SC-006/007
evidence. This batch does not award new survival/performance acceptance or change
previously retained owner/profile outcomes.

Only three tracked documentation files changed: `tests/README.md`,
`docs/verification/core-gameplay.md`, `specs/001-core-gameplay-prototype/tasks.md`.
Only T048's task marker changed; a Phase 5 closure note/checkpoint was added.
Earlier Batch 1/2 unrun/deferred/owner-pending statements remain historical and
are superseded by this section. Phase 6 T049–T056 remains unchanged and unchecked;
full integrated feature/provenance/performance review and the future 200-enemy/
60-FPS benchmark remain separate work, not Phase 5 blockers.

`git diff --check` passed (exit 0). Final working tree: the three documentation
files above modified and unstaged, no staged changes or untracked files; generated
validation/profile/import artifacts remain ignored and untracked. No new five-minute
profiling session, gameplay changes, staging, commit or push. **Stop after T048
and await owner review.**

## Phase 6 Batch 2 — T051 passed; T052 owner feedback reconciled, closure pending

**Recorded:** 2026-10-03. Scope is T051–T052 only, governed by constitution
v1.0.0 and the reconciled [quickstart](../../specs/001-core-gameplay-prototype/quickstart.md).
Validated branch: `001-core-gameplay-prototype`; source revision:
`31975d35d2dc5432633e0ae690409a293e7b5610`. The initial working tree was clean.
Both read-only requirements checklists passed (16/16 and 36/36); no
`.specify/extensions.yml` exists. No production/test/scene/resource/tuning,
launcher or profiling semantics changed. Historical acceptance above remains
historical; it does not supply observations for the new integrated journey.

### T051 automated evidence — PASSED

Actual environment: PowerShell **7.6.6** on Microsoft Windows 10 IoT Enterprise
LTSC, 64-bit, build/version **19044 / 10.0.19044**; Intel Core i7-12700KF;
34,099,900,416 bytes physical RAM reported by CIM (32 GB installed reference);
NVIDIA GeForce RTX 3080, Windows driver version **32.0.16.1062**; timezone
`Eastern Standard Time`. GPU VRAM was not independently measured. Engine is the
existing console Standard executable
`C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`, verified as
`4.7.2.stable.official.ed1daf0bf`, non-Mono, editor-capable, PE console subsystem.
These are headless checks; actual rendered GPU performance is unmeasured.
PowerShell 7.6.6 is the execution-shell deviation from the quickstart's Windows
PowerShell wording; Windows PowerShell 5.1 was not separately tested.

For clean import, the existing generated `.godot/` was moved to
`.cache/t051-import-before` after checking both resolved paths stayed under
`C:\GameDev\project-horde`, rejecting reparse-point roots and refusing to
overwrite an existing backup. `.godot/` was confirmed absent before validation.
The first successful full run rebuilt it from tracked sources/UIDs. The wrapper
then validated that imported project. The old cache and all new artifacts remain
ignored; nothing outside the workspace was moved or modified.

Commands actually executed from the repository root, in order:

```powershell
./.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
./tools/validate.ps1 -Mode All
./tools/validate.ps1 -Mode All -InfrastructureFixtures -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
# Retry the same command through approved execution outside sandbox isolation:
./tools/validate.ps1 -Mode All -InfrastructureFixtures -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
# Also through approved execution outside sandbox isolation:
./tools/test-validation.ps1 -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
./.cache/t051-audit.ps1
git check-ignore -v .godot/uid_cache.bin .cache/validation/20261003T160901684-0951428d062b466586829e4bf6ecf3ef/results.json .cache/t051-import-before .cache/profile
git diff --exit-code -- scripts tests scenes resources project.godot
git diff --check
```

The prerequisite check exited 0. The bare All command was **BLOCKED**, exit 1,
before engine launch: sandbox-visible Process/User/Machine GODOT_BIN scopes
were all absent/empty. The explicit sandbox command was **FAILED**, launcher
exit 1: version/help passed, but `paths` emitted
`ERROR: Failed to read the root certificate store.` at
`get_system_ca_certificates (platform/windows/os_windows.cpp:2582)` with child
exit 0. Import/parse/suite/startups/infrastructure were **UNRUN** in that attempt.
Failed session: `.cache/validation/20261003T160839471-f06ef2aeb9a34872bc953e5da6d436c4/`.
The genuine engine error was retained and not suppressed or converted to success.
The approved retry outside isolation resolved certificate access while preserving
the launcher's actual-path containment. No certificate/global configuration changed.

Successful full session:
`.cache/validation/20261003T160901684-0951428d062b466586829e4bf6ecf3ef/`.
Successful wrapper session:
`.cache/validation/20261003T160938844-18b2a4f6e08845a5a18774d4ef413352/`.
Both launcher/wrapper processes exited **0**, with **49/49 PASSED** top-level
records in each `results.json`. Each session retains exact per-child commands,
exits, timeouts, classified diagnostics, stdout/stderr and engine logs;
`verified-paths.json`, `infrastructure-fixtures.json` and
`infrastructure-child-results.json` provide containment and fixture evidence.
These paths are actual generated session identifiers, not owner playtest times.

| Required check | Full All result | Wrapper result |
|---|---|---|
| Version/help/actual-path preflight | PASSED, each exit 0 | PASSED, each exit 0 |
| Import/load | PASSED, clean `.godot/` rebuild, exit 0 | PASSED, exit 0 |
| Every GDScript parse | PASSED, 37/37: 20 production + 17 test/support, each exit 0 | PASSED, same 37/37 |
| Manifest/discovery/execution | PASSED, 82 authored/registered/required/executed, 5,843 assertions | PASSED, 82 authored/registered; 13 required/executed Foundation cases, 575 assertions; 69 intentionally excluded gameplay cases |
| Deferred/pending cases | 0 / 0; excluded 0 | 0 / 0; Foundation exclusion is declared scope |
| Normal main startup | PASSED, exit 0 | PASSED, exit 0 |
| Profile main startup | PASSED, exit 0, required receipt/manifest/raw stream/outcomes validated | PASSED, same lifecycle checks |
| Infrastructure | PASSED, 146/146 assertions | PASSED, 146/146 assertions |
| APPDATA/LOCALAPPDATA/TEMP/TMP restoration | PASSED, all four | PASSED, including initially absent TEMP |
| Wrapper's extra restoration checks | Not applicable | PASSED, all five: APPDATA/LOCALAPPDATA/TEMP/TMP/GODOT_BIN; TEMP and GODOT_BIN remained absent |
| Unexpected errors/ambiguous severity/warnings | 0 / 0 / 0 in required engine checks | 0 / 0 / 0 in required engine checks |

Full suite counts reconciled to `HORDE_CASE_END` records and actual ten-file
manifest/discovery; every case completed with positive assertions:

| Case group / source file | Cases | Assertions |
|---|---:|---:|
| definitions / `unit/test_definitions.gd` | 8 | 510 |
| runner / `unit/test_runner_contract.gd` | 5 | 65 |
| movement / `unit/test_movement_arena.gd` | 6 | 178 |
| combat / `unit/test_combat.gd` | 7 | 161 |
| survival / `integration/test_survival_loop.gd` | 13 | 469 |
| profile / `unit/test_profile_capture.gd` | 9 | 2,336 |
| defeat / `integration/test_defeat_restart.gd` | 9 | 824 |
| restart_evidence / `integration/test_restart_evidence.gd` | 7 | 160 |
| pause / `integration/test_pause_resume.gd` | 10 | 826 |
| pause_profile / `integration/test_pause_profile.gd` | 8 | 314 |
| **Total** | **82** | **5,843** |

Phase 3B/foundation: 48 cases / 3,719 assertions; Phase 4: 16 / 984;
Phase 5: 18 / 1,140. Infrastructure assertions are separate from suite totals.
The 22 retained infrastructure children exercise controls, real Profile restart
and segments, failed restart status, informational/warning output, engine errors,
capture/stream/sidecar faults, native error monitoring/assertions, parse/runtime/
resource faults, timeout cleanup, and all five runner reconciliation failures.
Five children pass normally; seventeen deliberately fail as their enclosing checks
require. Seven deliberately fail at exit 0 (missing earlier segment stream,
zero-exit error, capture failure, truncated capture, sidecar failure, runtime
exception and missing resource); nine exit 1; the timeout record uses exit -1
with `TimedOut=true`. Original
diagnostics and owned-process cleanup assertions are retained. The one deliberate
`fixture-warning` emits `WARNING: HORDE fixture warning`, recorded separately.
These fixture outcomes are verified error-policy evidence, not gameplay failures.

All default limits were used: version/help/path probe 30 s, import 180 s,
each parse 30 s, suite 120 s, each startup 30 s. Startup engine arguments were
`--headless --path C:\GameDev\project-horde --quit-after 120`, with
`-- --profile` for Profile; 120 counts iterations, not seconds. No timeout
override or optional `-RenderedProfileSmoke` was used. Infrastructure enforced
its own intentional one-second timeout; no required check timed out. Actual
user/data/config/cache/editor paths were checked under the unique workspace
session; project import stayed under `.godot/`. Profile startups and synthetic
endpoint/segmentation cases are diagnostic and establish no owner survival/FPS.

Source audit **PASSED**, exit 0: 37 unique, valid, tracked `.gd.uid` sidecars
for all 37 production/test scripts; 33 literal production source references
exist and are tracked across project/scenes/resources/scripts. There are **zero
explicit `uid://` references in production source text**; resource loading uses
tracked paths. Clean import/parse/startup additionally exercise resolution.
The two `.cache/` literals in Main/capture are documented output containment
paths, not source resources. Zero tracked generated cache/import/log/temp/raw
frame artifacts; `git check-ignore -v` confirmed `.godot/` and `.cache/` rules.
`git diff --exit-code -- scripts tests scenes resources project.godot` passed,
so clean import did not alter tracked source or UIDs. Audit script/results and
reference inventory are retained only under ignored `.cache/t051-*`.

Ancillary investigations: sandbox CIM OS/CPU/RAM/GPU queries reported access
denied, although that compound shell returned 0; they were not counted as
successful environment checks. Approved read-only CIM retry with terminating
errors passed and supplied the environment above. The initial reference audit
twice exited 1 by treating Main's profile destination and capture's cache root
as tracked inputs. Inspection identified both `ProjectSettings.globalize_path`
output literals; the corrected audit checks loaded source references and reports
those two destinations separately. Its initial diagnostic counter also counted
null fields on non-engine records; inspecting engine records directly corrected
the counter to zero. No production/test change or scope expansion was needed.

**T051 is complete.** No remaining required automated blocker, skipped or unrun
check. The optional rendered fixture and Windows PowerShell 5.1 run are unrun,
not required checks claimed as passed. T052 owner feedback has been received;
its accepted observations and remaining closure requirements are reconciled below.

### T052 owner procedure — prepared checks; aggregate owner acceptance recorded below

The owner has now reported performing the integrated journey to the best of
their ability, with all observed gameplay behaving as expected and no observable
failures. The A01–A15 entries retain the prepared procedure and expected results;
they are not individual execution records. Their individual details were not
supplied. See the owner-feedback reconciliation below for accepted observations,
technical evidence and remaining closure requirements.

Perform this after T051 in normal contained **Play**, using the quickstart's
unchanged default resources. Run it yourself without developer intervention:

```powershell
Set-Location 'C:\GameDev\project-horde'
./tools/validate.ps1 -Mode Play -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
```

Use the standalone 1920×1080 view with working Forward+ graphics. Keep the
console open; close with Alt+F4/window close at the end and report launcher
result/evidence path. Do not use the editor, debug injection, changed tuning or
Profile. Play has no automatic timeout. No five-minute session is requested.
Record your actual date, revision/working-tree state, OS/CPU/RAM/GPU/driver,
window resolution/settings and any deviation; do not assume the automated
environment is your manual environment. A stopwatch is useful; optional video
makes subsecond delays easier to review, but recording software is not required.

Movement is WASD; mouse changes yaw/depression; Escape toggles alive
Active/Paused once per press. Release/repress Escape; release other keys before
transitions and press movement afresh after resume. Restart is offered only in
Game Over and accepts mouse click, Enter/keypad Enter or Space. There is no
manual fire/jump/sprint. Cyan is the player, orange-red is the one enemy type;
yellow attack lines and white hit flashes last 0.12 active seconds.

Perform A01–A11 during ordinary attempts. Kite by moving around the open arena
when you need time; the player moves 6 m/s versus enemies' 3 m/s. If defeated
before a check, restart normally and identify the new attempt in your notes.
Complete A12–A14 as **three consecutive defeat/restart cycles in the same
application**, counting the first deliberate defeat as cycle 1. Finish A15 in
the final fresh run. Do not turn a missed observation into a pass.

**A01 — Fresh presentation (FR-003/006/009/011; SC-004).**
Steps: On launch, look at the player, floor, visible boundary strips and HUD;
note health, time and initial view before moving. Repeat this immediate inspection
after each counted restart.
Expected: One cyan player at the center, flat contrasting floor, identifiable
limits; health `100 / 100`, time `00:00`, no inherited enemies; Active pointer
captured, no Paused/Game Over/Restart overlay.
Timing/setup: Initial zero time/empty population lasts less than 1.5 active s;
use a restart if you missed launch.
Report: Recognizability/readability, actual fresh values/view/population, any
unexpected overlay or stale actor. Status/observation: **Individual execution/detail not separately reported; observed subset accepted below**.

**A02 — Directions, cancellation and stopping (FR-001; diagonal/opposed/release
edges; SC-004).**
Steps: Away from walls, tap W, S, A and D separately, releasing each. Hold W+S,
then A+D briefly. Compare approximately one second of W with one second of W+D
on open floor; release all keys after each. Rotate mouse yaw about 90° and repeat
the four individual keys. While moving, rotate yaw and see movement respond.
Expected: Forward/back/left/right follow current horizontal camera orientation;
opposed axes cancel; release stops; diagonal travel has comparable total speed;
new yaw changes movement direction promptly.
Timing/setup: Use short trials away from perimeter/enemies. No coordinate/ruler
HUD exists; this is an observable speed check, not an exact distance measurement.
Report: Each key before/after yaw, cancellation/stop, apparent diagonal speed,
simultaneous mouse/movement responsiveness and any uncertainty. **Individual execution/detail not separately reported; observed subset accepted below**.

**A03 — Mouse limits and follow (FR-001/002; SC-004).**
Steps: Stop moving and move mouse horizontally, then up/down. Continue vertical
motion to each limit; try further motion. Walk while observing follow at each
pitch, returning to a comfortable view afterward.
Expected: Mouse alone changes view but never player position; pitch never adds
vertical travel. Camera follows immediately; cyan player remains visible, with
no inversion or floor crossing. Depression stops within configured 15–65°.
Timing/setup: Active only; numeric angles need not be measured. Recheck visibility
at perimeter/corners in A04.
Report: Rotation directions, both limits, visibility/follow, capture feel/jumps.
**Individual execution/detail not separately reported; observed subset accepted below**.

**A04 — All boundaries and overlap (FR-003/004/008; containment/nonblocking
edges; SC-004).**
Steps: Traverse each of the four sides and four corners; hold movement outward
briefly at each. At a corner try diagonal outward input and both pitch limits.
Watch pursuing enemies at the perimeter. Walk through an approaching enemy or
overlapping group, then escape into open space.
Expected: Player/enemy bodies stay inside visible arena limits (centers inset
by 0.4 m); no vertical escape, speed advantage or camera loss at corners. Actors
can overlap without obstructing movement; enemies redirect and remain contained.
Timing/setup: Keep moving to avoid lethal crowd contact; repeat missed corners
on another normal attempt. No need to hold every corner until enemies arrive.
Report: Sides/corners actually visited, actor escape/occlusion/blocking, enemies
observed at limits. **Individual execution/detail not separately reported; observed subset accepted below**.

**A05 — Spawn cadence and pursuit (FR-004; safe-spawn edges; SC-004).**
Steps: On a fresh launch/restart, stay moving and watch the first three spawn
opportunities, then change direction/location and watch enemies follow. Where
possible keep targets outside the weapon's 4 m range for this observation.
Expected: No enemy immediately at reset; first spawn after 1.5 active s, then
one at ordinary 1.5 s opportunities while capacity is available, one visual type;
new actors start inside limits and strictly outside 1.2 m contact distance.
Pursuit follows your current position and can reach contact.
Timing/setup: Look for spawns around active 1.5, 3.0 and 4.5 s; HUD rounds to
whole seconds and does not expose IDs/counts. Distinguish kills from missing spawns.
Report: Observed first/next opportunities, type/placement, redirection/contact,
any immediate spawn damage, burst or diagnostic. **Individual execution/detail not separately reported; observed subset accepted below**.

**A06 — Automatic hits, selection and kills (FR-005/006/007; no-target,
reassessment/dead-source edges; SC-004).**
Steps: Keep away from enemies first and observe no attack without eligibility.
Let an approaching enemy enter weapon range, without pressing a fire control.
Watch yellow line/white target flash and the eventual disappearance. If two
enemies are visibly at unequal nearby distances, watch which receives the line.
After a kill, move through its former location when no other enemy is contacting.
Expected: Automatic attack identifies one nearest eligible living target; ready
weapon attacks promptly, later hits about 0.6 active s apart. A fresh enemy takes
three 10-damage hits to exhaust 30 health; death removes it promptly and it no
longer moves, flashes, is targeted or damages you. Other living targets are
reassessed at later opportunities.
Timing/setup: Feedback is only 0.12 s; track one actor when possible. There is
no enemy-health/debug-distance HUD. Do not report exact health, tied-distance
ordering or exact 4 m eligibility unless actually observable; see edge table.
Report: At least one witnessed kill, feedback clarity/cadence, absent-target
behaviour, nearest-target observation or missing opportunity, post-kill effects.
**Individual execution/detail not separately reported; observed subset accepted below**.

**A07 — Contact, vulnerability and independent damage (FR-006/008;
overlap/multiple-contact edges; SC-004).**
Steps: Note health. Move toward an approaching enemy and let it contact you;
watch the decrement. Remain briefly if safe, then separate. If feasible, quickly
leave and re-enter contact before one second elapses. Later allow two enemies
to contact you, then escape and wait several active seconds without contact.
Expected: Each ready living attacker removes 10 health on first contact;
sustained contact respects that enemy's 1.0 active s interval, not every frame.
Leaving stops contact damage; quick re-entry neither bypasses nor resets its
remaining cooldown. Multiple ready enemies may remove 20 or more in one update;
health never goes negative. Separation/waiting does not heal. Overlap does not
block movement; there is no grace period.
Timing/setup: Automatic weapon may kill the isolated enemy before a second
contact. Try another naturally approaching enemy/group; identify crowd size and
report any cooldown observation you could not isolate rather than guessing.
Report: Actual before/after health, approximate hit spacing, separation/re-entry
and no-healing observations, crowd size and vulnerability feel. **Individual execution/detail not separately reported; observed subset accepted below**.

**A08 — Active HUD/time (FR-009; SC-004).**
Steps: Kite in one ordinary attempt to at least 65 completed active seconds;
watch HUD throughout movement, attacks and health changes. Use a stopwatch from
fresh-run readiness, stopping it during pauses; look for `01:05`. If defeated
early, restart and identify the successful observation attempt separately.
Expected: Current/max health stays readable and damage appears promptly; time
starts zero and advances as MM:SS only in Active. At about 65 active s, display
is `01:05`, within one displayed second under smooth simulation.
Timing/setup: Wall stalls can make simulation lag the stopwatch; report stalls
and timings instead of equating wall time to exact completed ticks. This is a
65-second HUD check, not five-minute survival/profile acceptance.
Report: HUD readability, health update, displayed time/stopwatch estimate,
paused duration excluded and any stalls or inability to reach 65. **Individual execution/detail not separately reported; observed subset accepted below**.

**A09 — Ten-real-second pause during contact (FR-008/009/012; SC-003/004).**
Steps: When taking contact damage while alive, release movement and press Escape
once. Note health/time, actor positions, camera and any visible attack feedback.
Hold Escape after this press for at least two seconds: it must stay paused.
Release it, try WASD and mouse while paused, and wait at least ten real seconds
total. Compare the noted values, then release all keys and press/release Escape
once to resume; press movement afresh and escape the contact.
Expected: Paused/Escape-to-resume overlay, readable HUD, released pointer,
Restart hidden; zero gameplay/view/time/health changes, new spawns or attacks
throughout pause. Existing visible feedback freezes. Resume recaptures mouse,
keeps encounter/view, discards inactive mouse/input and causes no jump or burst.
Timing/setup: Pause promptly after a contact hit to retain some cooldown. A
different ready enemy may legitimately hit immediately after resume; note crowd
context. If feedback was absent at pause, record that clause as unobserved.
Report: Before/after health/time/view/positions, measured real pause duration,
held-Escape response, overlay/pointer, feedback observation, resume effects.
**Individual execution/detail not separately reported; observed subset accepted below**.

**A10 — Preserved spawn delay (FR-004/012; between-event/no-catch-up edges;
SC-003/004).**
Steps: In a fresh run, press Escape roughly half a second after readiness,
before the first enemy spawns. Note empty encounter/health/time/view, wait ten
real seconds with attempted WASD/mouse, release keys, then press/release Escape
to resume. Watch first spawn and the following two opportunities.
Expected: No spawn while paused; first spawn waits roughly the remaining one
active second after resume, rather than immediately, a new full 1.5 s, or a
ten-second backlog. Subsequent opportunities return to ordinary cadence.
Timing/setup: Repeat after a counted restart if launch setup was missed. A
stopwatch/video supports the approximation; there is no deadline debug HUD.
Report: Estimated active elapsed before pause and real pause duration,
resume-to-first-spawn delay, later cadence and any burst/reset/early event.
**Individual execution/detail not separately reported; observed subset accepted below**.

**A11 — Preserved weapon/contact delays and repeated transitions (FR-005/008/
009/012; inactive-input, feedback, no-reset/no-catch-up edges; SC-003/004).**
Steps: Press Escape immediately after a visible weapon hit while its target
remains alive and eligible. Wait ten real seconds, resume, and watch the next
hit. Separately pause immediately after a contact decrement while the same
enemy remains alive; wait ten real seconds, then resume and watch the next
decrement. Repeat at least two more short pause/resume cycles during ordinary
movement, releasing/repressing Escape and pressing movement afresh.
Expected: Eligible weapon/contact events wait their remaining portions of
0.6/1.0 active s, not wall pause time or a reset full interval; no catch-up burst.
Only one toggle per press; living encounter/HUD/view persist and fresh input
works each time. Feedback visible at pause persists until its remaining active
duration expires after resume. Restart stays absent in Active/Paused.
Timing/setup: Readiness may already be reached when you pause late, targets
may die/leave range, and different contacts have independent deadlines. Report
those circumstances; don't force fixtures or claim exact subsecond timing.
Report: What event preceded each pause, pause duration, same target/contact
availability, approximate resume delay, cycle count, pointer/input/view behaviour,
feedback if visible and any unobserved clause. **Individual execution/detail not separately reported; observed subset accepted below**.

**A12 — Defeat and terminal freeze (FR-006/007/009/010/012; lethal-order,
multiple-contact/Game-Over-Escape edges; SC-002/004).**
Steps: Deliberately stop/enter a crowd until health reaches zero. Note final
time and population/view. Wait ten real seconds trying WASD, mouse and several
discrete Escape presses; release all keys afterward. Perform this for each
counted defeat, identifying cycles 1, 2 and 3.
Expected: Zero health, Game Over, matching final survival time, readable HUD,
released pointer and focused/actionable Restart. No movement/camera/spawning/
attacks/damage/time after defeat; Escape never resumes. Defeat presentation
occurs once and the final result stays fixed; attack feedback is cleared.
Timing/setup: Multiple contacts can kill immediately; report crowd context.
Normal visuals cannot establish same-tick internal event order or old callback IDs.
Report: Final health/HUD/overlay time, ten-second durations, terminal freeze,
Restart visibility/focus, any post-defeat change or repeated transition.
**Individual execution/detail not separately reported; observed subset accepted below**.

**A13 — Three clean restarts with all activation paths (FR-011; SC-002/004).**
Steps: After cycle 1's A12 check, click Restart; after cycle 2, activate initially
focused Restart with Enter; after cycle 3, use Space. Keep the same application
open throughout. Immediately inspect A01 values after each, then watch the
first spawn and ordinary cadence. Rotate/move/damage the player before the
next defeat so each restart has changed state to clear.
Expected: Exactly one fresh encounter per activation, health 100/100, 00:00,
center/initial yaw 0° and depression 35°, no old enemies/carried damage, ready
weapon on first eligibility, full first-spawn delay 1.5 active s. Mouse captured;
Game Over/Restart gone; normal controls/cadence return each time.
Timing/setup: Capture fresh values immediately; naturally resumed simulation
starts advancing at once. The third restart opens a fourth fresh attempt.
Report: Cycle 1/2/3 activation method, reset values/view/population, first-spawn
delay, later attack/damage behaviour and any duplicate/stale encounter.
**Individual execution/detail not separately reported; observed subset accepted below**.

**A14 — Repeated/stale activation guard (FR-010/011/012; repeated-Restart,
inactive-restart/old-encounter edges; SC-002/004).**
Steps: During one of the counted Game Overs, activate Restart rapidly twice
(double click or two Enter presses). In the resulting Active run press Enter
and Space again; also try them while Paused, then resume. Observe the encounter
through at least three ordinary spawn opportunities.
Expected: One fresh run from the Game Over intent, no second reset/old actors,
duplicate spawn cadence or damage. Enter/Space do not restart Active/Paused;
Restart is unavailable there. Escape still resumes only the living paused run.
Timing/setup: Combine with A13 without adding an application relaunch. Internal
generation/ID/failure counters are fixture evidence, not visible HUD values.
Report: Repeated input used, any reset/duplication, active/paused guard response,
post-restart cadence and old-actor/damage symptoms. **Individual execution/detail not separately reported; observed subset accepted below**.

**A15 — Integrated usability, console and close (FR-001–012 observable journey;
SC-004).**
Steps: In the final fresh run demonstrate WASD, mouse, a normal pause/resume,
then close via Alt+F4/window close. Review the console's launcher result and
any warning/error/application diagnostic. Confirm which of A01–A14 you actually
completed without developer intervention.
Expected: Controls/contrast/HUD/feedback/overlays are usable across the complete
loop; close returns to console normally. Unexpected spawn/configuration/runtime
diagnostics are failures to investigate even if play continued or exit was zero.
Timing/setup: Console/log evidence survives closure in the printed contained
session directory. No five-minute run, Profile capture or tuning changes needed.
Report: Difficulty/game feel, unclear controls/visuals, intervention if any,
unobserved checks, console exit/result and evidence path, exact diagnostic text.
**Individual execution/detail not separately reported; observed subset accepted below**.

### T052 clause/edge evidence boundaries

The owner accepts the gameplay they directly observed during the integrated
journey. Individual A01–A15 executions, omissions and measurements were not
itemized; their procedure markers refer to those missing details, not absence
of owner participation. Automated coverage below is separate; it cannot replace
missing controls/visuals/game-feel or integrated owner evidence.
For clauses requiring invisible values or controlled geometry/data, normal Play
offers no debug HUD/setup; record the owner's limit explicitly at reconciliation.

| Clauses/edges | Owner observation procedure | Existing executed technical coverage / limit |
|---|---|---|
| FR-001 directions/yaw/equal speed/opposed/release/planar; diagonal wall contact | A02–A04 | `movement.directions`, `movement.containment`, `survival.order`; exact distances automated |
| FR-002 yaw/pitch/follow/player visibility/mouse-only/no floor crossing | A03–A04, A09/A11 | `movement.mouse_follow`; visuals/capture require owner |
| FR-003 flat/visible/original placeholders/player+enemy containment | A01/A04/A05 | `movement.containment/pursuit`; provenance retained from T050 |
| FR-004 first/fixed cadence/type/inside+strictly outside contact/pursuit/reachability | A04/A05/A10 | `movement.selection/pursuit`, `survival.cadence_cap/deadlines` |
| FR-004 full-cap skips/next-opportunity refill/no backlog; configurable cap/interval | Report only if naturally exposed in A05/A14; no forced cap run/tuning edits | `survival.cadence_cap/default_custom_cap/subtick_long_step`; cap 50 is resource-verified, not owner-counted |
| FR-004 unexpected selection/factory/partial failure consumed/reported/counter/invalid attempt | A15 diagnostic review; don't inject faults | `survival.selection_fault/instantiation_fault/partial_fault`; failure counter invisible |
| FR-005 nearest single living/inclusive range/tie order/positive damage/cadence/ready/reassessment/feedback; no target | A06/A11 | `combat.targeting/weapon_readiness/feedback`; exact 4 m boundary, equidistance/spawn-ID ties and changed-resource range/cadence are deterministic fixtures, owner observation unavailable unless exposed |
| FR-006 independent maximum/current health/subtraction/zero clamp/no regeneration | A01/A06/A07/A12/A13 | `combat.health/invalid_damage`; per-enemy internal health/excess damage lack manual inspection |
| FR-007 synchronous removal/no subsequent move/target/damage/contact; killed-before-contact | A06/A12 | `combat.registry_death`, `survival.order/lethal`; same-step order technical only |
| FR-008 inclusive XZ 1.2 m threshold/immediate/independent 10 damage+1 s cadence/separation/re-entry/nonblocking/multiple contacts | A04/A07/A09/A11/A12 | `combat.contact`, `pause.contact_delays`; exact threshold/changed distance require fixtures; report unisolated cooldowns |
| FR-009 current/max/fresh/time format/65 s/next-step damage/visible inactive HUD | A01/A07–A13 | `survival.hud`, `pause.hud_restart`, `defeat.final_hud`; owner readability/65 s stay pending |
| FR-010 zero/one lethal transition/final commit/overlay+Restart/complete freeze/no Escape resume; coincident later events | A12 | `survival.lethal`, `defeat.lethal_commit/freeze_escape/final_hud`, `pause.game_over_escape`; coincident events cannot be arranged reliably by owner |
| FR-011 exactly one reset/full spawn delay/ready weapon/all state/three cycles/repeated or stale intents/invalid restart | A01/A13/A14 | `defeat.three_cycles/guarded_requests/stale_callbacks_removal/invalid_restart/failure_isolation`, `restart_evidence.*`; generation/IDs/counters, stale callbacks and invalid-data recovery technical only; no resource edit requested |
| FR-012 once-per-press/frozen simulation+view+feedback+deadlines/UI/preserved resume/no catch-up/input clearing/invalid state intents | A09–A11/A14 | All ten `pause.*` cases plus `pause_profile.*`; exact deadlines/old callbacks technical; owner timing/pointer/visuals pending |
| SC-002 three consecutive defeat→restart cycles in one application | A12–A14 | Technical cycles and prior story acceptance passed; current integrated cycle count/session continuity not supplied |
| SC-003 ten real seconds paused during combat, frozen state and preserved delays | A09–A11 | Technical freeze/delay fixtures and prior story acceptance passed; current timed contexts not supplied |
| SC-004 independent integrated controls/boundaries/HUD/kill/damage/pause/resume/defeat/restart | A01–A15 | Owner reports an integrated journey with successful observed behaviour; complete named action set/independence not explicitly confirmed; cannot be established headlessly |

No owner acceptance is claimed for the exact-boundary/tie/cap/configuration/
internal-lifecycle edges just because their fixtures pass. Report missed natural
opportunities as UNOBSERVED with a reason; any required unresolved owner clause
remains pending for reconciliation. SC-001/final feature closure is not awarded
here. SC-005 remains **future/unverified**. T053–T056 and new SC-006/007 evidence
are unrun and outside this batch.

### Owner evidence return structure — aggregate feedback received; details not supplied

Return actual session/environment details and one entry per A01–A15:
`ID — PASS / FAIL / UNOBSERVED; attempt/cycle; steps actually performed;
observed behaviour; health/time before→after where applicable; measured pause
duration/estimated event delay; deviations/uncertainty; evidence path if any`.
Use actual execution dates/times only; no timestamps or measurements are presumed.
For A12/A13 identify all three cycles and click/Enter/Space methods. For A15 state
whether you completed the integrated journey without developer intervention.

Required evidence is your written per-check observations, environment/revision,
the two ten-real-second pause contexts (contact and between events), observed
resume delays, three cycles and the Play launcher result/diagnostics. Supply
exact diagnostic text and steps for failures. Screenshots/video are optional;
useful captures are fresh HUD, before/after paused HUD/view, Game Over/final time,
and a short resume/restart clip. Static screenshots alone cannot demonstrate
frozen simulation or preserved subsecond delays. Save any chosen captures inside
the workspace's ignored `.cache/`; do not stage generated evidence.

| Evidence field | Actual owner value |
|---|---|
| Session date/time, source revision and working-tree state | PENDING |
| Machine, driver, window/settings/default-tuning confirmation | PENDING |
| A01–A08 observations, including witnessed kill/damage/65-second HUD | Observed gameplay accepted in aggregate; individual checks and 65-second observation not identified |
| A09 contact pause: duration, before/after, resume | Observed gameplay accepted in aggregate; contact context/duration/values not supplied |
| A10 between-spawn pause: duration, before/after, resume delay | Observed gameplay accepted in aggregate; context/duration/delay not supplied |
| A11 weapon/contact/feedback delays and repeated cycles | Observed gameplay accepted in aggregate; individual timing/feedback/cycle observations not supplied |
| A12/A13 cycles 1/2/3: defeat freeze, activation, fresh values/cadence | Observed gameplay accepted in aggregate; number/consecutiveness/application session and activation methods not supplied |
| A14 repeated/Active/Paused activation guards | Observed gameplay accepted in aggregate; specific guard trials not identified |
| A15 usability, independence, console result/evidence paths | Owner reports performing the integrated journey; intervention status/console result/paths not supplied |
| Missing observations, deviations, failures and follow-up reconciliation | No observable failure reported; unobserved subset not identified; gaps listed below |
| Integrated FR/SC-002–004 owner outcome and T052 closure | Observed behaviour successful; complete current integrated criteria not yet confirmed; T052 remains open |

### T052 owner-feedback reconciliation and closure assessment

**Evidence source:** the product owner's follow-up request in this conversation:

> I have performed the integrated owner acceptance journey to the best of my
> ability as a human player. All gameplay behaviour I was able to observe worked
> as expected, and I encountered no observable failures.

**Owner acceptance result: SUCCESSFUL for directly observed gameplay.** Owner
participation is now established; the report is positive acceptance of the
observed integrated experience. No observable failure was reported, and no
production/test correction is indicated. The report is aggregate and qualified
by what the owner could observe. It supplies no individual behaviour descriptions,
omission list, counts, durations, health/time readings, execution date/time,
screenshots, machine/session revision, tuning confirmation or console outcome.
None is inferred or fabricated. In particular, the expected results in A01–A15
are not converted into actual observations, and no individual check is declared
independently executed or failed. Missing detail is an evidence gap, not a
reported gameplay failure.

The preceding FR clause/edge mapping still provides the specific technical
cross-references. T051's already executed clean full suite (82 cases / 5,843
assertions, all scripts/import/startups and infrastructure passed) is retained
without rerunning it for this documentation update. Evidence is reconciled as:

| Evidence class | Accepted result and limits |
|---|---|
| Human-observable movement/camera/arena/HUD, spawning/pursuit/hit/kill/contact and pause/defeat/restart presentation (FR-001–012, A01–A15) | SUCCESSFUL owner acceptance for the subset directly observed. The owner did not identify that subset by clause; this does not assert every listed action, visual limit or timing check was performed. |
| Exact normalized distances/yaw/pitch bounds, inclusive range/contact thresholds, nearest/tied spawn-order selection and health isolation (FR-001/002/005/006/008) | PASSED existing deterministic `movement.*` and `combat.*` evidence. No ruler/debug-distance/enemy-health HUD exists; these are technically verified, not claimed as new human measurements. |
| Cap-full opportunity consumption/refill, changed-definition cadence/range/contact, spawn faults/counters and invalid configuration (FR-004/005/008/011) | PASSED existing definition, survival and defeat fixtures referenced above. No new manual full-cap run, tuning edit or injected failure is reported or required by this normal-play journey. |
| Same-tick kill/contact/lethal ordering, removed actors, generations/IDs, old callbacks and exactly-once restart guards (FR-007/010/011) | PASSED `survival.order/lethal`, `defeat.*` and `restart_evidence.*`. Internal invariants are not separately visible to a human player; absent observable failure is consistent with, but does not independently prove, them. |
| Exact remaining spawn/weapon/contact/feedback deadlines, queued input clearing and frozen inactive fields (FR-012) | PASSED `pause.*` and `pause_profile.*`. Owner-observed pause/resume behaviour is accepted where observed; exact deadline/clock values were not measured in the owner report. |
| SC-002 / SC-003 historical acceptance | Retain the Phase 4 T041 owner closure and Phase 5 T048 owner-reported acceptance above, alongside T051 regression evidence. Those recorded story results remain passed; they are not reclassified as newly executed Phase 6 cycles or timed pauses. |
| SC-004 current integrated journey | Owner execution and successful observed gameplay are recorded. The qualified report does not establish the complete named action set or absence of developer intervention, so full SC-004/T052 closure is not asserted yet. |

**T052 cannot yet legitimately be marked complete from this report alone.**
Its task text requires the quickstart's integrated journey without developer
intervention and observations reconciled for the applicable clauses/SC-002–004.
The specification expressly includes counted/timed criteria below, and the
quickstart includes them in the current journey. Unobservable internal invariants
are covered technically; they are not the reason for leaving T052 open. The
remaining human-observable coverage cannot be inferred from “able to observe”
without knowing whether the corresponding procedure was actually completed.

| Remaining confirmation | Exact requirement and current evidence gap |
|---|---|
| Complete integrated action set and independence | SC-004: all movement directions, view rotation, health/time and boundary identification, an automatic kill, taking damage, pause/resume and restart after defeat using documented controls without developer intervention. The report confirms a journey and successful observed behaviour but does not identify omissions or confirm this whole set/independence. |
| Three consecutive cycles in one application | SC-002 and FR-011; quickstart journey step 4 / A12–A14: three consecutive run→defeat→restart cycles, fresh conditions and no duplicate events; quickstart also asks click/Enter/Space across cycles. Neither current cycle count/session continuity nor activation paths are supplied. Earlier story closure is retained, not represented as a repeated integrated check. |
| Ten-real-second pauses in both contexts, with preserved resume | SC-003 and FR-012; quickstart step 3 / A09–A11: pause during contact and separately between events, try movement/mouse/held Escape, wait ten real seconds, compare frozen health/time/positions/view, resume without early/burst events. The current report does not confirm both contexts or duration. Exact internal deadlines remain technically verified; human sub-tick measurement is not demanded. |
| Observable HUD and defeat timing checks | FR-009 acceptance / A08: after 65 active seconds show 01:05 within one displayed second; FR-009/010 and quickstart step 4 / A12: ten seconds defeated while trying WASD/mouse/Escape with fixed final health/time/encounter. The report does not say whether these timed procedures were performed. `survival.hud` and `defeat.freeze_escape/final_hud` pass technically, without establishing a new real-time owner execution. |

A concise confirmation of which of these prescribed procedures were actually
completed, plus any skipped/unobservable items, is sufficient to assess these
gaps; individual screenshots, exact coordinates, numeric sub-tick delays or an
invented per-check transcript are not required. If a procedure was skipped,
only that missing observable check needs further participation. No replay of
already confirmed observed gameplay is requested by this reconciliation.
Actual manual environment/revision/tuning and launcher/log results remain
unprovided quickstart context; record them if available, without copying the
automated session's values into owner evidence. No invented timestamp is a
condition for closure. No specification/criterion has been weakened.

SC-001/final feature acceptance remains outstanding. SC-005 remains
**future/unverified**. T053–T056 and new SC-006/007 survival/profile evidence are
outside this reconciliation and remain unrun. No gameplay or test implementation
changed and no engine, interactive or profiling session was run in this update.

Only `docs/verification/core-gameplay.md` and
`specs/001-core-gameplay-prototype/tasks.md` have tracked changes. Both already
contained staged Batch 2 work when this reconciliation began; those staged
changes are preserved, with the reconciliation edits left unstaged.
Documentation consistency checks and `git diff --check` passed (exit 0);
generated `.cache/`/`.godot/` and the preserved cache remain ignored/untracked.
No staging, commit or push was performed by this reconciliation.
**T051 complete; T052 observed gameplay accepted, explicit integrated coverage
confirmations still outstanding; task remains unchecked.
Stop here; do not start Batch 3/T053–T056.**
