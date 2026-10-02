# Project Horde Constitution

## Core Principles

All fourteen principles are non-negotiable. MUST and MUST NOT express requirements.

### I. Modular Architecture

Systems MUST have clear responsibilities and explicit interfaces. Dependencies MUST remain
loosely coupled through composition, Godot signals, or narrow interfaces. Systems MUST NOT
rely on unrelated scene-tree internals or uncontrolled global state. Changes MUST remain
localized where practical to support maintenance and independent validation.

### II. Data-Driven Gameplay

Weapons, enemies, upgrades, and progression MUST separate configurable definitions from runtime
behavior. Godot Resources or other validated, versioned data MUST hold tuning and content
values. Variants supported by existing behavior MUST NOT require duplicated implementation.
Invalid or missing definitions MUST produce actionable diagnostics.

### III. Reusable Scenes and Resources

Reusable entities and components MUST use composable Godot scenes and resources with explicit
configuration and ownership. Shared behavior MUST have a single maintained source where
practical. Mutable per-instance state MUST NOT accidentally modify shared resource data.

### IV. Horde Performance

Implementations MUST consider CPU, GPU, memory, physics, and allocation costs under large enemy
counts. Representative stress scenarios MUST be profiled before claiming performance compliance.
Expensive per-enemy work MUST be bounded or scheduled when profiling demonstrates a need.
Pooling, batching, and other optimizations MUST address measured bottlenecks. Performance target
revisions MUST follow governance rather than silently lowering expectations.

### V. Automated Validation

Changes MUST include automated testing and headless Godot validation wherever practical,
proportionate to risk. Reliably automatable gameplay logic and data contracts MUST be tested.
Project loading, script parsing, and relevant scene startup MUST be validated headlessly when
supported. Visual behavior, controls, and game feel MUST have reproducible manual playtest steps.
Unavailable or impractical checks MUST have documented reasons and outstanding verification.
Headless checks alone MUST NOT establish visual or interactive acceptance.

### VI. Explicit Acceptance Criteria

Every implemented feature MUST have observable acceptance criteria before implementation begins.
Criteria MUST define relevant behavior, failure cases, and verification steps. Performance
criteria MUST specify measurement conditions. Completion MUST have evidence against those
criteria; unverified criteria MUST remain explicitly outstanding.

### VII. Playable Vertical Slices

Work MUST prioritize small, integrated, playable slices demonstrating end-to-end gameplay.
Each slice MUST be runnable and reviewable before dependent scope expands. Large unfinished
systems MUST NOT take priority over validating the current milestone. Foundations MUST be
limited to what the current slice requires.

### VIII. Placeholder Assets First

Gameplay systems MUST be validated using simple placeholder visuals and audio before production
asset work for those systems begins. Placeholders MUST be identified and legally usable.
Asset interfaces MUST permit later replacement without rewriting validated gameplay behavior.

### IX. Necessary Complexity Only

Implementations MUST use the simplest design meeting current acceptance criteria. New dependencies
or abstractions MUST have a documented present need, maintenance cost, and reason existing code
or built-in Godot facilities are insufficient. Speculative frameworks, unnecessary dependencies,
premature abstractions, and excessive complexity MUST NOT be introduced.

### X. Version-Control-Friendly Content

Code, configuration, scenes, and resources MUST use diffable text formats where practical.
Source assets and necessary Godot identifiers MUST be tracked. Generated caches, import output,
temporary files, secrets, and machine-specific state MUST be excluded. Necessary binary assets
MUST have a storage approach appropriate to their size. Changes MUST avoid unrelated formatting
churn and preserve reproducible project imports from a clean checkout.

### XI. Accurate Technical Documentation

Documentation MUST reflect implemented behavior and be updated with relevant changes. Setup,
architecture boundaries, data formats, validation commands, profiling procedures, and known
limitations MUST be documented when introduced or changed. Planned behavior MUST be distinguished
from working behavior. Essential instructions MUST be reproducible without conversation history.

### XII. Honest Error and Test Reporting

Errors MUST NOT be silently ignored or converted into success. Expected failures MUST be handled
explicitly; unexpected failures MUST expose actionable diagnostics. Reports MUST identify the
commands actually executed and their outcomes, distinguishing passed, failed, skipped, blocked,
and unrun checks. Codex MUST NOT claim tests passed, gameplay was playtested, or performance was
achieved without executing the corresponding verification.

### XIII. Workspace Boundaries

Codex MUST NOT create, modify, move, or delete files outside the project workspace without explicit
product-owner approval. This includes global configuration, installations, and external caches
or temporary output affected by commands. Commands MUST keep writes inside the workspace where
practical; otherwise approval MUST precede execution. Existing user changes MUST be preserved
unless their modification is authorized by the task.

### XIV. Original Creative Identity

Megabonk MUST be used only as inspiration for broad genre and gameplay mechanics. Project Horde
MUST create original characters, artwork, branding, environments, narrative, and other creative
assets. Distinctive creative content from Megabonk MUST NOT be copied or imported. Third-party
assets, including placeholders, MUST have compatible licenses and recorded provenance.

## Project Constraints and Performance Target

Project Horde is a single-player, third-person 3D roguelite survival game. The development baseline
is Godot 4.7.2 Standard Edition with GDScript; C# is outside the approved stack. This baseline
records the product owner's environment and does not claim installation verification.

The reference environment is Windows 10 IoT Enterprise LTSC 2021 on an Intel i7-12700KF,
32 GB RAM, and NVIDIA RTX 3080 with 10 GB VRAM. Git and GitHub Spec Kit support version control
and specification workflows. OpenAI Codex CLI is the primary implementation agent. Engine or
stack changes MUST be documented and approved through governance.

The initial performance target is 60 FPS with 200 simultaneously active enemies on the reference
hardware, subject to profiling and product-owner-approved revision. Enemies MUST exercise
representative movement, combat, and damage behavior; disabled entities do not demonstrate
compliance. This is a target, not a claim of current performance.

Before a performance acceptance run, the plan MUST specify resolution, renderer, graphics
settings, build mode, scenario, warm-up, sampling duration, and frame-time statistics. Results
MUST record those conditions, enemy count, frame rate, frame-time distribution, and observed
bottlenecks. The 60 FPS frame budget is approximately 16.67 ms. Average FPS alone MUST NOT
conceal recorded stalls. Profiling evidence and reasons for revisions MUST be documented.

## Development Workflow and First Milestone

The product owner sets priorities, approves scope and governance changes, and playtests gameplay.
Codex is responsible for implementation, maintenance, technical testing, and technical
documentation. Codex MUST supply reproducible run instructions and playtest procedures.
Product-owner playtesting MUST NOT replace technical validation.

Work MUST progress through specifications with acceptance criteria, proportionate plans,
actionable tasks, implementation, and verification. Each review MUST check constitutional
compliance, scope, maintainability, validation evidence, and documentation. Failed required
checks MUST be fixed or reported as blocking completion. Reports MUST distinguish implemented
behavior, executed checks, known limitations, and outstanding playtesting.

The first milestone is a playable third-person 3D prototype containing movement, camera,
one automatic weapon, one enemy type, basic damage, and a small arena using placeholders.
Its specification MUST define concrete controls, camera behavior, automatic attack behavior,
enemy behavior, and damage outcomes before implementation. The slice MUST demonstrate movement,
camera control, automatic combat, and damage together in the arena. Additional weapons, enemy
rosters, upgrades, progression systems, and production art MUST remain outside this milestone
unless the product owner revises its scope.

This constitution records milestone direction only. Adoption MUST NOT initiate gameplay
implementation, project scaffolding, or creation of the full Godot project.

## Governance

This constitution governs specifications, plans, tasks, implementation, reviews, and agent
instructions. Conflicts MUST be surfaced to the product owner. Agents MUST NOT silently waive
principles or redefine acceptance to make incomplete work appear compliant.

Amendments MUST identify the change, rationale, affected artifacts, and migration or follow-up
work. The product owner MUST approve amendments before adoption. The constitution MUST record
the new version and amendment date while preserving the original ratification date. Downstream
artifacts MUST be reviewed for consistency in an appropriately scoped follow-up task.

Versions use semantic versioning: MAJOR for incompatible principle removals or redefinitions;
MINOR for new principles, sections, or materially expanded guidance; PATCH for clarifications
and corrections that do not change obligations. Initial adoption is 1.0.0. Performance target
revisions MUST record evidence, approval, and a version change matching their governance effect.

Every feature and change review MUST verify applicable principles and record unresolved gaps.
A gap MUST NOT be treated as an implicit exception. The temporary Sync Impact Report above
MUST be removed before committing the adopted document; removing review material does not
change governance or require a version increment.

**Version**: 1.0.0 | **Ratified**: 2026-10-02 | **Last Amended**: 2026-10-02
