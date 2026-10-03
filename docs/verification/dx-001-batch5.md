# DX-001 Batch 5 — execution tiers and final reconciliation

2026-10-03; Batch 5 only, ready for final DX-001 review. Initial working tree
clean, HEAD `a67eb7df6aeabef988d9c31869e9f4f014845050`. Batch 4's three final
executed-source SHA-256 hashes matched before edits despite the intervening
commit. Constitution v1.0.0 and the active spec/plan/tasks remain authoritative.
The [Batch 3 clause map](dx-001-batch3.md) preserves acceptance obligations;
[Batch 4 measurements](dx-001-batch4.md) guide execution scope, not thresholds.

## Implemented workflow and rationale

The [tests workflow](../../tests/README.md#dx-001-batch-5-execution-workflow)
is the canonical exact command, group inventory, impact-selection and mandatory
Full policy; the [quickstart](../../specs/001-core-gameplay-prototype/quickstart.md#proportionate-validation--dx-001-batch-5)
provides fresh-session reproduction. Fast selects 84 cases; Targeted selects
explicit exact subsystem groups; Full retains the unchanged All/infrastructure
command and all 88 required cases. Foundation remains 13 harness cases and
cannot establish gameplay acceptance. The infrastructure wrapper is unchanged.

Batch 4's four duration protocols cost 95.072910 of 96.815639 native seconds.
Fast excludes exactly those four IDs, retaining all 82 earlier cases and both
inexpensive technical checks. No duration/cycle/health/range/deadline/geometry
threshold or production/tuning change. The native runner and manifest gain small
selection helpers and per-ID exclusion receipts; the existing launcher forwards
scope/groups and records unrequested infrastructure as EXCLUDED. Import/all
parses/startups and containment remain on every tier, avoiding a separate
framework or speculative incremental parser. Eight assertions in existing
`runner.prerequisites` cover the 84-case partition, complete group union, pause
integration selection and empty/unknown/duplicate groups. No new required case.

Full authored discovery/reconciliation precedes selection; selected execution
reconciles afterward. Pending prerequisites and incomplete execution fail;
genuine-error classification is unchanged. All omitted IDs are EXCLUDED/UNRUN,
with acceptance pending, never passed. BLOCKED setup and dependent UNRUN checks
remain in launcher evidence; expected failing infrastructure children retain
their FAILED/nonzero/timeout receipts and passing exact-expectation assertions.
Full is mandatory for final integrated technical/feature/release review, shared
lifecycle/scheduling/input, runner/manifest/selection/diagnostic/launcher changes,
uncertain cross-subsystem impact and wider regression recovery. Fast/Targeted
cannot close omitted acceptance. No automatic tier choice is claimed: the agent
must inspect actual change impact and record why each group was selected.

## Actual commands, measurements and outcomes

All commands used the established approval-mediated outside-isolation route,
ignored `.cache/godot-bin.txt`, Godot Standard official console
`C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`,
`4.7.2.stable.official.ed1daf0bf`. No Windows sandbox/certificate reinvestigation.
All engine outputs and path probes stay inside the workspace; all four process
environment variables restore. Observed OS `Microsoft Windows NT 10.0.19044.0`,
PowerShell 7.6.6. GPU/driver/host load not measured. Existing imported checkout;
no cold-cache experiment or gameplay FPS/performance claim. Passive timing
boundaries are unchanged from Batch 4, including process/log handling and
aggregate setup/restoration; shell startup is excluded.

Exact executed commands, from `C:\GameDev\project-horde`:

```powershell
# Executed twice: initial genuine test error, then corrected passing run.
C:\GameDev\project-horde\tools\validate.ps1 -Mode All -SuiteScope Fast
# Executed once: representative subsystem/integration selection.
C:\GameDev\project-horde\tools\validate.ps1 -Mode All -SuiteScope Targeted -CaseGroups movement,combat,survival
# Executed once after final executable edits: required selection-infrastructure gate.
C:\GameDev\project-horde\tools\validate.ps1 -Mode All -InfrastructureFixtures -SuiteTimeoutSeconds 240
```

| Run | Outcome / exit | Executed / excluded / assertions | Aggregate / native seconds |
|---|---|---|---|
| Initial Fast | FAILED / 1 | 83 completed of 84 selected / 4 / 3,890 | 15.0824425 / 1.789110 |
| Corrected Fast | PASSED / 0 | 84 / 4 / 3,917 | 17.0179292 / 1.792539 |
| Targeted example | PASSED / 0 | 26 / 62 / 808 | 15.6708611 / 0.532855 |
| Full | PASSED / 0 | 88 / 0 / 4,152 | 118.1939238 / 96.952284 |

Targeted selects all `movement.*` (6), `combat.*` (7), `survival.*` (13) cases;
it exercises real subsystem/integration seams as a reproducible tier example,
not acceptance for a gameplay change in this batch. Other recommended group
combinations are documented recipes, not separately executed claims. Fast and
Targeted omit infrastructure (explicit EXCLUDED); Full passes all 163 fixture
assertions. All three passing runs execute version/help/actual paths/import,
38 parses, normal and Profile headless startups and four restorations. Pending/
deferred/blocked/failed required checks are zero in each passing scope. Omitted
cases still have outstanding acceptance for that limited invocation. Full has
zero omissions. Assertions grow from 4,144 to 4,152 solely due to eight selector
contract checks. There is no statistically established speedup: tier costs
describe different explicitly selected work on one uncontrolled host.

Evidence directories under ignored `.cache/validation/`, in table order:

1. `20261003T193227993-98368e9d516b473bbdba0ec1f658aa92`
2. `20261003T193300686-2d4c56537d544ed8a3265f37f1f9634b`
3. `20261003T193448534-feee4a5066c44e5a9851e668408e3e7e`
4. `20261003T193507973-e6dea706ae574483b01e2d34ffc05ce9`

Each retains exact child argv, original streams/logs, exits/classification,
`results.json`, `timing.json`, `verified-paths.json`, per-case timing and complete
selection summary; Full also retains infrastructure child/expectation receipts.
All children' individual costs are in `results.json`; no unexecuted cost is
invented. Full parses sum to 7.0898095 seconds. Infrastructure has no standalone
group stopwatch; do not attribute the entire aggregate remainder to it.

Initial Fast's failing subcommand was `suite`: the new regression test's typed
loop variable tried assigning an untyped Array to `Array[String]` at line 28.
Godot emitted a genuine runtime error, `runner.prerequisites` missed `done()`,
execution reconciliation failed, and both dependent startups were UNRUN.
Four durations and infrastructure were excluded by scope, not passed.
Fix: copy each invalid test vector into a typed array using `assign()` before
calling the selector validator. No error suppression, classifier change or
production fix. Corrected Fast, Targeted and Full executed the final source.
Only one Full ran; no full baseline/benchmark or unnecessary repeat.

## Preserved Full duration and cycle evidence

| Required protocol | Actual passing receipt |
|---|---|
| HUD automatic driver | 65.0333333333309 active seconds, 3,902 ticks, 01:05; automatic interval 64.943427 wall seconds; next-update health assertion retained |
| Contact pause | 10.000829 real seconds / 97 samples; frozen time 0.125, ticks 1; attempted WASD/mouse/held Escape |
| Between-event pause | 10.029978 real seconds / 97 samples; same frozen time/ticks/input protocol |
| Defeated inactivity | 10.029359 real seconds / 97 samples; frozen time 0.375, ticks 2 |
| Three consecutive cycles | Same Main ID 626494801950; viewport click/Enter/Space, generations 2/3/4; each fresh reset and exactly one first spawn at 1.5 |

Resumed weapon deadline 0.725/first service 0.734375, feedback 0.245/expiry 0.25,
spawn 1.5/service 1.5 retained. Contact case services damage exactly 1.125;
separated case has zero contact damage. Each pause resumes two ordinary attacks
and one spawn with no burst. Six technical cases retain their original counts
51/32/32/120/16/46. Original integration sources are unchanged from HEAD.

Executed final SHA-256 (source copies and patch retained under ignored
`.cache/dx001-batch5-source/`):

| File | SHA-256 |
|---|---|
| `tools/validate.ps1` | `98BF6F366BB9ECC79FBDCFC0435C107A2016E35387202EFECFD8693B30B34108` |
| `tests/case_manifest.gd` | `D862B775FA49DDC70F9406B7FBB0E1BAF70CC163460650BF79D7FC9F2DEB3FE8` |
| `tests/run_tests.gd` | `237F7AAC4F5EED730D5A6FD5CFE3D6752EAB39344D511F217A2C30B5411F2C94` |
| `tests/unit/test_runner_contract.gd` | `EE76F33E16D6AB1D0DAEEB89F873625C42F74BB6358BB4755B96552D99F8DDB4` |

## Final reconciliation and limitations

Quickstart, tests README, plan/tasks operational notes, gameplay ledger and
DX-001 handoff now describe the same implemented workflow. Acceptance spec and
task checkboxes are unchanged. No gameplay/tuning/dependency/constitution change,
installation/global configuration/external output, Phase 6 profiling, commit or push.
No executable source changed after final Full; later edits are documentation only.

Static verification: PowerShell `Parser.ParseFile` zero syntax errors;
`./.cache/dx001-batch5-audit.ps1` checks all three passing receipts, 88-ID
executed/excluded partition per run, counts/outcomes/parses/restorations,
infrastructure, source boundaries and local document links; `git diff --check`.
Actual final outcomes are appended in the ledger/handoff after execution.

Executed `./.cache/dx001-batch5-audit.ps1` PASSED exit 0: all three passing
receipts, case partitions/counts, parses/startups/restoration and infrastructure,
automatic HUD/real waits/same-application cycles, final source hashes, unchanged
manifest entries/maps and task checkbox requirements, production/acceptance
source boundaries, PowerShell syntax, whitespace and 69 local document links.
`git diff --check` PASSED exit 0 (LF-to-CRLF advisories only). A ledger patch
with unmatched context was rejected before writes, then corrected; it changed
no engine result. No other unexpected engine failure occurred after the
documented initial Fast test error.

T051 complete. T052 remains open pending independent owner SC-004 named actions
without developer intervention and physical controls, rendered readability/
presentation, responsiveness/feel. Manual protocol remains the quickstart journey:
move all directions, rotate view/traverse perimeter/identify boundaries and HUD,
witness an automatic kill/take contact damage, pause/resume, recognize defeat
and restart independently; record actual actions/omissions/intervention and feel.
Human playtest and rendered profile smoke UNRUN. No new SC-006/007 qualifying
owner survival/profile/source evidence. SC-005 future/unverified; T053–T056
remain unchecked and outside DX-001. Successful Full is technical evidence,
not full prototype acceptance. Stop for final DX-001 review.
