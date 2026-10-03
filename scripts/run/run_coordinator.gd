extends Node3D
const ArenaScene = preload("res://scenes/arena.tscn")
const PlayerScene = preload("res://scenes/player.tscn")
const EnemyScene = preload("res://scenes/enemy.tscn")
const CameraScene = preload("res://scenes/camera_rig.tscn")
const HudScene = preload("res://scenes/hud.tscn")
const Registry = preload("res://scripts/run/live_registry.gd")
const Spawner = preload("res://scripts/run/enemy_spawner.gd")
const Weapon = preload("res://scripts/combat/automatic_weapon.gd")
const Feedback = preload("res://scripts/combat/attack_feedback.gd")

signal state_changed(state: String)
signal time_changed(time: float)
var state: String = "ConfigurationError"
var simulation_enabled: bool = false
var active_time: float = 0.0
var completed_step_count: int = 0
var next_spawn_id: int = 0
var run_generation: int = 1
var spawn_failure_count: int = 0
var acceptance_invalid: bool = false
var configuration_diagnostics: Array[String] = []
var spawn_diagnostics: Array = []
var arena: Node3D
var player: Node3D
var camera: Node3D
var registry: Node
var spawner: Node
var weapon: Node
var hud: CanvasLayer
var feedback: Node3D
var profile_capture: Node
var runtime_definition: RunDefinition
var survival_window_outcome: String = "outstanding"
var continuation_outcome: String = "outstanding"
var continuation_evidence: Dictionary = {}
var stepping: bool = false
var configured_camera_distance: float
var configured_camera_fov: float

func start_run(definition: Variant) -> void:
	assert(hud == null, "US1 starts exactly one encounter; restart belongs to US2")
	hud = HudScene.instantiate()
	add_child(hud)
	configuration_diagnostics = DefinitionValidator.validate(definition)
	if not configuration_diagnostics.is_empty():
		hud.present_configuration_error(configuration_diagnostics)
		return
	runtime_definition = definition.duplicate()
	for field in ["arena", "player", "enemy", "weapon"]:
		runtime_definition.set(field, definition.get(field).duplicate())
	arena = ArenaScene.instantiate()
	add_child(arena)
	arena.configure(runtime_definition.arena)
	player = PlayerScene.instantiate()
	add_child(player)
	player.configure(runtime_definition.player)
	var start: Vector2 = runtime_definition.arena.player_start_xz
	player.position = Vector3(start.x, runtime_definition.arena.floor_y, start.y)
	camera = CameraScene.instantiate()
	add_child(camera)
	camera.reset(runtime_definition, player)
	# Record the engine's actual configured geometry, including real_t rounding.
	configured_camera_distance = camera.get_node("Yaw/Pitch/Camera3D").position.z
	configured_camera_fov = camera.get_node("Yaw/Pitch/Camera3D").fov
	registry = Registry.new()
	add_child(registry)
	weapon = Weapon.new()
	player.add_child(weapon)
	weapon.configure(runtime_definition.weapon)
	feedback = Feedback.new()
	add_child(feedback)
	feedback.configure(runtime_definition.weapon)
	weapon.attack_feedback.connect(feedback.show_attack)
	weapon.attack_feedback.connect(_weapon_feedback)
	spawner = Spawner.new()
	add_child(spawner)
	spawner.configure(runtime_definition, arena, registry, create_enemy, run_generation)
	spawner.opportunity_failed.connect(_spawn_failed)
	spawner.opportunity_consumed.connect(_spawn_consumed)
	player.health.health_changed.connect(hud.present_health)
	player.health.died.connect(_player_died)
	hud.present_health(player.health.current_health, player.health.max_health)
	hud.present_time(active_time)
	state = "Active"
	simulation_enabled = true
	state_changed.emit(state)

func create_enemy() -> Node3D:
	return EnemyScene.instantiate()

func _physics_process(delta: float) -> void:
	step(delta)

func step(delta: float) -> void:
	if not simulation_enabled or state != "Active" or stepping:
		return
	assert(is_finite(delta) and delta > 0, "Delivered simulation delta must be positive finite")
	stepping = true
	var t_end := active_time + delta
	var old_position := player.position
	var old_yaw: float = camera.yaw
	var old_depression: float = camera.depression
	var old_health: int = player.health.current_health
	camera.consume_mouse()
	var input := Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward"))
	player.step(delta, input, camera.yaw, arena)
	camera.follow(player.position)
	for enemy in registry.living_in_spawn_order():
		enemy.step(delta, player.position, arena)
	if spawner.step(t_end, player.position, next_spawn_id):
		next_spawn_id += 1
	weapon.step(t_end, player.position, registry.living_in_spawn_order())
	for enemy in registry.living_in_spawn_order():
		if state != "Active":
			break
		enemy.step_contact(t_end, player.position, player.health)
	active_time = t_end
	completed_step_count += 1
	time_changed.emit(active_time)
	if state == "Active":
		feedback.present(active_time)
	hud.present_time(active_time)
	hud.present_state(state)
	_record_continuation(old_position, old_yaw, old_depression)
	if active_time > 300 and player.health.current_health < old_health:
		continuation_evidence["contact_damage"] = active_time
	if profile_capture != null:
		profile_capture.record_step(run_generation, active_time, completed_step_count, Time.get_ticks_usec() / 1000000.0, registry.living_in_spawn_order().size(), state == "Active")
		profile_capture.record_continuation(run_generation, continuation_evidence)
	stepping = false

func _player_died() -> void:
	if state != "Active":
		return
	state = "GameOver"
	camera.clear_pending_input()
	feedback.clear()
	state_changed.emit(state)

func _spawn_failed(records: Array) -> void:
	spawn_failure_count += 1
	acceptance_invalid = true
	spawn_diagnostics.append_array(records)
	if profile_capture != null:
		profile_capture.record_spawn_failure(run_generation, {"records": records})

func _spawn_consumed(t_end: float, outcome: String) -> void:
	if t_end > 300 and outcome in ["spawned", "cap_skip"]:
		continuation_evidence["spawn_opportunity"] = t_end

func _weapon_feedback(t_end: float, _position: Vector3, _target: Node3D) -> void:
	if t_end > 300:
		continuation_evidence["weapon_attack"] = t_end

func _record_continuation(old_position: Vector3, old_yaw: float, old_depression: float) -> void:
	if survival_window_outcome == "outstanding" and (active_time >= 300 or state != "Active"):
		survival_window_outcome = "passed" if active_time >= 300 and state == "Active" else "failed"
	if active_time > 300:
		continuation_evidence["time_advanced"] = active_time
		if player.position != old_position:
			continuation_evidence["movement"] = active_time
		if camera.yaw != old_yaw or camera.depression != old_depression:
			continuation_evidence["view"] = active_time
		# Definitions are copied; record comparison rather than assuming no mutation.
		if _tuning_is_unchanged():
			continuation_evidence["unchanged_tuning_vulnerability"] = active_time
		else:
			continuation_evidence.erase("unchanged_tuning_vulnerability")
			acceptance_invalid = true
	if survival_window_outcome == "passed" and continuation_evidence.has_all(["time_advanced", "movement", "view", "spawn_opportunity", "unchanged_tuning_vulnerability"]):
		continuation_outcome = "passed"

func _tuning_is_unchanged() -> bool:
	var p: PlayerDefinition = runtime_definition.player
	var e: EnemyDefinition = runtime_definition.enemy
	var w: WeaponDefinition = runtime_definition.weapon
	var a: ArenaDefinition = runtime_definition.arena
	for enemy in registry.living_in_spawn_order():
		if not (enemy.health.max_health == e.max_health and enemy.movement_speed == e.movement_speed
			and enemy.visual_radius == e.visual_radius and enemy.contact_distance == e.contact_distance
			and enemy.contact_damage == e.contact_damage and enemy.contact_interval == e.contact_interval):
			return false
	return (player.health.max_health == p.max_health and player.movement_speed == p.movement_speed
		and player.visual_radius == p.visual_radius
		and spawner.spawn_interval == runtime_definition.spawn_interval
		and spawner.max_live_enemies == runtime_definition.max_live_enemies
		and spawner.enemy_definition.max_health == e.max_health
		and spawner.enemy_definition.movement_speed == e.movement_speed
		and spawner.enemy_definition.visual_radius == e.visual_radius
		and spawner.enemy_definition.contact_distance == e.contact_distance
		and spawner.enemy_definition.contact_damage == e.contact_damage
		and spawner.enemy_definition.contact_interval == e.contact_interval
		and weapon.damage == w.damage and weapon.range_squared == w.range * w.range
		and weapon.attack_interval == w.attack_interval and feedback.duration == w.feedback_duration
		and arena.floor_y == a.floor_y and arena.half_extents == a.half_extents_xz
		and camera.target_height == runtime_definition.camera_target_height
		and camera.sensitivity == runtime_definition.mouse_sensitivity
		and camera.depression_min == runtime_definition.depression_min
		and camera.depression_max == runtime_definition.depression_max
		and camera.get_node("Yaw/Pitch/Camera3D").position.z == configured_camera_distance
		and camera.get_node("Yaw/Pitch/Camera3D").fov == configured_camera_fov)
