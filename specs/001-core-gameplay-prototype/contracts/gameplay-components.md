# Gameplay Component Contracts

**Status**: Planned internal interfaces for implementation and tests; no callable game API currently exists.

Types/defaults are defined in [data-model.md](../data-model.md). Main owns explicit wiring. Components may access their own scene internals, never unrelated root paths. No autoload, network or external service.

## Component boundaries

| Component | Inputs / methods | Outputs / ownership |
|---|---|---|
| Definition validation | `validate(run_definition) -> Array[String]` | Empty means valid; otherwise actionable resource/field diagnostics; no mutation |
| Run coordinator | `start_run(definition)`, `step(delta)`, `toggle_pause()`, `request_restart()` | Owns state/time/order/registry; emits `state_changed(state)`, `time_changed(active_time)` |
| Arena | `clamp_position(position, radius) -> Vector3`, `choose_spawn(player_position, enemy_radius, contact_distance, rng) -> Vector3` | Inset containment and strictly noncontact spawn; no damage side effects |
| Player movement | `step(delta, input_vector, camera_yaw, arena)` | Normalized planar motion; input release stops immediately; zero changes when run inactive |
| Camera rig | `reset(definition, player)`, `apply_mouse(screen_motion)`, `follow(player_position)`, `clear_pending_input()` | Yaw/depression and bounded view; active-only mouse motion; injected player ref |
| Enemy movement | `step(delta, player_position, arena)` | Direct bounded pursuit of current position; stop at coincident position; no physical blocking |
| Health component | `apply_damage(amount) -> int`, `is_alive() -> bool` | Returns applied damage; clamps zero; emits `health_changed(current, maximum)` and `died()` once; invalid amount diagnostic |
| Live registry | `add(enemy, spawn_id)`, `remove(enemy)`, `living_in_spawn_order()` | Explicit membership; no group/tree traversal; unique IDs; dead instances removed before deferred deletion |
| Automatic weapon | `step(active_time, player_position, living_enemies)` | Reassesses nearest eligible target; emits `attacked(spawn_id, amount)` after actual hit; owns only its cooldown/feedback |
| Enemy contact attack | `step_contact(active_time, player_position, player_health)` | Own deadline persists across separation; deals one ready contact attack; coordinator aborts later contacts on lethal result |
| HUD | `present_health`, `present_time`, `present_state` | Presents values; emits `restart_requested()`; never modifies encounter itself |

Signatures are semantic contracts: GDScript types follow the model. Use synchronous health/death signals so eligibility changes immediately. UI listeners update by the next gameplay update. Feedback identifies attacker/target with a 0.12-active-second line and target color flash; pause freezes feedback and defeat clears it without applying damage.

## Ordered active update

1. Handle state intents once per input press. A pause intent prevents gameplay work in that update.
2. If Active, derive this step's scheduling time from the prior completed active time plus physics delta (60 Hz baseline). Commit that duration only when this active step completes, including a step that deliberately short-circuits on defeat. Do not derive delta or survival credit from stalled wall time.
3. Apply player motion and enemy pursuit, using current player position and arena containment.
4. Consume any due spawn opportunity, at most one spawn, only with capacity and valid position.
5. Reassess weapon targets from living registry. Apply one ready attack; immediately remove a lethal target before contacts.
6. Visit living enemies in spawn order for contact attacks. On lethal player damage, latch GameOver once, freeze time, and immediately stop all remaining gameplay work.
7. Commit completed-step survival time and present current state/health/time, including the final time after lethal damage. Inactive runs may update overlay intent but no gameplay, camera, feedback clock or deadline.

Events earlier in a lethal update may already have happened; once zero player health occurs nothing later changes the final result. Tests must include an enemy killed before its contact step, two simultaneous contacts, and skipped later contact after lethal damage.

## Timing and restart guarantees

- Fresh weapon and fresh enemies are ready; first spawn waits one full interval. Ready attackers act by the next gameplay update after eligibility appears.
- No-target weapon stays ready; attacks never occur early. Contact absence/re-entry does not alter the enemy deadline.
- Fixed-cadence spawn handling consumes cap-full or missed stall opportunities; no backlog, burst loop or immediate refill after death. Cadence is accurate to one physics update under normal conditions.
- Restart is valid only in GameOver. Guard immediately before rebuilding, disconnect old callbacks and dispose the old encounter. Use run generation to reject any delayed old-run callback if such a callback is introduced; prefer no delayed gameplay callbacks.
- New run: IDs reset, empty registry, full health, initial camera/player state, zero time, full spawn delay and ready weapon. Repeated restart intents cannot create two encounters.

## Failure contract

Reject invalid definitions before any run simulation, report exact path/field/constraint, display a visible startup/restart error and produce nonzero automated-check results. Do not substitute values silently. Discard a failed restart's old encounter and keep simulation disabled; correcting definitions and relaunching is sufficient recovery. No in-application configuration retry is required.

Unexpected spawn-selection or instantiation failure consumes that scheduled opportunity, emits actionable diagnostics and increments the coordinator's per-run spawn-failure counter. Continue simulation with the next ordinary scheduled opportunity, without retries, backlog or catch-up. Keep failed/partial instances out of the registry and clean them up. A full-cap skip is expected and is not a failure. Any unexpected spawn failure latches invalid acceptance for that attempt, even if play continues; record its counter and failure diagnostics in verification/profile evidence. Fault-injection tests may pass by asserting this error policy, but the intentionally faulted run never qualifies as a successful owner acceptance attempt. Check engine diagnostics as well as process exit status. No gameplay failure becomes an acceptance pass.
