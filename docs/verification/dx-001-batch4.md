# DX-001 Batch 4 — assertion cleanup and execution measurement

Batch 4 only, 2026-10-03; stop for review. Initial working tree clean, HEAD
`c9978527621b1850b4a54ff4610f3040a99a0d9a`. All five preserved Batch 3 source
hashes match this checkout. The [Batch 3 clause map](dx-001-batch3.md) remains
the technical obligation map; no acceptance requirement is replaced by counts.
No production/tuning/spec/plan/task/constitution change, new dependency, test
case, execution tier, T053–T056 work, commit or push.

## Measurement method and conditions

Both runs execute exactly:

```powershell
C:\GameDev\project-horde\tools\validate.ps1 -Mode All -InfrastructureFixtures -SuiteTimeoutSeconds 240
```

Established explicitly requested outside-isolation approval route, unchanged
local `.cache/godot-bin.txt` engine selection, version/help/actual-path gates,
workspace-contained output and all four environment restorations. Engine:
`C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`, Standard official
`4.7.2.stable.official.ed1daf0bf`. Observed OS `Microsoft Windows NT
10.0.19044.0`, PowerShell 7.6.6, processor identifier `Intel64 Family 6 Model
151 Stepping 2, GenuineIntel`. GPU/driver/load were not measured; these are
headless QA costs, not gameplay FPS or SC-005/007 profiling. Existing imported
checkout, no clean-cache rebuild or controlled cold/warm experiment.

Passive measurement was added **before** baseline, with assertions untouched:
`Time.get_ticks_usec()` measures each native case from before begin receipt
through setup/body/cleanup/diagnostics, and the suite from entry through
discovery/execution/reconciliation. `Diagnostics.Stopwatch` measures each child
from before start through stream/log processing and diagnostic classification.
Launcher aggregate starts after parameter binding, includes setup/infrastructure/
environment restoration and `results.json` writing, and ends before writing its
own `timing.json`/final evidence message/exit. Shell startup is excluded.
Timers do not decide acceptance or replace existing watchdogs. Both runs use
identical timing code; its small overhead is included in both measurements.
Child timing is not pure engine CPU time. Unexecuted records have no invented cost.

Baseline evidence: `.cache/validation/20261003T190404339-22cc7fee048a475e93bee07c90a01124/`.
Final evidence: `.cache/validation/20261003T190633709-610b11ffc3a544a2a03c166b8b949348/`.
Each directory retains exact child commands, original streams/engine logs,
diagnostics, exits, `results.json`, `verified-paths.json` and `timing.json`.
Executed source snapshots and patches are in ignored `.cache/dx001-batch4-source/`.
Only these two full validations ran; exploration used static inspection.

## Actual before/after costs and results

Both full commands PASSED, exit 0: version/help/actual paths/import, 38 script
parses, all 88 required cases, zero pending/deferred/excluded, normal/Profile
headless startup, 163 infrastructure assertions and four restorations. Native
assertions: 6,142 before, 4,144 after; only one case changes its count. Expected
negative infrastructure children remain FAILED/nonzero (including timeout and
reconciliation faults); their enclosing exact-expectation checks passed. No
unexpected failure, skipped or blocked required check occurred.

| Measured scope (seconds) | Before | After |
|---|---:|---:|
| Aggregate full validation | 118.775031 | 118.090575 |
| Native suite with discovery/reconciliation | 96.873584 | 96.815639 |
| Suite child with process/log/diagnostic handling | 97.170448 | 97.136788 |
| Version child | 0.222241 | 0.084478 |
| Help child | 0.050591 | 0.054540 |
| Actual-path preflight child | 2.381547 | 2.160526 |
| Import child | 2.067671 | 2.047140 |
| 38 parse children summed | 6.870370 | 7.031167 |
| Normal startup child | 1.104846 | 1.107556 |
| Profile startup child | 1.145083 | 1.144925 |
| `profile.bounded_late_failure` (2,023 → 25 assertions) | 0.770425 | 0.750221 |
| `technical.hud_clock` (51 assertions) | 64.926652 | 64.940208 |
| `technical.pause_contact` (32) | 10.021181 | 10.034547 |
| `technical.pause_between` (32) | 10.031292 | 10.039624 |
| `technical.three_cycles` (120) | 10.057924 | 10.058531 |
| `technical.configurable_eligibility` (16) | 0.001245 | 0.001247 |
| `technical.mapped_input` (46) | 0.008083 | 0.007290 |

All individual parse/infrastructure child costs are in `results.json`; every
native case cost is in suite stdout. Infrastructure's aggregate assertion record
has no independent stopwatch: do not invent its group time or attribute the
aggregate remainder exclusively to infrastructure. Ignored
`.cache/dx001-batch4-source/measurement-summary.json` collates complete per-child/
per-case before/after receipts for review.

Observed decreases: aggregate 0.684456 seconds, native suite 0.057945 seconds,
changed case 0.020204 seconds. One sequential pair, uncontrolled host load and
cache state cannot establish causation or a statistically demonstrated speedup.
No assertion microbenchmark ran. Before cleanup, six technical cases consumed
95.046377 seconds (about 98.1% of native suite time); unchanged mandatory clock/
waits dominate cost. The cleanup removes demonstrated API redundancy, not a
meaningful demonstrated wall-time bottleneck. Further assertion pruning for
speed is unsupported by these measurements.

| Retained actual evidence | Before | After |
|---|---|---|
| Automatic HUD clock | 65.0333333333309 active seconds/3,902 ticks at receipt, 01:05; automatic interval 64.922792 wall seconds | Same active seconds/ticks/HUD; 64.936354 wall seconds |
| Contact pause real wait | 10.010893 seconds, 97 samples | 10.025057 seconds, 97 samples |
| Between-event pause real wait | 10.020857 seconds, 97 samples | 10.029932 seconds, 97 samples |
| Defeated real wait | 10.028942 seconds, 97 samples | 10.028537 seconds, 97 samples |
| Same-Main click/Enter/Space cycles | ID 626394138654; generations 2/3/4; one first spawn at 1.5 each | ID 626427693086; generations 2/3/4; one first spawn at 1.5 each |

Both pause contexts retain weapon deadline 0.725/first service 0.734375,
feedback 0.245/expiry 0.25, spawn 1.5/service 1.5; contact pause exact 1.125
damage service, between-event context zero contact damage. Next-step HUD health,
frozen snapshots/signals/input, fresh reset values and configurable eligibility/
mapped-input assertions pass with unchanged counts.

Final executed source SHA-256:

| File | SHA-256 |
|---|---|
| `tests/run_tests.gd` | `BB0BB6FBB2B3C476B8116B554CC586CE1B46ED9402EA25147206BFBF7DCE92AB` |
| `tools/validate.ps1` | `01773F296665E3220CB5BD2FBC8CD2C5BED4449302EDA651DA504DCD4DEE1E49` |
| `tests/unit/test_profile_capture.gd` | `F71CCC732F573D998F6437C429F646039107C435CF6595952C150C74D81249E7` |

Baseline timing code is identical; baseline profile test equals HEAD. No source
changed after final validation. Later edits update evidence/documentation only.

## Removal and equivalent retained coverage

Only `profile.bounded_late_failure` changes, from 2,023 to 25 assertions:

| Removed repetition | Retained coverage and failure diagnostics |
|---|---|
| 999 redundant `F.invoke` method checks for `record_frame` on the same closed capture | One identical `object != null and object.has_method("record_frame")` assertion with exact `required real method: record_frame` message and native case ID; all 1,000 actual generation-3 calls with original timestamps remain |
| 999 redundant `F.invoke` method checks for `record_step` in the same loop | One identical method predicate and exact `required real method: record_step` message; all 1,000 original time/tick/wall/count/alive argument sets remain, plus the pre-loop endpoint invocation's existing check |

Static inspection of `F.invoke` establishes the old successful loop assertions
test API presence only, not callback outputs. The same object/script survives
the loop; neither production method changes its script or frees the object.
The closed-window methods return without accumulating samples. Repeated API
checks therefore add no distinct temporal/data obligation. Both retained API
assertions execute before the loop; a missing API records the original specific
failure and returns explicitly completed **failed** coverage, never a passing
empty loop. Direct calls still expose genuine runtime/signature errors to the
unchanged runner logger/nonzero policy; no error is caught or suppressed.

The existing post-loop checks still require both buffers empty after all calls,
then actual late spawn failure increments invalidity while preserving the
survival observation. The million-callback bounded-tail/disk-length/exact-order/
cross-chunk/statistics/stall/sidecar checks remain byte-for-byte unchanged.
No loop count, raw sample count, deadline, geometry, health or threshold changes.
This is removal of repeated successful contract bookkeeping; repeated copies
of a missing-method diagnostic are consolidated to one per method.

Other apparent repetition was retained:

| Inspected area | Why it remains |
|---|---|
| Definition invalid-value matrix and payload assertions | Different fields/values/constraints and each emitted diagnostic need coverage |
| Helper assertions outside this stable loop | Resource/method/signal checks describe independently constructed objects or changing lifecycle state; no global cache introduced |
| Synthetic inactive steps and real-duration Batch 3 waits | Controlled callback delivery and actual elapsed inactive processing cover different obligations |
| Component movement versus mapped-input integration | Math/geometry and physical-key mapping/viewport dispatch are different seams |
| Synthetic HUD boundaries versus automatic 65-second case | Boundary formatting and actual completed simulation driver are distinct |
| Restart fresh-state checks across cycles | Every successive generation/reset/input path must satisfy the original obligations |
| Stream/reference statistics and raw per-segment bounds | Independent algorithm agreement and each persisted datum detect distinct corruption |
| Manifest, prerequisites, reconciliation and negative infrastructure cases | Missing/unregistered/unexecuted cases and genuine errors must still fail |

No further meaningful redundancy was demonstrated. No additional tests were
introduced; retained coverage and exact failure predicates/messages were reviewed
statically, then exercised by required final full validation. No injected new
missing-method failure experiment is claimed.

## Remaining acceptance

T051 complete; T052 remains open for actual independent complete owner SC-004
movement/view/boundaries/HUD/kill/contact/pause/resume/defeat/restart participation
without developer intervention, physical usability, rendered presentation and
responsiveness/feel. Manual steps remain the existing quickstart journey; no
gameplay change adds a new playtest protocol. Human checks and rendered profile
smoke UNRUN. SC-006/007 and T053–T056 unstarted; SC-005 future/unverified.
Batch 5 requires separate review/authorization in the updated DX-001 handoff.

Final static verification actually executed:

| Command/check | Actual result |
|---|---|
| PowerShell `Parser.ParseFile` for `tools/validate.ps1` | PASSED, zero syntax errors |
| `./.cache/dx001-batch4-audit.ps1` | PASSED exit 0: both full receipts, all 88 case IDs/counts, only documented 1,998 consolidation, six technical cases, real waits/cycles, source hashes/boundaries, whitespace and 29 local link paths |
| `git diff --exit-code HEAD -- scripts scenes resources project.godot .specify/memory/constitution.md specs/001-core-gameplay-prototype/spec.md specs/001-core-gameplay-prototype/plan.md specs/001-core-gameplay-prototype/tasks.md tests/case_manifest.gd tests/integration tests/support tests/unit/test_runner_contract.gd` | PASSED exit 0, executed inside audit; production/requirements/task states and Batch 3 sources unchanged |
| `git diff --check` | PASSED exit 0; LF→CRLF advisories only |

An early read-only `rg` search guessed nonexistent `tests/test_runner.gd` and
reported a path error; corrected to discovered `tests/run_tests.gd`. Several
documentation patch attempts used unmatched context and were rejected before
writes; reapplied to actual file endings. A confirming `rg` returned exit 1
because the rejected text was absent. These authoring/search failures changed
no engine outcome; no failed check was hidden or credited as a passed validation.
