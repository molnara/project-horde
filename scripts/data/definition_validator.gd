class_name DefinitionValidator
extends RefCounted
## Pure validation. Callers decide presentation; no fallback or tuning mutation.
## Each returned string is a JSON diagnostic with actionable resource context.

static func is_positive_integer(value: Variant) -> bool:
	return typeof(value) == TYPE_INT and value > 0

static func positive_finite(value: Variant) -> bool:
	return (typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT) and is_finite(float(value)) and value > 0

static func source_of(resource: Resource, fallback: String) -> String:
	return resource.resource_path if resource != null and not resource.resource_path.is_empty() else fallback

static func add_error(errors: Array[String], source: String, field: String, observed: Variant, constraint: String) -> void:
	errors.append(JSON.stringify({"source": source, "field": field, "observed": str(observed), "constraint": constraint, "cause": "Correct the definition before starting a fresh run."}))

static func validate(run_definition: Variant) -> Array[String]:
	var errors: Array[String] = []
	if not run_definition is RunDefinition:
		add_error(errors, "RunDefinition", "run_definition", run_definition, "required RunDefinition resource")
		return errors
	var run: RunDefinition = run_definition
	var source := source_of(run, "RunDefinition")
	if run.schema_version != 1:
		add_error(errors, source, "schema_version", run.schema_version, "supported schema_version = 1")
	var reference_types := {"player": PlayerDefinition, "enemy": EnemyDefinition, "weapon": WeaponDefinition, "arena": ArenaDefinition}
	for field in reference_types:
		var reference: Resource = run.get(field)
		if reference == null or reference.get_script() != reference_types[field]:
			add_error(errors, source, field, reference, "required " + str(reference_types[field].get_global_name()) + " resource")
	# Inspect every correctly typed resource even if another reference is missing.
	var resources := {"run": run}
	for field in reference_types:
		var reference: Resource = run.get(field)
		if reference != null and reference.get_script() == reference_types[field]:
			resources[field] = reference
	var integer_fields := {"run": ["max_live_enemies"], "player": ["max_health"], "enemy": ["max_health", "contact_damage"], "weapon": ["damage"], "arena": []}
	var positive_fields := {
		"run": ["spawn_interval", "camera_depression", "depression_min", "depression_max", "camera_distance", "camera_target_height", "mouse_sensitivity", "camera_fov"],
		"player": ["movement_speed", "visual_radius", "visual_height"],
		"enemy": ["movement_speed", "visual_radius", "visual_height", "contact_distance", "contact_interval"],
		"weapon": ["range", "attack_interval", "feedback_duration"],
		"arena": ["boundary_visual_height"],
	}
	for name in resources:
		var resource: Resource = resources[name]
		var resource_source := source_of(resource, str(resource.get_script().get_global_name()))
		for field in integer_fields[name]:
			if not is_positive_integer(resource.get(field)):
				add_error(errors, resource_source, field, resource.get(field), "positive integer")
		for field in positive_fields[name]:
			if not positive_finite(resource.get(field)):
				add_error(errors, resource_source, field, resource.get(field), "positive finite value")
	if not is_finite(run.camera_yaw):
		add_error(errors, source, "camera_yaw", run.camera_yaw, "finite yaw")
	if run.arena is ArenaDefinition:
		var arena: ArenaDefinition = run.arena
		var arena_source := source_of(arena, "arena definition")
		for field in ["half_extents_xz", "player_start_xz"]:
			var vector: Vector2 = arena.get(field)
			if not vector.is_finite():
				add_error(errors, arena_source, field, vector, "finite XZ vector")
		if not is_finite(arena.floor_y):
			add_error(errors, arena_source, "floor_y", arena.floor_y, "finite floor height")
		if arena.half_extents_xz.x <= 0 or arena.half_extents_xz.y <= 0:
			add_error(errors, arena_source, "half_extents_xz", arena.half_extents_xz, "positive half-extents")
	# Dependent geometry is meaningful only after all primitive/type checks pass.
	if not errors.is_empty():
		return errors
	var player: PlayerDefinition = run.player
	var enemy: EnemyDefinition = run.enemy
	var arena: ArenaDefinition = run.arena
	var arena_source := source_of(arena, "arena definition")
	var enemy_source := source_of(enemy, "enemy definition")
	var extents := arena.half_extents_xz
	var radius := maxf(player.visual_radius, enemy.visual_radius)
	if extents.x <= radius or extents.y <= radius:
		add_error(errors, arena_source, "half_extents_xz", [extents, player.visual_radius, enemy.visual_radius], "half-extents exceed both entity radii")
	var player_inset := extents - Vector2.ONE * player.visual_radius
	if absf(arena.player_start_xz.x) > player_inset.x or absf(arena.player_start_xz.y) > player_inset.y:
		add_error(errors, arena_source, "player_start_xz", [arena.player_start_xz, player_inset], "start lies in inclusive player-inset bounds")
	# Low strips remain below the visual look target. Perimeter visibility also
	# requires the later rendered playtest; data validation cannot establish it.
	if arena.boundary_visual_height >= run.camera_target_height:
		add_error(errors, arena_source, "boundary_visual_height", arena.boundary_visual_height, "boundary height < camera_target_height (%s)" % run.camera_target_height)
	var enemy_inset := extents - Vector2.ONE * enemy.visual_radius
	# Vector2 uses engine real precision; cast to floats for squared comparisons.
	var half_diagonal_squared := float(enemy_inset.x) * float(enemy_inset.x) + float(enemy_inset.y) * float(enemy_inset.y)
	var contact_squared := enemy.contact_distance * enemy.contact_distance
	if not is_finite(contact_squared) or not is_finite(half_diagonal_squared) or contact_squared >= half_diagonal_squared:
		add_error(errors, enemy_source, "contact_distance", [enemy.contact_distance, enemy_inset], "contact_distance strictly less than enemy-inset half-diagonal; finite derived geometry")
	var radius_difference := maxf(enemy.visual_radius - player.visual_radius, 0.0)
	if contact_squared < 2.0 * radius_difference * radius_difference:
		add_error(errors, enemy_source, "contact_distance", [enemy.contact_distance, player.visual_radius, enemy.visual_radius], "contact_distance² >= 2 * max(enemy_radius - player_radius, 0)² (inclusive corner reachability)")
	if not (0.0 < run.depression_min and run.depression_min <= run.camera_depression and run.camera_depression <= run.depression_max and run.depression_max < 90.0):
		add_error(errors, source, "camera_depression", [run.depression_min, run.camera_depression, run.depression_max], "0 < depression_min <= camera_depression <= depression_max < 90")
	if not (1.0 < run.camera_fov and run.camera_fov < 179.0):
		add_error(errors, source, "camera_fov", run.camera_fov, "1 < FOV < 179 degrees")
	if run.camera_target_height > player.visual_height:
		add_error(errors, source, "camera_target_height", [run.camera_target_height, player.visual_height], "0 < camera target height <= player visual height")
	var relative_height := camera_height_above_floor(run)
	var absolute_height := arena.floor_y + relative_height
	if not is_finite(relative_height) or not is_finite(absolute_height) or relative_height <= 0.0 or absolute_height <= arena.floor_y:
		add_error(errors, source, "camera_distance", [relative_height, absolute_height, arena.floor_y], "finite camera height at minimum depression strictly above floor")
	return errors

static func camera_height_above_floor(run: RunDefinition) -> float:
	return run.camera_target_height + run.camera_distance * sin(deg_to_rad(run.depression_min))
