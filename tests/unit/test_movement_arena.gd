extends RefCounted

const F = preload("res://tests/support/gameplay_fixture.gd")
const Sampling = preload("res://tests/support/scripted_rng.gd")

func cases() -> Array[Dictionary]:
	return F.cases_for("movement", ["directions", "mouse_follow", "containment", "selection", "selection_failure", "pursuit"],
		["res://scenes/arena.tscn", "res://scenes/player.tscn", "res://scenes/camera_rig.tscn", "res://scenes/enemy.tscn"])

func directions(ctx) -> void:
	var d = ctx.definitions()
	var arena = F.arena(ctx, d)
	var player = F.player(ctx, d)
	# Explicit expected direction table, not the production rotation algorithm.
	var inputs := [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0), Vector2.ZERO,
		Vector2(0, -1) + Vector2(0, 1), Vector2(-1, 0) + Vector2(1, 0), Vector2(1, -1)]
	var forward := [Vector3(0, 0, -6), Vector3(0, 0, 6), Vector3(-6, 0, 0), Vector3(6, 0, 0), Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3(1, 0, -1).normalized() * 6]
	var rotated := [Vector3(-6, 0, 0), Vector3(6, 0, 0), Vector3(0, 0, 6), Vector3(0, 0, -6), Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3(-1, 0, -1).normalized() * 6]
	for yaw_index in 2:
		for index in inputs.size():
			player.position = Vector3.ZERO
			F.invoke(ctx, player, "step", [1.0, inputs[index], yaw_index * 90.0, arena])
			F.near(ctx, player.position, (forward if yaw_index == 0 else rotated)[index], "W/S/A/D/opposed/released/diagonal yaw " + str(yaw_index))
			ctx.check(player.position.y == d.arena.floor_y, "fixed floor Y")
	player.position = Vector3.ZERO
	F.invoke(ctx, player, "step", [0.5, Vector2(0, -1), 0.0, arena])
	var stopped: Vector3 = player.position
	F.invoke(ctx, player, "step", [1.0, Vector2.ZERO, 0.0, arena])
	ctx.check(player.position == stopped, "release stops immediately after motion")
	ctx.done()

func mouse_follow(ctx) -> void:
	var d = ctx.definitions()
	var player = F.player(ctx, d)
	var arena = F.arena(ctx, d)
	var camera = F.instance(ctx, "res://scenes/camera_rig.tscn")
	F.invoke(ctx, camera, "reset", [d, player])
	F.invoke(ctx, camera, "apply_mouse", [Vector2(750, 0)])
	ctx.check(camera.yaw == 90.0, "rightward 750 pixels rotates yaw +90 degrees")
	ctx.check(player.position == Vector3.ZERO, "mouse alone never moves player")
	for depression_motion in [Vector2(0, -10000), Vector2(0, 10000)]:
		F.invoke(ctx, camera, "apply_mouse", [depression_motion])
		ctx.check(camera.depression == (15.0 if depression_motion.y < 0 else 65.0), "depression clamps, upward reduces it")
		player.position = Vector3.ZERO
		F.invoke(ctx, player, "step", [1.0, Vector2(0, -1), camera.yaw, arena])
		F.near(ctx, player.position, Vector3(-6, 0, 0), "same-step mouse yaw; pitch-independent speed/Y")
		F.invoke(ctx, camera, "follow", [player.position])
		F.near(ctx, camera.global_position, player.position + Vector3(0, 1.2, 0), "synchronous target-height follow")
		var view = camera.get_node("Yaw/Pitch/Camera3D")
		ctx.check(view.global_position.y > d.arena.floor_y, "camera above floor at both bounds")
		ctx.check(is_equal_approx(view.global_position.distance_to(camera.global_position), 8.0) and view.fov == 70.0, "configured distance/FOV")
	F.invoke(ctx, camera, "clear_pending_input")
	ctx.check(camera.pending_mouse == Vector2.ZERO, "pending motion cleared")
	ctx.done()

func containment(ctx) -> void:
	var d = ctx.definitions()
	d.arena.floor_y = -2.0
	var arena = F.arena(ctx, d)
	for radius in [0.4, 1.0]:
		for signs in [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]:
			var actual = F.invoke(ctx, arena, "clamp_position", [Vector3(signs.x * 100, 99, signs.y * 100), radius])
			F.near(ctx, actual, Vector3(signs.x * (20 - radius), -2, signs.y * (20 - radius)), "both actor insets/corners")
		F.near(ctx, F.invoke(ctx, arena, "clamp_position", [Vector3(2, 99, 3), radius]), Vector3(2, -2, 3), "interior XZ preserved")
	ctx.done()

func selection(ctx) -> void:
	var d = ctx.definitions()
	var arena = F.arena(ctx, d)
	var rng := Sampling.new()
	var children_before: int = arena.get_child_count()
	# Sixteen rejected center samples, then deterministic farthest inset corner.
	var selected: Dictionary = F.invoke(ctx, arena, "choose_spawn", [Vector3.ZERO, 0.4, 1.2, rng])
	ctx.check(selected.success is bool and selected.success, "explicit success discriminator")
	ctx.check(selected.position is Vector3 and selected.diagnostics.is_empty(), "valid position with empty diagnostics")
	ctx.check(rng.calls == 32, "exactly sixteen X/Z candidate draws before fallback")
	ctx.check(is_equal_approx(absf(selected.position.x), 19.6) and is_equal_approx(absf(selected.position.z), 19.6) and selected.position.y == 0, "fallback is inset corner")
	var again: Dictionary = F.invoke(ctx, arena, "choose_spawn", [Vector3.ZERO, 0.4, 1.2, Sampling.new()])
	ctx.check(again.position == selected.position, "farthest-corner ties deterministic")
	rng = Sampling.new()
	rng.fractions.assign([0.75, 0.75])
	selected = F.invoke(ctx, arena, "choose_spawn", [Vector3(9.8, 0, 9.8), 0.4, 1.2, rng])
	F.near(ctx, selected.position, Vector3(-19.6, 0, -19.6), "fallback selects farthest corner for off-center player")
	rng = Sampling.new()
	selected = F.invoke(ctx, arena, "choose_spawn", [Vector3(10, 0, 0), 0.4, 1.2, rng])
	ctx.check(selected.success and selected.position == Vector3.ZERO and rng.calls == 2, "eligible Vector3.ZERO succeeds on first candidate")
	# Binary-exact inset/contact geometry: half extent 2.5, radius .5, candidate x=1.
	d.arena.half_extents_xz = Vector2(2.5, 2.5)
	F.invoke(ctx, arena, "configure", [d.arena])
	for fraction in [0.5, 0.75, 0.75006103515625]:
		rng = Sampling.new()
		rng.fractions.assign([fraction, 0.5])
		selected = F.invoke(ctx, arena, "choose_spawn", [Vector3.ZERO, 0.5, 1.0, rng])
		ctx.check(selected.success and Vector2(selected.position.x, selected.position.z).length_squared() > 1.0, "spawn excludes inside/exact contact; accepts strictly outside")
		ctx.check(rng.calls == (2 if fraction > 0.75 else 32), "at/inside samples require bounded fallback")
	ctx.check(arena.get_child_count() == children_before, "selection never instantiates or changes arena scene population")
	ctx.check(not arena.has_method("step_contact") and not arena.has_method("start_run"), "arena does not own combat/run scheduling")
	ctx.done()

func selection_failure(ctx) -> void:
	var d = ctx.definitions()
	var arena = F.arena(ctx, d)
	var before := F.snapshot(d)
	var result: Dictionary = F.invoke(ctx, arena, "choose_spawn", [Vector3.ZERO, 0.4, 100.0, Sampling.new()])
	ctx.check(result.success is bool and not result.success and not result.has("position"), "failure has no sentinel/position")
	ctx.check(result.diagnostics is Array and not result.diagnostics.is_empty(), "selection failure is actionable")
	for diagnostic in result.diagnostics:
		ctx.check(diagnostic.has_all(["stage", "source", "field", "observed", "constraint", "cause"]) and diagnostic.stage == "selection", "required selection diagnostic fields")
		ctx.check(not str(diagnostic.source).is_empty() and not str(diagnostic.constraint).is_empty() and not str(diagnostic.cause).is_empty(), "diagnostic source/constraint/cause nonempty")
		var observations: String = str(diagnostic.observed)
		ctx.check(observations.contains("bounds") and observations.contains("player_position") and observations.contains("enemy_radius") and observations.contains("contact_distance"), "observations include relevant selection inputs")
	ctx.check(F.snapshot(d) == before, "selection never mutates tuning or failure accounting")
	ctx.done()

func pursuit(ctx) -> void:
	var d = ctx.definitions()
	var arena = F.arena(ctx, d)
	var enemy = F.enemy(ctx, d, 0, Vector3.ZERO)
	F.invoke(ctx, enemy, "step", [10.0, Vector3(1, 90, 0), arena])
	ctx.check(enemy.position == Vector3(1, 0, 0), "long pursuit stops at target, ignores target Y")
	F.invoke(ctx, enemy, "step", [1.0, Vector3(1, -90, 0), arena])
	ctx.check(enemy.position == Vector3(1, 0, 0), "coincidence produces no movement")
	for radii in [Vector2(0.4, 0.4), Vector2(0.25, 1.0), Vector2(1.0, 0.25), Vector2(0.5, 1.0)]:
		d.player.visual_radius = radii.x
		d.enemy.visual_radius = radii.y
		d.enemy.contact_distance = sqrt(0.5) if radii == Vector2(0.5, 1.0) else 1.2
		F.invoke(ctx, enemy, "configure", [d.enemy, 0])
		var target := Vector3(20 - radii.x, 0, 20 - radii.x)
		enemy.position = Vector3.ZERO
		F.invoke(ctx, enemy, "step", [100.0, target, arena])
		var expected := Vector3(20 - maxf(radii.x, radii.y), 0, 20 - maxf(radii.x, radii.y))
		F.near(ctx, enemy.position, expected, "unequal radii corner is reachable without overshoot")
		ctx.check(Vector2(enemy.position.x - target.x, enemy.position.z - target.z).length_squared() <= d.enemy.contact_distance * d.enemy.contact_distance, "corner reaches unchanged inclusive contact threshold")
		var victim = F.health(ctx, 100)
		F.invoke(ctx, enemy, "step_contact", [0.0, target, victim])
		ctx.check(victim.current_health == 90, "corner contact is reachable, including equality of unequal-radius feasibility bound")
	ctx.done()
