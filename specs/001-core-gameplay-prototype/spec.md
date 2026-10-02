# Feature Specification: Core Gameplay Prototype

**Feature Branch**: `master` (existing branch; no branch hook configured)

**Created**: 2026-10-02

**Status**: Draft — validated specification; gameplay unimplemented and unverified

**Input**: A small, playable, single-player, third-person 3D survival arena demonstrating the foundational combat loop with original placeholders, movement, camera control, one enemy type, one automatic weapon, health, HUD, defeat, restart, and pause/resume.

**Governing document**: [Project Horde Constitution v1.0.0](../../.specify/memory/constitution.md). All principles remain applicable; architecture and technical solutions belong to planning.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Survive in the arena (Priority: P1)

As a player, I can navigate a bounded arena, rotate my view, and survive approaching enemies while my automatic weapon fights and the HUD shows health and time.

**Why this priority**: This integrated loop is the first milestone's purpose.

**Independent Test**: Start a run, move in all directions before and after camera rotation, observe approaching enemies and automatic kills, then take contact damage. This core slice can be assessed without pause or restart.

**Acceptance Scenarios**:

1. **Given** a fresh run, **When** I use WASD and the mouse, **Then** movement follows camera orientation, the view follows me, and boundaries contain me (FR-001–FR-003).
2. **Given** active play, **When** spawn intervals elapse, **Then** enemies appear and pursue my current position (FR-004).
3. **Given** approaching enemies, **When** attacks become ready, **Then** the weapon damages the nearest eligible target, defeated enemies disappear, and enemy contact reduces my health (FR-005–FR-008).
4. **Given** active play, **When** time passes or health changes, **Then** the HUD reflects both (FR-009).

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
- Equidistant targets: only the earliest-spawned tied living enemy is attacked.
- Target dies or leaves range: reassess targets at the attack opportunity; never damage a removed enemy.
- Multiple enemies contact the player: each contributes its own scheduled damage; health stays at or above zero and Game Over occurs once.
- Lethal damage coincides with another event: after zero player health, no subsequent event changes the final result.
- Pause between attacks/spawns: preserve remaining delays; no reset or missed-event accumulation.
- Escape during Game Over: cannot resume the defeated run.
- Repeated Restart activation: only one fresh run, without duplicate events.
- Diagonal movement and boundary contact: no speed advantage or escape from the arena.

## Requirements *(mandatory)*

### Functional Requirements

Timing uses active gameplay time, excluding Pause and Game Over. Verification uses documented tuning values for the run. Each criterion is an observable obligation, not a claim of completed testing.

- **FR-001 — Movement**: WASD MUST move the player horizontally relative to the camera's horizontal orientation: W forward, S backward, A left, D right. Speed MUST be equal in all directions, opposing inputs MUST cancel on their axis, and released input MUST stop movement.
  - **Acceptance**: Test each key before and after a 90-degree camera rotation; directions rotate with the view. Compare equal-duration straight and diagonal travel away from boundaries; distances match. Opposing keys cancel, release stops movement, and camera pitch does not cause vertical travel.
- **FR-002 — Camera**: A third-person camera MUST follow the player and support mouse-controlled horizontal rotation and vertical look. The player MUST remain visible. Vertical look MUST be bounded to prevent flipping upside down or passing below the floor.
  - **Acceptance**: Traverse the arena and its perimeter; the view follows and the player stays visible. Horizontal and vertical mouse movement change the respective viewing directions. Sustained vertical input reaches a limit without flipping or passing below the floor. Mouse input alone does not move the player.
- **FR-003 — Arena**: One small flat 3D arena MUST have visible boundaries, contain players and enemies, and use simple original placeholder geometry. Player, enemies, and floor MUST be visually distinguishable.
  - **Acceptance**: Inspect and traverse the entire arena and perimeter; the floor is flat, boundaries are visible, and neither player nor enemies leave the playable area. A reviewer identifies player, enemies, and limits from the normal view.
- **FR-004 — Enemy Spawning and Pursuit**: Exactly one enemy type MUST spawn periodically at a documented positive interval during active play. Living enemies MUST pursue the player's current position and be able to reach contact distance. Spawns MUST be inside the arena and outside player contact distance.
  - **Acceptance**: Starting with no enemies, the first spawn occurs after one interval; observe at least three consecutive spawn events at that interval, all of the same type. Move elsewhere; enemies redirect and can reach the new position. No spawn immediately damages the player or appears outside the boundary.
- **FR-005 — Automatic Weapon**: Exactly one weapon MUST automatically attack one nearest living enemy within an inclusive configurable range, applying configured positive damage once per attack with visible feedback identifying the attack and affected enemy. Consecutive attacks MUST be separated by a configurable positive interval. Tied targets MUST resolve to earliest spawn order.
  - **Acceptance**: With two targets at unequal distances inside range, only the nearer receives the configured damage. With tied distances, only the earliest-spawned receives it. A target exactly at range is eligible; a target beyond it is not. With no eligible target, no attack or damage occurs. Continuous eligible targets are attacked at the configured interval. Changing range or interval before a new run changes observed eligibility or cadence.
  - **Acceptance**: A fresh weapon is ready; when an eligible target appears while ready, attack occurs by the next gameplay update. Following an attack, another cannot occur until the interval elapses. Eligibility is reassessed at each opportunity, excluding dead or departed targets.
- **FR-006 — Health**: Player and enemies MUST start at their positive configured maximum health, with independent current health. Damage MUST subtract its amount, bounded at zero. No regeneration is provided.
  - **Acceptance**: Fresh player and enemies have full health. Damage to one enemy leaves other enemies unchanged. Nonlethal and excessive damage reduce health correctly without negative values. Waiting without damage does not restore health.
- **FR-007 — Enemy Death**: At zero health, an enemy MUST die and be removed from the encounter, unable to move, be targeted, receive damage, or damage the player.
  - **Acceptance**: Lethal weapon damage removes the enemy by the next gameplay update. At a later attack opportunity and at its former position, it is neither a target nor a damage source.
- **FR-008 — Player Damage**: Living enemies MUST deal configured positive contact damage immediately on first contact and subsequently at a positive per-enemy contact-attack interval. Leaving contact MUST stop damage; re-entry MUST NOT bypass a remaining delay.
  - **Acceptance**: First contact reduces health by the configured amount. Sustained contact produces further damage at the configured interval. Separation causes no contact damage. Re-entry before readiness causes no early damage. Two contacting enemies contribute their own eligible attacks.
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
- All constitutional architectural, validation, documentation, and workspace constraints remain binding for subsequent phases; this specification selects no technical solution.

### Key Entities *(include if feature involves data)*

- **Player**: Single controlled survivor with position, maximum/current health, and one weapon.
- **Enemy**: Instance of the sole type with position, maximum/current health, spawn order, and contact-attack readiness.
- **Weapon**: Automatic attack capability with range, damage, interval, and readiness.
- **Arena**: Flat playable area with visible containment boundaries and placeholder visuals.
- **Run**: Survival attempt with Active, Paused, or Game Over state, elapsed active time, and current encounter.
- **Gameplay Tuning**: Valid starting health, movement speeds, spawn interval, weapon range/damage/interval, and enemy contact damage/interval used consistently for a run.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All FR-001–FR-012 acceptance criteria and listed edge cases have recorded verification results; any unverified criterion prevents a claim of feature completion.
- **SC-002**: A reviewer completes three consecutive run → defeat → restart cycles in one application session; each restart restores fresh-run conditions without duplicate events.
- **SC-003**: Ten seconds paused during combat produce zero health, position, view, or survival-time changes and zero spawns/attacks; resume preserves remaining delays.
- **SC-004**: In an integrated playtest, the product owner demonstrates all movement directions, rotates the view, identifies health/time and boundaries, witnesses an automatic kill, takes damage, pauses/resumes, and restarts after defeat using documented controls without developer intervention.
- **SC-005**: Target 60 FPS with 200 simultaneously active enemies exercising representative pursuit, combat, and damage on the constitution's reference hardware. Before verification, planning MUST specify resolution, renderer, graphics settings, build mode, scenario, warm-up, sampling duration, and frame-time statistics. Evidence MUST record those conditions, enemy count, FPS, frame-time distribution, stalls, and bottlenecks against the approximately 16.67 ms frame budget. Average FPS alone is insufficient. Target revisions require constitutional governance and product-owner approval.

## Assumptions

- Keyboard and mouse are the required controls. Jump, sprint, manual aiming/firing, and controller support are outside this milestone.
- A fresh run begins directly in the arena with no enemies and a ready weapon. Survival continues until death with no victory condition or fixed duration.
- Direct weapon damage and enemy contact damage suffice. Projectiles, ammunition, reloads, critical hits, and damage-over-time effects are not required.
- Horizontal mouse movement rotates the view in the same direction; upward movement looks upward. Sensitivity, view limits, arena dimensions, and positive tuning values are selected and documented during planning. A player-facing settings screen is not required.
- Target distance is measured between player and enemy positions on the flat floor. Earliest spawn order is a stable tie-breaker.
- Restart uses a clearly labeled selectable Game Over control. Restart from Pause is not required. Escape only pauses/resumes a living run.
- The arena has no interior obstacles preventing pursuit. Placeholder geometry must not create unreachable encounter areas.
- No existing gameplay or external service is required. The approved constitution and subsequent plan supply development/verification constraints. All described gameplay is planned behavior.
