extends Node
const Statistics = preload("res://scripts/run/profile_statistics.gd")
## Main owns the sampler. After closure only outcome/failure metadata can grow.
## Lossless disk spool: RAM holds at most 4096 float64 timestamps (32 KiB).
const FRAME_CHUNK_SIZE: int = 4096
signal diagnostic(record: Dictionary)
var output_directory: String
var run_generation: int = 0
var buffer_open: bool = false
var frame_timestamps := PackedFloat64Array()
var frame_output: FileAccess
var frame_evidence_path: String = ""
var frame_sample_count: int = 0
var last_frame_timestamp: float = -INF
var frame_callback_audit: Dictionary = {}
var enemy_samples: Array = []
var retained_attempts: Array = []
var spawn_failure_count: int = 0
var acceptance_invalid: bool = false
var failure_diagnostics: Array = []
var capture_diagnostics: Array = []
var survival_window_outcome: String = "outstanding"
var continuation_outcome: String = "outstanding"
var profile_capture_outcome: String = "outstanding"
var continuation_evidence: Dictionary = {}
var completed_simulation_duration: float = 0.0
var completed_step_count: int = 0
var evidence_path: String = ""
var t0: float = 0.0
var t1: float = 0.0
var next_count_second: int = 1
var conditions: Dictionary = {}
var summary: Dictionary = {}
var sampler_overhead_usec: int = 0
var attempt_serial: int = 0
var configured: bool = false

func configure(absolute_workspace_output_directory: String) -> void:
	var cache_root := ProjectSettings.globalize_path("res://.cache/").replace("\\", "/")
	var requested := absolute_workspace_output_directory.replace("\\", "/").simplify_path()
	configured = requested.is_absolute_path() and requested.begins_with(cache_root)
	if not configured:
		_capture_fault("output_directory", requested, "absolute output inside workspace .cache", "Choose an output directory inside this project's ignored cache.")
		return
	output_directory = requested

func open_attempt(generation: int, wall_seconds: float) -> void:
	if run_generation != 0:
		shutdown(wall_seconds)
		retained_attempts.append(_metadata())
	run_generation = generation
	attempt_serial += 1
	t0 = wall_seconds
	t1 = wall_seconds
	completed_simulation_duration = 0
	completed_step_count = 0
	frame_timestamps.clear()
	enemy_samples.clear()
	spawn_failure_count = 0
	acceptance_invalid = false
	failure_diagnostics.clear()
	capture_diagnostics.clear()
	continuation_evidence.clear()
	summary.clear()
	sampler_overhead_usec = 0
	survival_window_outcome = "outstanding"
	continuation_outcome = "outstanding"
	profile_capture_outcome = "outstanding"
	next_count_second = 1
	evidence_path = ""
	frame_sample_count = 0
	last_frame_timestamp = -INF
	frame_evidence_path = ""
	frame_callback_audit = {"first_engine_frame": -1, "last_engine_frame": -1, "repeated_engine_frame_ids": 0, "skipped_engine_frame_ids": 0}
	buffer_open = true
	if configured:
		var error := DirAccess.make_dir_recursive_absolute(output_directory)
		if error == OK:
			evidence_path = output_directory.path_join("attempt-%d-%d-%d.json" % [run_generation, attempt_serial, Time.get_ticks_usec()])
			frame_evidence_path = evidence_path + ".frames.bin"
			frame_output = FileAccess.open(frame_evidence_path, FileAccess.WRITE)
			if frame_output == null:
				_capture_fault("frame_evidence_path", frame_evidence_path, "writable complete frame stream", "Frame stream open failed: %s" % FileAccess.get_open_error())
		else:
			_capture_fault("output_directory", error, "writable workspace output", "Could not create the capture directory.")
	else:
		_capture_fault("output_directory", output_directory, "configured workspace output", "Capture output was not configured safely.")

func record_frame(generation: int, wall_seconds: float, engine_frame: int = -1) -> void:
	if generation != run_generation or not buffer_open:
		return
	var begin := Time.get_ticks_usec()
	if engine_frame >= 0:
		if frame_callback_audit.first_engine_frame < 0:
			frame_callback_audit.first_engine_frame = engine_frame
		elif engine_frame <= int(frame_callback_audit.last_engine_frame):
			frame_callback_audit.repeated_engine_frame_ids += 1
		else:
			frame_callback_audit.skipped_engine_frame_ids += maxi(0, engine_frame - int(frame_callback_audit.last_engine_frame) - 1)
		frame_callback_audit.last_engine_frame = engine_frame
	if not is_finite(wall_seconds) or wall_seconds < t0 or wall_seconds < last_frame_timestamp:
		_capture_fault("frame_timestamp", wall_seconds, "monotonic finite wall timestamp", "Frame callback timestamps must be monotonic.")
	elif frame_output != null:
		frame_timestamps.append(wall_seconds)
		last_frame_timestamp = wall_seconds
		frame_sample_count += 1
		if frame_timestamps.size() == FRAME_CHUNK_SIZE:
			_flush_frames()
	sampler_overhead_usec += Time.get_ticks_usec() - begin

func record_step(generation: int, committed_time: float, ticks: int, wall_seconds: float, count: int, alive: bool) -> void:
	if generation != run_generation:
		return
	if not buffer_open:
		# Unlimited continuation must never accumulate raw samples or overwrite t1.
		return
	var begin := Time.get_ticks_usec()
	completed_simulation_duration = committed_time
	completed_step_count = ticks
	if committed_time >= next_count_second:
		enemy_samples.append({"active_time": committed_time, "wall_time": wall_seconds, "count": count})
		next_count_second = int(floor(committed_time)) + 1
	sampler_overhead_usec += Time.get_ticks_usec() - begin
	if committed_time >= 300 or not alive:
		survival_window_outcome = "passed" if committed_time >= 300 and alive else "failed"
		_close(wall_seconds)

func record_spawn_failure(generation: int, record: Dictionary) -> void:
	if generation != run_generation:
		return
	spawn_failure_count += 1
	acceptance_invalid = true
	failure_diagnostics.append(record.duplicate(true))

func record_continuation(generation: int, observations: Dictionary) -> void:
	if generation != run_generation:
		return
	continuation_evidence = observations.duplicate(true)
	if survival_window_outcome == "passed" and observations.has_all(["time_advanced", "movement", "view", "spawn_opportunity", "unchanged_tuning_vulnerability"]):
		continuation_outcome = "passed"

func qualifies_attempt() -> bool:
	# Technical evidence candidate only; actual conditions/owner acceptance must
	# still be reviewed in the verification ledger. Sparse timing is insufficient.
	return survival_window_outcome == "passed" and continuation_outcome == "passed" and profile_capture_outcome == "passed" and not acceptance_invalid and summary.get("full_intervals_available", false) and summary.get("enemy_min") != null and not conditions.is_empty()

func shutdown(wall_seconds: float) -> void:
	if run_generation == 0:
		return
	if buffer_open:
		_close(wall_seconds)
	if not evidence_path.is_empty():
		_write_json(evidence_path + ".outcomes.json", _metadata())
	print("HORDE_PROFILE_RESULT=" + JSON.stringify({"profile_capture_outcome": profile_capture_outcome, "evidence_path": evidence_path, "frame_evidence_path": frame_evidence_path, "frame_sample_count": frame_sample_count, "capture_diagnostics": capture_diagnostics, "survival_window_outcome": survival_window_outcome, "continuation_outcome": continuation_outcome, "acceptance_invalid": acceptance_invalid}))

func _flush_frames() -> void:
	if frame_output == null or frame_timestamps.is_empty():
		return
	frame_output.store_buffer(frame_timestamps.to_byte_array())
	frame_output.flush()
	var error := frame_output.get_error()
	if error != OK:
		_capture_fault("frame_evidence_path", frame_evidence_path, "writable complete frame stream", "Frame stream write failed: %s" % error)
		frame_output.close()
		frame_output = null
	# On faults retain partial disk evidence and the explicit incomplete outcome.
	frame_timestamps.clear()

func _close(wall_seconds: float) -> void:
	buffer_open = false
	t1 = wall_seconds
	var begin := Time.get_ticks_usec()
	_flush_frames()
	if frame_output != null:
		frame_output.close()
		frame_output = null
	sampler_overhead_usec += Time.get_ticks_usec() - begin
	var helper := Statistics.new()
	summary = helper.summarize_file(t0, t1, frame_evidence_path, frame_sample_count, enemy_samples)
	summary["frame_callback_audit"] = frame_callback_audit.duplicate()
	if frame_callback_audit.repeated_engine_frame_ids > 0 or frame_callback_audit.skipped_engine_frame_ids > 0:
		_capture_fault("frame_callback_audit", frame_callback_audit, "one callback per successive engine draw", "Repeated or skipped engine frame IDs; raw callbacks retained for investigation.")
	if summary.has("capture_error"):
		_capture_fault("frame_evidence_path", frame_evidence_path, "readable complete frame stream", summary.capture_error)
	summary["sampler_overhead_usec"] = sampler_overhead_usec
	summary["overhead_excludes"] = "Includes callback, step and chunk-write/flush work plus final flush; excludes endpoint summary/JSON output. No GPU timing claimed."
	summary["engine_monitors"] = {"process_seconds": Performance.get_monitor(Performance.TIME_PROCESS), "physics_seconds": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS), "static_memory_bytes": Performance.get_monitor(Performance.MEMORY_STATIC), "objects": Performance.get_monitor(Performance.OBJECT_COUNT), "render_draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
	if not evidence_path.is_empty():
		# Serialize intended success; any write/flush fault resets it to outstanding.
		profile_capture_outcome = "passed" if capture_diagnostics.is_empty() else "outstanding"
		var payload := _metadata()
		payload["conditions"] = conditions.duplicate(true)
		payload["frame_stream"] = {"path": frame_evidence_path, "format": "little-endian float64 monotonic wall seconds; 8 bytes per callback", "sample_count": frame_sample_count, "chunk_capacity": FRAME_CHUNK_SIZE}
		payload["enemy_samples"] = enemy_samples
		payload["summary"] = summary
		_write_json(evidence_path, payload)
	# No raw frame/count copies in retained metadata after writing.
	summary.erase("enemy_samples")
	frame_timestamps.clear()
	enemy_samples.clear()

func _write_json(path: String, payload: Dictionary) -> bool:
	var output := FileAccess.open(path, FileAccess.WRITE)
	if output == null:
		_capture_fault("evidence_path", path, "required output written successfully", "File open failed: %s" % FileAccess.get_open_error())
		return false
	output.store_string(JSON.stringify(payload, "\t"))
	output.flush()
	var error := output.get_error()
	output.close()
	if error != OK:
		_capture_fault("evidence_path", path, "required output written successfully", "File write failed: %s" % error)
		return false
	return true

func _capture_fault(field: String, observed: Variant, constraint: String, cause: String) -> void:
	var record := {"source": "ProfileCapture", "field": field, "observed": str(observed), "constraint": constraint, "cause": cause}
	capture_diagnostics.append(record)
	profile_capture_outcome = "outstanding"
	diagnostic.emit(record)
	printerr("Profile capture failure: " + JSON.stringify(record))

func _metadata() -> Dictionary:
	return {"run_generation": run_generation, "t0": t0, "t1": t1, "completed_simulation_duration": completed_simulation_duration, "completed_step_count": completed_step_count, "survival_window_outcome": survival_window_outcome, "continuation_outcome": continuation_outcome, "continuation_evidence": continuation_evidence.duplicate(true), "profile_capture_outcome": profile_capture_outcome, "acceptance_invalid": acceptance_invalid, "spawn_failure_count": spawn_failure_count, "failure_diagnostics": failure_diagnostics.duplicate(true), "capture_diagnostics": capture_diagnostics.duplicate(true), "evidence_path": evidence_path, "summary": summary.duplicate(true)}
