# DX-001 — Autonomous QA implementation and session handoff

**Approved sequence:** Batch 1 acceptance-method amendment → Batch 2 environment
reliability → Batch 3 autonomous technical acceptance → Batch 4 assertion cleanup
and execution measurement → Batch 5 execution tiers and final reconciliation.
**Authority:** product-owner DX-001 Bootstrap + Batch 1 request, 2026-10-03;
[constitution v1.0.0](../../.specify/memory/constitution.md) remains unchanged.
Current authority: product-owner **DX-001 Batch 4: Assertion Cleanup and Execution
Measurement** request, 2026-10-03. Batch 4 only is authorized in this session;
stop for review. Current results and exact Batch 5 instructions are appended below;
earlier session handoffs remain historical.

## Repository baseline and evidence

Active feature: [spec](../../specs/001-core-gameplay-prototype/spec.md),
[plan](../../specs/001-core-gameplay-prototype/plan.md),
[tasks](../../specs/001-core-gameplay-prototype/tasks.md),
[quickstart](../../specs/001-core-gameplay-prototype/quickstart.md).
Validation references: [tests README](../../tests/README.md),
[Phase 1 validation](../phase1-validation.md),
[verification ledger](../verification/core-gameplay.md).

The ledger's Phase 6 Batch 2 records T051 passed: 82 cases / 5,843 assertions,
37 script parses, import, normal/Profile startup and 146 infrastructure assertions.
These are historical executed results, not checks rerun by DX-001. It records
GODOT_BIN absent in sandbox-visible Process/User/Machine scopes and an explicit
binary retry failing the path probe with `Failed to read the root certificate store.`
despite child exit 0. An approved retry outside isolation passed with containment
preserved. Phase 1 documents earlier discovery/certificate friction as well.
No runtime cost or redundant-assertion finding is inferred from assertion counts.

The latest owner reconciliation accepts directly observed integrated gameplay,
with no observable failure reported, but does not establish complete SC-004 action
coverage or absence of developer intervention. T051 is complete; T052 remains
open pending sufficient evidence. Earlier T033/T041/T048 owner results remain
recorded. SC-005 is future/unverified. The future prototype-profile report is
absent; T053–T056 remain unstarted by DX-001.

## Batch 1 — Acceptance-method amendment

**Scope:** amend the six active acceptance/validation documents named above and
this handoff. Distinguish technical proof from human experience; reconcile the
current ledger without rewriting historical observations.
**Dependencies:** read AGENTS.md, constitution and feature/validation evidence;
owner approval supplied by this request.
**Acceptance:** reproducible automated evidence may establish objective FR/edge
and SC-002/003 correctness. Evidence must map actual exercised clauses, conditions,
durations/cycles, revision, commands, outputs and outcomes; gaps stay open. Human
acceptance covers independent controls, observable presentation, responsiveness
and subjective feel. SC-004 still requires the actual independent owner journey.
Preserve every gameplay requirement, threshold, duration and cycle count,
including ten-real-second inactive checks, 65-second HUD check and three consecutive
same-application cycles. Preserve SC-006/007 owner survival/profile requirements.
T051 checked, T052 unchecked, T053–T056 unchecked; SC-005 future/unverified.
Documentation consistency and `git diff --check` must pass.
**Constraints:** documentation only; no production/test/tool implementation,
new engine session, tuning changes, commit or push. No retroactive evidence credit.

## Batch 2 — Environment reliability (implemented; ready for review)

**Exact scope:** improve existing engine discovery, setup diagnostics and the
contained validation entry points for fresh sessions. Inspect explicit `-GodotBin`
and Process → User → Machine discovery, absent/empty/inaccessible scope handling,
and certificate-store failure reporting/retry instructions. Provide a reproducible
way to select the existing approved executable without machine-specific tracked
state. Retain applicable approval for execution outside isolation; reliability
does not grant approval or suppress certificate errors.
**Dependencies:** Batch 1 review and separate authorization; existing installed
Godot 4.7.2 Standard console executable and safe execution permissions.
**Relevant files:** `tools/validate.ps1`, `tools/test-validation.ps1`,
`tools/validation_diagnostics.ps1`, quickstart, tests README, Phase 1 validation
and the verification ledger; this handoff tracks actual changes/results.
**Acceptance criteria:**

- Fresh-session discovery and explicit override have reproducible instructions
  and evidence for valid selection, absent/empty/inaccessible scopes and invalid
  overrides. Invalid explicit selection blocks without fallback.
- Selected engine still verifies absolute existing console executable, approved
  version/Standard edition and supported flags. No installation/global config change.
- Certificate failure, including child exit zero, remains FAILED with original
  diagnostics, failed subcommand and dependent UNRUN checks. The documented
  authorized retry retains errors and proves actual-path containment before the
  real project runs; an unavailable retry is reported as blocked.
- APPDATA/LOCALAPPDATA/TEMP/TMP restoration preserves prior present/absent values;
  actual user/data/config/cache/editor paths and all generated output remain
  inside the workspace. No external writes or marker changes without approval.
- Relevant launcher fixtures, import/parse/suite/startup checks actually execute
  successfully where available; commands/results and remaining blockers are
  recorded honestly. No gameplay/threshold changes or T053–T056 work.

## Batch 3 — Autonomous technical acceptance (implemented; ready for review)

**Scope:** map objective acceptance clauses to existing evidence, then add only
missing reproducible technical checks in a separately authorized implementation.
Include actual-duration evidence where synthetic time is insufficient, three
consecutive same-application defeat/restart cycles, HUD formatting/updates,
inactive input/state and resume deadlines. Human observation remains necessary
for presentation/physical usability/feel and independent SC-004 participation.
**Dependencies:** reviewed Batch 1 method and reliable Batch 2 execution.
**Files:** test manifest/runner, relevant unit/integration/support scripts,
validation tools as needed, quickstart, tests README and ledger.
**Acceptance:** every targeted clause has an explicit executed-evidence mapping
or an outstanding gap; exact original durations/counts remain. Controlled fixtures
cannot claim real-time/rendered/owner survival evidence. T052 closes only with
sufficient combined technical and independent human evidence, never by test count.
**Constraints:** no weakened criteria, production cheats or substituted SC-004
participation; T053–T056 require their own authorization.

## Batch 4 — Assertion cleanup and execution measurement (implemented; ready for review)

**Scope:** measure current execution cost and inspect repeated assertions before
removing demonstrated redundancy; retain distinct failure/edge/data contracts.
**Dependencies:** Batch 3 coverage map and passing baseline.
**Files:** relevant tests/support/runner/manifest, validation tools for measurement
if needed, tests README, ledger and this handoff.
**Acceptance:** record actual before/after commands, environment, suite scope,
case/assertion counts and elapsed measurements; justify each removed assertion
against retained coverage and diagnostics. Counts alone do not demonstrate speed
or redundancy. No timing result is invented and no gameplay threshold is lowered.
**Constraints:** no dependencies, speculative optimization or fixed speed target
without evidence/approval; preserve required cases unless an approved reconciliation
explicitly accounts for equivalent coverage.

## Batch 5 — Execution tiers and final reconciliation (planned)

**Scope:** define proportionate fast/targeted/full validation instructions using
measured costs and preserved coverage; reconcile all DX-001 artifacts and gaps.
Existing Foundation scope remains a limited 13-case infrastructure selection,
not full gameplay acceptance.
**Dependencies:** Batches 2–4 executed evidence and review.
**Files:** validation tools, test runner/manifest as necessary, tests README,
quickstart, plan/tasks, ledger and this handoff.
**Acceptance:** each tier documents selection, prerequisites, omissions and when
full validation is mandatory; full required discovery/execution reconciliation
and genuine-error policy remain enforced. Execute and report appropriate tier
checks; final reconciliation distinguishes technical proof, human acceptance,
unverified survival/profile gates and SC-005. DX-001 completion cannot imply
feature completion with outstanding criteria.
**Constraints:** no silent skipping, synthetic benchmark claims, automatic commits
or expansion into T053–T056 without authorization.

## Historical Batch 1 session outcome and handoff

**Batch 1 complete, ready for review.** The active spec, plan, tasks, quickstart,
tests README and ledger adopt the method amendment. SC-002 now allows automated
cycle verification; its original cycle/session/reset obligations remain. Human
SC-004 participation is preserved verbatim. T052 stays open.

Actual documentation-only verification on 2026-10-03:

| Command/check | Actual result |
|---|---|
| `./.cache/dx001-doc-check.ps1` (workspace-local, ignored audit harness) | PASSED, exit 0: 35 checks, 44 local links/anchors resolve. Compared against Git HEAD: all FR text/acceptance values, edge cases, original stories, scope and entities unchanged; SC-001/003–007 unchanged; SC-002 original three-cycle/session/reset obligations retained. All task states and T053–T056 text unchanged. |
| `git diff --exit-code HEAD -- scripts scenes resources tools project.godot tests ':!tests/README.md' .specify/memory/constitution.md` | PASSED, exit 0: no production, test implementation, tool or constitution changes. |
| `git diff --check` | PASSED, exit 0. The harness separately checks the new untracked handoff for trailing whitespace. Git emitted LF→CRLF conversion advisories, not whitespace errors. |
| Engine import/parse/startup, gameplay suite, interactive owner playtest, profiling | UNRUN for this documentation-only amendment; no code changed. Historical T051 results are retained, not claimed as new execution. |

Two authoring/read-command failures were corrected before final verification:
a read-only `rg` command used unsupported PowerShell brace syntax (parser exit 1;
rerun with explicit paths), and a ledger patch used a nonexistent context line
(tool rejected before writes; reapplied against actual headings). Neither changed
source or produced a hidden acceptance failure. Initial Git status was clean;
all tracked changes are the six authorized Markdown documents, plus this new
handoff. No staging, commit or push occurred.

**Remaining blockers:** no Batch 1 documentation blocker. T052 still needs
sufficient clause-mapped technical evidence and complete independent SC-004
coverage/independence confirmation; the owner's qualified positive feedback
does not supply those missing facts. Real-duration/input protocol coverage needs
an evidence audit, without relabeling synthetic fixtures. Fresh-session engine
discovery/certificate reliability is still unresolved implementation work for
Batch 2; prior approved retries are evidence, not permission for this session.
SC-006/007 final survival/profile/source qualification and the absent profile
report remain future work; SC-005 remains future/unverified.

**Next authorized work, after separate review/authorization:** Batch 2 only,
exact scope and acceptance criteria in the Batch 2 section above. Batches 2–5
are unstarted. Do not start T053–T056 or mark T052 complete from this amendment.
Stop for review.

## Batch 2 session outcome and next handoff — 2026-10-03

**Batch 2 implemented and verified; stop for review.** Initial Git status was clean.
Source baseline: `32b7d27684ce7f1fd1f0bf0161f0bd722934d280` plus this session's
uncommitted Batch 2 tooling/documentation changes. Constitution/spec/plan/tasks,
gameplay, scenes/resources, manifest and suite implementations are unchanged.
No dependency, installation, global configuration, external marker, staging,
commit or push. Batches 3–5 and T053–T056 remain unstarted; T052 remains open.

### Actual changes

- `tools/validate.ps1`: explicit override → ignored workspace
  `.cache/godot-bin.txt` → Process/User/Machine discovery. Local file is optional,
  containment/reparse-checked before read, and never written by the launcher.
  Empty/unreadable/invalid selections block without fallback. Explicit override
  bypasses local/scoped discovery. All existing absolute/existence/PE/version/
  Standard/help and actual-path gates remain. No engine search/install or host edits.
- `tools/validation_diagnostics.ps1`: classify the root certificate-store failure
  from stdout/stderr or engine log, retaining original text even without a severity
  prefix. Exit zero cannot pass. Launcher prints failed-subcommand/retry guidance;
  missing dependent checks receive UNRUN records. No automatic retry/elevation.
- `tools/test-validation.ps1`: expanded selection and diagnostic fixtures, including
  each inaccessible scope, all absent/empty scopes, invalid first selection, local
  file precedence and a real zero-exit child printing certificate failure text.
  Existing security, timeout, error, reconciliation and restoration checks remain.
- Quickstart, tests README and Phase 1 validation explain the local setup and
  supported approval-mediated outside-isolation retry. This ledger/handoff records
  actual evidence. Created ignored `.cache/godot-bin.txt` with the approved existing
  console path after explicit validation passed; fresh-session selection is available
  in this checkout without tracked machine state. Cache deletion removes the pin.

### Executed verification

All engine commands used existing
`C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`, verified as
`4.7.2.stable.official.ed1daf0bf`, console PE and Standard (`mono=false`).
Evidence directories below are relative to `.cache/validation/` and ignored;
each contains exact child commands, exits, original streams/logs and results.

| Actual command/check | Actual result and evidence |
|---|---|
| `./tools/validate.ps1 -GodotBin 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' -Mode All -InfrastructureFixtures` inside isolation | FAILED, exit 1: `paths` child exit 0 with `ERROR: Failed to read the root certificate store.` Version/help passed; import/remaining parses/suite/startups/infrastructure UNRUN; all four environment restorations passed. `20261003T172701054-6c0b886aeb3946ffa292a89dd3e2bad9`. |
| Same exact launcher command, approved execution outside isolation | PASSED, exit 0: version/help/actual paths, import, 37 script parses, full 82 cases / 5,843 assertions, normal/Profile startup, 159 infrastructure assertions and four environment restorations. `20261003T172730269-652f3b4221f541949abf87eb455adba4`. This preceded the final four extra scope fixtures. |
| `./tools/test-validation.ps1`, separately approved outside isolation, no override | PASSED, exit 0: actual local-file selection, version/help/paths/import, 37 parses, Foundation 13 cases / 575 assertions (69 excluded by explicit scope), normal/Profile startup and final 163 infrastructure assertions. Wrapper confirms initially absent TEMP/GODOT_BIN and present APPDATA/LOCALAPPDATA/TMP restored. `20261003T173503745-839b792a71a34729822c81ede74af38d`. |
| `./.cache/dx001-environment-check.ps1` inside isolation | PASSED, exit 0, 12 checks: actual valid/empty/relative local-file selection, explicit bypass, original selection restored; all four variables deliberately absent before real launcher and still absent afterward; expected certificate failure/exit-zero, six dependent UNRUN records and no `verified-paths.json`. Expected FAILED child session `20261003T173749099-18205d02287549aea559735e24c4eba2`; retained harness output `.cache/dx001-environment-check.txt`. |
| PowerShell `Parser.ParseFile` for all three tool scripts | PASSED: zero syntax errors. |
| `git check-ignore .cache/godot-bin.txt` | PASSED, exit 0: machine selection is ignored. |
| `./.cache/dx001-batch2-doc-check.ps1` | PASSED, exit 0: 28 local links/anchors, whitespace in five changed documents, syntax in three tool scripts. |
| `git diff --check` | PASSED, exit 0; LF→CRLF advisories only, no whitespace errors. |
| `git diff --exit-code HEAD -- scripts scenes resources project.godot tests ':!tests/README.md' .specify/memory/constitution.md specs/001-core-gameplay-prototype/spec.md specs/001-core-gameplay-prototype/plan.md specs/001-core-gameplay-prototype/tasks.md` | PASSED, exit 0: gameplay, test implementation, constitution, spec/plan/tasks and task states unchanged. Final status contains only the eight scoped tooling/documentation files. |
| Interactive owner controls/visuals/game feel, rendered profile smoke, survival/performance acceptance | UNRUN: outside Batch 2. Existing quickstart owner steps remain the manual protocol; short headless Profile startup grants no profile/survival acceptance. |

Intentional infrastructure child failures remain FAILED in separate child evidence;
only their asserted expected failure/diagnostic/cleanup gives a passing fixture.
The zero-exit certificate fixture is synthetic diagnostic-policy evidence; the
isolated `paths` error above is the actual certificate-store access failure.
Authorized retries retain actual-path containment and leave earlier failures intact.

Two ignored harness setup errors were corrected: extracted resolver functions
initially lacked the launcher's `$GodotBin` default variable (exit 1 before engine);
the first all-absent harness used .NET null assignment, which left empty variables
present in this PowerShell environment (assertion failed, exit 1 after expected
certificate failure; session `20261003T173734625-0a168efb329a49ba9a5f170888af8496`).
Binding the default and using checked `Remove-Item Env:` to establish actual absence
corrected the harness; final 12 checks passed. Both attempts restored original
selection/environment in `finally`. An intermediate read-only fixture edit had a
duplicated selection parameter; inspection corrected it before fixture execution.
A read-only evidence JSON summary exceeded depth 2 and was rerun using just the
native suite summary lines. No failure was suppressed or credited as an engine pass.

### Remaining blockers and exact Batch 3 instructions

Certificate-store access remains unavailable **inside isolation**; this batch
provides reliable diagnosis and a successfully executed authorized route, not a
host/certificate repair. Fresh sessions must still obtain applicable approval for
outside-isolation execution; today's approvals are not future-session permission.
If unavailable, report retry BLOCKED and project checks UNRUN. No Batch 2 blocker
remains on the approved route in this environment. Engine availability and ignored
selection are local prerequisites; never invent success if missing.

After separate review and authorization, execute **DX-001 Batch 3 only**:

1. Read AGENTS.md, constitution, this handoff, active spec/plan/tasks/quickstart,
   tests README and verification ledger. Preserve the Batch 1 method and Batch 2 gates.
2. Run contained All with infrastructure using local selection (or explicit approved
   path); use the documented approval route if certificate access fails. Record
   revision, exact commands, outputs, environment/tuning and actual outcomes.
3. Audit retained executed evidence clause by clause for objective FR/edges and
   SC-002/003. Identify unexercised clauses and synthetic-time limits before adding
   only missing reproducible checks. Do not infer coverage from passing counts.
4. Preserve and prove the original three consecutive same-application defeat/restart
   cycles and reset/input obligations, ten-real-second inactive contact/between-event
   and defeated checks, 65-active-second HUD/01:05 within one displayed second,
   next-update health, frozen input/state and preserved resume deadlines. Synthetic
   ticks cannot establish elapsed-duration/rendered/owner evidence.
5. Update evidence mapping and this handoff with executed results and explicit gaps.
   Human independent SC-004 action coverage/controls/presentation/feel remains
   necessary; no automation can substitute owner participation. Keep T052 open
   unless sufficient combined evidence supports closure. Do not start Batch 4/5,
   T053–T056, lower criteria, add production cheats, commit or push. Stop for review.

SC-006/007 survival/profile/source qualification remain future work, the prototype
profile report is absent, and SC-005 remains future/unverified.

## Batch 2 final environment comparison — 2026-10-03

**Authority:** owner's Final Environment Verification request. No additional
implementation changes. Only this tracked handoff was updated; earlier uncommitted
Batch 2 changes are preserved. No full suite, gameplay, Batch 3, commit or push.

### Discovery and probe method

All three runs discovered ignored `.cache/godot-bin.txt` using the unchanged
production `Resolve-GodotExecutable`, with no `-GodotBin` and no explicit
`GODOT_BIN` assignment. Process `GODOT_BIN` was absent. Production selection
returned `C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`; the PE/absolute/
existence/reparse/self-contained-marker gate passed. The local selection takes
precedence over persistent scopes, so User/Machine values were unnecessary and
were not inspected. Engine output identified `4.7.2.stable.official.ed1daf0bf`;
the probe reported Standard (`mono=false`) and editor capability.

The ignored verification-only harness `.cache/dx001-certificate-comparison.ps1`
loads existing launcher functions through their parsed definitions and invokes
the unchanged `Invoke-GodotCheck` on the existing preflight project. It does not
run the launcher's real-project body, modify tool implementation, or create a
new Godot probe. This is the smallest existing certificate/editor-path preflight,
not a strictly write-free process: `--import` updates only ignored preflight/editor
cache and evidence. No source, game project or global host state is modified.

Inside → approved outside → inside comparison used the identical engine command:

```text
C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path C:\GameDev\project-horde\.cache\validation\20261003T173503745-839b792a71a34729822c81ede74af38d\preflight --import --log-file C:\GameDev\project-horde\.cache\dx001-certificate-comparison\paths.engine.log
```

Working directory was the same preflight directory. APPDATA/LOCALAPPDATA/TEMP/TMP
were redirected to the same four subdirectories under ignored
`.cache/dx001-certificate-comparison/` in every run, then restored to their prior
present/absent values. All restorations passed. SHA-256 comparisons confirmed the
same executable and three probe source files; exact argv and observed paths also
matched. The first inside evidence was archived before the explicit repeat.

### Actual results

Evidence root: `.cache/dx001-certificate-comparison/`. Each evidence prefix below
has `.json`, `.stdout.txt`, `.stderr.txt` and `.engine.log`; JSON retains full child
command/exit/outcome, diagnostics, observed paths, engine/probe hashes and
restoration. The shared `paths.*` files reflect the last run; archived prefixes
preserve every context independently.

| Context / UTC start / command | Godot child / harness exit | Stderr and diagnostics | Containment / evidence |
|---|---|---|---|
| Normal Codex sandbox, 17:45:41Z; `./.cache/dx001-certificate-comparison.ps1 -Context inside` | 0 / 1; FAILED | 125 bytes: root certificate-store error below; also retained in engine log. No timeout. | Actual paths passed independent containment inspection; `inside-first.*`. |
| Outside isolation, 17:46:33Z; same harness with `-Context outside`, requested through `require_escalated` | 0 / 0; PASSED | Stderr empty (0 bytes); no error/warning/ambiguous or certificate diagnostics. No timeout. | Actual paths passed; `outside.*`. |
| Explicit normal-sandbox repeat after outside pass, 17:47:23Z; `-Context inside` | 0 / 1; FAILED | Same 125-byte stderr and engine-log certificate diagnostic. No timeout. | Same actual paths passed independent containment inspection; `inside.*`. |

Exact stderr for both isolated failures:

```text
ERROR: Failed to read the root certificate store.
   at: get_system_ca_certificates (platform/windows/os_windows.cpp:2582)
```

All observed user/data/config/cache/editor data/config/cache paths were within
workspace `.cache/`; editor project path was within the existing preflight's
`.godot/editor`. Reparse checks passed. Path inspection on a FAILED run is evidence
about location only: it does not convert certificate failure into success or open
the real-project gate. No real-project command ran in any context. The two harness
exit-1 results are expected faithful failure reporting despite child exit zero.

### Permission evidence and interpretation

The available conversation transcript includes prior Batch 2 `require_escalated`
requests for the full launcher and the Foundation wrapper, their justifications,
and successful execution results. Retained `results.json` confirms failed isolated
`paths` and passed retry paths, but does not independently encode sandbox mode or
approval decisions. There is **no separate approval-history/audit API or decision
log available here** to establish whether a particular earlier UI click or an
existing permission rule allowed execution. The handoff/transcript identifies
the intended contexts; neither should be misrepresented as an OS permission audit.

For this comparison an explicit execution approval request was issued for the
outside-isolation command, and the tool then executed it successfully. Command
approval authorizes that execution route; it does not itself grant arbitrary
Windows rights or make normal sandbox children unrestricted. Both verification
PowerShell principals reported `administrator_token=false`. No `RunAs`, UAC
elevation, global ACL/certificate change or external marker was used.

PowerShell containment and Codex sandbox isolation are separate mechanisms. The
former redirects environment paths and checks observed locations; it remained
enabled and passed in every run. The latter changes the process execution/resource
access context. Godot actually launched and reported paths inside isolation, so
the observed failure is not a command-approval rejection or executable-discovery
failure. It is a Godot failure while accessing the Windows system CA certificate
resource, despite successful process exit.

**Inference:** the controlled inside/outside/inside results strongly support an
isolation-specific resource-access restriction in this environment. Identical
commands, binary/source hashes and paths, plus the failure returning after the
successful outside run, argue against an engine path/version problem, containment
redirection or simple cache warm-up. Both contexts lacking an administrator token
also argues against administrative elevation being needed to succeed. This does
not identify the exact Windows ACL, restricted-token rule, registry view, security
software interaction or failed system call: Godot's message supplies no underlying
Win32 access status, and those mechanisms were not audited. A resource policy
interacting with isolation remains plausible; universal causation is not claimed.

### Acceptance and supported route

**Batch 2 acceptance criteria: SATISFIED for the documented approval-mediated
contained execution route**, combining this controlled comparison with the
previously executed full suite, final 163 infrastructure fixtures and restoration
checks above. This is not a claim that the isolated certificate failure is fixed
or that unrestricted autonomous sandbox execution is available. The blocked
resource inside isolation remains a known limitation, not a waived certificate
error. No comparison result justified repeating the 82-case suite; it was UNRUN
in this verification turn.

Recommended route: use the ignored local selection and existing contained
launcher. If certificate preflight fails inside isolation, retain its FAILED
evidence and dependent UNRUN outcomes, request applicable explicit execution
approval, then rerun the same launcher outside isolation with containment and
fresh actual-path verification intact. If approval/execution is unavailable,
report retry BLOCKED. Do not treat outside-isolation approval as Windows
administrative elevation, disable TLS verification, suppress diagnostics, install
certificates, change host configuration or use a direct uncontained engine launch.
Earlier exact Batch 3 instructions remain pending separate authorization.
Final documentation verification: `./.cache/dx001-batch2-doc-check.ps1` PASSED,
exit 0 (28 local links/anchors, five documents' whitespace, three existing tool
scripts parsed); SHA-256 checks confirmed the other seven previously modified
Batch 2 tracked files unchanged during this turn. `git diff --check` PASSED,
exit 0, with LF→CRLF advisories only.
**Stop for review.**

## Batch 2 Windows sandbox compatibility investigation — 2026-10-03

**Authority:** owner's minimal, time-boxed Windows Sandbox Compatibility
Investigation request. Investigation ended at the feasibility/security boundary:
**zero alternative-mode Godot comparisons executed**. No full suite, Batch 3,
configuration edit, rule installation, dependency, commit or push. Existing
Batch 2 approval-mediated execution remains the supported permanent route.

### Active implementation and effective constraints

Read-only inspection established native **elevated** Windows sandbox execution:

- User `C:\Users\xzarian\.codex\config.toml` contains `[windows]` with
  `sandbox = "elevated"`; the project is trusted. No workspace `.codex/config.toml`
  or user-home `requirements.toml` exists at the inspected paths. Absence at those
  paths does not establish absence of all enterprise/remote requirements.
- Normal tool shell identity is `OMEN-PC\CodexSandboxOffline`, with administrator
  role false. This dedicated sandbox identity corroborates the configured mode;
  `elevated` names the sandbox implementation/setup, not an administrator Godot
  process. The daemon resources in the sandbox log identify release `0.160.0`.
- Session policy remains workspace-write, restricted network, writes limited to
  authorized workspace output, with approval-mediated outside-isolation execution.
  These supplied effective session restrictions take precedence over assumptions
  from the user configuration. No effective configuration dump or mode-switch API
  is exposed by this session's tools.

Official [Windows sandbox documentation](https://learn.chatgpt.com/docs/windows/windows-sandbox)
describes dedicated low-privilege identities in elevated mode and a restricted
token derived from the current user in the unelevated fallback. Both establish
ACL filesystem boundaries; elevated setup also uses firewall/local policy.
The [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)
documents native mode selection and administrator restrictions on implementations.
That supports identity differences as a plausible explanation to investigate,
not a finding that switching modes fixes Godot certificate access.

### CLI inspection, failures and feasibility limit

The installed executable is
`C:\Users\xzarian\AppData\Local\Programs\OpenAI\Codex\bin\codex.exe`.
The available CLI syntax was checked; no Godot command ran during these checks:

| Actual check | Result |
|---|---|
| `codex.exe sandbox windows --help` inside normal sandbox | FAILED exit 1: warning about unavailable PATH aliases, then `Could not find home directory`. Dedicated sandbox identity could not initialize CLI home resolution. |
| Same invocation outside isolation, via explicit approval request disclosing possible user-local CLI startup cache/alias writes | FAILED exit 1: `CreateProcessAsUserW failed: 2`; current CLI interpreted `windows --help` as a child command rather than a subcommand. No child executable found and no Godot probe launched. |
| `codex.exe sandbox --help` outside isolation, separately requested | PASSED exit 0: `codex sandbox [OPTIONS] [COMMAND]...`, supports temporary `-c/--config` values, permission profiles, working-directory selection and managed requirements. This is help evidence only; it does not prove switching modes is free of setup side effects. |

**Unexpected side effect evidence:** the sandbox log surrounding the failed
`windows --help` runner invocation records setup refresh, `read-acl-only mode:
applying read ACLs`, helper reuse, and a failed attempt to hide
`C:\Users\Default` (`SetFileAttributesW`, access denied 5). Some setup refreshes
also occur around ordinary tool commands. The historical CLI syntax assumption
should have been checked with parent help first. The runner entered sandbox setup
before discovering the missing command. This is not evidence of an alternative
mode comparison. No explicit ACL/security edit was issued by the agent, but these
logs prevent claiming the helper performed no host ACL side effects. Exact ACL
targets/deltas and their rollback were not audited; no security rollback was
attempted because that would itself change host security without authorization.

User config SHA-256 before and after CLI inspection matched:
`61F1A57B1C1F6DF82D74D11798D69E272E7D9B475F24DEFEC3AAFD09EB24FE88`.
Original `[windows] sandbox = "elevated"` was never changed, so no configuration
restoration was necessary. No new persistent allow rule was created; the inspected
user rules directory was absent.

A one-command `-c 'windows.sandbox="unelevated"'` override is syntactically
supported as configuration input. However, there is no established installed
runner option to guarantee no external ACL/setup/security effects, and effective
managed constraints have not been exhaustively inspected. Starting a nested
unelevated runner inside the active dedicated elevated identity would also not
test the intended unrestricted owner's identity. Starting it outside isolation
would require authorization plus confidence that its setup respects the owner's
prohibition on host security changes. The observed runner setup makes that safety
condition unresolved. Editing a project/global config would not switch already
running tool processes and would not solve this boundary.

**Alternative comparison: BLOCKED under the stated no-host-security-change
constraints; diagnostics and process exit code UNRUN.** No configuration-change
approval was requested because no concrete procedure meeting those constraints
could be established within this investigation. Do not infer a certificate result
from help/config support. Do not broaden this investigation into setup/ACL repairs,
Full Access, another implementation, or further mode attempts.

### Retained results and narrowly scoped approval option

The previous existing harmless path probe's retained JSON was reread: elevated
sandbox FAILED / child exit 0 / certificate failure; approved outside isolation
PASSED / child exit 0 / no certificate diagnostic; elevated repeat FAILED / child
exit 0 / same certificate failure. Actual path containment passed in all three.
No probe or full suite was rerun in this compatibility turn. The alternative
identity explanation remains plausible but untested; the previously established
isolation-specific inference and approved route remain supported.

Official [rules documentation](https://learn.chatgpt.com/docs/agent-configuration/rules)
supports command-prefix allow decisions to run selected commands outside the
sandbox without repeated prompts; stricter matching rules still take precedence.
A user-approved, project-specific rule can reduce prompts for the existing
contained technical-validation entry point while keeping other commands subject
to sandbox/approval policy. Proposed narrow invocation and rule for review only:

```text
C:\GameDev\project-horde\tools\validate.ps1 -Mode All -InfrastructureFixtures
```

```python
prefix_rule(
    pattern = ["C:\\GameDev\\project-horde\\tools\\validate.ps1", "-Mode", "All", "-InfrastructureFixtures"],
    decision = "allow",
    justification = "Project Horde contained technical validation; certificate-store access requires execution outside isolation.",
)
```

Use the exact direct script invocation, not a generic `powershell`, `pwsh`,
`-Command`, arbitrary Godot-binary or Codex allow rule. This is a prefix rule,
not a cryptographic script pin or argument-complete allowlist: later arguments
may match, and modified launcher/test/project code still runs with normal user
rights outside isolation. It narrows which command is authorized; it does not
enforce an OS sandbox on that command or make its descendants incapable of other
access. Re-review changes to the entry point and invoked code/selection before
reusing approval; if that trust condition is unacceptable, retain per-command
approval. No unrestricted Full Access mode is required or recommended. Do not
install the rule automatically or treat this assessment as permission to write
outside the workspace. Rule syntax/matching was not executed here.

**Permanent recommendation:** retain elevated sandbox for ordinary work and the
verified approval-mediated existing validation launcher for Godot checks. An
explicitly accepted narrow rule is an optional prompt reduction, not a certificate
repair or a substitute for containment/error reporting. Batch 2 acceptance remains
satisfied for that supported route; alternative-mode compatibility remains
inconclusive/UNRUN. Stop for review; do not begin Batch 3.

Documentation checks executed after this update: ignored
`./.cache/dx001-batch2-doc-check.ps1` PASSED exit 0 (28 local links/anchors, five
documents' whitespace and three existing tool parses); `git diff --check` PASSED
exit 0, LF→CRLF advisory only. No implementation change was made.

## Batch 3 session outcome and exact Batch 4 handoff — 2026-10-03

**Batch 3 implemented and verified; stop for review.** Scope/authority is the
owner's Batch 3 request. Initial status clean; HEAD
`2022d403f44eb18d90d1e2dd2cf051041eada416` plus this session's uncommitted
tests/documentation. The complete pre-implementation audit, requirement map,
conditions, failures/corrections, exact results and source hashes are in the
[Batch 3 technical evidence](../verification/dx-001-batch3.md). That report and
this section supersede earlier future-Batch-3 statements; history is preserved.

Changes are limited to six native acceptance cases and their manifest/UID,
Context freed-signal-source cleanup with a regression check, inventory assertions,
README/quickstart and evidence/handoff docs. Existing 82 cases remain mandatory;
no assertion redundancy removal, gameplay/tuning/threshold/duration/cycle change,
launcher implementation/default change, dependency, installation/global config,
alternative Windows sandbox/certificate investigation, commit or push.

All engine invocations used ignored workspace selection, existing Godot 4.7.2
Standard console and explicit approval outside isolation through the unchanged
actual-path-containment launcher. APPDATA/LOCALAPPDATA/TEMP/TMP restorations passed.
Outputs/source snapshots remain ignored/workspace-local.

| Actual command/result | Evidence under `.cache/validation/` |
|---|---|
| `C:\GameDev\project-horde\tools\validate.ps1 -Mode All -InfrastructureFixtures`: baseline PASSED exit 0, 37 parses, 82 cases / 5,843 assertions, both startups, 163 infrastructure assertions | `20261003T180119398-ec4769de5414432faa064a32f6391415/` |
| Same command with `-SuiteTimeoutSeconds 240`: first expanded run FAILED exit 1 on hard-coded inventory, buffered input, stale cleanup and an incorrectly added wall-time gate; dependent startup/infrastructure UNRUN. Corrected test infrastructure, preserved original criteria | `20261003T180518843-d1d0b40262794ec99ed3c068eb8695a8/` |
| Same expanded command: final PASSED exit 0, 38 parses, 88/88 cases / 6,142 assertions, zero pending/deferred/excluded, normal/Profile startup, 163 infrastructure assertions | `20261003T180830902-06a41356654849c199b9629b050d214c/` |

Actual new evidence: >=65 completed automatic physics seconds/01:05 and next-step
health; ten-real-second contact/between-event/defeated waits respectively
10.025078/10.034548/10.028147 seconds with 97 state/input samples each; no inactive
state/signal changes; preserved default resume deadlines; three consecutive
same-Main click/Enter/Space cycles, generations 2/3/4 with all fresh invariants,
full 1.5-second first-spawn delay and one event each; fresh range/contact-distance
eligibility and actual mapped WASD after yaw/pitch/nonblocking overlap.
These controlled headless fixtures are not rendered usability or owner survival.
The 240-second invocation watchdog accommodates mandatory waits; default 120
seconds and all original acceptance durations remain unchanged.

**Remaining gaps:** T052 stays unchecked. Technical evidence maps objective
FR/edges and SC-002/003, but current complete independent SC-004 action coverage,
no developer intervention, physical controls, readable/observable presentation,
responsiveness and subjective feel need actual owner evidence. Prior qualified
positive owner feedback and T033/T041/T048 results remain historical. No new human
playtest or rendered profile smoke ran. T053–T056 and SC-006/007 final
survival/profile/source qualification remain unstarted/outstanding; no prototype
profile report created; SC-005 remains future/unverified. Batches 4/5 unstarted.

### Exact next-session instructions — Batch 4 only after review/authorization

1. Read AGENTS.md, constitution v1.0.0, this handoff, active spec/plan/tasks,
   quickstart, tests README, gameplay ledger and Batch 3 report. Inspect initial
   Git status; preserve uncommitted work and the six new required cases. Confirm
   Batch 3 source/evidence or document intervening changes. Keep T052 open while
   independent human evidence is missing. Do not start Batch 5 or T053–T056.
2. Check ignored `.cache/godot-bin.txt` exists/valid before use, or obtain the
   documented explicit engine selection. Use the established approval-mediated
   contained route only; do not retry known ineffective isolated Godot execution
   or investigate sandbox modes/certificates. Approval is session-specific. If
   unavailable: execution BLOCKED, affected checks UNRUN, retain static findings.
3. Establish **new measured pre-cleanup evidence** with the full command:
   `C:\GameDev\project-horde\tools\validate.ps1 -Mode All -InfrastructureFixtures -SuiteTimeoutSeconds 240`.
   Record exact argv, revision/diff, engine/environment, scope, case/assertion
   counts, outcomes and monotonic elapsed time for the command and native suite.
   Add only necessary workspace-contained timing instrumentation/receipt tooling
   if existing logs cannot measure those costs; do not treat Batch 3 durations or
   assertion counts as a suite-cost benchmark. Preserve mandatory real waits.
4. Inspect repeated assertions **before editing**. For each proposed removal,
   show the exact failure/edge/data obligation and retained assertion/case that
   gives equivalent coverage and diagnostics. Keep distinct contracts, all
   required discovery/execution checks, true error classification, real durations,
   cycle counts, health/range/deadline thresholds and production behavior. If no
   demonstrated redundancy exists, report that result without speculative cleanup.
5. Run the same fully scoped command and measurement method after justified
   edits. Record actual before/after environment, commands, per-check/full-suite
   elapsed measurements, case/assertion counts, failures and reasons. Do not claim
   speed from counts or assume machine noise proves improvement. Rerun relevant
   parsing/startups/infrastructure after changes; add tests only for distinct gaps.
6. Update tests README, evidence ledger and this handoff with actual measurements,
   a removal-to-retained-coverage map, remaining technical/human gaps, and exact
   separately authorized Batch 5 instructions. No gameplay tuning/production
   cheats/new dependencies/fixed speed target, commit or push. Stop for review.

Batch 5 tiering/final reconciliation remains dependent on the reviewed Batch 4
results; no tier is introduced or measured by this Batch 3 handoff.

Final documentation/provenance checks executed: ignored
`./.cache/dx001-batch3-doc-check.ps1` PASSED exit 0 (five documents' whitespace,
33 local link paths, five source hashes, final outcomes/counts and real-wait/cycle
receipts); `git diff --check` PASSED exit 0; `git diff --exit-code HEAD -- scripts scenes resources tools project.godot .specify/memory/constitution.md specs/001-core-gameplay-prototype/spec.md specs/001-core-gameplay-prototype/plan.md specs/001-core-gameplay-prototype/tasks.md`
PASSED exit 0. All original gameplay/spec/plan/task/launcher/constitution files
remain unchanged. Final source matches the passing run; evidence docs were edited
afterward. No code rerun is claimed for those documentation-only edits.

## Batch 4 completed results and exact Batch 5 handoff — 2026-10-03

**Batch 4 complete; stop for review.** Owner's Batch 4 request supersedes the
historical authorization/status above. Initial Git status clean; HEAD
`c9978527621b1850b4a54ff4610f3040a99a0d9a`; all five retained Batch 3 hashes match.
[Batch 4 report](../verification/dx-001-batch4.md) records measurement boundaries,
full per-check/case receipts, exact removal-to-coverage/diagnostics map and limits.

Passive monotonic timing added before baseline to native case/suite receipts,
launcher child records and aggregate `timing.json`. Baseline assertions unchanged.
Only cleanup: consolidate 1,000 identical API checks per method in
`profile.bounded_late_failure` to one per method with original failure predicates/
messages; remove 1,998 redundant checks. All 1,000 callback pairs, million-sample
stress protocol and behavioural/late-failure assertions remain. No other pruning
is supported. All 88 cases and six Batch 3 acceptance cases remain mandatory;
technical cases retain original counts, durations, cycles and thresholds.

Both executions use the same explicitly requested approval-mediated contained
route and existing Godot 4.7.2 Standard console selection. No isolated execution
or sandbox/certificate investigation. Exact command for both:

```powershell
C:\GameDev\project-horde\tools\validate.ps1 -Mode All -InfrastructureFixtures -SuiteTimeoutSeconds 240
```

| Actual result | Baseline | Final |
|---|---|---|
| Outcome | PASSED exit 0 | PASSED exit 0 |
| Aggregate/native suite seconds | 118.775031 / 96.873584 | 118.090575 / 96.815639 |
| Required/executed cases; assertions | 88/88; 6,142 | 88/88; 4,144 |
| Parses/startups/infrastructure/restoration | 38; normal/Profile; 163; all four | Same |
| Evidence under `.cache/validation/` | `20261003T190404339-22cc7fee048a475e93bee07c90a01124` | `20261003T190633709-610b11ffc3a544a2a03c166b8b949348` |

Zero pending/deferred/excluded in both. Expected negative infrastructure child
failures retain original evidence; no unexpected required failure. No new test
case or full exploratory rerun. About 98.1% of baseline native time lies in the
six technical cases, dominated by mandatory waits. One uncontrolled before/after
pair establishes no causal speedup; cleanup is justified API redundancy, not a
demonstrated wall-time bottleneck. No duration/cycle reduction is authorized.

T051 complete; **T052 stays open** pending independent complete SC-004 owner
evidence without developer intervention. Existing manual quickstart journey
remains; human controls/presentation/responsiveness/feel and rendered profile
smoke UNRUN. SC-006/007 qualification and T053–T056 unstarted, SC-005 future/
unverified. No gameplay/tuning/constitution/spec/plan/task change, new dependency,
execution tier, installation/global configuration, commit or push.

### Exact next-session instructions — Batch 5 only after review/authorization

1. Read AGENTS.md, constitution v1.0.0, this current handoff, active spec/plan/
   tasks/quickstart, tests README, gameplay ledger and Batch 3/4 evidence. Inspect
   status/revision/diff; preserve all existing work. Verify executed-source hashes
   or document intervening changes. Keep T052 open for missing independent SC-004.
2. Check local engine selection exists/valid, or use documented explicit selection.
   Use the established approval-mediated contained route; do not investigate
   isolation/certificates again. If execution approval is unavailable, report
   BLOCKED route and dependent checks UNRUN, continuing useful static work.
3. Define proportionate fast/targeted/full execution instructions from actual
   Batch 4 per-child/per-case costs and coverage map. Foundation remains the
   existing limited 13-case infrastructure selection, excluding gameplay; never
   label it feature acceptance. Add runner/manifest/tool selection only if needed
   for a concrete targeted use. Keep full discovery/reconciliation, genuine-error
   classification and explicit selection/omission reporting for every tier.
4. For each tier document exact command, selected cases, prerequisites, omissions,
   expected scope and applicable use. Define when full validation is mandatory,
   particularly integrated acceptance and changes touching shared lifecycle,
   scheduling, input or runner/selection infrastructure. Preserve all 88 required
   cases, six Batch 3 obligations, mandatory real waits/three cycles/thresholds;
   a targeted pass never silently completes omitted acceptance. Keep default
   watchdogs unless a separately justified change is approved; full invocation
   currently uses `-SuiteTimeoutSeconds 240` to accommodate original protocols.
5. Execute appropriate tier checks through containment, using passive timing and
   the smallest relevant selections during exploration. Run full All/infrastructure
   where required by final changes/acceptance; report exact commands, actual
   outcomes/counts/costs and failures. Do not repeatedly run full suites merely to
   chase noise or claim speed from counts. Add tests only for distinct risks.
6. Reconcile README, quickstart, plan/tasks, ledger and this handoff with final
   implementation/selection and measured evidence. Distinguish technical FR/
   SC-002/003 proof, remaining independent SC-004, and future SC-005/006/007 gates.
   DX-001 completion cannot imply prototype acceptance. Leave T052 open absent
   sufficient independent owner evidence; do not start T053–T056, alter gameplay
   tuning/requirements, commit or push. Record remaining gaps and stop for review.

Batch 5 is **not started** here. Current changes are ready for owner review.

Final static checks PASSED: launcher PowerShell syntax, ignored
`./.cache/dx001-batch4-audit.ps1` (both receipts/88 case counts, preserved six
technical cases/durations/cycles, source hashes, unchanged production/spec/plan/
task boundaries, whitespace and 29 local links), and `git diff --check`.
No executable source changed after the passing final run. Search/rejected
documentation-context mistakes are recorded in the report; no engine failure
or hidden acceptance result occurred.
