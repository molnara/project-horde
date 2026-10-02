# Implementation Plan: Core Gameplay Prototype

**Branch**: `001-core-gameplay-prototype` | **Date**: 2026-10-02 | **Spec**: [spec.md](spec.md)

**Input**: `specs/001-core-gameplay-prototype/spec.md`, including its five clarification decisions.

**Status**: Phase 0 research and Phase 1 design complete. Gameplay, tooling, tests, and measurements below are planned, not implemented or executed. Task generation follows separately.

## Summary

Build one directly playable flat arena in Godot 4.7.2 Standard Edition using typed GDScript, original primitive meshes, and text scenes/resources. A run coordinator composes player, camera, arena, spawner, automatic weapon, enemy registry, and HUD. One active-time clock provides deterministic spawn, weapon, and independent enemy-contact timing. Entities move on XZ without blocking one another; containment remains separate from combat. Immutable definitions provide tuning; each entity owns its mutable health and deadlines.

Deliver the P1 movement/camera/spawn/combat/HUD loop first, then defeat/restart and pause/resume, followed by complete acceptance evidence and the actual five-minute survival profile. No save system, progression, additional content, third-party plugins, production assets, or benchmark harness is included.

## Technical Context

**Language/Version**: Typed GDScript; Godot 4.7.2 Standard Edition, no C#.

**Primary Dependencies**: Godot built-ins only: Node3D, Camera3D, MeshInstance3D, Resource, CanvasLayer/Control, signals, InputMap, SceneTree, FileAccess, and built-in monitors/profiler. PowerShell for workspace-contained validation. No package or extension required.

**Storage**: Diffable `.gd`, `.tscn`, `.tres`, `project.godot`; read-only definitions; memory-only run state. Generated validation/profile output in ignored `.cache/`; summarized evidence and provenance in `docs/`.

**Testing**: Native headless GDScript assertion runner with nonzero failure exit; engine import, per-script parse and scene startup; manual controls/visual/playfeel acceptance; real rendered five-minute profiling. Environment recheck on 2026-10-02 verified persistent user-scope `GODOT_BIN` resolves to an existing Windows console executable (PE subsystem 3). Executing that binary with `--headless --version` returned `4.7.2.stable.official.ed1daf0bf`, exit 0, matching the approved engine version. The current process has not inherited the variable; use process scope first, then persistent user/machine scope when absent. Sandbox registry access may hide persistent scope; report that limitation explicitly. No Godot project exists yet, so project import, parsing, tests and startup remain unrun. No installation is needed or authorized by this plan.

**Target Platform**: Windows 10 IoT Enterprise LTSC 2021, keyboard/mouse; reference i7-12700KF, 32 GB RAM, RTX 3080 10 GB VRAM. Supplied hardware/OS reference, not locally verified.

**Project Type**: Offline single-player third-person 3D desktop game.

**Performance Goals**: SC-007 records actual five-minute playtest performance without a numerical prototype pass threshold. SC-005 remains 60 FPS with 200 representative active enemies, approximately 16.67 ms/frame; future benchmark, explicitly unverified, not a prototype acceptance gate.

**Constraints**: One weapon/type/flat arena; original placeholders; independent definitions/state; inclusive XZ eligibility; spawn-order ties; no entity blocking; workspace-contained writes; no gameplay implementation during planning.

**Scale/Scope**: One player; zero initial enemies; configurable live cap default 50 with no hard-coded upper limit preventing future 200-enemy testing; fixed spawning; unlimited survival until death; three run states with HUD overlays.

**Resolved research topics**: Active clock/order, cooldown persistence, cap scheduling, safe spawning, containment, camera conventions, tuning validation, test harness, workspace-safe launch and profile protocol. Decisions are in [research.md](research.md); defaults in [data-model.md](data-model.md). No unresolved design clarifications. Engine location and version are verified; project/tooling implementation and filesystem confinement for project/editor execution remain validation prerequisites.

## Constitution Check

Pre-research review used spec and constitution v1.0.0; post-design review uses these artifacts. PASS means design compliance, not gameplay acceptance.

| Principle | Pre-research | Post-design evidence/result |
|---|---|---|
| I Modular Architecture | PASS | PASS: explicit coordinator wiring, narrow component methods/signals, no global singleton or unrelated tree searches |
| II Data-Driven Gameplay | PASS | PASS: validated Resource definitions; separate instance health and deadlines |
| III Reusable Scenes/Resources | PASS | PASS: composable player/enemy/camera/HUD; one maintained enemy behavior; read-only definitions |
| IV Horde Performance | PASS | PASS: bounded O(N) targeting/contact, actual profile protocol, future target preserved; no unmeasured pooling |
| V Automated Validation | PASS | PASS: import/parse/tests/startup plus manual controls and profile; runtime checks currently unrun |
| VI Explicit Acceptance | PASS | PASS: existing FR/SC mapped to boundary fixtures and reproducible manual checks |
| VII Playable Vertical Slices | PASS | PASS: integrated P1 before dependent P2; foundations limited to slice |
| VIII Placeholder Assets First | PASS | PASS: original primitives and simple feedback; provenance ledger required |
| IX Necessary Complexity | PASS | PASS: built-ins/native runner; no plugin, service, navigation mesh, projectile/crowd framework |
| X Version-Control-Friendly Content | PASS | PASS: text assets, required UID files tracked, generated cache/raw output excluded |
| XI Accurate Documentation | PASS | PASS: planned files/commands explicitly labeled; implementation updates evidence/provenance |
| XII Honest Reporting | PASS | PASS: passed/failed/skipped/blocked/unrun outcomes; diagnostics inspected with exit codes |
| XIII Workspace Boundaries | PASS | PASS: process path isolation and actual-path verification before engine/editor use |
| XIV Original Creative Identity | PASS | PASS: original geometry/colors, no copied distinctive content |

No violations or constitutional exceptions proposed. Spec's future-benchmark distinction preserves the target without establishing compliance.

## Project Structure

### Documentation (this feature)

```text
specs/001-core-gameplay-prototype/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── gameplay-components.md
│   └── player-interface.md
├── checklists/requirements.md
└── tasks.md                  # next phase; not generated by this command
```

### Source Code (repository root)

Proposed paths; no gameplay scaffolding created during planning.

```text
project.godot
scenes/
├── main.tscn
├── arena.tscn
├── player.tscn
├── enemy.tscn
├── camera_rig.tscn
└── hud.tscn
scripts/
├── run/                      # coordinator, schedule, live registry
├── actors/                   # player input/movement, enemy pursuit
├── combat/                   # health, automatic weapon
├── arena/                    # containment, valid spawning
├── camera/                   # yaw/pitch, following
├── ui/                       # HUD and overlay intent
└── data/                     # definition classes, validation
resources/definitions/        # player, enemy, weapon, arena, run .tres
tests/
├── run_tests.gd
├── unit/
└── integration/
tools/validate.ps1            # engine/path checks and validation modes
docs/
├── asset-provenance.md
└── verification/
    ├── core-gameplay.md
    └── prototype-profile.md
.cache/                      # ignored paths/logs/raw profile data
```

**Structure Decision**: One root Godot project; reusable scenes and explicit responsibility boundaries. Preserve `.specify/`, `.agents/`, spec and checklist. Contracts describe game/UI boundaries, not a network service.

## Phase 0 — Research outcome

[research.md](research.md) records official documentation, decisions, alternatives and environmental limits. One coordinator-driven 60 Hz physics update and active-time deadlines replace independent timers. Node3D planar movement plus an arena containment function meets this obstacle-free nonblocking slice. No pooling/spatial partitioning before measured need.

## Phase 1 — Design outcome

- [data-model.md](data-model.md): exact default tuning, definitions, validation, ownership and transitions.
- [contracts/gameplay-components.md](contracts/gameplay-components.md): dependency injection, ordering, events and failure behavior.
- [contracts/player-interface.md](contracts/player-interface.md): controls, camera, HUD and overlays.
- [quickstart.md](quickstart.md): future runnable validation modes, acceptance mapping, manual scenarios and profiling.

### Delivery order for task generation

1. Minimal project, validated resources, original primitive scenes and safe validation launcher; prove import/parse/startup.
2. Runnable P1: movement/camera/containment, spawning/pursuit, health/weapon/contact, HUD. Test exact tuning/distance/timing boundaries with small fixtures.
3. P2 defeat/restart: lethal short-circuit, immediate registry removal, fresh conditions and repeat activation guard.
4. P2 pause/resume: preserve clock/deadlines/view, reject echoed input, manage mouse capture.
5. Verify all FR/edge cases, three restart cycles, owner playtest and five uninterrupted active minutes; profile that actual run. Unavailable checks remain outstanding.

### Measurement conditions fixed before profiling

SC-007 uses reference Windows/hardware above; record actual OS/GPU/driver/engine and deviations. Standalone debug game without editor/debugger, Forward+ renderer, 1920×1080 content resolution, 100% 3D scale, MSAA/FXAA/TAA off, VSync off, uncapped FPS, one directional light, shadows/SSAO/SSIL/glow off. Physics 60 Hz. Record resource values and source revision.

Warm up for 30 active seconds in a separate attempt, then begin a clean fresh run. Sample the actual SC-006 run from active time zero through 300 seconds, including normal startup effects. No pause during that attempt; continue beyond five minutes to prove no timed ending. Failed attempts are retained, never spliced into success.

Capture rendered-frame monotonic wall-time intervals and enemy counts. Summarize frames / sampled active duration for average FPS; 1000 / maximum frame interval in milliseconds for minimum instantaneous FPS; p50/p95/p99/max frame times, >16.67 ms and >33.33 ms frame counts; one-second enemy-count min/max/mean and observed stalls. Initialize/reset the sampling origin at run start/resume to exclude paused intervals. Physics delta/smoothed FPS alone cannot establish distributions.

Label frame-loop samples as CPU-observed timing, not GPU measurements. Capture built-in CPU/physics/render monitors where available; diagnose bottlenecks with a separate built-in-profiler run if needed and report overhead/missing GPU metrics. Buffer samples, write raw data inside ignored `.cache/`, summarize in `docs/verification/prototype-profile.md`. No new numerical acceptance threshold. Future SC-005 needs its own 200-enemy scenario/build/settings/warm-up/sampling plan; no benchmark implementation or result here.

## Complexity Tracking

None. No violations or added dependencies requiring justification.
