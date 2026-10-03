extends Node3D
const Coordinator = preload("res://scripts/run/run_coordinator.gd")
const Capture = preload("res://scripts/run/profile_capture.gd")
@export var run_definition: Resource = preload("res://resources/definitions/run.tres")
var coordinator: Node3D
var capture: Node

func _ready() -> void:
	coordinator = Coordinator.new()
	add_child(coordinator)
	coordinator.start_run(run_definition)
	if not coordinator.simulation_enabled:
		for record in coordinator.configuration_diagnostics:
			printerr("Configuration failure: " + record)
		# Visible failure remains available in Play; automated startup is nonzero.
		if DisplayServer.get_name() == "headless" and not OS.get_cmdline_args().has("--script"):
			get_tree().quit(1)
		return
	coordinator.state_changed.connect(_state_changed)
	coordinator.spawner.diagnostic.connect(func(record): printerr("Spawn failure: " + JSON.stringify(record)))
	if OS.get_cmdline_user_args().has("--profile"):
		capture = Capture.new()
		add_child(capture)
		capture.configure(ProjectSettings.globalize_path("res://.cache/profile"))
		coordinator.profile_capture = capture
		capture.conditions = _profile_conditions()
		capture.open_attempt(coordinator.run_generation, Time.get_ticks_usec() / 1000000.0)
		RenderingServer.frame_post_draw.connect(_record_frame)
	_state_changed(coordinator.state)

func _unhandled_input(event: InputEvent) -> void:
	if coordinator.simulation_enabled and coordinator.state == "Active" and event is InputEventMouseMotion:
		coordinator.camera.queue_mouse(event.relative)

func _state_changed(state: String) -> void:
	if DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if state == "Active" else Input.MOUSE_MODE_VISIBLE

func _record_frame() -> void:
	if capture != null:
		capture.record_frame(coordinator.run_generation, Time.get_ticks_usec() / 1000000.0, Engine.get_frames_drawn())

func _exit_tree() -> void:
	if RenderingServer.frame_post_draw.is_connected(_record_frame):
		RenderingServer.frame_post_draw.disconnect(_record_frame)
	if is_instance_valid(capture):
		capture.shutdown(Time.get_ticks_usec() / 1000000.0)
	if DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _profile_conditions() -> Dictionary:
	var tuning: Dictionary = {}
	for entry in [coordinator.runtime_definition, coordinator.runtime_definition.player, coordinator.runtime_definition.enemy, coordinator.runtime_definition.weapon, coordinator.runtime_definition.arena]:
		var values: Dictionary = {}
		for property in entry.get_property_list():
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				values[property.name] = str(entry.get(property.name))
			tuning[str(entry.get_script().get_global_name())] = values
	return {"engine": Engine.get_version_info(), "os": OS.get_name(), "debug_build": OS.is_debug_build(), "renderer": RenderingServer.get_current_rendering_method(), "viewport": get_viewport().get_visible_rect().size, "max_fps": Engine.max_fps, "vsync_mode": DisplayServer.window_get_vsync_mode(), "physics_ticks_per_second": Engine.physics_ticks_per_second, "frame_sampling": "One frame_post_draw callback per audited engine draw; CPU wall clock, not GPU presentation", "tuning": tuning, "source_revision": "Record Git revision independently before owner attempt", "warmup": "Separate 30-active-second warm-up required; relaunch for measured attempt", "owner_acceptance": "Manual controls/normal tuning/survival observations required"}
