extends RefCounted

const Validator = preload("res://scripts/data/definition_validator.gd")

func cases() -> Array[Dictionary]:
	return [
		{"id": "definitions.defaults", "method": "defaults"},
		{"id": "definitions.references", "method": "references"},
		{"id": "definitions.numbers", "method": "numbers"},
		{"id": "definitions.vectors", "method": "vectors"},
		{"id": "definitions.geometry", "method": "geometry"},
		{"id": "definitions.camera", "method": "camera"},
		{"id": "definitions.boundaries", "method": "boundaries"},
		{"id": "definitions.nonmutation", "method": "nonmutation"},
	]

func defaults(ctx) -> void:
	var run: RunDefinition = ctx.definitions()
	ctx.check(Validator.validate(run).is_empty(), "default resource set validates")
	var expected := {
		"player": {"max_health": 100, "movement_speed": 6.0, "visual_radius": 0.4, "visual_height": 1.6},
		"enemy": {"max_health": 30, "movement_speed": 3.0, "visual_radius": 0.4, "visual_height": 1.2, "contact_distance": 1.2, "contact_damage": 10, "contact_interval": 1.0},
		"weapon": {"range": 4.0, "damage": 10, "attack_interval": 0.6, "feedback_duration": 0.12},
		"arena": {"half_extents_xz": Vector2(20, 20), "floor_y": 0.0, "boundary_visual_height": 0.15, "player_start_xz": Vector2.ZERO},
	}
	for reference in expected:
		for field in expected[reference]:
			ctx.check(run.get(reference).get(field) == expected[reference][field], reference + "." + field)
	for field in {"schema_version": 1, "spawn_interval": 1.5, "max_live_enemies": 50, "camera_yaw": 0.0, "camera_depression": 35.0, "depression_min": 15.0, "depression_max": 65.0, "camera_distance": 8.0, "camera_target_height": 1.2, "mouse_sensitivity": 0.12, "camera_fov": 70.0}:
		ctx.check(run.get(field) == RunDefinition.new().get(field), "run default " + field)
	run.max_live_enemies = 200
	ctx.check(Validator.validate(run).is_empty(), "custom 200 cap is allowed")
	ctx.done()

func references(ctx) -> void:
	ctx.check(not Validator.validate(null).is_empty(), "missing run rejected")
	ctx.check(not Validator.validate(Resource.new()).is_empty(), "wrong run type rejected")
	for field in ["player", "enemy", "weapon", "arena"]:
		for value in [null, Resource.new()]:
			var run: RunDefinition = ctx.definitions()
			run.set(field, value)
			reject(ctx, run, field)
	var run: RunDefinition = ctx.definitions()
	run.schema_version = 2
	reject(ctx, run, "schema_version")
	ctx.done()

func numbers(ctx) -> void:
	for reference in ["player", "enemy", "weapon", "run"]:
		var integer_fields: Array = {"player": ["max_health"], "enemy": ["max_health", "contact_damage"], "weapon": ["damage"], "run": ["max_live_enemies"]}[reference]
		for field in integer_fields:
			for value in [0, -1]:
				var run: RunDefinition = ctx.definitions()
				var target: Resource = run if reference == "run" else run.get(reference)
				target.set(field, value)
				reject(ctx, run, field)
	# Typed integer exports prevent float assignment without conversion. Test the
	# validator's raw integer predicate too; it must never accept integral floats.
	for value in [50.0, 1.5, "50", true, null, INF, NAN, 0, -1]:
		ctx.check(not Validator.is_positive_integer(value), "integer contract rejects " + str(value))
	ctx.check(Validator.is_positive_integer(200), "integer contract accepts 200")
	var fields := {
		"player": ["movement_speed", "visual_radius", "visual_height"],
		"enemy": ["movement_speed", "visual_radius", "visual_height", "contact_distance", "contact_interval"],
		"weapon": ["range", "attack_interval", "feedback_duration"],
		"arena": ["boundary_visual_height"],
		"run": ["spawn_interval", "camera_depression", "depression_min", "depression_max", "camera_distance", "camera_target_height", "mouse_sensitivity", "camera_fov"],
	}
	for reference in fields:
		for field in fields[reference]:
			for value in [0.0, -1.0, NAN, INF, -INF]:
				var run: RunDefinition = ctx.definitions()
				var target: Resource = run if reference == "run" else run.get(reference)
				target.set(field, value)
				reject(ctx, run, field)
	for field in ["camera_yaw", "floor_y"]:
		for value in [NAN, INF, -INF]:
			var run: RunDefinition = ctx.definitions()
			var target: Resource = run if field == "camera_yaw" else run.arena
			target.set(field, value)
			reject(ctx, run, field)
	var valid: RunDefinition = ctx.definitions()
	valid.arena.floor_y = -30.0
	valid.camera_yaw = -720.0
	valid.spawn_interval = 0.001
	ctx.check(Validator.validate(valid).is_empty(), "finite floor/yaw and sub-tick interval accepted")
	ctx.done()

func vectors(ctx) -> void:
	for field in ["half_extents_xz", "player_start_xz"]:
		for value in [Vector2(NAN, 0), Vector2(0, NAN), Vector2(INF, 0), Vector2(0, -INF)]:
			var run: RunDefinition = ctx.definitions()
			run.arena.set(field, value)
			reject(ctx, run, field)
	for value in [Vector2.ZERO, Vector2(-1, 20), Vector2(20, -1)]:
		var run: RunDefinition = ctx.definitions()
		run.arena.half_extents_xz = value
		reject(ctx, run, "half_extents_xz")
	ctx.done()

func geometry(ctx) -> void:
	for reference in ["player", "enemy"]:
		var run: RunDefinition = ctx.definitions()
		run.get(reference).visual_radius = 20.0
		reject(ctx, run, "half_extents_xz")
	for value in [Vector2(19.60001, 0), Vector2(0, -19.60001)]:
		var run: RunDefinition = ctx.definitions()
		run.arena.player_start_xz = value
		reject(ctx, run, "player_start_xz")
	var run: RunDefinition = ctx.definitions()
	run.arena.player_start_xz = Vector2(19.6, -19.6)
	ctx.check(Validator.validate(run).is_empty(), "inclusive player inset")
	run.arena.boundary_visual_height = run.camera_target_height
	reject(ctx, run, "boundary_visual_height")
	ctx.done()

func camera(ctx) -> void:
	for changes in [{"depression_min": 36.0}, {"depression_max": 34.0}, {"depression_max": 90.0}, {"camera_fov": 1.0}, {"camera_fov": 179.0}, {"camera_target_height": 1.60001}]:
		var run: RunDefinition = ctx.definitions()
		for field in changes:
			run.set(field, changes[field])
		ctx.check(not Validator.validate(run).is_empty(), "invalid view " + str(changes))
	var run: RunDefinition = ctx.definitions()
	run.camera_depression = run.depression_min
	ctx.check(Validator.validate(run).is_empty(), "inclusive depression min")
	run.camera_depression = run.depression_max
	run.camera_target_height = run.player.visual_height
	ctx.check(Validator.validate(run).is_empty(), "inclusive depression max and visual height")
	ctx.check(Validator.camera_height_above_floor(run) > 0.0, "minimum-depression camera above floor")
	# Finite inputs whose arithmetic overflows must also fail derived geometry.
	run.camera_distance = 1.7e308
	run.camera_target_height = 1.7e308
	run.player.visual_height = 1.7e308
	run.depression_min = 80.0
	run.camera_depression = 80.0
	run.depression_max = 85.0
	reject(ctx, run, "camera_distance")
	ctx.done()

func boundaries(ctx) -> void:
	var run: RunDefinition = ctx.definitions()
	run.enemy.visual_radius = 0.5
	run.arena.half_extents_xz = Vector2(3.5, 4.5)
	run.enemy.contact_distance = 5.0
	reject(ctx, run, "contact_distance")
	run.enemy.contact_distance = 4.999999
	ctx.check(Validator.validate(run).is_empty(), "strict spawn upper bound just inside")
	run.enemy.contact_distance = 5.000001
	reject(ctx, run, "contact_distance")
	run = ctx.definitions()
	run.player.visual_radius = 0.5
	run.enemy.visual_radius = 1.5
	run.enemy.contact_distance = sqrt(2.0)
	ctx.check(Validator.validate(run).is_empty(), "inclusive unequal-radius corner lower bound")
	run.enemy.contact_distance = sqrt(2.0) - 0.000001
	reject(ctx, run, "contact_distance")
	run.enemy.contact_distance = sqrt(2.0) + 0.000001
	ctx.check(Validator.validate(run).is_empty(), "unequal-radius above lower bound")
	run.arena.half_extents_xz = Vector2(1.6, 1.6)
	reject(ctx, run, "contact_distance")
	ctx.done()

func nonmutation(ctx) -> void:
	var shared: RunDefinition = load("res://resources/definitions/run.tres")
	var before := snapshot(shared)
	var copy: RunDefinition = ctx.definitions()
	copy.enemy.contact_distance = 0.001
	copy.enemy.visual_radius = 2.0
	var copy_before := snapshot(copy)
	ctx.check(not Validator.validate(copy).is_empty(), "incompatible copy rejected")
	ctx.check(snapshot(copy) == copy_before, "validator never repairs incompatible data")
	ctx.check(snapshot(shared) == before, "isolated fixtures never mutate shared resources")
	ctx.check(Validator.validate(shared).is_empty(), "shared resources still valid")
	ctx.done()

func reject(ctx, run: RunDefinition, field: String) -> void:
	var errors: Array[String] = Validator.validate(run)
	var found := false
	for error in errors:
		var record: Variant = JSON.parse_string(error)
		ctx.check(record is Dictionary and record.has_all(["source", "field", "observed", "constraint", "cause"]), "actionable diagnostic payload")
		if record is Dictionary and record.field == field:
			found = true
			ctx.check(not str(record.source).is_empty() and not str(record.constraint).is_empty(), "resource/constraint identified")
	ctx.check(found, "rejected field " + field)

func snapshot(run: RunDefinition) -> String:
	var result := {}
	for reference in [run, run.player, run.enemy, run.weapon, run.arena]:
		var values := {}
		for property in reference.get_property_list():
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and not reference.get(property.name) is Resource:
				values[property.name] = str(reference.get(property.name))
		result[str(result.size())] = values
	return JSON.stringify(result)
