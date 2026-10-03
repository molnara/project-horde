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
signal restart_requested(generation: int)
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
var restart_in_progress: bool = false
var encounter_connections: Array[Dictionary] = []
var retained_attempts: Array[Dictionary] = []

func start_run(definition: Variant) -> void:
	assert(hud == null, "Dispose the previous encounter before constructing a fresh one")
	simulation_enabled = false
	state = "ConfigurationError"
	active_time = 0.0
	completed_step_count = 0
	next_spawn_id = 0
	spawn_failure_count = 0
	acceptance_invalid = false
	spawn_diagnostics.clear()
	continuation_evidence.clear()
	survival_window_outcome = "outstanding"
	continuation_outcome = "outstanding"
	hud = HudScene.instantiate()
	add_child(hud)
	_connect_encounter(hud.restart_requested, request_restart.bind(run_generation))
	configuration_diagnostics = DefinitionValidator.validate(definition)
	if not configuration_diagnostics.is_empty():
		hud.present_configuration_error(configuration_diagnostics)
		state_changed.emit(state)
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
	_connect_encounter(weapon.attack_feedback, _weapon_feedback.bind(run_generation))
	spawner = Spawner.new()
	add_child(spawner)
	spawner.configure(runtime_definition, arena, registry, create_enemy, run_generation)
	_connect_encounter(spawner.opportunity_failed, _spawn_failed.bind(run_generation))
	_connect_encounter(spawner.opportunity_consumed, _spawn_consumed.bind(run_generation))
	_connect_encounter(player.health.health_changed, _health_changed.bind(run_generation))
	_connect_encounter(player.health.died, _player_died.bind(run_generation))
	hud.present_health(player.health.current_health, player.health.max_health)
	hud.present_time(active_time)
	state = "Active"
	simulation_enabled = true
	hud.present_state(state)
	state_changed.emit(state)

func _connect_encounter(event: Signal, callback: Callable) -> void:
	event.connect(callback)
	encounter_connections.append({"signal": event, "callback": callback})

func _current_callback(generation: int) -> bool:
	return generation == run_generation and simulation_enabled and not restart_in_progress

func _health_changed(current: int, maximum: int, generation: int) -> void:
	if _current_callback(generation) and state == "Active":
		hud.present_health(current, maximum)

func request_restart(generation: int = -1) -> void:
	if state != "GameOver" or restart_in_progress or (generation != -1 and generation != run_generation):
		return
	# Latch before notifying Main, including reentrant signals during tree exit.
	restart_in_progress = true
	simulation_enabled = false
	hud.set_restart_enabled(false)
	if stepping:
		# Finish the lethal commit before any observer can replace its encounter.
		_emit_restart.call_deferred(run_generation)
	else:
		_emit_restart(run_generation)

func _emit_restart(generation: int) -> void:
	if generation == run_generation and restart_in_progress and not stepping:
		restart_requested.emit(generation)

func dispose_encounter() -> void:
	simulation_enabled = false
	for connection in encounter_connections:
		var event: Signal = connection.signal
		if not event.is_null() and event.is_connected(connection.callback):
			event.disconnect(connection.callback)
	encounter_connections.clear()
	if registry != null:
		for enemy in registry.members.keys():
			registry.remove(enemy)
	if camera != null:
		camera.clear_pending_input()
	if feedback != null:
		feedback.clear()
	# Remove synchronously, free after signal dispatch finishes. Weapon/health and
	# all enemies belong to player/spawner respectively.
	for node in [spawner, player, camera, registry, feedback, arena, hud]:
		if node != null:
			remove_child(node)
			node.queue_free()
	arena = null
	player = null
	camera = null
	registry = null
	spawner = null
	weapon = null
	feedback = null
	hud = null
	runtime_definition = null

func retain_attempt() -> void:
	# Normal Play also preserves failed attempts without allocating a sampler.
	retained_attempts.append({"run_generation": run_generation, "active_time": active_time,
		"completed_step_count": completed_step_count, "spawn_failure_count": spawn_failure_count,
		"acceptance_invalid": acceptance_invalid, "spawn_diagnostics": spawn_diagnostics.duplicate(true),
		"survival_window_outcome": survival_window_outcome, "continuation_outcome": continuation_outcome,
		"continuation_evidence": continuation_evidence.duplicate(true)})

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

func _player_died(generation: int = -1) -> void:
	if state != "Active" or (generation != -1 and not _current_callback(generation)):
		return
	state = "GameOver"
	camera.clear_pending_input()
	feedback.clear()
	if not stepping:
		# Out-of-step lethal damage has no additional simulated duration to commit.
		hud.present_time(active_time)
		hud.present_state(state)
		_record_continuation(player.position, camera.yaw, camera.depression)
		if profile_capture != null:
			profile_capture.record_step(run_generation, active_time, completed_step_count, Time.get_ticks_usec() / 1000000.0, registry.living_in_spawn_order().size(), false)
	state_changed.emit(state)

func _spawn_failed(records: Array, generation: int = -1) -> void:
	if state != "Active" or (generation != -1 and not _current_callback(generation)):
		return
	spawn_failure_count += 1
	acceptance_invalid = true
	spawn_diagnostics.append_array(records)
	if profile_capture != null:
		profile_capture.record_spawn_failure(run_generation, {"records": records})

func _spawn_consumed(t_end: float, outcome: String, generation: int = -1) -> void:
	if state != "Active" or (generation != -1 and not _current_callback(generation)):
		return
	if t_end > 300 and outcome in ["spawned", "cap_skip"]:
		continuation_evidence["spawn_opportunity"] = t_end

func _weapon_feedback(t_end: float, attack_position: Vector3, target: Node3D, generation: int = -1) -> void:
	if state != "Active" or (generation != -1 and not _current_callback(generation)):
		return
	feedback.show_attack(t_end, attack_position, target)
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
