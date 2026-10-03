extends Node3D
const Health = preload("res://scripts/combat/health.gd")
var health: Node
var movement_speed: float
var visual_radius: float

func configure(definition: PlayerDefinition) -> void:
	movement_speed = definition.movement_speed
	visual_radius = definition.visual_radius
	if health == null:
		health = Health.new()
		add_child(health)
	health.configure(definition.max_health)
	$Visual.mesh = CylinderMesh.new()
	$Visual.mesh.top_radius = visual_radius
	$Visual.mesh.bottom_radius = visual_radius
	$Visual.mesh.height = definition.visual_height
	$Visual.position.y = definition.visual_height / 2.0

func step(delta: float, input_vector: Vector2, camera_yaw: float, arena: Node3D) -> void:
	if not health.is_alive():
		return
	var direction := Vector3(input_vector.x, 0, input_vector.y).normalized().rotated(Vector3.UP, deg_to_rad(camera_yaw))
	position = arena.clamp_position(position + direction * movement_speed * delta, visual_radius)
