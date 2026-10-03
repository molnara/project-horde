extends Node3D
const Health = preload("res://scripts/combat/health.gd")
const Arena = preload("res://scripts/arena/arena.gd")
var health: Node
var spawn_id: int
var movement_speed: float
var visual_radius: float
var contact_distance: float
var contact_damage: int
var contact_interval: float
var next_contact_at: float = 0.0
var configured: bool = false

func configure(definition: EnemyDefinition, id: int) -> bool:
	spawn_id = id
	movement_speed = definition.movement_speed
	visual_radius = definition.visual_radius
	contact_distance = definition.contact_distance
	contact_damage = definition.contact_damage
	contact_interval = definition.contact_interval
	next_contact_at = 0.0
	if health == null:
		health = Health.new()
		add_child(health)
		health.died.connect(_on_death)
	health.configure(definition.max_health)
	$Visual.mesh = CylinderMesh.new()
	$Visual.mesh.top_radius = visual_radius
	$Visual.mesh.bottom_radius = visual_radius
	$Visual.mesh.height = definition.visual_height
	$Visual.position.y = definition.visual_height / 2.0
	# Flash changes must be private to this instance.
	$Visual.material_override = $Visual.material_override.duplicate()
	configured = true
	return true

func _on_death() -> void:
	visible = false
	queue_free()

func step(delta: float, player_position: Vector3, arena: Node3D) -> void:
	if not health.is_alive():
		return
	var offset := Vector3(player_position.x - position.x, 0, player_position.z - position.z)
	var remaining := offset.length()
	if remaining > 0:
		position += offset / remaining * minf(movement_speed * delta, remaining)
	position = arena.clamp_position(position, visual_radius)

func step_contact(t_end: float, player_position: Vector3, player_health: Node) -> void:
	if not health.is_alive() or not player_health.is_alive() or t_end < next_contact_at:
		return
	if Arena.distance_squared_xz(position, player_position) <= contact_distance * contact_distance:
		if player_health.apply_damage(contact_damage) > 0:
			next_contact_at = t_end + contact_interval
