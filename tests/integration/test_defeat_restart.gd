extends RefCounted
## T034: executable US1 regression cases plus staged US2 acceptance cases.
## No restart substitute: every transition goes through the real coordinator/HUD.
const F = preload("res://tests/support/gameplay_fixture.gd")
const Faults = preload("res://tests/support/spawn_faults.gd")

func cases() -> Array[Dictionary]:
	return F.cases_for("defeat", ["lethal_commit", "freeze_escape", "final_hud", "game_over_control", "three_cycles", "guarded_requests", "stale_callbacks_removal", "invalid_restart", "failure_isolation"],
		["res://scripts/run/main.gd", "res://scripts/run/run_coordinator.gd", "res://scenes/main.tscn", "res://scenes/hud.tscn"])

func definition(ctx):
	var d = ctx.definitions()
	d.enemy.max_health = 1000
	d.enemy.movement_speed = 0.000001
	return d

func main_scene(ctx, d):
	var main = F.instance(ctx, "res://scenes/main.tscn", {"run_definition": d})
	manual_driver(ctx, main.coordinator)
	return main

func manual_driver(ctx, run) -> void:
	run.set_physics_process(false)
	if run.spawner != null:
		run.spawner.rng = ctx.rng

func population(run) -> int:
	return run.registry.living_in_spawn_order().size()

func add_contact(ctx, run, d):
	var enemy = F.enemy(ctx, d, run.next_spawn_id, run.player.position)
	# Production encounter ownership, rather than an independently owned root enemy.
	enemy.reparent(run.spawner)
	ctx.check(run.registry.add(enemy, run.next_spawn_id), "real registry accepts contact actor")
	run.next_spawn_id += 1
	return enemy

func defeat(ctx, run, d, delta: float = 0.125) -> void:
	add_contact(ctx, run, d)
	F.invoke(ctx, run.player.health, "apply_damage", [run.player.health.current_health - 1])
	F.invoke(ctx, run, "step", [delta])
	ctx.check(run.state == "GameOver" and run.player.health.current_health == 0, "real contact step defeats player")

func restart(ctx, main) -> bool:
	var run = main.coordinator
	ctx.check(run.has_method("request_restart"), "T038 supplies coordinator.request_restart()")
	if not run.has_method("request_restart"):
		return false
	run.call("request_restart")
	manual_driver(ctx, main.coordinator)
	return true

func runtime_snapshot(run) -> Dictionary:
	var enemies: Array = []
	for enemy in run.registry.living_in_spawn_order():
		enemies.append([enemy.get_instance_id(), enemy.position, enemy.health.current_health, enemy.next_contact_at])
	return {"state": run.state, "time": run.active_time, "ticks": run.completed_step_count,
		"position": run.player.position, "health": run.player.health.current_health,
		"camera": run.camera.transform, "yaw": run.camera.yaw, "depression": run.camera.depression,
		"ids": run.next_spawn_id, "spawn": [run.spawner.next_spawn_index, run.spawner.next_spawn_at],
		"attack": run.weapon.next_attack_at, "enemies": enemies,
		"failures": run.spawn_failure_count, "invalid": run.acceptance_invalid,
		"feedback": [run.feedback.visible, run.feedback.target_spawn_id, run.feedback.expires_at],
		"diagnostics": run.spawn_diagnostics.duplicate(true), "outcomes": [run.survival_window_outcome, run.continuation_outcome, run.continuation_evidence.duplicate(true)],
		"hud": [run.hud.get_node("Health").text, run.hud.get_node("Time").text]}

func input_event(main, key: Key, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.pressed = true
	event.echo = echo
	# Delivers the public input event to the real scene tree, including UI processing.
	main.get_viewport().push_input(event)

func lethal_commit(ctx) -> void:
	var d = definition(ctx)
	d.player.max_health = 10
	d.spawn_interval = 100.0
	var main = main_scene(ctx, d)
	var run = main.coordinator
	var first = add_contact(ctx, run, d)
	var later = add_contact(ctx, run, d)
	run.active_time = 65.0
	run.completed_step_count = 3900
	var commits := F.observe(ctx, run, "time_changed")
	var states := F.observe(ctx, run, "state_changed")
	var deaths := F.observe(ctx, run.player.health, "died")
	F.invoke(ctx, run, "step", [0.125])
	ctx.check(states == [["GameOver"]] and deaths == [[]], "exactly one lethal transition and death signal")
	ctx.check(commits == [[65.125]] and run.active_time == 65.125 and run.completed_step_count == 3901, "one final t_end commit includes lethal step")
	ctx.check(first.next_contact_at == 66.125 and later.next_contact_at == 0.0, "spawn-order lethal contact aborts later contacts")
	ctx.check(not run.stepping and run.camera.pending_mouse == Vector2.ZERO and not run.feedback.visible, "lethal step finishes and clears input/feedback")
	F.invoke(ctx, run.player.health, "apply_damage", [10])
	F.invoke(ctx, run, "_player_died")
	F.invoke(ctx, run, "step", [1.0])
	ctx.check(states == [["GameOver"]] and deaths == [[]] and commits == [[65.125]], "repeated lethal notifications cannot recommit or transition")
	ctx.done()

func freeze_escape(ctx) -> void:
	var d = definition(ctx)
	var main = main_scene(ctx, d)
	var run = main.coordinator
	defeat(ctx, run, d)
	var frozen := runtime_snapshot(run)
	var commits := F.observe(ctx, run, "time_changed")
	var states := F.observe(ctx, run, "state_changed")
	var attacks := F.observe(ctx, run.weapon, "attacked")
	var spawns := F.observe(ctx, run.spawner, "opportunity_consumed")
	Input.action_press("move_forward")
	Input.action_press("move_right")
	for index in 600:
		input_event(main, KEY_ESCAPE, index % 2 == 1)
		var motion := InputEventMouseMotion.new()
		motion.relative = Vector2(17, -11)
		main.get_viewport().push_input(motion)
		F.invoke(ctx, run, "step", [1.0 / 60.0])
	Input.action_release("move_forward")
	Input.action_release("move_right")
	ctx.check(runtime_snapshot(run) == frozen, "600 delivered inactive ticks (ten seconds equivalent) freeze every gameplay field")
	ctx.check(commits.is_empty() and states.is_empty() and attacks.is_empty() and spawns.is_empty(), "Escape/echo cannot resume, commit, spawn or attack")
	ctx.check(run.camera.pending_mouse == Vector2.ZERO and not Engine.get_main_loop().paused, "inactive mouse ignored while scene tree remains available to UI")
	ctx.done()

func final_hud(ctx) -> void:
	var d = definition(ctx)
	var main = main_scene(ctx, d)
	var run = main.coordinator
	run.active_time = 65.0
	run.spawner.next_spawn_at = 100.0
	defeat(ctx, run, d)
	ctx.check(run.hud.visible and run.hud.get_node("Health").is_visible_in_tree() and run.hud.get_node("Time").is_visible_in_tree(), "final HUD remains visible")
	ctx.check(run.hud.get_node("Health").text == "Health: 0 / 100" and run.hud.get_node("Time").text == "01:05", "final zero health and floor(final t_end) presented by lethal update")
	ctx.done()

func controls(node: Node, kind: String) -> Array:
	var result: Array = []
	if node.is_class(kind):
		result.append(node)
	for child in node.get_children():
		result.append_array(controls(child, kind))
	return result

func restart_button(ctx, hud):
	var buttons: Array = []
	for button in controls(hud, "Button"):
		if button.text == "Restart":
			buttons.append(button)
	ctx.check(buttons.size() == 1, "exactly one clearly labeled Restart control")
	return buttons[0] if buttons.size() == 1 else null

func game_over_control(ctx) -> void:
	var d = definition(ctx)
	var main = main_scene(ctx, d)
	var run = main.coordinator
	for button in controls(run.hud, "Button"):
		ctx.check(not button.is_visible_in_tree(), "Restart absent during Active")
	run.active_time = 65.0
	run.spawner.next_spawn_at = 100.0
	defeat(ctx, run, d)
	var visible_text := ""
	for label in controls(run.hud, "Label"):
		if label.is_visible_in_tree():
			visible_text += label.text + "\n"
	ctx.check(visible_text.contains("Game Over") and visible_text.contains("01:05"), "Game Over and final survival time visible together")
	var button = restart_button(ctx, run.hud)
	ctx.check(run.hud.has_signal("restart_requested"), "presentation-only restart_requested signal supplied")
	if button != null and run.hud.has_signal("restart_requested"):
		ctx.check(button.is_visible_in_tree() and not button.disabled and button.has_focus(), "Restart actionable and initially focused")
		var requests := F.observe(ctx, run.hud, "restart_requested")
		var generation: int = run.run_generation
		button.pressed.emit()
		manual_driver(ctx, main.coordinator)
		ctx.check(requests == [[]] and main.coordinator.run_generation == generation + 1, "actual button signal reaches one coordinator restart")
		ctx.check(main.coordinator.state == "Active", "UI activation returns to active play")
	ctx.done()

func assert_fresh(ctx, run, d, generation: int) -> void:
	ctx.check(run.state == "Active" and run.simulation_enabled and not run.stepping, "fresh active run with released step/restart guard")
	ctx.check(run.run_generation == generation and run.active_time == 0 and run.completed_step_count == 0, "generation advances once; time/ticks reset")
	ctx.check(run.player.health.current_health == d.player.max_health and run.player.health.max_health == d.player.max_health, "independent full fresh health")
	F.near(ctx, run.player.position, Vector3(d.arena.player_start_xz.x, d.arena.floor_y, d.arena.player_start_xz.y), "configured fresh position")
	ctx.check(run.camera.yaw == d.camera_yaw and run.camera.depression == d.camera_depression and run.camera.pending_mouse == Vector2.ZERO, "configured view and empty input buffer")
	ctx.check(run.camera.target == run.player, "camera binds only fresh player")
	F.near(ctx, run.camera.position, run.player.position + Vector3(0, d.camera_target_height, 0), "fresh follow pivot")
	ctx.check(is_equal_approx(run.camera.get_node("Yaw/Pitch/Camera3D").position.z, d.camera_distance) and is_equal_approx(run.camera.get_node("Yaw/Pitch/Camera3D").fov, d.camera_fov), "fresh distance/FOV")
	ctx.check(population(run) == 0 and run.registry.used_ids.is_empty() and run.registry.callbacks.is_empty() and run.next_spawn_id == 0, "registry membership/ID history/callbacks and spawn IDs reset")
	ctx.check(run.spawner.next_spawn_index == 1 and run.spawner.next_spawn_at == d.spawn_interval and run.spawner.run_generation == generation, "full spawn delay and fresh opportunity generation")
	ctx.check(run.weapon.next_attack_at == 0.0 and not run.feedback.visible and run.feedback.target == null and run.feedback.target_spawn_id == -1 and run.feedback.expires_at == 0.0, "weapon ready; feedback has no old target/deadline")
	ctx.check(run.spawn_failure_count == 0 and not run.acceptance_invalid and run.spawn_diagnostics.is_empty() and run.configuration_diagnostics.is_empty(), "fresh failure/invalidity/diagnostic state")
	ctx.check(run.survival_window_outcome == "outstanding" and run.continuation_outcome == "outstanding" and run.continuation_evidence.is_empty(), "fresh survival and continuation metadata")
	ctx.check(run.hud.get_node("Health").text == "Health: %d / %d" % [d.player.max_health, d.player.max_health] and run.hud.get_node("Time").text == "00:00", "fresh HUD")
	ctx.check(run.profile_capture == null, "normal Play restart adds no sampler")
	ctx.check(run._tuning_is_unchanged(), "all copied runtime tuning matches fresh definitions")

func three_cycles(ctx) -> void:
	var d = definition(ctx)
	d.spawn_interval = 0.5
	var original := F.snapshot(d)
	var main = main_scene(ctx, d)
	for cycle in 3:
		var run = main.coordinator
		var generation: int = run.run_generation
		F.invoke(ctx, run.camera, "queue_mouse", [Vector2(100, -50)])
		Input.action_press("move_right")
		F.invoke(ctx, run, "step", [0.25])
		Input.action_release("move_right")
		defeat(ctx, run, d, 0.25)
		ctx.check(run.weapon.next_attack_at > 0 and run.next_spawn_id > 0, "cycle dirties weapon/IDs/population before restart")
		# Later observations belong only to the defeated attempt.
		run.continuation_evidence["time_advanced"] = run.active_time
		run.continuation_outcome = "passed"
		var old_health = run.player.health
		var old_camera = run.camera
		if not restart(ctx, main):
			ctx.done()
			return
		run = main.coordinator
		ctx.check(not is_instance_valid(old_health) or not old_health.is_inside_tree(), "old health detached synchronously")
		ctx.check(not is_instance_valid(old_camera) or not old_camera.is_inside_tree(), "old camera detached synchronously")
		assert_fresh(ctx, run, d, generation + 1)
		var opportunities := F.observe(ctx, run.spawner, "opportunity_consumed")
		F.invoke(ctx, run, "step", [0.25])
		ctx.check(population(run) == 0 and opportunities.is_empty(), "cycle %d waits full fresh spawn interval" % cycle)
		F.invoke(ctx, run, "step", [0.25])
		ctx.check(population(run) == 1 and run.next_spawn_id == 1 and opportunities == [[0.5, "spawned"]], "one first spawn/event, fresh ID zero, normal cadence")
		var enemy = run.registry.living_in_spawn_order()[0]
		ctx.check(enemy.spawn_id == 0 and enemy.next_contact_at == 0 and enemy.health.current_health == d.enemy.max_health, "fresh enemy health/contact deadline")
	ctx.check(F.snapshot(d) == original, "three cycles never mutate shared definitions")
	ctx.done()

func guarded_requests(ctx) -> void:
	var d = definition(ctx)
	var main = main_scene(ctx, d)
	var run = main.coordinator
	var initial := runtime_snapshot(run)
	var generation: int = run.run_generation
	if not restart(ctx, main):
		ctx.done()
		return
	ctx.check(main.coordinator.run_generation == generation and runtime_snapshot(main.coordinator) == initial, "Active restart request ignored")
	ctx.check(run.hud.has_signal("restart_requested"), "T037 supplies restart intent for invalid/repeated signal checks")
	if run.hud.has_signal("restart_requested"):
		run.hud.emit_signal("restart_requested")
		ctx.check(runtime_snapshot(run) == initial and run.run_generation == generation, "Active HUD restart signal ignored")
	# US3 pause input is not implemented here; inject only the state precondition.
	run.state = "Paused"
	var paused := runtime_snapshot(run)
	run.request_restart()
	if run.hud.has_signal("restart_requested"):
		run.hud.emit_signal("restart_requested")
	ctx.check(runtime_snapshot(run) == paused and run.run_generation == generation, "Paused restart request/signal ignored without resetting fields")
	run.state = "Active"
	defeat(ctx, run, d)
	# Reentrant activation while teardown is executing must see the immediate guard.
	ctx.connect_callback(run.arena.tree_exiting, func(): run.request_restart())
	for _index in 5:
		main.coordinator.request_restart()
		if main.coordinator.hud.has_signal("restart_requested"):
			main.coordinator.hud.emit_signal("restart_requested")
	manual_driver(ctx, main.coordinator)
	ctx.check(main.coordinator.run_generation == generation + 1 and main.coordinator.state == "Active", "reentrant/repeated activation starts exactly one generation")
	ctx.check(main.get_children().filter(func(node): return node.get_script() == load("res://scripts/run/run_coordinator.gd")).size() == 1, "one coordinator remains in application")
	ctx.done()

func stale_callbacks_removal(ctx) -> void:
	var d = definition(ctx)
	var main = main_scene(ctx, d)
	var run = main.coordinator
	F.invoke(ctx, run, "step", [d.spawn_interval])
	var old_enemy = run.registry.living_in_spawn_order()[0]
	var old_registry = run.registry
	var old_health = run.player.health
	var old_spawner = run.spawner
	var old_hud = run.hud
	# Save actual connected production callbacks, including any generation bound
	# by T038. A queued Callable can outlive a disconnected/freed signal emitter.
	var queued_deaths: Array = old_health.died.get_connections()
	var queued_health: Array = old_health.health_changed.get_connections()
	var queued_failures: Array = old_spawner.opportunity_failed.get_connections()
	var queued_spawns: Array = old_spawner.opportunity_consumed.get_connections()
	defeat(ctx, run, d)
	if not restart(ctx, main):
		ctx.done()
		return
	run = main.coordinator
	for old in [old_enemy, old_registry, old_health, old_spawner]:
		ctx.check(not is_instance_valid(old) or not old.is_inside_tree(), "old encounter node removed synchronously before request returns")
	if is_instance_valid(old_registry):
		ctx.check(old_registry.living_in_spawn_order().is_empty() and old_registry.callbacks.is_empty(), "old registry membership/callbacks cleared synchronously")
	var fresh := runtime_snapshot(run)
	if is_instance_valid(old_health):
		old_health.died.emit()
		old_health.health_changed.emit(0, 100)
	if is_instance_valid(old_spawner):
		old_spawner.opportunity_failed.emit([{"run_generation": run.run_generation - 1, "cause": "stale encounter"}])
		old_spawner.opportunity_consumed.emit(301.0, "spawned")
	# A rebuilt/reused HUD must disconnect the old encounter's restart callback.
	if is_instance_valid(old_hud) and old_hud != run.hud and old_hud.has_signal("restart_requested"):
		old_hud.emit_signal("restart_requested")
	for connection in queued_deaths:
		if connection.callable.is_valid():
			connection.callable.call()
	for connection in queued_health:
		if connection.callable.is_valid():
			connection.callable.call(0, 100)
	for connection in queued_failures:
		if connection.callable.is_valid():
			connection.callable.call([{"run_generation": run.run_generation - 1, "cause": "queued old callback"}])
	for connection in queued_spawns:
		if connection.callable.is_valid():
			connection.callable.call(301.0, "spawned")
	ctx.check(runtime_snapshot(run) == fresh and run.continuation_evidence.is_empty(), "stale death/health/spawn/restart callbacks cannot mutate fresh run")
	await Engine.get_main_loop().process_frame
	ctx.check(not is_instance_valid(old_enemy) and not is_instance_valid(old_spawner) and not is_instance_valid(old_health), "old encounter disposed by next update")
	ctx.done()

func invalid_restart(ctx) -> void:
	var d = definition(ctx)
	var main = main_scene(ctx, d)
	var run = main.coordinator
	defeat(ctx, run, d)
	var old_nodes: Array = [run.arena, run.player, run.camera, run.spawner, run.weapon, run.registry]
	var generation: int = run.run_generation
	d.player.max_health = 0
	if not restart(ctx, main):
		ctx.done()
		return
	run = main.coordinator
	ctx.check(run.run_generation == generation + 1 and run.state == "ConfigurationError" and not run.simulation_enabled, "invalid fresh definitions consume generation and disable simulation")
	for old in old_nodes:
		ctx.check(not is_instance_valid(old) or not old.is_inside_tree(), "invalid restart still discards old encounter synchronously")
	ctx.check(run.player == null and run.spawner == null and run.registry == null and run.camera == null, "invalid restart publishes no encounter")
	ctx.check(not run.configuration_diagnostics.is_empty(), "invalid restart retains diagnostics")
	for record in run.configuration_diagnostics:
		ctx.application_diagnostic(JSON.parse_string(record))
	var label = run.hud.get_node("ConfigurationError")
	ctx.check(label.is_visible_in_tree() and label.text.contains("PlayerDefinition") and label.text.contains("max_health") and label.text.contains("positive integer"), "visible resource/field/constraint failure")
	var time: float = run.active_time
	F.invoke(ctx, run, "step", [10.0])
	run.request_restart()
	ctx.check(run.active_time == time and run.run_generation == generation + 1 and not run.simulation_enabled, "error state neither simulates nor retries/revives old run")
	ctx.done()

func failure_isolation(ctx) -> void:
	var d = definition(ctx)
	var main = main_scene(ctx, d)
	var run = main.coordinator
	var faults := Faults.new()
	run.spawner.selection_callable = faults.choose_spawn
	ctx.connect_callback(run.spawner.diagnostic, ctx.application_diagnostic)
	F.invoke(ctx, run, "step", [d.spawn_interval])
	ctx.check(run.spawn_failure_count == 1 and run.acceptance_invalid and run.spawn_diagnostics.size() == 2, "one old failed opportunity, two retained diagnostics")
	defeat(ctx, run, d)
	if not restart(ctx, main):
		ctx.done()
		return
	run = main.coordinator
	ctx.check(run.spawn_failure_count == 0 and not run.acceptance_invalid and run.spawn_diagnostics.is_empty(), "fresh counter/diagnostics/invalidity isolated from failed attempt")
	F.invoke(ctx, run, "step", [d.spawn_interval])
	ctx.check(population(run) == 1 and run.spawn_failure_count == 0 and not run.acceptance_invalid, "fresh normal spawn uses real selector and clean failure state")
	ctx.done()
