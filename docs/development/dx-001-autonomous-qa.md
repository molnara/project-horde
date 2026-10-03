# DX-001 — Autonomous QA implementation and session handoff

**Approved sequence:** Batch 1 acceptance-method amendment → Batch 2 environment
reliability → Batch 3 autonomous technical acceptance → Batch 4 assertion cleanup
and execution measurement → Batch 5 execution tiers and final reconciliation.
**Authority:** product-owner DX-001 Bootstrap + Batch 1 request, 2026-10-03;
[constitution v1.0.0](../../.specify/memory/constitution.md) remains unchanged.
Only bootstrap and Batch 1 are authorized in this session. Stop for review afterward.

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

## Batch 2 — Environment reliability (next, not started)

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

## Batch 3 — Autonomous technical acceptance (planned)

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

## Batch 4 — Assertion cleanup and execution measurement (planned)

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

## Session outcome and next handoff

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
