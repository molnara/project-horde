extends RefCounted
## T043/T047: all profiling segmentation cases are required and executable.
## Real Main/capture integration plus deterministic wall timestamps on the real
## helper. Production API/metadata contract is documented in tests/README.md.
const F = preload("res://tests/support/gameplay_fixture.gd")
const Pause = preload("res://tests/integration/test_pause_resume.gd")
const Evidence = preload("res://tests/integration/test_restart_evidence.gd")
var pause := Pause.new()
var evidence := Evidence.new()

func cases() -> Array[Dictionary]:
	return F.cases_for("pause_profile", ["close_segment", "resume_origin", "exclude_gap", "preserve_attempt", "paused_endpoint", "nonqualification", "retained_diagnostics", "post_endpoint_pause"],
		["res://scripts/run/profile_capture.gd", "res://scripts/run/main.gd", "res://scripts/run/run_coordinator.gd"])

func profile_main(ctx):
	var d = pause.definition(ctx)
	d.spawn_interval = 1000.0
	return evidence.profile_main(ctx, d)

func metadata(ctx, capture) -> Dictionary:
	var value: Variant = F.invoke(ctx, capture, "_metadata")
	ctx.check(value is Dictionary and value.has_all(["segments", "interrupted", "active_capture_duration"]), "diagnostic metadata exposes segments, interruption and active wall duration")
	return value if value is Dictionary else {}

func segments(ctx, capture) -> Array:
	var value := metadata(ctx, capture)
	var records: Variant = value.get("segments", [])
	ctx.check(records is Array, "segment records are inspectable")
	return records if records is Array else []

func raw_count(ctx, segment: Dictionary) -> int:
	ctx.check(segment.has_all(["t0", "t1", "summary", "frame_stream"]), "closed segment retains timing/summary/raw stream descriptor")
	var stream: Dictionary = segment.get("frame_stream", {})
	var path: String = stream.get("path", "")
	ctx.check(not path.is_empty() and FileAccess.file_exists(path), "closed segment raw evidence exists")
	if path.is_empty() or not FileAccess.file_exists(path):
		return -1
	var file := FileAccess.open(path, FileAccess.READ)
	ctx.check(file != null, "closed segment raw evidence readable")
	if file == null:
		return -1
	var count: int = stream.get("sample_count", -1)
	ctx.check(file.get_length() == count * 8, "segment retains every float64 callback, including final tail")
	for _index in maxi(count, 0):
		var stamp := file.get_double()
		ctx.check(stamp >= float(segment.get("t0", INF)) and stamp <= float(segment.get("t1", -INF)), "raw callback belongs inside its active segment")
	file.close()
	return count

func capture_at(ctx, generation: int = 7, origin: float = 0.0):
	var capture = F.instance(ctx, "res://scripts/run/profile_capture.gd")
	var directory := ProjectSettings.globalize_path("res://.cache/pause-profile-fixtures/" + ctx.case_id + "-" + str(Time.get_ticks_usec()))
	F.invoke(ctx, capture, "configure", [directory])
	capture.conditions = {"fixture": "deterministic diagnostic timestamps; not owner acceptance", "physics_ticks_per_second": 60}
	F.invoke(ctx, capture, "open_attempt", [generation, origin])
	return capture

func close_at(ctx, capture, wall: float) -> void:
	# Production segment API rejects stale generations and preserves the attempt.
	F.invoke(ctx, capture, "close_segment", [capture.run_generation, wall])

func resume_at(ctx, capture, wall: float) -> void:
	F.invoke(ctx, capture, "open_segment", [capture.run_generation, wall])

func frames(ctx, capture, stamps: Array, first_engine_frame: int = -1) -> void:
	for index in stamps.size():
		F.invoke(ctx, capture, "record_frame", [capture.run_generation, stamps[index], first_engine_frame + index if first_engine_frame >= 0 else -1])

func continuation() -> Dictionary:
	return {"time_advanced": 301.0, "movement": 301.0, "view": 301.0, "spawn_opportunity": 301.0, "unchanged_tuning_vulnerability": 301.0}

func close_segment(ctx) -> void:
	var main = profile_main(ctx)
	var run = main.coordinator
	var capture = main.capture
	evidence.seed_frames(ctx, main)
	F.invoke(ctx, run, "step", [1.0])
	var frozen := pause.snapshot(run)
	var begin := Time.get_ticks_usec() / 1000000.0
	if pause.transition(ctx, run, "Paused"):
		var end := Time.get_ticks_usec() / 1000000.0
		var closed := segments(ctx, capture)
		ctx.check(closed.size() == 1, "Main/coordinator pause closes exactly one segment")
		if closed.size() == 1:
			ctx.check(closed[0].t1 >= begin and closed[0].t1 <= end, "segment endpoint is actual pause transition, not prior frame")
			ctx.check(raw_count(ctx, closed[0]) >= 3, "pause flushes the real final raw tail")
		ctx.check(not capture.buffer_open and capture.frame_output == null and capture.frame_timestamps.is_empty() and capture.enemy_samples.is_empty(), "pause seals active raw/count buffers")
		var sample_count: int = capture.frame_sample_count
		main._record_frame()
		F.invoke(ctx, run, "step", [10.0])
		await Engine.get_main_loop().process_frame
		ctx.check(capture.frame_sample_count == sample_count and segments(ctx, capture) == closed, "inactive production frame callback and step do not capture or rewrite segment")
		ctx.check(pause.snapshot(run) == frozen and capture.completed_simulation_duration == 1.0, "capture bookkeeping does not advance encounter or survival")
	ctx.done()

func resume_origin(ctx) -> void:
	var main = profile_main(ctx)
	var run = main.coordinator
	var capture = main.capture
	evidence.seed_frames(ctx, main)
	var generation: int = run.run_generation
	var serial: int = capture.attempt_serial
	if pause.transition(ctx, run, "Paused"):
		var closed := segments(ctx, capture)
		var frozen := pause.snapshot(run)
		# Real short wait proves wiring chooses a NEW origin; the exact ten-second
		# gap and interval arithmetic are covered deterministically in exclude_gap.
		await Engine.get_main_loop().create_timer(0.03).timeout
		var begin := Time.get_ticks_usec() / 1000000.0
		if pause.transition(ctx, run, "Active"):
			var end := Time.get_ticks_usec() / 1000000.0
			ctx.check(capture.buffer_open and capture.t0 >= begin and capture.t0 <= end, "resume opens a new real wall origin")
			ctx.check(segments(ctx, capture) == closed, "opening next segment never overwrites sealed diagnostic segment")
			ctx.check(capture.run_generation == generation and capture.attempt_serial == serial and capture.retained_attempts.is_empty(), "resume continues same attempt, not restart or a fabricated attempt")
			ctx.check(pause.snapshot(run) == frozen, "resume capture origin leaves encounter unchanged")
			var count: int = capture.frame_sample_count
			main._record_frame()
			ctx.check(capture.frame_sample_count == count + 1, "resumed production callback captures normally")
	ctx.done()

func exclude_gap(ctx) -> void:
	var capture = capture_at(ctx)
	frames(ctx, capture, [0.0, 0.25, 0.5], 100)
	F.invoke(ctx, capture, "record_step", [7, 1.0, 60, 1.0, 2, true])
	close_at(ctx, capture, 1.0)
	var closed := segments(ctx, capture)
	frames(ctx, capture, [5.0, 10.0])
	ctx.check(segments(ctx, capture) == closed, "inactive helper callbacks cannot add paused timestamps")
	resume_at(ctx, capture, 11.0)
	frames(ctx, capture, [11.0, 11.25, 11.5], 900)
	F.invoke(ctx, capture, "record_step", [7, 2.0, 120, 12.0, 3, true])
	close_at(ctx, capture, 12.0)
	var records := segments(ctx, capture)
	ctx.check(records.size() == 2, "two active windows retained independently")
	if records.size() == 2:
		for index in 2:
			var segment: Dictionary = records[index]
			var summary: Dictionary = segment.get("summary", {})
			ctx.check(raw_count(ctx, segment) == 3, "three raw callbacks retained per segment")
			ctx.check(summary.get("wall_duration") == 1.0 and summary.get("callback_count") == 2 and summary.get("whole_window_fps") == 2.0, "segment FPS uses its own active wall duration with origin excluded")
			ctx.check(summary.get("interval_count") == 2 and summary.get("max_ms") == 250.0 and summary.get("interval_coverage") == 0.5, "no full interval bridges ten paused seconds")
			ctx.check(summary.get("final_partial_seconds") == 0.5 and summary.get("final_partial_stall") == true, "active boundary stall remains diagnostic; only inactive gap excluded")
			var audit: Dictionary = summary.get("frame_callback_audit", {})
			ctx.check(audit.get("repeated_engine_frame_ids") == 0 and audit.get("skipped_engine_frame_ids") == 0, "successive draws audited within each segment; paused draws are not missing active callbacks")
		ctx.check(records[0].t0 == 0.0 and records[0].t1 == 1.0 and records[1].t0 == 11.0 and records[1].t1 == 12.0, "resume origin excludes exact [1,11] pause gap")
	ctx.check(metadata(ctx, capture).get("active_capture_duration") == 2.0 and capture.completed_simulation_duration == 2.0 and capture.completed_step_count == 120, "active capture duration excludes gap; completed simulation remains independently measured")
	ctx.check(capture.capture_diagnostics.is_empty(), "intentional pause gap causes no capture fault")
	F.invoke(ctx, capture, "shutdown", [12.0, false])
	ctx.done()

func preserve_attempt(ctx) -> void:
	var main = profile_main(ctx)
	var run = main.coordinator
	var capture = main.capture
	evidence.seed_frames(ctx, main)
	F.invoke(ctx, run, "step", [1.0])
	var generation: int = run.run_generation
	var serial: int = capture.attempt_serial
	var conditions: Dictionary = capture.conditions.duplicate(true)
	var outcomes: Array = [capture.survival_window_outcome, capture.continuation_outcome]
	var frozen := pause.snapshot(run)
	for _cycle in 3:
		if not pause.transition(ctx, run, "Paused"):
			break
		ctx.check([capture.survival_window_outcome, capture.continuation_outcome] == outcomes, "closing partial segment does not fail or complete survival/continuation")
		F.invoke(ctx, run, "step", [10.0])
		if not pause.transition(ctx, run, "Active"):
			break
		ctx.check(run.run_generation == generation and capture.run_generation == generation and capture.attempt_serial == serial, "repeated pause/resume preserves encounter and evidence generation")
		ctx.check(pause.snapshot(run) == frozen and capture.completed_simulation_duration == 1.0 and capture.completed_step_count == 1, "same outcomes/time/ticks/gameplay through repeated segments")
		ctx.check(capture.conditions == conditions and capture.retained_attempts.is_empty(), "conditions preserved and no attempt retired by pause")
	ctx.done()

func paused_endpoint(ctx) -> void:
	var main = profile_main(ctx)
	var run = main.coordinator
	var capture = main.capture
	evidence.seed_frames(ctx, main)
	# Endpoint-crossing fixture only; this does not simulate owner survival.
	run.active_time = 299.5
	run.completed_step_count = 17999
	F.invoke(ctx, run, "step", [0.25])
	if pause.transition(ctx, run, "Paused"):
		F.invoke(ctx, run, "step", [10.0])
		ctx.check(run.active_time == 299.75 and run.completed_step_count == 18000 and capture.completed_simulation_duration == 299.75, "paused delivery cannot cross 300 or award steps")
		ctx.check(run.survival_window_outcome == "outstanding" and capture.survival_window_outcome == "outstanding", "pause closure is not survival endpoint completion")
		if pause.transition(ctx, run, "Active"):
			F.invoke(ctx, run, "step", [0.125])
			ctx.check(run.active_time == 299.875 and capture.survival_window_outcome == "outstanding", "still outstanding just before completed endpoint")
			F.invoke(ctx, run, "step", [0.125])
			ctx.check(run.active_time == 300.0 and run.completed_step_count == 18002 and run.state == "Active" and not capture.buffer_open, "only completed resumed simulation closes endpoint; play remains Active")
			ctx.check(not capture.qualifies_attempt() and metadata(ctx, capture).get("interrupted") == true, "segmented endpoint is diagnostic, never uninterrupted owner acceptance")
	ctx.done()

func nonqualification(ctx) -> void:
	# Otherwise-complete synthetic evidence eliminates missing continuation,
	# sparse callbacks and missing conditions as alternative rejection causes.
	for interrupted in [false, true]:
		var capture = capture_at(ctx)
		frames(ctx, capture, [0.0, 0.25, 0.5])
		F.invoke(ctx, capture, "record_step", [7, 1.0, 60, 1.0, 2, true])
		if interrupted:
			close_at(ctx, capture, 1.0)
			resume_at(ctx, capture, 11.0)
			frames(ctx, capture, [11.0, 11.25, 11.5])
		F.invoke(ctx, capture, "record_step", [7, 300.0, 18000, 12.0 if interrupted else 1.0, 2, true])
		F.invoke(ctx, capture, "record_continuation", [7, continuation()])
		ctx.check(capture.survival_window_outcome == "passed" and capture.continuation_outcome == "passed" and capture.profile_capture_outcome == "passed" and capture.spawn_failure_count == 0, "individual observations/output success preserved, separate from interruption qualification")
		ctx.check(capture.qualifies_attempt() == not interrupted, "technical candidate rejected specifically for segmentation; clean control still eligible (not owner proof)")
		F.invoke(ctx, capture, "shutdown", [12.0 if interrupted else 1.0, false])
		var persisted := evidence.payload(ctx, capture.evidence_path + ".outcomes.json")
		ctx.check(persisted.get("interrupted") == interrupted, "interruption/nonqualification provenance persists on shutdown")
	ctx.done()

func retained_diagnostics(ctx) -> void:
	var capture = capture_at(ctx)
	frames(ctx, capture, [0.0, 0.25, 0.5])
	var failure := {"run_generation": 7, "opportunity_index": 3, "scheduled_at": 4.5, "t_end": 4.5, "cause": "previous spawn-selection failure"}
	F.invoke(ctx, capture, "record_spawn_failure", [7, failure])
	F.invoke(ctx, capture, "record_step", [7, 1.0, 60, 1.0, 2, true])
	close_at(ctx, capture, 1.0)
	resume_at(ctx, capture, 11.0)
	frames(ctx, capture, [11.0, 11.25, 11.5])
	F.invoke(ctx, capture, "record_step", [7, 2.0, 120, 12.0, 3, false])
	F.invoke(ctx, capture, "retain_attempt", [12.0])
	var old := metadata(ctx, capture)
	ctx.check(old.get("interrupted") == true and old.get("spawn_failure_count") == 1 and old.get("failure_diagnostics") == [failure] and old.get("survival_window_outcome") == "failed", "interrupted defeated attempt retains earlier failure provenance and distinct outcomes")
	var records := segments(ctx, capture)
	ctx.check(records.size() == 2 and capture.frame_timestamps.is_empty() and capture.enemy_samples.is_empty(), "defeat seals resumed segment; bounded raw buffers released")
	for segment in records:
		ctx.check(raw_count(ctx, segment) == 3 and not segment.has("frame_timestamps"), "lossless raw artifacts retained without raw copies in metadata")
	var sidecar := evidence.payload(ctx, capture.evidence_path + ".outcomes.json")
	# Godot JSON parses all numbers as floats, and nested Dictionary equality is
	# type-sensitive. Compare every persisted field against its JSON representation
	# without dropping fields or adding a numeric tolerance.
	ctx.check(sidecar.get("segments") == JSON.parse_string(JSON.stringify(old.get("segments"))), "disk diagnostics preserve every segment boundary/summary/raw descriptor")
	ctx.check(sidecar.get("failure_diagnostics") == JSON.parse_string(JSON.stringify([failure])), "disk diagnostics preserve every earlier failure field")
	ctx.check(sidecar.get("active_capture_duration") == 2.0, "disk diagnostics preserve active duration independent of qualification")
	F.invoke(ctx, capture, "open_attempt", [8, 20.0])
	ctx.check(capture.retained_attempts.size() == 1 and capture.retained_attempts[0] == old, "fresh attempt retains all previous interrupted diagnostics exactly once")
	ctx.check(metadata(ctx, capture).get("interrupted") == false and segments(ctx, capture).is_empty(), "fresh generation resets only its own interruption and segments")
	var fresh := metadata(ctx, capture)
	F.invoke(ctx, capture, "record_frame", [7, 21.0])
	F.invoke(ctx, capture, "record_step", [7, 300.0, 18000, 21.0, 99, true])
	F.invoke(ctx, capture, "close_segment", [7, 21.0])
	F.invoke(ctx, capture, "open_segment", [7, 22.0])
	ctx.check(metadata(ctx, capture) == fresh and capture.retained_attempts[0] == old, "stale interrupted-generation samples cannot rewrite fresh or retained evidence")
	F.invoke(ctx, capture, "shutdown", [20.0, false])
	ctx.done()

func post_endpoint_pause(ctx) -> void:
	var main = profile_main(ctx)
	var run = main.coordinator
	var capture = main.capture
	evidence.seed_frames(ctx, main)
	run.active_time = 299.5
	run.completed_step_count = 17999
	F.invoke(ctx, run, "step", [0.5])
	var endpoint := evidence.payload(ctx, capture.evidence_path)
	var t1: float = capture.t1
	var count: int = capture.frame_sample_count
	ctx.check(capture.survival_window_outcome == "passed" and not capture.buffer_open, "clean endpoint seals successful survival observations")
	if pause.transition(ctx, run, "Paused"):
		F.invoke(ctx, run, "step", [10.0])
		if pause.transition(ctx, run, "Active"):
			main._record_frame()
			F.invoke(ctx, run, "step", [0.125])
			ctx.check(not capture.buffer_open and capture.t1 == t1 and capture.frame_sample_count == count and evidence.payload(ctx, capture.evidence_path) == endpoint, "post-endpoint pause/resume never reopens or rewrites five-minute raw window")
			ctx.check(capture.survival_window_outcome == "passed" and run.survival_window_outcome == "passed", "later interruption preserves previously collected survival observation")
			ctx.check(metadata(ctx, capture).get("interrupted") == true and not capture.qualifies_attempt(), "later interruption remains explicit and cannot grant full uninterrupted attempt acceptance")
	# Isolate post-endpoint interruption from missing continuation or sparse data.
	var control = capture_at(ctx)
	frames(ctx, control, [0.0, 0.25, 0.5])
	F.invoke(ctx, control, "record_step", [7, 300.0, 18000, 1.0, 2, true])
	F.invoke(ctx, control, "record_continuation", [7, continuation()])
	ctx.check(control.qualifies_attempt(), "complete clean technical control qualifies before later interruption; not owner proof")
	var sealed := evidence.payload(ctx, control.evidence_path)
	close_at(ctx, control, 11.0)
	resume_at(ctx, control, 21.0)
	ctx.check(not control.qualifies_attempt() and control.survival_window_outcome == "passed" and control.continuation_outcome == "passed" and control.profile_capture_outcome == "passed", "post-300 interruption alone disqualifies otherwise-complete evidence and preserves all collected outcomes")
	ctx.check(not control.buffer_open and control.t1 == 1.0 and metadata(ctx, control).get("active_capture_duration") == 1.0 and evidence.payload(ctx, control.evidence_path) == sealed, "post-300 pause gap never changes sealed window or active capture duration")
	F.invoke(ctx, control, "shutdown", [21.0, false])
	ctx.check(evidence.payload(ctx, control.evidence_path + ".outcomes.json").get("interrupted") == true, "post-300 interruption persists even with previously successful observations")
	ctx.done()
