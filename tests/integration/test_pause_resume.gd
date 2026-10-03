extends RefCounted
## T042: game_over_escape is executable today; all other cases are staged.
## No simulated pause implementation: transitions invoke the real contract or
## deliver real viewport input. Only automatic physics driving is disabled.
const F = preload("res://tests/support/gameplay_fixture.gd")
const Lifecycle = preload("res://tests/integration/test_defeat_restart.gd")
var lifecycle := Lifecycle.new()

func cases() -> Array[Dictionary]:
	return F.cases_for("pause", ["game_over_escape", "escape_edges", "freeze_combat", "inactive_callbacks", "spawn_delay", "weapon_delay", "contact_delays", "feedback_delay", "mouse_discard", "hud_restart"],
		["res://scenes/main.tscn", "res://scripts/run/run_coordinator.gd", "res://scenes/hud.tscn"])

func definition(ctx):
	var d = lifecycle.definition(ctx)
	d.spawn_interval = 2.0
	d.weapon.attack_interval = 1.0
	d.weapon.feedback_duration = 0.5
	return d

func key(main, code: Key = KEY_ESCAPE, pressed: bool = true, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	event.echo = echo
	main.get_viewport().push_input(event)

func mouse(main, motion: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.relative = motion
	main.get_viewport().push_input(event)

func transition(ctx, run, expected: String) -> bool:
	# Synchronous semantic-method seam. Escape dispatch is tested separately.
	F.invoke(ctx, run, "toggle_pause")
	ctx.check(run.state == expected, "real toggle_pause reaches " + expected)
	return run.state == expected

func snapshot(run) -> Dictionary:
	var result: Dictionary = lifecycle.runtime_snapshot(run)
	result.erase("state")
	result["generation"] = run.run_generation
	result["nodes"] = [run.player.get_instance_id(), run.camera.get_instance_id(), run.spawner.get_instance_id(), run.registry.get_instance_id()]
	result["view"] = run.camera.get_node("Yaw/Pitch/Camera3D").global_transform
	result["flash"] = []
	for enemy in run.registry.living_in_spawn_order():
		result.flash.append(enemy.get_node("Visual").material_override.albedo_color)
	result["line"] = [run.feedback.line.visible, run.feedback.line.transform, run.feedback.line.mesh]
	return result

func events(ctx, run) -> Dictionary:
	# Shared F.observe deliberately supports only 0–2 arguments. Keep this
	# three-argument observation local and use Context's normal cleanup ownership.
	var hits: Array = []
	ctx.connect_callback(run.weapon.attack_feedback, func(time, position, target): hits.append([time, position, target]))
	return {"commits": F.observe(ctx, run, "time_changed"),
		"spawns": F.observe(ctx, run.spawner, "opportunity_consumed"),
		"attacks": F.observe(ctx, run.weapon, "attacked"),
		"damage": F.observe(ctx, run.player.health, "health_changed"),
		"hits": hits}

func silent(ctx, observed: Dictionary) -> void:
	for id in observed:
		ctx.check(observed[id].is_empty(), "no inactive gameplay signal: " + id)

func game_over_escape(ctx) -> void:
	var d = definition(ctx)
	var main = lifecycle.main_scene(ctx, d)
	var run = main.coordinator
	lifecycle.defeat(ctx, run, d)
	var frozen := snapshot(run)
	var states := F.observe(ctx, run, "state_changed")
	var observed := events(ctx, run)
	for echo in [false, true, false]:
		key(main, KEY_ESCAPE, true, echo)
		key(main, KEY_ESCAPE, false)
		mouse(main, Vector2(100, -50))
		F.invoke(ctx, run, "step", [0.125])
	ctx.check(run.state == "GameOver" and snapshot(run) == frozen, "Escape press/echo/release cannot revive defeated encounter or alter final result")
	ctx.check(states.is_empty() and run.camera.pending_mouse == Vector2.ZERO, "no resume notification or accumulated defeated mouse input")
	silent(ctx, observed)
	ctx.done()

func escape_edges(ctx) -> void:
	var d = definition(ctx)
	d.spawn_interval = 100.0
	var main = lifecycle.main_scene(ctx, d)
	var run = main.coordinator
	var states := F.observe(ctx, run, "state_changed")
	var before := snapshot(run)
	key(main, KEY_ESCAPE, true, true)
	key(main, KEY_ESCAPE, false)
	ctx.check(run.state == "Active" and states.is_empty(), "echo and key release do not pause Active")
	for cycle in 3:
		var time: float = run.active_time
		var ticks: int = run.completed_step_count
		key(main)
		F.invoke(ctx, run, "step", [0.125])
		ctx.check(run.state == "Paused" and run.active_time == time and run.completed_step_count == ticks, "discrete pause intent prevents that simulation step")
		for _repeat in 4:
			key(main, KEY_ESCAPE, true, true)
			F.invoke(ctx, run, "step", [0.125])
		key(main, KEY_ESCAPE, false)
		key(main, KEY_ENTER)
		F.invoke(ctx, run, "step", [0.125])
		ctx.check(run.state == "Paused" and states.size() == cycle * 2 + 1, "held echo, release and unrelated key cannot toggle Pause")
		key(main)
		F.invoke(ctx, run, "step", [0.125])
		ctx.check(run.state == "Active" and states.size() == (cycle + 1) * 2, "next non-echo Escape resumes exactly once")
		key(main, KEY_ESCAPE, true, true)
		key(main, KEY_ESCAPE, false)
		F.invoke(ctx, run, "step", [0.125])
		ctx.check(run.state == "Active" and states.size() == (cycle + 1) * 2, "resume echo/release cannot re-pause")
	ctx.check(states == [["Paused"], ["Active"], ["Paused"], ["Active"], ["Paused"], ["Active"]], "three press pairs yield only six transitions")
	ctx.check(snapshot(run).nodes == before.nodes and run.run_generation == before.generation, "pause pairs preserve encounter identity and generation")
	ctx.done()

func freeze_combat(ctx) -> void:
	var d = definition(ctx)
	var main = lifecycle.main_scene(ctx, d)
	var run = main.coordinator
	lifecycle.add_contact(ctx, run, d)
	F.invoke(ctx, run, "step", [0.125])
	ctx.check(run.feedback.visible and run.player.health.current_health == 90, "pause fixture has actual attack feedback and contact damage")
	var before := snapshot(run)
	var observed := events(ctx, run)
	if transition(ctx, run, "Paused"):
		Input.action_press("move_forward")
		Input.action_press("move_right")
		for _index in 600:
			mouse(main, Vector2(17, -11))
			F.invoke(ctx, run, "step", [1.0 / 60.0])
		Input.action_release("move_forward")
		Input.action_release("move_right")
		# Also deliver real idle frames: autonomous process/physics work must not run.
		await Engine.get_main_loop().process_frame
		await Engine.get_main_loop().physics_frame
		await Engine.get_main_loop().process_frame
		ctx.check(snapshot(run) == before and run.state == "Paused", "600 inactive ticks plus real tree frames freeze positions/view/health/time/ticks/deadlines/line/flash")
		silent(ctx, observed)
		ctx.check(not Engine.get_main_loop().paused, "UI scene tree continues processing")
		if transition(ctx, run, "Active"):
			ctx.check(snapshot(run) == before, "resume preserves same encounter before the next active step")
	ctx.done()

func inactive_callbacks(ctx) -> void:
	var d = definition(ctx)
	var main = lifecycle.main_scene(ctx, d)
	var run = main.coordinator
	var enemy = lifecycle.add_contact(ctx, run, d)
	F.invoke(ctx, run, "step", [0.125])
	# Saved real connected Callables model already queued delivery, without
	# emitting fake component signals or mutating health in the fixture.
	var deliveries: Array = []
	for pair in [[run.player.health.health_changed, [0, 100]], [run.player.health.died, []],
		[run.spawner.opportunity_failed, [[{"cause": "late inactive callback"}]]],
		[run.spawner.opportunity_consumed, [301.0, "spawned"]],
		[run.weapon.attack_feedback, [301.0, run.player.position, enemy]]]:
		for connection in pair[0].get_connections():
			deliveries.append([connection.callable, pair[1]])
	ctx.check(deliveries.size() >= 5, "actual encounter callbacks captured for each gameplay phase")
	if transition(ctx, run, "Paused"):
		var frozen := snapshot(run)
		var states := F.observe(ctx, run, "state_changed")
		for delivery in deliveries:
			delivery[0].callv(delivery[1])
		ctx.check(snapshot(run) == frozen and run.state == "Paused" and states.is_empty(), "queued health/death/spawn/feedback callbacks have no inactive gameplay effects")
	ctx.done()

func pause_wait_resume(ctx, run) -> bool:
	var before := snapshot(run)
	if not transition(ctx, run, "Paused"):
		return false
	F.invoke(ctx, run, "step", [10.0])
	ctx.check(snapshot(run) == before, "ten-second inactive delivery neither consumes nor resets any delay")
	if not transition(ctx, run, "Active"):
		return false
	ctx.check(snapshot(run) == before, "resume itself has no catch-up events or deadline reset")
	return true

func spawn_delay(ctx) -> void:
	var d = definition(ctx)
	var run = lifecycle.main_scene(ctx, d).coordinator
	F.invoke(ctx, run, "step", [0.5])
	var spawns := F.observe(ctx, run.spawner, "opportunity_consumed")
	if pause_wait_resume(ctx, run):
		F.invoke(ctx, run, "step", [1.25])
		ctx.check(run.active_time == 1.75 and spawns.is_empty(), "no spawn before preserved 2-second deadline")
		F.invoke(ctx, run, "step", [0.25])
		ctx.check(spawns == [[2.0, "spawned"]] and lifecycle.population(run) == 1, "one spawn at original deadline, not reset or accumulated")
		F.invoke(ctx, run, "step", [0.125])
		ctx.check(spawns.size() == 1 and run.spawner.next_spawn_at == 4.0, "no post-resume burst, ordinary cadence retained")
	ctx.done()

func weapon_delay(ctx) -> void:
	var d = definition(ctx)
	d.spawn_interval = 100.0
	var run = lifecycle.main_scene(ctx, d).coordinator
	var enemy = lifecycle.add_contact(ctx, run, d)
	enemy.position.x += 2.0
	F.invoke(ctx, run, "step", [0.125])
	var attacks := F.observe(ctx, run.weapon, "attacked")
	var health: int = enemy.health.current_health
	ctx.check(run.weapon.next_attack_at == 1.125, "actual first hit creates binary-exact deadline")
	if pause_wait_resume(ctx, run):
		F.invoke(ctx, run, "step", [0.875])
		ctx.check(run.active_time == 1.0 and attacks.is_empty() and enemy.health.current_health == health, "weapon waits until original remaining delay completes")
		F.invoke(ctx, run, "step", [0.125])
		ctx.check(attacks == [[enemy.spawn_id, d.weapon.damage]] and enemy.health.current_health == health - d.weapon.damage, "one hit at preserved completion deadline")
		F.invoke(ctx, run, "step", [0.125])
		ctx.check(attacks.size() == 1 and run.weapon.next_attack_at == 2.125, "weapon resumes normal cooldown without burst")
	ctx.done()

func contact_delays(ctx) -> void:
	var d = definition(ctx)
	d.spawn_interval = 100.0
	var run = lifecycle.main_scene(ctx, d).coordinator
	var first = lifecycle.add_contact(ctx, run, d)
	F.invoke(ctx, run, "step", [0.125])
	var second = lifecycle.add_contact(ctx, run, d)
	F.invoke(ctx, run, "step", [0.125])
	ctx.check(first.next_contact_at == 1.125 and second.next_contact_at == 1.25, "two attackers have independently earned staggered deadlines")
	var damage := F.observe(ctx, run.player.health, "health_changed")
	if pause_wait_resume(ctx, run):
		F.invoke(ctx, run, "step", [0.75])
		ctx.check(damage.is_empty() and run.player.health.current_health == 80, "neither contacting enemy damages before remaining delays")
		F.invoke(ctx, run, "step", [0.125])
		ctx.check(damage == [[70, 100]] and first.next_contact_at == 2.125 and second.next_contact_at == 1.25, "only first enemy attacks at its preserved deadline")
		F.invoke(ctx, run, "step", [0.125])
		ctx.check(damage == [[70, 100], [60, 100]] and second.next_contact_at == 2.25, "second enemy retains its separate delay, no catch-up")
	ctx.done()

func feedback_delay(ctx) -> void:
	var d = definition(ctx)
	d.spawn_interval = 100.0
	var run = lifecycle.main_scene(ctx, d).coordinator
	var enemy = lifecycle.add_contact(ctx, run, d)
	enemy.position.x += 2.0
	var original: Color = enemy.get_node("Visual").material_override.albedo_color
	F.invoke(ctx, run, "step", [0.125])
	ctx.check(run.feedback.visible and run.feedback.expires_at == 0.625, "real attack has a half-second feedback delay")
	if pause_wait_resume(ctx, run):
		F.invoke(ctx, run, "step", [0.375])
		ctx.check(run.feedback.visible and run.feedback.line.visible and enemy.get_node("Visual").material_override.albedo_color == Color.WHITE, "line and affected-target flash remain until preserved expiry")
		F.invoke(ctx, run, "step", [0.125])
		ctx.check(not run.feedback.visible and not run.feedback.line.visible and enemy.get_node("Visual").material_override.albedo_color == original, "line and flash expire at original active deadline")
	ctx.done()

func mouse_discard(ctx) -> void:
	var d = definition(ctx)
	d.spawn_interval = 100.0
	var main = lifecycle.main_scene(ctx, d)
	var run = main.coordinator
	mouse(main, Vector2(25, -10))
	ctx.check(run.camera.pending_mouse != Vector2.ZERO, "Active viewport motion is queued before transition")
	var view: Transform3D = run.camera.get_node("Yaw/Pitch/Camera3D").global_transform
	if transition(ctx, run, "Paused"):
		ctx.check(run.camera.pending_mouse == Vector2.ZERO, "entering Pause discards unconsumed Active motion")
		Input.action_press("move_forward")
		for _index in 20:
			mouse(main, Vector2(100, -100))
			F.invoke(ctx, run, "step", [0.5])
		Input.action_release("move_forward")
		ctx.check(run.camera.pending_mouse == Vector2.ZERO, "inactive mouse events are discarded, not buffered")
		var position: Vector3 = run.player.position
		if transition(ctx, run, "Active"):
			F.invoke(ctx, run, "step", [0.125])
			ctx.check(run.player.position == position and run.camera.get_node("Yaw/Pitch/Camera3D").global_transform == view, "released inactive WASD and discarded mouse cause no movement or resumed view jump")
			mouse(main, Vector2(10, 0))
			F.invoke(ctx, run, "step", [0.125])
			ctx.check(is_equal_approx(run.camera.yaw, d.camera_yaw + 10 * d.mouse_sensitivity), "fresh Active motion works exactly once after resume")
	ctx.done()

func visible_text(hud) -> String:
	var result := ""
	for label in lifecycle.controls(hud, "Label"):
		if label.is_visible_in_tree():
			result += label.text + "\n"
	return result

func hud_restart(ctx) -> void:
	var d = definition(ctx)
	var run = lifecycle.main_scene(ctx, d).coordinator
	F.invoke(ctx, run, "step", [0.125])
	if transition(ctx, run, "Paused"):
		var frozen := snapshot(run)
		ctx.check(visible_text(run.hud).contains("Paused") and visible_text(run.hud).contains("Escape to resume"), "visible pause indication and resume instruction, independent of overlay node names")
		ctx.check(run.hud.visible and run.hud.get_node("Health").is_visible_in_tree() and run.hud.get_node("Time").is_visible_in_tree(), "health/time HUD stays visible during Pause")
		for button in lifecycle.controls(run.hud, "Button"):
			ctx.check(not button.is_visible_in_tree(), "Restart is hidden while Paused")
		var requests := F.observe(ctx, run, "restart_requested")
		for _repeat in 3:
			run.request_restart()
			run.hud.restart_requested.emit()
		ctx.check(requests.is_empty() and not run.restart_in_progress and snapshot(run) == frozen and run.state == "Paused", "Paused coordinator requests and HUD intents cannot reset encounter")
		if transition(ctx, run, "Active"):
			ctx.check(not visible_text(run.hud).contains("Paused") and not visible_text(run.hud).contains("Escape to resume"), "pause overlay disappears on resume")
			ctx.check(run.hud.get_node("Health").is_visible_in_tree() and run.hud.get_node("Time").is_visible_in_tree(), "HUD remains visible on resume")
	ctx.done()
