extends Node3D
var yaw: float
var depression: float
var depression_min: float
var depression_max: float
var sensitivity: float
var target_height: float
var target: Node3D
var pending_mouse := Vector2.ZERO

func reset(definition: RunDefinition, player: Node3D) -> void:
	target = player
	yaw = definition.camera_yaw
	depression = definition.camera_depression
	depression_min = definition.depression_min
	depression_max = definition.depression_max
	sensitivity = definition.mouse_sensitivity
	target_height = definition.camera_target_height
	$Yaw/Pitch/Camera3D.position.z = definition.camera_distance
	$Yaw/Pitch/Camera3D.fov = definition.camera_fov
	clear_pending_input()
	apply_mouse(Vector2.ZERO)
	follow(player.position)

func queue_mouse(motion: Vector2) -> void:
	pending_mouse += motion

func consume_mouse() -> void:
	var motion := pending_mouse
	clear_pending_input()
	apply_mouse(motion)

func apply_mouse(motion: Vector2) -> void:
	yaw += motion.x * sensitivity
	depression = clampf(depression + motion.y * sensitivity, depression_min, depression_max)
	$Yaw.rotation.y = deg_to_rad(yaw)
	$Yaw/Pitch.rotation.x = -deg_to_rad(depression)

func follow(player_position: Vector3) -> void:
	position = player_position + Vector3(0, target_height, 0)

func clear_pending_input() -> void:
	pending_mouse = Vector2.ZERO
