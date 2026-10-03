extends Node3D
## Replaceable presentation of actual hits; simulation supplies absolute time.
var duration: float
var expires_at: float = 0.0
var target_spawn_id: int = -1
var target: Node3D
var original_color: Color
var line: MeshInstance3D

func _init() -> void:
	line = MeshInstance3D.new()
	line.name = "Line"
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1, 0.95, 0.4)
	line.material_override = material
	add_child(line)
	clear()

func configure(definition: WeaponDefinition) -> void:
	duration = definition.feedback_duration

func show_attack(t_end: float, attacker_position: Vector3, affected_target: Node3D) -> void:
	clear()
	target = affected_target
	target_spawn_id = target.spawn_id
	expires_at = t_end + duration
	original_color = target.get_node("Visual").material_override.albedo_color
	target.get_node("Visual").material_override.albedo_color = Color.WHITE
	var start := attacker_position + Vector3(0, 0.8, 0)
	var finish := target.position + Vector3(0, 0.6, 0)
	var length := start.distance_to(finish)
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.035
	mesh.bottom_radius = 0.035
	mesh.height = maxf(length, 0.001)
	line.mesh = mesh
	line.position = (start + finish) * 0.5
	if length > 0:
		line.quaternion = Quaternion(Vector3.UP, (finish - start).normalized())
	visible = true
	line.visible = true

func present(time: float) -> void:
	if visible and time >= expires_at:
		clear()

func clear() -> void:
	if is_instance_valid(target):
		target.get_node("Visual").material_override.albedo_color = original_color
	target = null
	target_spawn_id = -1
	visible = false
	line.visible = false
