extends Node3D
## Selection is pure with respect to the scene, scheduling and failure accounting.
var half_extents: Vector2
var floor_y: float
var definition_source: String

func configure(definition: ArenaDefinition) -> void:
	half_extents = definition.half_extents_xz
	floor_y = definition.floor_y
	definition_source = DefinitionValidator.source_of(definition, "Arena")
	$Floor.mesh = PlaneMesh.new()
	$Floor.mesh.size = half_extents * 2.0
	$Floor.position.y = floor_y
	var height: float = definition.boundary_visual_height
	for strip in [$North, $South, $East, $West]:
		strip.mesh = BoxMesh.new()
		strip.position.y = floor_y + height / 2.0
	$North.mesh.size = Vector3(half_extents.x * 2, height, 0.12)
	$South.mesh.size = $North.mesh.size
	$East.mesh.size = Vector3(0.12, height, half_extents.y * 2)
	$West.mesh.size = $East.mesh.size
	$North.position.z = -half_extents.y
	$South.position.z = half_extents.y
	$East.position.x = half_extents.x
	$West.position.x = -half_extents.x

func clamp_position(value: Vector3, radius: float) -> Vector3:
	var inset := half_extents - Vector2.ONE * radius
	return Vector3(clampf(value.x, -inset.x, inset.x), floor_y, clampf(value.z, -inset.y, inset.y))

func choose_spawn(player_position: Vector3, enemy_radius: float, contact_distance: float, rng: Variant) -> Dictionary:
	var inset := half_extents - Vector2.ONE * enemy_radius
	var inputs_valid := player_position.is_finite() and is_finite(enemy_radius) and enemy_radius > 0 and inset.x > 0 and inset.y > 0 and is_finite(contact_distance) and contact_distance > 0
	if inputs_valid:
		for _index in 16:
			var candidate := Vector3(rng.randf_range(-inset.x, inset.x), floor_y, rng.randf_range(-inset.y, inset.y))
			if outside_contact(candidate, player_position, contact_distance):
				return {"success": true, "position": candidate, "diagnostics": []}
		# Fixed corner order breaks exact ties; select the farthest before testing.
		var farthest := Vector3(-inset.x, floor_y, -inset.y)
		var farthest_squared := -1.0
		for corner in [Vector3(-inset.x, floor_y, -inset.y), Vector3(-inset.x, floor_y, inset.y), Vector3(inset.x, floor_y, -inset.y), Vector3(inset.x, floor_y, inset.y)]:
			var squared := distance_squared_xz(corner, player_position)
			if squared > farthest_squared:
				farthest = corner
				farthest_squared = squared
		if outside_contact(farthest, player_position, contact_distance):
			return {"success": true, "position": farthest, "diagnostics": []}
	return {"success": false, "diagnostics": [{"stage": "selection", "source": definition_source, "field": "spawn_geometry", "observed": {"bounds": inset, "player_position": player_position, "enemy_radius": enemy_radius, "contact_distance": contact_distance}, "constraint": "finite inset position strictly outside contact distance", "cause": "Check arena bounds, radii and contact distance; bounded selection found no eligible position."}]}

static func distance_squared_xz(a: Vector3, b: Vector3) -> float:
	# Scalar floats retain precision for inclusive unequal-radius feasibility.
	var dx := float(a.x) - float(b.x)
	var dz := float(a.z) - float(b.z)
	return dx * dx + dz * dz

static func outside_contact(a: Vector3, b: Vector3, distance: float) -> bool:
	return a.is_finite() and distance_squared_xz(a, b) > distance * distance
