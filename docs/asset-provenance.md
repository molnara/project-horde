# Asset provenance

**Reconciled:** 2026-10-03, Phase 6 Batch 1 (T050), against all production
`project.godot`, `scenes/`, `scripts/` and `resources/` sources at baseline
`f9d9273031c03d8775ff8c5b68c170305a3c9380`. This is a source/provenance audit,
not new visual acceptance. No artwork, executable asset or production file
was changed or removed.

## Production inventory and usage

Geometry and project color/layout choices below are original Project Horde
placeholders authored in checked-in scripts/scenes. Scenes contain mesh nodes
and materials; **meshes are constructed at runtime**, not mesh subresources.
Production has no imported model, texture, custom font or audio files/references,
custom shaders, audio playback nodes or procedural audio generator. The automatic
weapon has no separate model/projectile: it presents the line and target flash.

| Asset / usage | Actual source and construction | Appearance / default dimensions |
|---|---|---|
| Player mesh | `scenes/player.tscn` supplies Visual; `scripts/actors/player.gd:configure()` assigns a new Godot CylinderMesh from `resources/definitions/player.tres` | Radius 0.4 m, height 1.6 m; Visual center Y = height / 2 relative to actor |
| Player material | StandardMaterial3D subresource cyan in `scenes/player.tscn`, used by Visual.material_override | Albedo RGBA (0.05, 0.85, 0.95, 1), roughness 0.8 |
| Sole enemy mesh | `scenes/enemy.tscn` supplies Visual; `scripts/actors/enemy.gd:configure()` creates a new CylinderMesh from `resources/definitions/enemy.tres` | Radius 0.4 m, height 1.2 m; center Y = height / 2 |
| Enemy material / flash | StandardMaterial3D subresource orange in `scenes/enemy.tscn`; enemy.gd duplicates it per instance. `scripts/combat/attack_feedback.gd` saves/restores albedo and flashes the actual target white | Normal RGBA (0.95, 0.22, 0.06, 1), roughness 0.8; white (1, 1, 1, 1) |
| Arena floor mesh | `scenes/arena.tscn` supplies Floor; `scripts/arena/arena.gd:configure()` creates a PlaneMesh from `resources/definitions/arena.tres` | 40 × 40 m; floor Y = 0.0 |
| Floor material | StandardMaterial3D subresource floor in `scenes/arena.tscn`, assigned to Floor.material_override | RGBA (0.15, 0.2, 0.25, 1), roughness 1.0 |
| Four arena limit meshes | North/South/East/West in `scenes/arena.tscn`; arena.gd creates four separate BoxMesh objects | North/South size (40, 0.15, 0.12) m at Z = ±20; East/West size (0.12, 0.15, 40) m at X = ±20; center Y = 0.075 |
| Limit material | Shared StandardMaterial3D subresource limits in `scenes/arena.tscn`, used by all four strips | RGBA (0.75, 0.8, 0.55, 1); other properties inherit engine defaults |
| Attack line mesh | `scripts/combat/attack_feedback.gd` creates MeshInstance3D child Line; each actual hit assigns a CylinderMesh, oriented between player + (0, 0.8, 0) and target + (0, 0.6, 0) | Radius 0.035 m; height = max(endpoint distance, 0.001 m); midpoint position; line shadows off |
| Attack line material | attack_feedback.gd:_init() creates a private StandardMaterial3D assigned to Line.material_override | Unshaded yellow RGBA (1, 0.95, 0.4, 1); line/flash expires at attack completion + 0.12 active s from weapon.tres |
| Lighting / background | `scenes/main.tscn`: DirectionalLight3D and WorldEnvironment with Environment subresource environment | Light rotation (−60, −30, 0)°, energy 1, shadows off; background RGBA (0.09, 0.12, 0.17, 1); ambient RGB (0.7, 0.8, 1), energy 0.6; no sky/environment texture |
| HUD text / controls | `scenes/hud.tscn`, `scripts/ui/hud.gd`: health/time/status/configuration labels, Game Over/final time/Restart, Paused/Escape to resume | Project text/layout; ordinary labels/button 32 px, titles 48 px, configuration error 28 px; health/time black shadow offset (2, 2); error RGBA (1, 0.6, 0.4, 1) |
| Overlay rectangles / button style | Two ColorRect nodes in `scenes/hud.tscn`; Restart inherits engine theme styles with project sizing/text/font-size overrides | Both fills RGBA (0.02, 0.03, 0.05, 0.75); no panel/button image or custom theme resource |
| Runtime font | All HUD Labels/Restart Button inherit engine default theme; no project font/theme/font-data override | Approved official engine upstream uses embedded **Open Sans SemiBold**, attribution below |
| Audio | None in production files or runtime construction | Silent prototype; no music/sound effects/source to attribute |

`scenes/camera_rig.tscn` has transforms/Camera3D only. Definition resources
hold values/script references, not external creative assets. Four scene material
sources plus the feedback-created material are the complete authored material
inventory; enemy private copies derive from orange. Engine primitive generation
and inherited theme facilities are functionality, not imported third-party artwork.

## Third-party source and attribution

The approved baseline is official Standard `4.7.2.stable.official.ed1daf0bf`.
Attribution was checked against upstream at **that revision**, not moving master:

| Unavoidable item | Verified source / attribution | License and usage |
|---|---|---|
| Godot primitive/material/theme facilities | Godot Engine contributors (2014–present); Juan Linietsky and Ariel Manzur (2007–2014), in the [revision inventory](https://github.com/godotengine/godot/blob/ed1daf0bf/COPYRIGHT.txt) | MIT / Expat; runtime generation/default styling. See [Godot license](https://godotengine.org/license/) |
| Embedded runtime font | [Default theme source](https://github.com/godotengine/godot/blob/ed1daf0bf/scene/theme/default_theme.cpp) selects _font_OpenSans_SemiBold; [font inventory](https://github.com/godotengine/godot/blob/ed1daf0bf/COPYRIGHT.txt#L275) attributes thirdparty/fonts/OpenSans*.woff2 to **2020, The Open Sans Project Authors** | **SIL Open Font License 1.1 (OFL-1.1)**, full text in that inventory; inherited HUD/button font, no separate font imported/modified here |

The previous Noto Sans attribution was incorrect for the runtime default. Its
presence in the engine inventory did not establish HUD use. Open Sans use follows
from production inheritance and the approved official revision's theme source;
this audit did not extract/fingerprint font bytes from the local executable.
A different/custom engine or theme requires a fresh check. Preserve applicable
engine/bundled third-party notices when distributing binaries. No distribution
or export was performed here.

No separate repository LICENSE establishes a public redistribution license for
Project Horde's authored colors/layout/placeholder configuration. Local project
source is known; a broader license grant or specific human authorship cannot be
inferred and is not invented. Engine MIT and font OFL do not establish the license
of Project Horde's original work.

## Actual visual replacement interface

Replacement is a presentation change with concrete coupling, not a drop-in
imported-art slot:

- Actor scenes require Visual to remain a MeshInstance3D for current configuration.
  configure() overwrites its mesh with a CylinderMesh each fresh run; setting a
  scene mesh alone will not survive startup. Later authorized replacement must
  adapt visual construction while preserving movement/health/spawn-ID interfaces
  and definition-driven dimensions.
- Enemy configure() duplicates Visual.material_override; feedback directly
  reads/writes albedo_color. Preserve a compatible private material and restoration
  or adapt that presentation seam later. Renaming/removing Visual or substituting
  an incompatible material breaks it.
- Arena configure() replaces Floor and all four named strip meshes/sizes/positions.
  Preserve those nodes or adapt construction. Mathematical inset containment/spawn
  eligibility remain in arena.gd; visuals must match bounds/floor.
- Feedback exposes configure(WeaponDefinition), show_attack(t_end, position, target),
  present(active_time), clear(). It observes combat events without damage authority.
  Preserve target identity, absolute expiry, pause freeze, defeat/restart clearing
  and private material restoration.
- HUD is presentation/intent only. Keep health/time/overlays/actionable Restart
  legible. Future font/theme changes require source/author/license records.
  Lighting/environment changes must preserve visibility and recorded profiling
  conditions or explicitly document deviations.

No replacement was attempted. Actor radius remains gameplay containment even if
a later mesh differs; artwork must not silently change combat/movement/tuning.
Production art remains outside this prototype.

## Audit outcome and unresolved boundaries

The audit enumerated tracked content and actual production files, followed all
scene/resource/script references and searched runtime mesh/material/texture/font/
shader/audio construction. No undocumented imported asset, distinctive copied
Megabonk content or other third-party artwork was found. No removal was required.
Runtime mesh locations, overlays/button styling, correct font attribution and
replacement constraints are now documented.

**T050 is complete for the present inventory.** Specific human authorship/public
licensing of original project content and direct binary font fingerprinting were
not established; their limits and the attribution basis are explicit above.
Historical profile **source-snapshot provenance** remains unresolved in the
gameplay ledger, separately from creative asset provenance. New assets or another
engine require a new inventory with actual source/author/compatible license/usage.
This audit establishes no integrated Phase 6 visual/owner acceptance or SC-005
performance claim.
