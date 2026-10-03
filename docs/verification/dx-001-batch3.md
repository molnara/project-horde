# DX-001 Batch 3 technical acceptance — 2026-10-03

Authority: product-owner Batch 3 request. Constitution v1.0.0 and the active
spec/plan/tasks govern; no gameplay requirement is amended. T052 stays open.

## Audit before implementation

Initial Git status was clean; HEAD `2022d403f44eb18d90d1e2dd2cf051041eada416`.
Read AGENTS.md, constitution, active spec/plan/tasks/quickstart, tests README,
the gameplay ledger and DX-001 handoff including Batch 2 execution findings.
Inspected native manifest, runner, Context, fixtures and actual case bodies.
The existing 82-case evidence is reproducible; broad manifest `maps` tags alone
do not establish every acceptance clause. No existing assertion needs removal.

Pre-change baseline command, explicitly approved outside isolation:
`C:\GameDev\project-horde\tools\validate.ps1 -Mode All -InfrastructureFixtures`.
PASSED exit 0: import, 37 parses, 82 cases / 5,843 assertions, normal/Profile
startup, 163 infrastructure assertions. Evidence:
`.cache/validation/20261003T180119398-ec4769de5414432faa064a32f6391415/`.
Expected failing infrastructure children remain retained negative-test evidence.

Confirmed missing coverage before adding cases:

- `survival.hud` passes 65 directly to the formatter; it does not execute 65
  active seconds through the coordinator's physics driver.
- `pause.freeze_combat` and `defeat.freeze_escape` deliver 600 synthetic ticks;
  other pause cases inject a 10.0 delta. None measures ten real elapsed seconds.
- `defeat.three_cycles` runs three consecutive cycles in one Main but restarts by
  semantic method. `game_over_control` emits `pressed`; neither delivers an
  actual click/Enter/Space sequence across those cycles.
- `combat.targeting/contact` prove fixed eligibility boundaries; custom interval
  and cap fixtures exist, but paired fresh range/contact-distance changes are
  not asserted against the same target geometry.
- `movement.directions` supplies vectors and `survival.order` presses actions;
  the full configured WASD key mapping before/after yaw is not exercised.

Add only these missing checks, reusing Context, F and lifecycle/pause helpers.
Production files, durations/counts/thresholds, launcher defaults and existing
cases remain unchanged. New execution results and complete traceability follow.

## Requirement traceability and limits

Clause suffixes refer to the original per-clause table in
[core-gameplay.md](core-gameplay.md#per-clause-gameplay-acceptance). All listed
cases are required by the full manifest. Baseline and final commands execute the
old cases anew; their historical results are not relabeled as new real waits.
The final executed outcome is recorded below. Rows identify technical coverage;
the human column prevents a fixture from claiming the whole FR is accepted.

| Required clauses | Exercised case IDs and exact scope | Remaining human/gap boundary |
|---|---|---|
| FR-001.a–f | `movement.directions` explicit expected W/S/A/D table at yaw 0/90, equal straight/diagonal travel, opposing/released vectors, fixed Y; `movement.mouse_follow` pitch-independent travel; `survival.order` same-step mouse then input; `technical.mapped_input` configured physical keys, release/opposing/diagonal after viewport yaw/pitch | Physical keyboard/mouse usability and responsiveness need owner; injected events are technical input proof |
| FR-002.a–d,f | `movement.mouse_follow` follow offset, yaw +90, both depression limits 15/65, above-floor camera and mouse-only stationary player; `technical.mapped_input`, `pause.mouse_discard` actual viewport mouse/no resumed jump | FR-002.e visibility throughout normal traversal/perimeter, physical feel and pointer capture remain human |
| FR-003.b,c; geometry/provenance portion of a,d | `movement.containment` both actor insets/all corners with floor -2; `movement.pursuit` unequal radii corner reachability; `definitions.defaults/geometry/references`; existing T050 original primitive provenance | Visible small flat floor/boundaries (a), creative/visual review (d), distinguishability (e) remain human; no new asset introduced |
| FR-004.a–e | `survival.fresh/cadence_cap/deadlines/order`, `movement.selection/pursuit`; first 1.5-second deadline, three ordinary opportunities, current-position pursuit/reachability, strict outside-contact/inset selection including exact rejection; `technical.hud_clock` all spawned actors use single production script | Rendered spawning/pursuit observation still human; controlled geometry proves safety rather than a visually observed spawn |
| FR-004.f–j,m | `survival.cadence_cap` cap 3, three skips, death between opportunities, delayed single refill; `survival.default_custom_cap` caps 50/200, three extra opportunities, interval 0.125; `survival.subtick_long_step` no backlog; `definitions.defaults` default cap 50 | Cap-200 fixture is logic only; no SC-005 performance claim |
| FR-004.k,l; invalid configuration | `survival.selection_fault/instantiation_fault/partial_fault/startup_failure`, `defeat.invalid_restart/failure_isolation`, `runner.fixtures`, definition invalid-value cases; consume once, full diagnostics/failure counter/latched invalidity, ordinary next cadence, partial disposal | Fault-injected attempts cannot qualify for survival; no human fault injection needed |
| FR-005.a–h | `combat.targeting/weapon_readiness`, `survival.order/deadlines/subtick_long_step`; nearest/tie spawn order, XZ inclusive range 4, empty/dead/departed eligibility, ready weapon, one positive damage hit, exact binary deadlines and custom 0.5 interval | Attack observability/target identification are human |
| FR-005.i,j | `technical.configurable_eligibility` fresh ranges 1/3 with identical target x=2; `combat.weapon_readiness` custom interval versus default targeting cadence; `combat.feedback` line/flash target/expiry, `pause.feedback_delay` preserved expiry | Actual rendered hit feedback readability/visibility remains human; node/material state is technical only |
| FR-006.a–d | `combat.health/invalid_damage/weapon_readiness`, `survival.fresh`, `defeat.assert_fresh` exercised by cycles; independent full health, exact subtraction/clamp, one death, invalid rejection, no regeneration during damage-free movement | HUD health readability remains human |
| FR-007.a–c | `combat.registry_death/health/targeting`, `survival.order`; synchronous membership removal, next-frame free, dead motion/damage/contact/target exclusion, lethal weapon before contact | Witnessing automatic kill is part of SC-004 |
| FR-008.a–g,i | `combat.contact` inclusive binary-exact threshold 1, outside/separation/re-entry and independent deadlines; `movement.pursuit` contact reachability; `survival.deadlines/lethal`, `pause.contact_delays`; default 10 damage/1-second independent timing; `technical.configurable_eligibility` contact thresholds 1/3 at same x=2 | Exact values are fixtures, not owner measurements |
| FR-008.h; overlap edge | `technical.mapped_input` player leaves two coincident pursuing enemies at normal speed, enemies remain coincident without blocking/separation; `movement.containment/pursuit` bounds; `combat.contact` overlap never bypasses cooldown | Physical movement feel remains owner |
| FR-009.a–e | `survival.fresh/hud`, `defeat.final_hud`, `pause.hud_restart`; `technical.hud_clock` >=65 actual completed physics seconds/01:05 and next-step health; measured `technical.pause_contact/pause_between/three_cycles` frozen HUD ten real seconds and tree visibility | Human readability/presentation remains open; clock fixture cannot prove normal-tuning owner survival |
| FR-010.a–d; lethal coincident event | `survival.lethal`, `defeat.lethal_commit/final_hud/game_over_control`, `pause.game_over_escape`; `technical.three_cycles` actual lethal update, actionable focused Restart, ten-real-second WASD/mouse/Escape frozen state/signals/final values | Owner recognition and Restart usability remain human |
| FR-011.a–e; SC-002 | `defeat.three_cycles/guarded_requests/stale_callbacks_removal/invalid_restart/failure_isolation`, `restart_evidence.*` existing lifecycle contracts; `technical.three_cycles` same Main, three successive generations, viewport click/Enter/Space, old actors detached, all fresh values/full 1.5-second spawn delay/single event, repeated public activation ignored | Objective SC-002 is automatable; this cannot substitute for SC-004 Restart participation |
| FR-012.a–e; SC-003 | All `pause.*`: once-per-press/echo/repeated transitions, stale inactive callbacks, spawn/weapon/two independent contacts/feedback remaining delays, input discard, HUD/hidden Restart; `technical.pause_contact/pause_between` each >=10 monotonic seconds with live callbacks, all WASD/mouse/held Escape, frozen snapshots/signals, default deadlines preserved and no bursts | Objective SC-003 has real-duration proof; pointer capture/rendered frozen presentation/physical resume responsiveness remain owner |

Every specified gameplay edge is covered above: no/at/beyond-range target,
contact equality/outside/invalid spawn, tie/dead/departed target, multiple contacts,
overlap, cap refill, lethal coincident events, between-event pause, defeated Escape,
repeated Restart, diagonal/boundary contact and consumed diagnostic spawn faults.
Binary-neighbour deadline cases, independent cooldowns, invalid values, source
resource nonmutation and retained failed-attempt/profile-lifecycle cases remain
required. No test count substitutes for any mapping or a human observation.

## Conditions and reproduction

All engine runs use the ignored workspace `.cache/godot-bin.txt` selection:
`C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`, version
`4.7.2.stable.official.ed1daf0bf`, Standard/console. Explicit execution approval
is used outside isolation; version/help/actual-path containment precede imports.
APPDATA/LOCALAPPDATA/TEMP/TMP are redirected/restored by the unchanged launcher;
Godot user/data/config/cache/editor output stays in the workspace. No alternative
sandbox or certificate repair is investigated. An unavailable approval means
BLOCKED retry and dependent checks UNRUN, never permission inferred from this report.

Full post-change invocation:

```powershell
C:\GameDev\project-horde\tools\validate.ps1 -Mode All -InfrastructureFixtures -SuiteTimeoutSeconds 240
```

The launcher default remains 120 seconds. This invocation's 240-second watchdog
allows the unchanged 65-active-second and three ten-real-second protocols. It
does not lower an acceptance threshold or define a Batch 5 tier. Source is HEAD
above plus the uncommitted test changes; preserved source hashes/snapshot below
make that distinction explicit. No commit/push/staging.

New cases use seed 4702052 and actual Main/components/HUD/native runner:

- HUD: 60 Hz automatic physics from zero; enemy speed 0.000001 and weapon range
  0.01 isolate the clock while normal default 1.5-second/cap-50 spawning runs.
  No assigned clock/forced 65 delta; measured wall time is separate from completed
  simulation. The physics accumulator can service already due ticks on enable,
  so wall time need not equal simulation time. No owner survival credit.
- Pauses/cycles: existing lifecycle definition has enemy health 1000/speed
  0.000001. Health 100, spawn interval 1.5/cap 50, range 4/damage 10/interval
  0.6/feedback 0.12, contact distance 1.2/damage 10/interval 1.0 stay default.
  Real contact actors/production damage establish earned deadlines and defeat;
  fixture health damage arranges lethal contact. It is not an autonomous normal
  survival attempt. Actual inactive physics driving stays enabled during waits.
- Inactive waits measure `Time.get_ticks_usec()` for >=10 seconds and sample every
  timer opportunity (~0.1 seconds), attempt all four actions/viewport keys, mouse,
  duplicate and echoed held Escape. Full snapshots plus commit/spawn/hit/attack/
  damage/state signals detect changes. UI tree keeps processing. Resume uses real
  Escape input and controlled 1/64-second active steps; no automatic real-time
  resume servicing claim beyond those exercised steps and existing exact fixtures.
- Three cycles keep one Main/application and default full first-spawn timing;
  no application relaunch or isolated-fixture reset replaces a cycle. Mouse click
  reaches the actual Button via viewport dispatch; Enter/Space reach real HUD.
  Fresh-state helpers assert health/time/position/view/population/generation/
  callbacks/IDs/failure state/weapon/feedback and no sampler. Waiting ten defeated
  seconds once retains FR-010's count; SC-002 retains all three full cycles.
- Configurable eligibility uses fresh real components with range/contact 1 and
  3 against the same target at x=2, with default positive damage. Mapped input
  uses actual physical-key InputMap dispatch/flush, viewport mouse and production
  coordinator stepping; spawn interval 100 isolates movement. Headless input
  injection and Control visibility flags do not prove physical/rendered usability.

## Actual execution and investigated failures

All paths below are relative to `.cache/validation/`; each retains exact child
commands, stdout/stderr/engine logs, exits, diagnostics and `results.json`.

| Executed command | Outcome and retained evidence |
|---|---|
| `C:\GameDev\project-horde\tools\validate.ps1 -Mode All -InfrastructureFixtures` (approved baseline) | PASSED exit 0, 37 parses, 82/82 cases, 5,843 assertions, both startups, 163 infrastructure assertions, all four environment restorations; `20261003T180119398-ec4769de5414432faa064a32f6391415/` |
| Same launcher with `-SuiteTimeoutSeconds 240` (first expanded run) | FAILED exit 1: 38 parses passed; suite executed 88 cases/6,140 assertions but failed `runner.prerequisites`, `technical.hud_clock`, `technical.mapped_input` and unexpected stale-signal cleanup errors. Startups/infrastructure UNRUN by launcher. All four restorations passed; `20261003T180518843-d1d0b40262794ec99ed3c068eb8695a8/` |
| Same expanded command (corrected final rerun) | PASSED exit 0: version/help/actual paths/import, 38/38 parses, 88/88 cases, 6,142 assertions, zero pending/deferred/excluded, normal/Profile startup, 163 infrastructure assertions and all four restorations; `20261003T180830902-06a41356654849c199b9629b050d214c/` |

The first expanded run did not demonstrate a gameplay regression. The preserved
diagnostics identify four test infrastructure causes, corrected before claiming
completion:

1. The inventory contract hard-coded 82; update to 88 retains the Foundation
   13-case assertion and adds the explicit six-case inclusion/exclusion assertion.
2. I incorrectly added a >=65 wall-second gate. The original HUD criterion is
   65 **completed active simulation seconds**, not a second wall gate. Actual
   automatic simulation reached 65.016666… before the health update in about
   64.9 wall seconds as the engine serviced due physics ticks on enable. Remove
   that invented gate, retain all original active-time/tick/HUD checks and record
   the independent positive monotonic wall duration. No original threshold changed.
3. Parsed physical key events were buffered before synchronous manual stepping;
   flushing the native input queue now exercises the actual InputMap before
   assertions. No action press is substituted for the active physical-key test.
4. Real frames between consecutive cycles freed old signal emitters. Context
   called `is_connected` on a non-null Signal whose source no longer existed,
   producing five genuine engine errors. Guard source instance validity before
   disconnect and add a freed-source cleanup regression assertion. No logger/
   genuine-error classification is suppressed. This support fix is necessary
   for the new lifecycle coverage; no assertion cleanup/optimization is performed.

The final run keeps all original cases and adds 297 acceptance assertions plus
two infrastructure regression/inventory assertions. New-case outcomes:

| Case / assertions | Actual final evidence |
|---|---|
| `technical.hud_clock` / 51 | PASSED: actual driver >=65 active seconds, 01:05. Receipt after one additional health-update step: 65.0333333333309 seconds, 3,902 ticks; automatic interval measured 64.926899 wall seconds; health 90/100 by next step. No clock assignment. |
| `technical.pause_contact` / 32 | PASSED: 10.025078 real seconds, 97 samples, active time 0.125/ticks 1 unchanged, no inactive signals. Resume: weapon first 0.734375 for deadline 0.725, feedback expires 0.25 for 0.245, contact exactly 1.125, spawn exactly 1.5. One contact/one spawn/two ordinary attacks across 96 resumed steps; no burst. |
| `technical.pause_between` / 32 | PASSED: 10.034548 real seconds, 97 samples, active time 0.125/ticks 1 unchanged; same weapon/feedback/spawn deadlines, zero contact damage before/during/after separated pause. |
| `technical.three_cycles` / 120 | PASSED: defeated wait 10.028147 real seconds/97 samples, time 0.375/ticks 2 unchanged. Same Main ID 626494801950; click→Enter→Space advanced generations 2→3→4, each full fresh-state check and exactly one first spawn at 1.5. Old nodes/actors detached; repeated input starts no duplicate run. |
| `technical.configurable_eligibility` / 16 | PASSED: same x=2 target excluded at fresh range/contact 1 and included at 3; positive default weapon/contact damage. |
| `technical.mapped_input` / 46 | PASSED: all four physical mapped keys before/after 90° viewport yaw/pitch, key release/opposing axes, equal diagonal distance, mouse-only stationary player and two overlapping nonblocking enemies. |

No new check is skipped or blocked on the approved route. Expected negative
infrastructure children still report FAILED/nonzero where designed (including
timeout and missing/unregistered/unexecuted-case fixtures); their enclosing exact
expectation checks pass. They are not unexpected launcher failure results.
Original streams remain available. Rendered profile smoke is UNRUN (not requested).

Executed source copies, UID and SHA-256 records are retained under ignored
`.cache/dx001-batch3-source/`, alongside `tracked-tests.patch`.
Final test implementation hashes:

| File | SHA-256 |
|---|---|
| `tests/case_manifest.gd` | `35B8EC36E0D1F2BDF4B4649CC559064AD2506B438F2AD864C3679AF95CFE7FFE` |
| `tests/integration/test_technical_acceptance.gd` | `D11D056696A79F9FF08DAF26A4F5E9691A3A620351FD3F92C4879954E3656D2B` |
| `tests/support/test_context.gd` | `41614E9D9945DFDEEBE2D33A74D03C58F690C4B4EE72D56C8C43BD39A8A73F3C` |
| `tests/unit/test_runner_contract.gd` | `11EC1A112F99613D54A52393661CA5BFC03273BED248E26B701ABDE7A7F2CC0B` |

Early read-only commands incorrectly guessed manifest/runner/Main filenames
(two commands returned exit 1), used Windows `rg` wildcard paths (reported path
errors), and read a suite stdout before the launcher created it (reported missing
file despite the surrounding command's final exit 0). Corrected using discovered
paths and explicit existence checks. These caused no source writes or hidden
engine acceptance result; all executed failing engine checks above remain recorded.

Final static verification actually executed:

| Check | Result |
|---|---|
| `./.cache/dx001-batch3-doc-check.ps1` | PASSED exit 0: five documents' whitespace, 33 local link paths, five executed-source hashes, required final outcomes/38 parses/88 cases/6,142 assertions, three real waits and three same-application cycles |
| `git diff --check` | PASSED exit 0; LF→CRLF advisories only |
| `git diff --exit-code HEAD -- scripts scenes resources tools project.godot .specify/memory/constitution.md specs/001-core-gameplay-prototype/spec.md specs/001-core-gameplay-prototype/plan.md specs/001-core-gameplay-prototype/tasks.md` | PASSED exit 0: production, tuning, launcher, constitution and spec/plan/task states unchanged |

No source changed after the passing engine run. Subsequent edits are evidence
and reproduction documentation. Source-hash verification confirms the executed
test implementation still matches this checkout.

## Remaining acceptance and review boundary

T051 remains complete. Objective FR/edge and SC-002/003 results are bounded by
the mappings and actual executed outcomes. T052 remains unchecked: current owner
feedback accepts what was observed but does not explicitly establish the entire
independent SC-004 named action set or absence of developer intervention. Prior
T033/T041/T048 acceptance is preserved as historical evidence, not silently promoted
to a newly completed integrated journey. Human checks here are UNRUN.

Owner procedure remains the quickstart usability journey: move all directions,
rotate view/traverse perimeter/identify boundaries and health/time, witness an
automatic kill/take contact damage, pause/resume, recognize defeat and restart
using documented controls independently. Record actions, omissions, readability,
camera/player visibility, responsiveness/feel and whether developer intervention
occurred. Technical values need no duplicate manual measurement if fixtures suffice.

SC-006/007 final owner survival/profile/source qualification and T053–T056 are
UNRUN/out of scope. Existing diagnostic profile tests/startups are not a new
five-minute run. SC-005 is future/unverified. Batch 4 assertion cleanup/cost
measurement and Batch 5 tiering are not started. Stop for review.
