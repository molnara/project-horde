# Feature Specification: Core Gameplay Prototype

**Feature Branch**: `001-core-gameplay-prototype` (existing dedicated Git feature branch; registered in `.specify/feature.json`)

**Created**: 2026-10-02

**Status**: Implemented through Phase 5; T051 technical validation complete, T052 integrated acceptance open. SC-006/007 final qualification outstanding; SC-005 future/unverified. DX-001 Batch 1 amends verification methods only.

**Input**: A small, playable, single-player, third-person 3D survival arena demonstrating the foundational combat loop with original placeholders, movement, camera control, one enemy type, one automatic weapon, health, HUD, defeat, restart, and pause/resume.

**Governing document**: [Project Horde Constitution v1.0.0](../../.specify/memory/constitution.md). All principles remain applicable; architecture and technical solutions belong to planning.

## Clarifications

### Session 2026-10-02

- Q: What should count as a successful five-minute survival playtest for the first milestone? → A: One uninterrupted run reaching five active minutes with ongoing spawning, pursuit, automatic combat, and player vulnerability. Paused time does not count. This is prototype acceptance, not a fixed run duration or a guarantee that every attempt succeeds; play continues normally beyond five minutes until player death.
- Q: What performance evidence should be required before accepting the first playable milestone? → A: Profile the actual five-minute playtest and document measured performance and observed bottlenecks, capturing average FPS, minimum observed FPS, frame-time behaviour, and approximate active enemy counts where practical. The constitutional 200-simultaneous-enemy / 60 FPS target remains a separate future benchmark, explicitly unverified until properly tested, and does not block first playable prototype acceptance.
- Q: Should enemies physically block the player or one another during the prototype? → A: Enemies may overlap one another and the player without obstructing movement. Contact damage retains each enemy's attack interval and MUST NOT repeat every physics frame merely because overlap persists. Arena boundaries constrain all entities. Collision behaviour remains modular so later separation, blocking, knockback, and crowd behaviour can be added without rewriting core combat; those behaviours are outside this milestone.
- Q: Should the prototype spawn one enemy at each fixed interval without a population cap, or limit how many enemies can be alive at once? → A: Spawn one enemy per configurable fixed interval, subject to a configurable maximum live-enemy population defaulting to 50. Skip scheduled spawns while full without queuing or catch-up bursts; resume at the next scheduled opportunity once below the cap. No difficulty scaling, waves, or additional enemy types. The cap is a gameplay/testing safeguard, not the constitutional target; a future 200-enemy benchmark remains independently testable.
- Q: What should count as enemy contact for dealing damage to the player? → A: Contact occurs when horizontal XZ-plane distance between player and enemy positions is less than or equal to a configurable threshold; spawns start strictly outside it. Preserve immediate first-contact damage and independent per-enemy attack intervals. Leaving and re-entering range never resets or bypasses an active cooldown. Exact distance values belong to planning. No physical movement blocking or collision-volume-based damage detection in this milestone.

### Technical review decisions — approved 2026-10-02

- Five-minute survival means 300 seconds of completed, unpaused physics simulation. Pauses and stalls do not award unsimulated survival time; wall-clock duration and actual FPS are recorded separately.
- Unexpected enemy spawn-selection or instantiation failures consume the scheduled opportunity, emit diagnostics, increment a per-run failure counter, and allow simulation to continue without catch-up. Any such failure invalidates that acceptance attempt. A population-cap skip is expected and is not a failure.
- Invalid configuration disables simulation and produces actionable diagnostics. Correcting configuration and relaunching is sufficient recovery; in-application configuration retry is outside this milestone.
- A–G technical resolutions are approved with refinements: completion-time event deadlines; separate survival, continuation and profiling results; no automatic acceptance at 300 seconds; and genuine-error classification that preserves harmless informational logs. See the adopted plan and contracts.

## User Scenarios & Testing *(mandatory)*

### Acceptance methods — DX-001 Batch 1, approved 2026-10-03

Objective technical correctness for FR-001–FR-012, their acceptance scenarios
and edge cases, and SC-002/003 may be established by reproducible automated
evidence exercising actual components/scenes. This amends the verification
method only: all original gameplay obligations, thresholds, durations and cycle
counts remain mandatory. Map each claimed clause to executed checks, actual
conditions/tuning, source revision, command, output and result. A passing suite
count without that mapping is insufficient. Uncovered clauses remain outstanding.

Technical evidence includes exact movement/range/health/timing invariants, HUD
values, frozen inactive state, remaining deadlines and restart isolation. Preserve
the 65-active-second HUD check, ten-second defeated freeze, ten-real-second pauses
in contact and between-event contexts, and three consecutive defeat/restart cycles
in one application. Synthetic deltas/timestamps can prove deterministic logic;
they cannot prove a real elapsed duration or physical input usability. Required
real-duration checks need measured monotonic elapsed time and exercised input/state
checks, through automation or a documented human run. Do not convert existing
synthetic fixtures into evidence of a newly executed real-time check.

Human owner acceptance focuses on independent control usability, observable
presentation/readability, responsiveness and subjective game feel. Exact internal
values and technical edge cases need not be remeasured manually when sufficient
automated evidence exists. Headless results cannot establish these human qualities.
SC-004 retains the full named integrated action set, actual product-owner
participation and absence of developer intervention; automation cannot replace it.
SC-006/007 retain their actual owner survival/profile obligations. Historical
observations remain historical, T051 is complete, and T052 remains open pending
sufficient combined evidence. See [DX-001](../../docs/development/dx-001-autonomous-qa.md).

### User Story 1 - Survive in the arena (Priority: P1)

As a player, I can navigate a bounded arena, rotate my view, and survive approaching enemies while my automatic weapon fights and the HUD shows health and time.

**Why this priority**: This integrated loop is the first milestone's purpose.

**Independent Test**: Start a run, move in all directions before and after camera rotation, observe approaching enemies and automatic kills, then take contact damage. This core slice can be assessed without pause or restart.

**Acceptance Scenarios**:

1. **Given** a fresh run, **When** I use WASD and the mouse, **Then** movement follows camera orientation, the view follows me, and boundaries contain me (FR-001–FR-003).
2. **Given** active play below the live-enemy cap, **When** spawn intervals elapse, **Then** one enemy appears per scheduled opportunity and pursues my current position; at the cap, the opportunity is skipped without queuing or catch-up spawns (FR-004).
3. **Given** approaching enemies, **When** attacks become ready, **Then** the weapon damages the nearest eligible target, defeated enemies disappear, and enemy contact reduces my health (FR-005–FR-008).
4. **Given** active play, **When** time passes or health changes, **Then** the HUD reflects both (FR-009).
5. **Given** a fresh run with documented prototype tuning, **When** the product owner survives for five active minutes in one uninterrupted run, **Then** spawning, pursuit, automatic combat, and player vulnerability remain active throughout; reaching five minutes does not end or otherwise change the run, which continues normally until player death. Paused time does not count, and not every attempt must succeed.

---

### User Story 2 - Try again after defeat (Priority: P2)

As a player, I can recognize defeat and start a clean new attempt in the same application.

**Why this priority**: Repeatable attempts make the prototype playable and reviewable.

**Independent Test**: From an active core-loop run, take lethal damage and restart across three successive defeats. Pause is not needed for this journey.

**Acceptance Scenarios**:

1. **Given** positive health, **When** damage reaches or exceeds remaining health, **Then** Game Over stops the run and shows final survival time (FR-010).
2. **Given** Game Over, **When** I activate Restart, **Then** one fresh active run begins with full health, zero time, initial position/view, no previous enemies, and fresh event timing (FR-011).

---

### User Story 3 - Pause during combat (Priority: P2)

As a player, I can interrupt combat and resume the same encounter without losing health or survival time while paused.

**Why this priority**: An interruption must preserve the player's attempt.

**Independent Test**: During core-loop combat, press Escape, wait ten seconds while trying movement and camera input, then resume and compare state and event timing.

**Acceptance Scenarios**:

1. **Given** active combat, **When** I press Escape, **Then** Paused appears and all gameplay and camera changes stop (FR-012).
2. **Given** Pause, **When** I press Escape again, **Then** the encounter resumes with preserved state and remaining delays, without catch-up events (FR-012).

### Edge Cases

- No enemy in range: no attack or damage; other active gameplay continues.
- Exactly at range: eligible; beyond range: ineligible.
- Exactly at the contact-distance threshold: contact damage is eligible subject to that enemy's attack readiness; beyond it: no contact damage. A spawn at or inside the threshold is invalid.
- Equidistant targets: only the earliest-spawned tied living enemy is attacked.
- Target dies or leaves range: reassess targets at the attack opportunity; never damage a removed enemy.
- Multiple enemies contact the player: each contributes its own scheduled damage; health stays at or above zero and Game Over occurs once.
- Persistent overlap: enemies do not block the player or one another; each enemy deals contact damage only when its own attack timing permits, never on every physics frame merely because overlap persists. Arena boundaries still contain all entities.
- Population at cap: skip each scheduled spawn without queuing. After an enemy dies, spawn only at the next scheduled opportunity with available capacity; never spawn immediately merely because capacity becomes available or accumulate missed spawns.
- Lethal damage coincides with another event: after zero player health, no subsequent event changes the final result.
- Pause between attacks/spawns: preserve remaining delays; no reset or missed-event accumulation.
- Escape during Game Over: cannot resume the defeated run.
- Repeated Restart activation: only one fresh run, without duplicate events.
- Diagonal movement and boundary contact: no speed advantage or escape from the arena.
- Unexpected spawn-selection or instantiation failure: consume the opportunity, report diagnostics and increment the run's failure counter; continue simulation without catch-up. The acceptance attempt is invalid even if it reaches 300 simulation seconds. Full-cap skips do not increment the counter.

## Requirements *(mandatory)*

### Functional Requirements

Timing uses completed, unpaused physics simulation time, excluding Pause and Game Over. Only executed simulation steps contribute elapsed survival time; stalls do not add unsimulated wall time. Verification uses documented tuning values for the run. Each criterion is an observable obligation, not a claim of completed testing.

**Approved timing interpretation for FR-004/005/008**: Spawn, weapon and contact deadlines all use the current step's completion simulation time after movement. They never trigger before their deadline. Normal servicing is within one executed physics tick; a positive interval shorter than a tick remains valid but permits at most one action per step, with its effective cadence documented and no backlog. “Immediately” means the first eligible contact phase. Spawning retains fixed scheduled multiples; attack deadlines advance from actual attack completion time. Inactive/stalled wall time gives no unsimulated survival credit.

- **FR-001 — Movement**: WASD MUST move the player horizontally relative to the camera's horizontal orientation: W forward, S backward, A left, D right. Speed MUST be equal in all directions, opposing inputs MUST cancel on their axis, and released input MUST stop movement.
  - **Acceptance**: Test each key before and after a 90-degree camera rotation; directions rotate with the view. Compare equal-duration straight and diagonal travel away from boundaries; distances match. Opposing keys cancel, release stops movement, and camera pitch does not cause vertical travel.
- **FR-002 — Camera**: A third-person camera MUST follow the player and support mouse-controlled horizontal rotation and vertical look. The player MUST remain visible. Vertical look MUST be bounded to prevent flipping upside down or passing below the floor.
  - **Acceptance**: Traverse the arena and its perimeter; the view follows and the player stays visible. Horizontal and vertical mouse movement change the respective viewing directions. Sustained vertical input reaches a limit without flipping or passing below the floor. Mouse input alone does not move the player.
- **FR-003 — Arena**: One small flat 3D arena MUST have visible boundaries, contain players and enemies, and use simple original placeholder geometry. Player, enemies, and floor MUST be visually distinguishable.
  - **Acceptance**: Inspect and traverse the entire arena and perimeter; the floor is flat, boundaries are visible, and neither player nor enemies leave the playable area. A reviewer identifies player, enemies, and limits from the normal view.
- **FR-004 — Enemy Spawning and Pursuit**: Exactly one enemy type MUST spawn one enemy per configurable, documented positive fixed interval during active play, subject to a configurable positive integer maximum live-enemy population defaulting to 50. At the cap, the scheduled spawn MUST be skipped without queuing missed spawns or catch-up bursts. Once below the cap, spawning MUST resume at the next scheduled opportunity with available capacity. Living enemies MUST pursue the player's current position and be able to reach contact distance. Spawns MUST be inside the arena and outside player contact distance. Unexpected spawn-selection or instantiation failures consume the scheduled opportunity, report diagnostics, increment a failure counter and allow simulation to continue without catch-up; they invalidate the acceptance attempt. Full-cap skips are expected and are not failures. No difficulty scaling or spawn waves are included.
  - **Acceptance**: Starting with no enemies and capacity for at least three, the first spawn occurs after one interval; observe three consecutive opportunities producing one enemy each at that interval, all of the same type. Move elsewhere; enemies redirect and can reach the new position. No spawn immediately damages the player or appears outside the boundary. With no kills, reach the configured cap, then observe at least three scheduled opportunities with no new enemies. Remove one enemy between opportunities; no immediate replacement occurs, and exactly one spawns at the next opportunity with capacity, without catch-up spawns. Confirm the default cap is 50 and changing interval or cap before a fresh run changes observed cadence or maximum population without changing spawning logic.
- **FR-005 — Automatic Weapon**: Exactly one weapon MUST automatically attack one nearest living enemy within an inclusive configurable range, applying configured positive damage once per attack with visible feedback identifying the attack and affected enemy. Consecutive attacks MUST be separated by a configurable positive interval. Tied targets MUST resolve to earliest spawn order.
  - **Acceptance**: With two targets at unequal distances inside range, only the nearer receives the configured damage. With tied distances, only the earliest-spawned receives it. A target exactly at range is eligible; a target beyond it is not. With no eligible target, no attack or damage occurs. Continuous eligible targets are attacked at the configured interval. Changing range or interval before a new run changes observed eligibility or cadence.
  - **Acceptance**: A fresh weapon is ready; when an eligible target appears while ready, attack occurs by the next gameplay update. Following an attack, another cannot occur until the interval elapses. Eligibility is reassessed at each opportunity, excluding dead or departed targets.
- **FR-006 — Health**: Player and enemies MUST start at their positive configured maximum health, with independent current health. Damage MUST subtract its amount, bounded at zero. No regeneration is provided.
  - **Acceptance**: Fresh player and enemies have full health. Damage to one enemy leaves other enemies unchanged. Nonlethal and excessive damage reduce health correctly without negative values. Waiting without damage does not restore health.
- **FR-007 — Enemy Death**: At zero health, an enemy MUST die and be removed from the encounter, unable to move, be targeted, receive damage, or damage the player.
  - **Acceptance**: Lethal weapon damage removes the enemy by the next gameplay update. At a later attack opportunity and at its former position, it is neither a target nor a damage source.
- **FR-008 — Player Damage**: Contact MUST be determined by horizontal XZ-plane distance between player and enemy positions, less than or equal to a configurable positive contact-distance threshold, with exact values documented during planning. Living enemies MUST deal configured positive contact damage immediately on first contact and subsequently at a positive per-enemy contact-attack interval. Leaving contact MUST stop damage; leaving and re-entering range MUST NOT reset or bypass a remaining delay. Damage detection MUST NOT depend on collision-volume overlap or physically block movement in this milestone.
  - **Acceptance**: First contact reduces health by the configured amount. A ready enemy exactly at the configured threshold deals damage; beyond it, no contact damage occurs. Sustained contact produces further damage at the configured interval, not every physics frame merely because overlap persists. Separation causes no contact damage. Re-entry before readiness causes no early damage or cooldown reset. Two contacting enemies contribute their own eligible attacks. Changing contact distance before a new run changes observed eligibility; every spawn starts strictly outside the configured threshold.
- **FR-009 — HUD**: A visible HUD MUST show current/maximum player health and elapsed survival time as minutes and seconds, starting at zero and advancing only during active play. It MUST remain visible in Pause and Game Over.
  - **Acceptance**: A fresh run shows full health and 00:00. After 65 active seconds, time reads 01:05 within one displayed second of measured time. Damage updates displayed health by the next gameplay update. Ten seconds paused or defeated leave health/time unchanged.
- **FR-010 — Game Over**: Zero player health MUST end the run, visibly showing Game Over, final survival time, and an actionable Restart control. Movement, camera rotation, spawning, attacks, damage, and survival timing MUST stop. Escape MUST NOT resume defeat.
  - **Acceptance**: Lethal damage shows zero health, Game Over, final time, and Restart by the next gameplay update. Wait ten seconds while attempting WASD, mouse input, and Escape; encounter state/time remain unchanged and no new spawns or attacks occur.
- **FR-011 — Restart**: Restart from Game Over MUST start exactly one clean active run without restarting the application. Health, player position, camera orientation, elapsed time, enemy population, and spawn/attack delays MUST return to fresh-run values.
  - **Acceptance**: Restart restores full health, initial position/view, 00:00, no previous enemies, and a ready weapon. The first enemy appears after a full spawn interval. Repeat across three defeats and attempt repeated activation; only one run remains active, with normal cadence and no duplicate events or carried-over damage.
- **FR-012 — Pause/Resume**: Escape MUST toggle Active/Paused while the player is alive, once per press, with visible pause indication. Pause MUST freeze player/enemy movement, camera rotation, spawns, attacks, damage, elapsed time, and remaining gameplay delays. Resume MUST preserve state and delays without catch-up events.
  - **Acceptance**: Pause during contact combat and between scheduled events. Record health, time, positions, view, and remaining event delays. Wait ten seconds while trying movement/mouse input; all remain unchanged. Resume; events occur after their preserved remaining delays with no extra events for paused time. Holding Escape does not repeatedly toggle.

### Scope and Validation Constraints

- Only original placeholder visuals with recorded provenance are allowed. No copied creative assets or production-quality artwork/audio.
- No experience, upgrades, additional weapons/enemy types, procedural terrain, multiplayer, or save system. Prioritize the integrated playable slice over polish.
- Gameplay tuning MUST be configurable independently of mutable per-run state. Missing or invalid definitions MUST produce actionable diagnostics rather than silently starting broken gameplay. Configuration mechanisms belong to planning.
- Implementation verification MUST include proportionate automated checks where practical and reproducible manual playtests for controls, visuals, and game feel. Unexecuted checks remain outstanding; specification review establishes no gameplay or performance compliance.
- First playable prototype acceptance requires SC-001–SC-004 and SC-006–SC-007. SC-005 is a separate future performance benchmark and MUST NOT block prototype acceptance; its compliance remains explicitly unverified until representative benchmark testing establishes it. Accepting the prototype does not establish constitutional performance compliance or revise the target.
- Collision behaviour MUST remain modular and separate from core combat responsibilities, allowing later enemy separation, physical blocking, knockback, and more sophisticated crowd behaviour without rewriting core combat. These future behaviours are outside this milestone; no speculative crowd system is required.
- The configurable live-enemy cap is a gameplay/testing safeguard, not a performance target or a revision of SC-005. It MUST NOT prevent independent testing of the separate 200-enemy benchmark in a future milestone. A benchmark scenario is not required in this milestone.
- All constitutional architectural, validation, documentation, and workspace constraints remain binding for subsequent phases. Approved technical solutions are recorded in the plan/model/contracts, without changing the milestone scope.
- Invalid configuration MUST keep simulation disabled with actionable diagnostics. Correcting data and relaunching suffices; no in-application configuration retry is required. Restart failure MUST NOT revive the defeated encounter.
- Unexpected spawn-selection or instantiation failures MUST consume the opportunity, produce diagnostics, increment a per-run failure counter and continue simulation without catch-up spawning. Such failures invalidate the affected acceptance attempt; expected population-cap skips are not failures. Verification MUST record the counter and distinguish these outcomes.
- Reaching 300 completed simulation seconds alone MUST NOT classify an attempt as fully accepted. Preserve separate survival-window, continuation and profile-capture outcomes; required continuation/profiling verification and zero unexpected spawn failures are necessary before acceptance. Feature completion still requires all prototype gates. Informational engine output is not a validation failure; genuine script/runtime failures MUST remain visible even with exit zero.

### Key Entities *(include if feature involves data)*

- **Player**: Single controlled survivor with position, maximum/current health, and one weapon.
- **Enemy**: Instance of the sole type with position, maximum/current health, spawn order, and contact-attack readiness.
- **Weapon**: Automatic attack capability with range, damage, interval, and readiness.
- **Arena**: Flat playable area with visible containment boundaries and placeholder visuals.
- **Run**: Survival attempt with Active, Paused, or Game Over state, elapsed active time, and current encounter.
- **Gameplay Tuning**: Valid starting health, movement speeds, fixed spawn interval, maximum live-enemy population (positive integer; default 50), weapon range/damage/interval, and enemy contact distance/damage/interval used consistently for a run.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All FR-001–FR-012 acceptance criteria and listed edge cases have recorded verification results; any unverified criterion prevents a claim of feature completion.
- **SC-002**: A reviewer verifies three consecutive run → defeat → restart cycles in one application session, using reproducible automated execution or human execution; each restart restores fresh-run conditions without duplicate events. Human Restart usability remains part of SC-004.
- **SC-003**: Ten seconds paused during combat produce zero health, position, view, or survival-time changes and zero spawns/attacks; resume preserves remaining delays.
- **SC-004**: In an integrated playtest, the product owner demonstrates all movement directions, rotates the view, identifies health/time and boundaries, witnesses an automatic kill, takes damage, pauses/resumes, and restarts after defeat using documented controls without developer intervention.
- **SC-005 — Future performance benchmark (compliance unverified)**: Target 60 FPS with 200 simultaneously active enemies exercising representative pursuit, combat, and damage on the constitution's reference hardware. This separate future benchmark is not a first playable prototype acceptance gate. Before verification, planning MUST specify resolution, renderer, graphics settings, build mode, scenario, warm-up, sampling duration, and frame-time statistics. Evidence MUST record those conditions, enemy count, FPS, frame-time distribution, stalls, and bottlenecks against the approximately 16.67 ms frame budget. Average FPS alone is insufficient. Target revisions require constitutional governance and product-owner approval.
- **SC-006**: The product owner demonstrates one uninterrupted run reaching at least 300 completed, unpaused physics simulation seconds using documented prototype tuning, with ongoing spawning, pursuit, automatic combat, and player vulnerability. Paused time is excluded. Play MUST continue normally beyond five minutes until player death, without a timed ending or victory condition. Record the 300-second survival window and subsequent continuation verification separately. If later death prevents all continuation observations, preserve valid survival evidence while leaving unobserved continuation clauses outstanding; full SC-006 is not yet satisfied. This is a prototype acceptance/playtest criterion, not a requirement that every attempt succeeds.
- **SC-007**: Profile the actual SC-006 five-minute simulation-time playtest and document measured performance and any observed bottlenecks. Record completed simulation duration and actual wall-clock duration separately; actual FPS uses measured wall time and retains active-play stalls. Unexpected spawn failures invalidate the acceptance attempt, including its SC-006/007 qualification. Capture average FPS, minimum observed FPS, frame-time behaviour (including observed stalls), and approximate active enemy counts where practical; document reasons and outstanding verification for unavailable measurements. Before profiling, planning MUST specify hardware, resolution, renderer, graphics settings, build mode, scenario, warm-up, sampling duration, and frame-time statistics; results MUST record those conditions and measurement methods. Paused time MUST be excluded from active-play measurements. This evidence records prototype performance without establishing SC-005 compliance or introducing a new numerical performance acceptance threshold.

## Assumptions

SC-006's five active minutes are at least 300 completed, unpaused physics simulation seconds, not 300 wall-clock seconds. A qualifying acceptance attempt has zero unexpected spawn failures. For SC-007, record the actual elapsed wall-clock duration and compute actual FPS from measured wall time, separately from simulation duration; include active-play stalls in wall-time evidence. Whole-window actual frame-loop FPS uses observed callbacks divided by measured wall duration; full-interval statistics and partial boundary gaps are reported separately under the adopted plan/quickstart method.

- Keyboard and mouse are the required controls. Jump, sprint, manual aiming/firing, and controller support are outside this milestone.
- A fresh run begins directly in the arena with no enemies and a ready weapon. Survival continues until death with no victory condition or fixed duration.
- Direct weapon damage and enemy contact damage suffice. Projectiles, ammunition, reloads, critical hits, and damage-over-time effects are not required.
- Horizontal mouse movement rotates the view in the same direction; upward movement looks upward. Sensitivity, view limits, arena dimensions, and positive tuning values are selected and documented during planning. A player-facing settings screen is not required.
- Weapon-target and contact distance are measured horizontally in the XZ plane between player and enemy positions. Contact uses its own configurable threshold, inclusive at equality; spawns MUST start strictly outside that threshold. Earliest spawn order is a stable weapon-target tie-breaker.
- Restart uses a clearly labeled selectable Game Over control. Restart from Pause is not required. Escape only pauses/resumes a living run.
- The arena has no interior obstacles preventing pursuit. Placeholder geometry must not create unreachable encounter areas.
- Enemies may overlap one another and the player without physically obstructing movement. Contact damage remains governed by FR-008, including each enemy's attack interval; all entities remain constrained by FR-003 arena boundaries. Verify movement through enemies, sustained overlap damage cadence, and containment at the perimeter.
- No existing gameplay or external service is required. The approved constitution and subsequent plan supply development/verification constraints. All described gameplay is planned behavior.
