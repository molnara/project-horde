# Asset provenance

Phase 1 contains only an empty `Node3D` bootstrap in `scenes/main.tscn`.
There are no imported meshes, textures, fonts, audio, or third-party assets.
The following original placeholder design is approved for later gameplay tasks;
it does not claim those visuals are implemented.

| Planned visual | Source and ownership | Intended appearance |
|---|---|---|
| Player | Godot built-in primitive mesh and project-authored material | Cyan; radius 0.4 m, height 1.6 m |
| Sole enemy type | Godot built-in primitive mesh and project-authored material | Orange-red; radius 0.4 m, height 1.2 m |
| Arena floor | Godot built-in primitive mesh and project-authored material | Muted floor contrasting with both actors; flat 40 × 40 m |
| Arena limits | Godot built-in primitive meshes and project-authored material | Contrasting low boundary strips, 0.15 m high |
| Attack feedback | Project-authored simple line geometry and material change | Short line to the affected target and hit flash |

These placeholders require no external source files or asset licenses. Godot's
built-in facilities are provided by the engine under its MIT license; see the
[Godot license](https://godotengine.org/license/). No copied creative content from
Megabonk or third-party artwork is used or planned for this slice.

Actor visuals will live in their reusable scene subtrees; arena geometry will
live in the arena scene. Meshes/materials can be replaced without changing the
movement, containment, health, targeting or damage interfaces. Visual dimensions
and colors must continue to meet the approved definition and visibility contracts.
Feedback presents actual combat events and never applies damage itself.

Reconcile this ledger with actual sources when those scenes are implemented
(T050). Any future third-party asset requires recorded source, author, compatible
license and use; production art remains outside this prototype.
