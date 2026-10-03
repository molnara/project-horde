# Player Interface Contract

**Status**: Planned player-visible behavior; manual acceptance required after implementation.

## Controls

| Input | Active | Paused | GameOver |
|---|---|---|---|
| WASD | Camera-yaw-relative planar movement; constant directional speed; opposing axes cancel; release stops | No movement | No movement |
| Mouse horizontal | Rotate view same direction | No rotation | No rotation |
| Mouse upward/downward | Look upward/downward within 15–65° depression | No rotation | No rotation |
| Escape, discrete press | Pause | Resume preserved encounter | No resume |
| Restart button, mouse/keyboard activation | Not offered | Not offered | One fresh run |

Capture mouse on Active; release in Paused/GameOver. Ignore keyboard echo so holding Escape does not repeatedly toggle. Clear queued mouse motion at transitions so inactive movement does not jump the resumed view. Restart button is clearly labeled, focusable and initially focused on GameOver; Enter/Space or mouse click can activate it. No manual fire, jump, sprint, settings screen or controller support.

## View and scene

Camera tracks player without smoothing; yaw rotates continuously, pitch bounds prevent inversion/floor crossing. Defaults: 8 m offset, target height 1.2 m, initial depression 35°, yaw 0°, sensitivity 0.12° per screen pixel, FOV 70°. Camera orientation never adds vertical player motion. Player remains visible during traversal/perimeter checks.

Arena is one flat 40×40 m plane, with low visible boundary strips; cyan player, orange/red enemies, muted contrasting floor. All entity centers respect radius-inset limits while actors freely overlap. No interior obstacle, tall wall or ceiling may occlude normal view or block pursuit. Meshes/materials are original built-in primitives with provenance recorded in `docs/asset-provenance.md` during implementation.

Automatic attacks show a short visible line to the affected enemy and its hit flash; feedback is at the actual attack opportunity and deals no extra damage. Dead enemies disappear by the next gameplay update. Later visual replacement must preserve combat interfaces.

## HUD and overlays

- HUD always visible: `Health: current / maximum` and active survival time `MM:SS` (minutes may exceed two digits). Fresh values are `100 / 100`, `00:00`. Display floor(active_time) seconds, no paused/defeated elapsed time.
- Paused overlay says `Paused` and `Escape to resume`; health/time remain readable. View, encounter, damage, clock and delays freeze.
- GameOver overlay says `Game Over`, shows final survival time and actionable `Restart`. Zero health remains on HUD. Escape cannot resume; freeze persists until restart.
- Restart restores initial health/view/position, time zero, no enemies and fresh event timing in the same application. Five minutes triggers no victory/ending; active play continues until defeat.
- Configuration failure shows the resource/field diagnostic; it must not look like a valid active encounter.
- Configuration recovery requires correcting the definition and relaunching; no in-application retry control is required. The HUD survival clock measures completed, unpaused physics simulation time, not wall-clock time lost in stalls.

Verify from normal 1920×1080 view: player/enemies/limits recognizable, HUD readable, affected enemy identifiable, and every overlay/button usable. Headless tests do not establish these outcomes.
