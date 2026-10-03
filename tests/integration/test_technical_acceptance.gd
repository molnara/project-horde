extends RefCounted
## DX-001 Batch 3: measured time and input gaps only. No production bypasses.
const F = preload("res://tests/support/gameplay_fixture.gd")
const Lifecycle = preload("res://tests/integration/test_defeat_restart.gd")
const Pause = preload("res://tests/integration/test_pause_resume.gd")
var lifecycle := Lifecycle.new()
var pause := Pause.new()
const ACTIONS = ["move_forward", "move_backward", "move_left", "move_right"]
const KEYS = [KEY_W, KEY_S, KEY_A, KEY_D]

func cases() -> Array[Dictionary]:
	return F.cases_for("technical", ["hud_clock", "pause_contact", "pause_between", "three_cycles", "configurable_eligibility", "mapped_input"],
		["res://scenes/main.tscn", "res://scenes/hud.tscn", "res://scripts/run/run_coordinator.gd"])

func receipt(ctx, values: Dictionary) -> void:
	values["case"] = ctx.case_id
	values["seed"] = ctx.seed_value
	print("HORDE_TECHNICAL_EVIDENCE=" + JSON.stringify(values))

func hud_clock(ctx) -> void:
	# Same scheduling-isolation tuning as survival.quiet_definition. Actual
	# physics driver/time commits stay enabled; this is not owner survival proof.
	var d = ctx.definitions()
	d.enemy.movement_speed = 0.000001
	d.weapon.range = 0.01
	var main = lifecycle.main_scene(ctx, d)
	var run = main.coordinator
	ctx.check(run.hud.get_node("Time").text == "00:00" and run.hud.get_node("Health").text == "Health: 100 / 100", "fresh HUD full health and zero")
	var start := Time.get_ticks_usec()
	run.set_physics_process(true)
	while run.active_time < 65.0 and run.state == "Active" and Time.get_ticks_usec() - start < 90000000:
		await Engine.get_main_loop().process_frame
	run.set_physics_process(false)
	var elapsed := (Time.get_ticks_usec() - start) / 1000000.0
	ctx.check(run.state == "Active" and run.active_time >= 65.0 and run.active_time < 66.0, "65 completed active seconds reached with actual physics driver")
	ctx.check(run.completed_step_count >= 3900 and abs(run.active_time - run.completed_step_count / 60.0) < 0.000001, "time equals executed 60 Hz simulation, never assigned by fixture")
	ctx.check(run.hud.get_node("Time").text == "01:05", "65-second integrated HUD within original one displayed second")
	ctx.check(is_finite(elapsed) and elapsed > 0.0, "monotonic wall duration retained separately from completed simulation")
	ctx.check(run.spawn_failure_count == 0 and not run.acceptance_invalid, "clock fixture has no unexpected spawn failures")
	for enemy in run.registry.living_in_spawn_order():
		ctx.check(enemy.get_script() == load("res://scripts/actors/enemy.gd"), "scheduled enemies all use the single production type")
	run.player.health.apply_damage(10)
	run.step(1.0 / 60.0)
	ctx.check(run.hud.get_node("Health").text == "Health: 90 / 100", "integrated health updates by next step")
	receipt(ctx, {"wall_seconds": elapsed, "active_seconds": run.active_time, "ticks": run.completed_step_count,
		"hud": run.hud.get_node("Time").text, "tuning": {"enemy_speed": d.enemy.movement_speed, "weapon_range": d.weapon.range, "spawn_interval": d.spawn_interval, "cap": d.max_live_enemies}, "driver": "automatic 60 Hz, then one health update"})
	ctx.done()

func inactive_wait(ctx, main, expected: String) -> void:
	var run = main.coordinator
	var frozen := pause.snapshot(run)
	var observed := pause.events(ctx, run)
	var states := F.observe(ctx, run, "state_changed")
	var start := Time.get_ticks_usec()
	var samples := 0
	var stable := true
	# Exercise actual inactive physics callbacks and live tree processing, rather
	# than sleeping the application or supplying synthetic ten-second deltas.
	run.set_physics_process(true)
	while Time.get_ticks_usec() - start < 10000000:
		for action in ACTIONS:
			Input.action_release(action)
		Input.action_press(ACTIONS[samples % ACTIONS.size()])
		pause.key(main, KEYS[samples % KEYS.size()])
		pause.mouse(main, Vector2(17, -11))
		pause.key(main, KEY_ESCAPE, true, samples % 2 == 0)
		await Engine.get_main_loop().create_timer(0.1).timeout
		stable = stable and pause.snapshot(run) == frozen and run.state == expected
		pause.key(main, KEYS[samples % KEYS.size()], false)
		samples += 1
	run.set_physics_process(false)
	var elapsed := (Time.get_ticks_usec() - start) / 1000000.0
	for action in ACTIONS:
		Input.action_release(action)
	pause.key(main, KEY_ESCAPE, false)
	ctx.check(elapsed >= 10.0 and samples >= 4, "at least ten monotonic real seconds with all four movement inputs")
	ctx.check(stable and pause.snapshot(run) == frozen and run.state == expected, "every sampled inactive state/view/health/time/deadline/feedback remains frozen")
	ctx.check(states.is_empty() and run.pause_intents == 0 and run.camera.pending_mouse == Vector2.ZERO, "held/echo Escape and mouse cannot toggle or buffer inactive input")
	ctx.check(run.hud.visible and run.hud.get_node("Health").is_visible_in_tree() and run.hud.get_node("Time").is_visible_in_tree(), "inactive health/time controls remain visible in tree")
	pause.silent(ctx, observed)
	receipt(ctx, {"state": expected, "wall_seconds": elapsed, "samples": samples, "active_seconds": run.active_time,
		"ticks": run.completed_step_count, "driver": "automatic inactive physics; sampled state and signals", "input": "W/S/A/D actions and viewport keys, mouse, held/echo Escape"})

func pause_contact(ctx) -> void:
	await pause_context(ctx, true)

func pause_between(ctx) -> void:
	await pause_context(ctx, false)

func pause_context(ctx, in_contact: bool) -> void:
	var d = lifecycle.definition(ctx)
	var main = lifecycle.main_scene(ctx, d)
	var run = main.coordinator
	var enemy = lifecycle.add_contact(ctx, run, d)
	if not in_contact:
		enemy.position.x = 2.0
	run.step(0.125)
	ctx.check(run.feedback.visible and enemy.health.current_health == 990, "actual attack earns weapon/feedback deadlines")
	ctx.check(run.player.health.current_health == (90 if in_contact else 100), "distinct contact/between-event pause context")
	var frozen := pause.snapshot(run)
	var deadlines := {"spawn": run.spawner.next_spawn_at, "weapon": run.weapon.next_attack_at, "contact": enemy.next_contact_at, "feedback": run.feedback.expires_at}
	pause.key(main)
	run.step(1.0 / 60.0)
	ctx.check(run.state == "Paused" and pause.snapshot(run) == frozen, "Escape pauses before another active step")
	ctx.check(pause.visible_text(run.hud).contains("Paused"), "pause indication exists")
	await inactive_wait(ctx, main, "Paused")
	# Dispatch resume via input, then observe actual default deadlines under
	# controlled small steps. Existing binary-neighbour tests retain exact edges.
	var observed := pause.events(ctx, run)
	Input.action_press("move_right")
	pause.key(main)
	var dt := 1.0 / 64.0
	var first := {"spawn": -1.0, "weapon": -1.0, "contact": -1.0, "feedback": -1.0}
	for _tick in 96:
		run.step(dt)
		if not observed.spawns.is_empty() and first.spawn < 0:
			first.spawn = run.active_time
		if not observed.attacks.is_empty() and first.weapon < 0:
			first.weapon = run.active_time
		if not observed.damage.is_empty() and first.contact < 0:
			first.contact = run.active_time
		if not run.feedback.visible and first.feedback < 0:
			first.feedback = run.active_time
	ctx.check(run.state == "Active" and run.player.position == frozen.position and run.camera.transform == frozen.camera, "resume clears held movement and discarded mouse; same encounter/view")
	for id in ["spawn", "weapon", "feedback"]:
		ctx.check(first[id] >= deadlines[id] and first[id] <= deadlines[id] + dt, "preserved default " + id + " deadline, never early, serviced within one step")
	if in_contact:
		ctx.check(first.contact >= deadlines.contact and first.contact <= deadlines.contact + dt and observed.damage.size() == 1, "one contact at preserved independent default deadline")
	else:
		ctx.check(observed.damage.is_empty(), "separated between-event encounter remains damage-free")
	ctx.check(observed.spawns.size() == 1 and observed.attacks.size() == 2, "ordinary resumed cadence without paused-time bursts")
	receipt(ctx, {"context": "contact" if in_contact else "between-events", "pause_active_time": frozen.time,
		"deadlines": deadlines, "first_resumed_events": first, "resume_step": dt, "spawn_count": observed.spawns.size(), "attack_count": observed.attacks.size(),
		"tuning": {"enemy_speed": d.enemy.movement_speed, "enemy_health": d.enemy.max_health, "spawn_interval": d.spawn_interval, "weapon_interval": d.weapon.attack_interval, "contact_interval": d.enemy.contact_interval, "feedback_duration": d.weapon.feedback_duration}})
	ctx.done()

func click(main, button) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = button.get_global_rect().get_center()
	event.global_position = event.position
	event.pressed = true
	main.get_viewport().push_input(event, true)
	event = event.duplicate()
	event.pressed = false
	main.get_viewport().push_input(event, true)

func three_cycles(ctx) -> void:
	var d = lifecycle.definition(ctx)
	var main = lifecycle.main_scene(ctx, d)
	var application_id: int = main.get_instance_id()
	var original := F.snapshot(d)
	for cycle in 3:
		var run = main.coordinator
		var generation: int = run.run_generation
		pause.mouse(main, Vector2(100, -50))
		Input.action_press("move_right")
		run.step(0.25)
		Input.action_release("move_right")
		lifecycle.defeat(ctx, run, d)
		var old_nodes: Array = [run.player, run.camera, run.spawner, run.registry]
		var old_enemies: Array = run.registry.living_in_spawn_order()
		ctx.check(run.hud.get_node("Health").text == "Health: 0 / 100" and pause.visible_text(run.hud).contains("Game Over"), "lethal step presents final zero health/Game Over")
		var button = lifecycle.restart_button(ctx, run.hud)
		ctx.check(button != null and button.has_focus() and not button.disabled, "Restart actionable by next update")
		# Wait only once: FR-010 specifies one ten-second defeated check, while
		# SC-002 specifies exactly three consecutive cycles, not three such waits.
		if cycle == 0:
			await inactive_wait(ctx, main, "GameOver")
		await Engine.get_main_loop().process_frame
		if cycle == 0 and button != null:
			click(main, button)
		else:
			pause.key(main, KEY_ENTER if cycle == 1 else KEY_SPACE)
			pause.key(main, KEY_ENTER if cycle == 1 else KEY_SPACE, false)
		# Repeated public activation after replacement must be ignored.
		pause.key(main, KEY_ENTER)
		pause.key(main, KEY_ENTER, false)
		lifecycle.manual_driver(ctx, main.coordinator)
		run = main.coordinator
		ctx.check(main.get_instance_id() == application_id, "same Main/application across all three consecutive cycles")
		lifecycle.assert_fresh(ctx, run, d, generation + 1)
		for old in old_nodes + old_enemies:
			ctx.check(not is_instance_valid(old) or not old.is_inside_tree(), "old actor/encounter detached before fresh run")
		var spawns := F.observe(ctx, run.spawner, "opportunity_consumed")
		run.step(1.0)
		ctx.check(spawns.is_empty() and lifecycle.population(run) == 0, "full original 1.5-second spawn delay retained")
		run.step(0.5)
		ctx.check(spawns == [[1.5, "spawned"]] and lifecycle.population(run) == 1 and run.next_spawn_id == 1, "one fresh ordinary first spawn, no duplicate events")
		receipt(ctx, {"cycle": cycle + 1, "main_id": application_id, "generation": run.run_generation, "activation": ["viewport mouse click", "viewport Enter", "viewport Space"][cycle], "first_spawn": spawns, "spawn_interval": d.spawn_interval})
	ctx.check(F.snapshot(d) == original, "three cycles never mutate definitions")
	ctx.done()

func configurable_eligibility(ctx) -> void:
	for radius in [1.0, 3.0]:
		var d = ctx.definitions()
		d.weapon.range = radius
		d.enemy.contact_distance = radius
		var weapon = F.weapon(ctx, d)
		var enemy = F.enemy(ctx, d, 0, Vector3(2, 0, 0))
		var victim = F.health(ctx, 100)
		weapon.step(0.0, Vector3.ZERO, [enemy])
		enemy.step_contact(0.0, Vector3.ZERO, victim)
		ctx.check(enemy.health.current_health == (20 if radius == 3.0 else 30), "fresh range change alters same-geometry eligibility")
		ctx.check(victim.current_health == (90 if radius == 3.0 else 100), "fresh contact-distance change alters same-geometry eligibility")
	ctx.done()

func movement_key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func mapped_input(ctx) -> void:
	var d = ctx.definitions()
	d.spawn_interval = 100.0
	var main = lifecycle.main_scene(ctx, d)
	var run = main.coordinator
	var arena_start: Vector3 = run.player.position
	var directions := [[Vector3(0, 0, -3), Vector3(0, 0, 3), Vector3(-3, 0, 0), Vector3(3, 0, 0)],
		[Vector3(-3, 0, 0), Vector3(3, 0, 0), Vector3(0, 0, 3), Vector3(0, 0, -3)]]
	for yaw_index in 2:
		run.player.position = arena_start
		if yaw_index == 1:
			pause.mouse(main, Vector2(750, -10000))
			run.step(0.125)
			ctx.check(run.camera.yaw == 90 and run.player.position == arena_start, "mouse-only viewport rotation sets 90-degree yaw without player travel")
		for index in KEYS.size():
			run.player.position = arena_start
			movement_key(KEYS[index], true)
			ctx.check(Input.is_action_pressed(ACTIONS[index]), "configured physical key activates corresponding action")
			run.step(0.5)
			F.near(ctx, run.player.position - arena_start, directions[yaw_index][index], "actual WASD input after yaw/pitch")
			movement_key(KEYS[index], false)
			var stopped: Vector3 = run.player.position
			run.step(0.125)
			ctx.check(run.player.position == stopped, "physical key release stops movement")
		for pair in [[KEY_W, KEY_S], [KEY_A, KEY_D]]:
			var stopped: Vector3 = run.player.position
			for code in pair:
				movement_key(code, true)
			run.step(0.5)
			ctx.check(run.player.position == stopped, "opposed mapped physical keys cancel")
			for code in pair:
				movement_key(code, false)
		# Same encounter, same position: no player/player or enemy blocking.
		run.player.position = arena_start
		var first = lifecycle.add_contact(ctx, run, d)
		var second = lifecycle.add_contact(ctx, run, d)
		movement_key(KEY_D, true)
		movement_key(KEY_W, true)
		run.step(0.5)
		movement_key(KEY_D, false)
		movement_key(KEY_W, false)
		ctx.check(abs(run.player.position.distance_to(arena_start) - 3.0) < 0.00001, "diagonal mapped input has equal travel and leaves overlapping enemies without blocking")
		ctx.check(first.position.is_equal_approx(second.position), "overlapping pursuing enemies do not separate or block each other")
		first.health.apply_damage(999)
		second.health.apply_damage(999)
	ctx.done()
