extends RefCounted

const F = preload("res://tests/support/gameplay_fixture.gd")
const Faults = preload("res://tests/support/spawn_faults.gd")

func cases() -> Array[Dictionary]:
	return F.cases_for("survival", ["fresh", "cadence_cap", "default_custom_cap", "deadlines", "subtick_long_step", "wall_stall", "order", "lethal", "hud", "startup_failure", "selection_fault", "instantiation_fault", "partial_fault"],
		["res://scripts/run/main.gd", "res://scripts/run/run_coordinator.gd", "res://scripts/run/enemy_spawner.gd", "res://scenes/arena.tscn", "res://scenes/player.tscn", "res://scenes/enemy.tscn", "res://scenes/camera_rig.tscn", "res://scenes/hud.tscn"])

func quiet_definition(ctx):
	var d = ctx.definitions()
	d.enemy.movement_speed = 0.000001
	d.weapon.range = 0.01
	return d

func population(ctx, run) -> int:
	return F.invoke(ctx, run.registry, "living_in_spawn_order").size()

func fresh(ctx) -> void:
	var d = ctx.definitions()
	var before := F.snapshot(d)
	var run = F.run(ctx, d)
	ctx.check(run.state == "Active" and run.active_time == 0 and run.completed_step_count == 0, "fresh valid Active clock")
	ctx.check(population(ctx, run) == 0 and run.next_spawn_id == 0, "fresh empty population and IDs")
	ctx.check(run.spawn_failure_count == 0 and not run.acceptance_invalid, "fresh failure isolation")
	ctx.check(run.player.health.current_health == 100 and run.weapon.next_attack_at == 0, "full health and ready weapon")
	ctx.check(run.spawner.next_spawn_at == 1.5 and run.spawner.next_spawn_index == 1, "full initial spawn delay")
	ctx.check(run.camera.yaw == 0 and run.camera.depression == 35 and run.player.position == Vector3.ZERO, "initial view and position")
	ctx.check(run.profile_capture == null, "normal Play creates no profile sampler")
	ctx.check(F.snapshot(d) == before, "startup does not mutate definition assets")
	d.player.movement_speed = 1.0
	d.enemy.contact_damage = 99
	d.weapon.damage = 99
	d.spawn_interval = 0.125
	d.camera_distance = 12.0
	d.arena.floor_y = 10.0
	F.invoke(ctx, run, "step", [0.25])
	ctx.check(run.player.movement_speed == 6.0 and run.spawner.enemy_definition.contact_damage == 10 and run.weapon.damage == 10, "existing encounter retains independent actor/combat tuning after shared edits")
	ctx.check(run.spawner.next_spawn_at == 1.5 and population(ctx, run) == 0 and run.arena.floor_y == 0.0 and run.camera.get_node("Yaw/Pitch/Camera3D").position.z == 8.0, "existing encounter retains cadence/arena/view snapshots after shared edits")
	ctx.done()

func cadence_cap(ctx) -> void:
	var d = quiet_definition(ctx)
	d.max_live_enemies = 3
	var run = F.run(ctx, d)
	F.invoke(ctx, run, "step", [1.0])
	ctx.check(population(ctx, run) == 0, "no first spawn before full interval")
	F.invoke(ctx, run, "step", [0.5])
	ctx.check(population(ctx, run) == 1, "first opportunity at 1.5")
	F.invoke(ctx, run, "step", [1.5])
	ctx.check(population(ctx, run) == 2, "second opportunity at 3.0")
	F.invoke(ctx, run, "step", [1.5])
	ctx.check(population(ctx, run) == 3, "third opportunity at 4.5")
	var faults := Faults.new()
	run.spawner.selection_callable = faults.choose_spawn
	for _index in 3:
		F.invoke(ctx, run, "step", [1.5])
		ctx.check(population(ctx, run) == 3 and run.spawn_failure_count == 0, "three full-cap opportunities skipped without failures")
	ctx.check(faults.selection_calls == 0, "cap skip never invokes selection")
	var enemy = F.invoke(ctx, run.registry, "living_in_spawn_order")[0]
	F.invoke(ctx, enemy.health, "apply_damage", [999])
	ctx.check(population(ctx, run) == 2, "death removes capacity synchronously; no immediate refill")
	F.invoke(ctx, run, "step", [0.5])
	ctx.check(population(ctx, run) == 2, "capacity does not reopen consumed opportunity")
	# Restore the real selector before the next ordinary cadence, not a fake spawn.
	run.spawner.selection_callable = run.arena.choose_spawn
	F.invoke(ctx, run, "step", [1.0])
	ctx.check(population(ctx, run) == 3 and run.spawner.next_spawn_at == 12.0, "one next-cadence refill without catch-up")
	ctx.done()

func default_custom_cap(ctx) -> void:
	for cap in [50, 200]:
		var d = quiet_definition(ctx)
		d.max_live_enemies = cap
		d.spawn_interval = 0.125
		var run = F.run(ctx, d)
		for _index in cap + 3:
			F.invoke(ctx, run, "step", [0.125])
		ctx.check(population(ctx, run) == cap and run.spawn_failure_count == 0, "default/custom cap reached without hard-coded ceiling: " + str(cap))
	ctx.done()

func deadlines(ctx) -> void:
	# Representable deltas bracket t_end; no timer HUD rounding or epsilon.
	var before := 0.5 - pow(2.0, -54.0)
	var after := 0.5 + pow(2.0, -53.0)
	ctx.check(before < 0.5 and after > 0.5, "binary neighbours actually bracket completion deadline")
	for end in [before, 0.5, after]:
		var d = quiet_definition(ctx)
		d.spawn_interval = 0.5
		var run = F.run(ctx, d)
		F.invoke(ctx, run, "step", [end])
		ctx.check(population(ctx, run) == (0 if end < 0.5 else 1), "spawn compares t_end before/at/after deadline")
		ctx.check(run.active_time == end and run.completed_step_count == 1, "one final completed-time commit")
	for end in [before, 0.5, after]:
		var d = ctx.definitions()
		d.spawn_interval = 100.0
		var run = F.run(ctx, d)
		var enemy = F.enemy(ctx, d, 0, Vector3.ZERO)
		F.invoke(ctx, run.registry, "add", [enemy, 0])
		run.weapon.next_attack_at = 0.5
		enemy.next_contact_at = 0.5
		F.invoke(ctx, run, "step", [end])
		ctx.check(enemy.health.current_health == (30 if end < 0.5 else 20), "weapon uses step completion deadline")
		ctx.check(run.player.health.current_health == (100 if end < 0.5 else 90), "contact uses same completion deadline")
	ctx.done()

func subtick_long_step(ctx) -> void:
	var d = ctx.definitions()
	d.spawn_interval = 0.001
	d.weapon.attack_interval = 0.001
	d.enemy.contact_interval = 0.001
	d.enemy.max_health = 1000
	# Isolate scheduling: normal-speed spawned actors otherwise reach contact
	# during the eight-second pursuit step and correctly add independent hits.
	d.enemy.movement_speed = 0.000001
	var run = F.run(ctx, d)
	var enemy = F.enemy(ctx, d, 0, Vector3.ZERO)
	F.invoke(ctx, run.registry, "add", [enemy, 0])
	run.next_spawn_id = 1
	for _index in 2:
		F.invoke(ctx, run, "step", [0.015625])
	ctx.check(population(ctx, run) == 3 and enemy.health.current_health == 980 and run.player.health.current_health == 80, "sub-tick intervals permit one spawn/hit/contact per step")
	ctx.check(run.spawner.next_spawn_at > run.active_time and run.spawner.next_spawn_at <= run.active_time + 0.001, "crossed spawn multiples consumed")
	print("HORDE_CADENCE=subtick fixture: 2 actions in 2 executed 0.015625-second steps (64 Hz effective, configured 1000 Hz)")
	F.invoke(ctx, run, "step", [8.0])
	ctx.check(population(ctx, run) == 4 and enemy.health.current_health == 970 and run.player.health.current_health == 70, "long simulated step never creates bursts")
	ctx.done()

func wall_stall(ctx) -> void:
	var d = quiet_definition(ctx)
	var run = F.run(ctx, d)
	F.invoke(ctx, run, "step", [0.25])
	# A real short wall wait while its automatic driver is disabled; no synthetic delta.
	OS.delay_msec(20)
	ctx.check(run.active_time == 0.25 and run.completed_step_count == 1 and population(ctx, run) == 0, "wall stall alone awards no simulation time/events")
	F.invoke(ctx, run, "step", [0.25])
	ctx.check(run.active_time == 0.5, "next delivered simulation delta alone advances time")
	ctx.done()

func order(ctx) -> void:
	var d = ctx.definitions()
	d.spawn_interval = 1.0
	var run = F.run(ctx, d)
	var enemy = F.enemy(ctx, d, 0, Vector3(0, 0, -10))
	F.invoke(ctx, run.registry, "add", [enemy, 0])
	run.next_spawn_id = 1
	var selection_observations: Array = []
	run.spawner.selection_callable = func(player_position, _radius, _contact, _rng):
		selection_observations.append([player_position, enemy.position])
		return {"success": true, "position": player_position + Vector3(2, 0, 0), "diagnostics": []}
	F.invoke(ctx, run.camera, "queue_mouse", [Vector2(750, 0)])
	Input.action_press("move_forward")
	F.invoke(ctx, run, "step", [1.0])
	Input.action_release("move_forward")
	F.near(ctx, run.player.position, Vector3(-6, 0, 0), "queued mouse consumed before same-step input")
	F.near(ctx, run.camera.global_position, Vector3(-6, 1.2, 0), "camera follows moved player")
	ctx.check(enemy.position.x < 0 and enemy.position.z > -10 and enemy.position.distance_to(Vector3(0, 0, -10)) <= 3.000001, "pursuit uses already moved player before spawn")
	ctx.check(selection_observations.size() == 1 and selection_observations[0][0] == run.player.position and selection_observations[0][1] == enemy.position, "spawn selection occurs after player movement and existing-enemy pursuit")
	var spawned = F.invoke(ctx, run.registry, "living_in_spawn_order")[1]
	ctx.check(spawned.health.current_health == 20 and run.player.health.current_health == 100, "new eligible spawn participates in same-step weapon, stays outside contact")
	# Actual synchronous death is the ordering witness: weapon excludes contact.
	d = ctx.definitions()
	d.spawn_interval = 100.0
	d.weapon.damage = 30
	run = F.run(ctx, d)
	enemy = F.enemy(ctx, d, 0, Vector3.ZERO)
	F.invoke(ctx, run.registry, "add", [enemy, 0])
	F.invoke(ctx, run, "step", [0.125])
	ctx.check(population(ctx, run) == 0 and run.player.health.current_health == 100, "weapon death/removal occurs before contacts")
	ctx.done()

func lethal(ctx) -> void:
	var d = ctx.definitions()
	d.player.max_health = 10
	d.spawn_interval = 100.0
	var run = F.run(ctx, d)
	var first = F.enemy(ctx, d, 0, Vector3.ZERO)
	var later = F.enemy(ctx, d, 1, Vector3.ZERO)
	F.invoke(ctx, run.registry, "add", [later, 1])
	F.invoke(ctx, run.registry, "add", [first, 0])
	var commits := F.observe(ctx, run, "time_changed")
	var states := F.observe(ctx, run, "state_changed")
	F.invoke(ctx, run, "step", [0.125])
	ctx.check(run.state == "GameOver" and run.player.health.current_health == 0 and states == [["GameOver"]], "one lethal transition in spawn order")
	ctx.check(not run.feedback.visible, "defeat clears actual feedback")
	ctx.check(first.next_contact_at == 1.125 and later.next_contact_at == 0, "later contact aborted after lethal damage")
	ctx.check(run.active_time == 0.125 and run.completed_step_count == 1 and commits == [[0.125]], "lethal final timestamp committed once")
	F.invoke(ctx, run, "step", [10.0])
	ctx.check(run.active_time == 0.125 and run.completed_step_count == 1 and later.next_contact_at == 0, "no subsequent gameplay after lethal step")
	ctx.done()

func hud(ctx) -> void:
	var hud = F.instance(ctx, "res://scenes/hud.tscn")
	for row in [[0.0, "00:00"], [65.0, "01:05"], [65.999, "01:05"], [6000.0, "100:00"]]:
		F.invoke(ctx, hud, "present_time", [row[0]])
		ctx.check(hud.get_node("Time").text == row[1], "real HUD floor/minute formatting")
	F.invoke(ctx, hud, "present_health", [90, 100])
	ctx.check(hud.get_node("Health").text == "Health: 90 / 100", "actual health label")
	var d = ctx.definitions()
	var run = F.run(ctx, d)
	F.invoke(ctx, run.player.health, "apply_damage", [10])
	F.invoke(ctx, run, "step", [0.125])
	ctx.check(run.hud.get_node("Health").text == "Health: 90 / 100", "signal-wired damage presented by next update")
	ctx.done()

func startup_failure(ctx) -> void:
	var d = ctx.definitions()
	d.player.max_health = 0
	var run = F.run(ctx, d)
	ctx.check(run.state != "Active" and not run.simulation_enabled, "invalid startup blocks simulation")
	ctx.check(run.player == null and run.spawner == null, "invalid startup creates no partial encounter")
	ctx.check(not run.configuration_diagnostics.is_empty(), "actionable configuration diagnostics retained")
	var text: String = run.hud.get_node("ConfigurationError").text
	ctx.check(text.contains("PlayerDefinition") and text.contains("max_health") and text.contains("positive integer"), "visible resource/field/constraint diagnostic")
	for diagnostic in run.configuration_diagnostics:
		ctx.application_diagnostic(JSON.parse_string(diagnostic) if diagnostic is String else diagnostic)
	F.invoke(ctx, run, "step", [10.0])
	ctx.check(run.active_time == 0 and run.completed_step_count == 0, "invalid configuration never simulates")
	ctx.done()

func instantiation_fault(ctx) -> void:
	var run = F.run(ctx, quiet_definition(ctx))
	var faults := Faults.new()
	faults.mode = "instantiate"
	run.spawner.selection_callable = faults.choose_spawn
	run.spawner.enemy_factory = faults.create_enemy
	ctx.connect_callback(Signal(run.spawner, "diagnostic"), ctx.application_diagnostic)
	F.invoke(ctx, run, "step", [1.5])
	ctx.check(faults.selection_calls == 1 and faults.factory_calls == 1 and population(ctx, run) == 0, "null factory result cannot enter registry")
	ctx.check(run.spawn_failure_count == 1 and run.acceptance_invalid and run.spawner.next_spawn_at == 3.0, "instantiation failure consumes/counts once")
	ctx.done()

func selection_fault(ctx) -> void:
	var d = quiet_definition(ctx)
	var run = F.run(ctx, d)
	var faults := Faults.new()
	run.spawner.selection_callable = faults.choose_spawn
	run.spawner.enemy_factory = faults.create_enemy
	var diagnostics := F.observe(ctx, run.spawner, "diagnostic")
	ctx.connect_callback(Signal(run.spawner, "diagnostic"), ctx.application_diagnostic)
	F.invoke(ctx, run, "step", [1.5])
	ctx.check(faults.selection_calls == 1 and faults.factory_calls == 0 and population(ctx, run) == 0, "failed selection has no position read/instantiation/publication")
	ctx.check(diagnostics.size() == 2 and run.spawn_failure_count == 1 and run.acceptance_invalid, "multiple diagnostics consume/count exactly one failed opportunity")
	for event in diagnostics:
		var record: Dictionary = event[0]
		ctx.check(record.has_all(["stage", "source", "field", "observed", "constraint", "cause", "run_generation", "opportunity_index", "scheduled_at", "t_end"]), "enriched diagnostic payload")
		ctx.check(record.run_generation == run.run_generation and record.opportunity_index == 1 and record.scheduled_at == 1.5 and record.t_end == 1.5, "actual failed opportunity timestamps/generation")
	ctx.check(run.spawner.next_spawn_at == 3.0 and run.state == "Active", "failure consumes cadence while simulation continues")
	run.spawner.selection_callable = run.arena.choose_spawn
	run.spawner.enemy_factory = run.create_enemy
	F.invoke(ctx, run, "step", [1.0])
	ctx.check(population(ctx, run) == 0, "no retry before ordinary cadence")
	F.invoke(ctx, run, "step", [0.5])
	ctx.check(population(ctx, run) == 1 and run.spawn_failure_count == 1 and run.acceptance_invalid, "ordinary next spawn; invalidity remains latched")
	ctx.done()

func partial_fault(ctx) -> void:
	var d = quiet_definition(ctx)
	var run = F.run(ctx, d)
	var faults := Faults.new()
	faults.mode = "partial"
	run.spawner.selection_callable = faults.choose_spawn
	run.spawner.enemy_factory = faults.create_enemy
	ctx.connect_callback(Signal(run.spawner, "diagnostic"), ctx.application_diagnostic)
	F.invoke(ctx, run, "step", [1.5])
	ctx.check(faults.factory_calls == 1 and population(ctx, run) == 0, "partially configured instance never published")
	await Engine.get_main_loop().process_frame
	ctx.check(not is_instance_valid(faults.partial), "partial instance disposed before next update")
	ctx.check(run.spawn_failure_count == 1 and run.acceptance_invalid and run.spawner.next_spawn_at == 3.0, "partial construction failure consumes one opportunity")
	ctx.done()
