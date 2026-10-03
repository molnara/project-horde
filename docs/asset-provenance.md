# Asset provenance

Phase 3B implements the following original placeholders. No imported meshes,
textures, custom fonts, audio or third-party artwork are included. The HUD uses
Godot's built-in default font. Colors and geometry are authored in this project.

| Implemented visual | Source and ownership | Appearance |
|---|---|---|
| Player | Built-in CylinderMesh in `scenes/player.tscn`, configured by `scripts/actors/player.gd`; project material | Cyan; default radius 0.4 m, height 1.6 m |
| Sole enemy type | Built-in CylinderMesh in `scenes/enemy.tscn`, configured by `scripts/actors/enemy.gd`; private project material per instance | Orange-red; default radius 0.4 m, height 1.2 m |
| Arena floor | Built-in PlaneMesh in `scenes/arena.tscn`, configured by `scripts/arena/arena.gd` | Muted contrasting flat floor; default 40 × 40 m |
| Arena limits | Four built-in BoxMesh strips in the arena scene | Contrasting low limits; default 0.15 m high |
| Attack feedback | Built-in thin CylinderMesh named `Line` and private target material changes in `scripts/combat/attack_feedback.gd` | Yellow line and white hit flash until absolute expiry |
| Lighting/background | One shadow-free DirectionalLight3D and flat-color Environment in `scenes/main.tscn` | Original neutral lighting and dark background |
| HUD | Label controls using the engine's bundled default font in `scenes/hud.tscn` | White health/time with shadow; orange configuration diagnostics |

The primitive placeholders require no external source files. Godot's built-in
facilities use its [MIT license](https://godotengine.org/license/). The engine's
bundled font assets have their own licenses: upstream records Noto Sans
(Google, 2012) under SIL OFL 1.1 in its
[copyright inventory](https://github.com/godotengine/godot/blob/master/COPYRIGHT.txt#L276).
The HUD inherits the engine default font without importing or redistributing a
separate font file. Keep the engine's bundled notices when distributing it.
No copied creative content from
Megabonk or third-party artwork is used or planned for this slice.

Actor visuals live under `Visual` in their reusable scenes; arena geometry lives
in the arena scene. Meshes/materials can be replaced without changing the
movement, containment, health, targeting or damage interfaces. Visual dimensions
and colors must continue to meet the approved definition and visibility contracts.
Feedback presents actual combat events and never applies damage itself.

Final cross-feature reconciliation remains T050. Any future third-party asset requires recorded source, author, compatible
license and use; production art remains outside this prototype.
