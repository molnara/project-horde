extends RefCounted
## T035 authoring only: NONE of these cases enter the executable manifest until
## T039/T040 are ready. Existing helper behavior is not restart integration proof.
const F = preload("res://tests/support/gameplay_fixture.gd")
const Defeat = preload("res://tests/integration/test_defeat_restart.gd")
var lifecycle := Defeat.new()

func cases() -> Array[Dictionary]:
	return F.cases_for("restart_evidence", ["seal_before_teardown", "stale_generations", "valid_open", "invalid_no_open", "shutdown_fault", "write_fault", "post300_death"],
		["res://scripts/run/profile_capture.gd", "res://scripts/run/main.gd", "res://scripts/run/run_coordinator.gd", "res://scenes/hud.tscn"])

func profile_main(ctx, d):
	var main = lifecycle.main_scene(ctx, d)
	# Inject the real Profile-only owner/helper wiring without making normal Play
	# create a sampler or requiring every other fixture to run with --profile.
	var capture = F.instance(ctx, "res://scripts/run/profile_capture.gd")
	capture.reparent(main)
	main.capture = capture
	main.coordinator.profile_capture = capture
	var directory := ProjectSettings.globalize_path("res://.cache/restart-evidence-fixtures/" + ctx.case_id + "-" + str(Time.get_ticks_usec()))
	F.invoke(ctx, capture, "configure", [directory])
	capture.conditions = main._profile_conditions()
	F.invoke(ctx, capture, "open_attempt", [main.coordinator.run_generation, Time.get_ticks_usec() / 1000000.0])
	ctx.connect_callback(RenderingServer.frame_post_draw, main._record_frame)
	return main

func payload(ctx, path: String) -> Dictionary:
	ctx.check(FileAccess.file_exists(path), "required evidence persisted: " + path)
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	ctx.check(parsed is Dictionary, "persisted evidence parses as Dictionary")
	return parsed if parsed is Dictionary else {}

func seed_frames(ctx, main) -> void:
	# Real disk-backed callbacks, monotonic and not in the future relative to the
	# next real coordinator commit. No synthetic wall duration credited to play.
	var capture = main.capture
	for _index in 3:
		F.invoke(ctx, capture, "record_frame", [capture.run_generation, Time.get_ticks_usec() / 1000000.0])
	ctx.check(capture.frame_sample_count >= 3, "old generation has real raw frame evidence")

func seal_before_teardown(ctx) -> void:
	var d = lifecycle.definition(ctx)
	var main = profile_main(ctx, d)
	var run = main.coordinator
	var capture = main.capture
	seed_frames(ctx, main)
	F.invoke(ctx, run, "step", [1.0])
	ctx.check(not capture.enemy_samples.is_empty(), "old attempt contains enemy-count samples")
	lifecycle.defeat(ctx, run, d)
	var old_path: String = capture.evidence_path
	var raw_path: String = capture.frame_evidence_path
	var sample_count: int = capture.frame_sample_count
	var old_generation: int = run.run_generation
	var observations: Array = []
	ctx.connect_callback(run.spawner.tree_exiting, func():
		observations.append(capture.run_generation)
		ctx.check(not capture.buffer_open and capture.frame_output == null and capture.frame_timestamps.is_empty() and capture.enemy_samples.is_empty(), "raw old buffers sealed before encounter teardown")
		var written := payload(ctx, old_path + ".outcomes.json")
		ctx.check(written.get("run_generation") == old_generation and written.get("survival_window_outcome") == "failed" and written.get("completed_simulation_duration") == run.active_time, "final committed old outcomes persisted before teardown")
		var manifest := payload(ctx, old_path)
		ctx.check(manifest.get("enemy_samples", []).size() == 1 and manifest.get("frame_stream", {}).get("sample_count") == sample_count, "old count/frame evidence flushed into manifest before teardown")
		ctx.check(FileAccess.file_exists(raw_path), "old raw stream retained before teardown")
		if FileAccess.file_exists(raw_path):
			var raw := FileAccess.open(raw_path, FileAccess.READ)
			ctx.check(raw != null, "sealed raw stream readable")
			if raw != null:
				ctx.check(raw.get_length() == sample_count * 8, "sealed raw stream contains every callback including final tail")
				raw.close())
	if lifecycle.restart(ctx, main):
		ctx.check(observations == [old_generation], "one teardown, before fresh capture generation opens")
		ctx.check(capture.retained_attempts.size() == 1 and capture.retained_attempts[0].run_generation == old_generation, "old metadata retained exactly once")
		var old: Dictionary = capture.retained_attempts[0]
		ctx.check(old.survival_window_outcome == "failed" and old.continuation_outcome == "outstanding" and old.profile_capture_outcome == "passed", "survival/continuation/capture outcomes remain distinct")
		ctx.check(old.evidence_path == old_path and not old.has("frame_timestamps") and not old.has("enemy_samples"), "retention stores provenance/outcomes without unbounded raw copies")
		ctx.check(capture.run_generation == old_generation + 1 and capture.buffer_open, "new evidence belongs only to fresh generation")
	ctx.done()

func stale_generations(ctx) -> void:
	var d = lifecycle.definition(ctx)
	var main = profile_main(ctx, d)
	var capture = main.capture
	var old_generation: int = capture.run_generation
	seed_frames(ctx, main)
	lifecycle.defeat(ctx, main.coordinator, d)
	if not lifecycle.restart(ctx, main):
		ctx.done()
		return
	var old_records: Array = capture.retained_attempts.duplicate(true)
	var before: Dictionary = capture._metadata()
	var sample_count: int = capture.frame_sample_count
	var frames: PackedFloat64Array = capture.frame_timestamps.duplicate()
	var counts: Array = capture.enemy_samples.duplicate(true)
	var audit: Dictionary = capture.frame_callback_audit.duplicate(true)
	F.invoke(ctx, capture, "record_frame", [old_generation, capture.t0 + 1.0, 999])
	F.invoke(ctx, capture, "record_step", [old_generation, 300.0, 18000, capture.t0 + 2.0, 99, false])
	F.invoke(ctx, capture, "record_spawn_failure", [old_generation, {"cause": "stale failure"}])
	F.invoke(ctx, capture, "record_continuation", [old_generation, {"time_advanced": 999.0}])
	ctx.check(capture._metadata() == before and capture.frame_timestamps == frames and capture.enemy_samples == counts and capture.frame_callback_audit == audit, "old frame/step/failure/continuation callbacks rejected without modifying fresh metadata/buffers/audit")
	ctx.check(capture.retained_attempts == old_records, "stale callbacks cannot rewrite sealed attempts")
	F.invoke(ctx, capture, "record_frame", [main.coordinator.run_generation, Time.get_ticks_usec() / 1000000.0])
	ctx.check(capture.frame_sample_count == sample_count + 1, "current-generation callback still captures")
	ctx.done()

func valid_open(ctx) -> void:
	var d = lifecycle.definition(ctx)
	var main = profile_main(ctx, d)
	var capture = main.capture
	var old_path: String = capture.evidence_path
	var generation: int = capture.run_generation
	# Old acceptance invalidity must survive while the fresh attempt resets it.
	F.invoke(ctx, capture, "record_spawn_failure", [generation, {"cause": "old failed attempt"}])
	lifecycle.defeat(ctx, main.coordinator, d)
	d.player.max_health = 150
	d.camera_yaw = 90.0
	d.spawn_interval = 2.0
	if lifecycle.restart(ctx, main):
		var run = main.coordinator
		ctx.check(run.runtime_definition.player.max_health == 150 and run.player.health.current_health == 150 and run.camera.yaw == 90.0 and run.spawner.next_spawn_at == 2.0, "fresh definitions validated/applied before new buffers")
		ctx.check(capture.run_generation == run.run_generation and capture.run_generation == generation + 1 and capture.buffer_open, "fresh capture opens at valid ready encounter")
		ctx.check(capture.attempt_serial == 2 and capture.evidence_path != old_path and capture.completed_simulation_duration == 0 and capture.completed_step_count == 0, "one new buffer/path before first simulated step")
		ctx.check(capture.frame_sample_count == 0 and capture.enemy_samples.is_empty() and capture.spawn_failure_count == 0 and not capture.acceptance_invalid and capture.failure_diagnostics.is_empty(), "fresh raw evidence/counter/invalidity isolation")
		ctx.check(capture.survival_window_outcome == "outstanding" and capture.continuation_outcome == "outstanding" and capture.profile_capture_outcome == "outstanding", "new outcomes start outstanding")
		ctx.check(capture.retained_attempts[0].spawn_failure_count == 1 and capture.retained_attempts[0].acceptance_invalid and capture.retained_attempts[0].failure_diagnostics == [{"cause": "old failed attempt"}], "fresh reset does not erase old failed attempt")
		ctx.check(capture.conditions.tuning.PlayerDefinition.max_health == "150", "fresh capture conditions reflect freshly applied tuning")
	ctx.done()

func invalid_no_open(ctx) -> void:
	var d = lifecycle.definition(ctx)
	var main = profile_main(ctx, d)
	var capture = main.capture
	var old_generation: int = capture.run_generation
	var old_path: String = capture.evidence_path
	lifecycle.defeat(ctx, main.coordinator, d)
	d.player.max_health = 0
	if lifecycle.restart(ctx, main):
		var run = main.coordinator
		ctx.check(not run.simulation_enabled and run.player == null and run.spawner == null, "invalid restart has no ready encounter")
		for record in run.configuration_diagnostics:
			ctx.application_diagnostic(JSON.parse_string(record))
		ctx.check(not capture.buffer_open and capture.frame_output == null and capture.attempt_serial == 1, "invalid definitions never open or allocate fresh evidence buffers")
		ctx.check(capture.evidence_path == old_path and capture.run_generation == old_generation, "no fabricated attempt for invalid next generation")
		var written := payload(ctx, old_path + ".outcomes.json")
		ctx.check(written.get("run_generation") == old_generation and written.get("survival_window_outcome") == "failed", "old failed outcomes remain accessible after invalid restart")
		ctx.check(capture.retained_attempts.size() == 1 and capture.retained_attempts[0].run_generation == old_generation, "invalid restart retains sealed old metadata without fabricating a fresh attempt")
		var before: Dictionary = capture._metadata()
		main._record_frame()
		ctx.check(capture._metadata() == before and capture.frame_timestamps.is_empty(), "frame callback cannot reopen old capture in error state")
	ctx.done()

func block_output(ctx, path: String) -> void:
	ctx.check(path.begins_with(ProjectSettings.globalize_path("res://.cache/").replace("\\", "/")), "fault injection stays in workspace cache")
	ctx.check(DirAccess.make_dir_recursive_absolute(path) == OK, "directory at required file path injects a real output-open failure")

func shutdown_fault(ctx) -> void:
	var d = lifecycle.definition(ctx)
	var main = profile_main(ctx, d)
	var capture = main.capture
	ctx.connect_callback(capture.diagnostic, ctx.application_diagnostic)
	seed_frames(ctx, main)
	F.invoke(ctx, main.coordinator, "step", [0.25])
	var old_path: String = capture.evidence_path
	block_output(ctx, old_path + ".outcomes.json")
	# Exercise Main's actual exit/shutdown callback while retaining the helper for
	# assertions. This is the callback Godot invokes on application scene removal.
	F.invoke(ctx, main, "_exit_tree")
	ctx.check(not capture.buffer_open and capture.profile_capture_outcome == "outstanding" and capture.capture_diagnostics.size() == 1, "failed shutdown output stays outstanding with retained diagnostic")
	ctx.check(capture.capture_diagnostics[0].has_all(["source", "field", "observed", "constraint", "cause"]) and capture.capture_diagnostics[0].field == "evidence_path", "shutdown diagnostic actionable")
	ctx.check(capture.survival_window_outcome == "outstanding" and capture.continuation_outcome == "outstanding" and not capture.qualifies_attempt(), "shutdown of an unfinished attempt cannot grant acceptance or erase outcomes")
	ctx.check(FileAccess.file_exists(old_path) and FileAccess.file_exists(capture.frame_evidence_path), "successful partial artifacts retained after shutdown failure")
	# Avoid invoking the fault twice when normal context cleanup removes Main.
	main.capture = null
	ctx.done()

func write_fault(ctx) -> void:
	var d = lifecycle.definition(ctx)
	var main = profile_main(ctx, d)
	var capture = main.capture
	ctx.connect_callback(capture.diagnostic, ctx.application_diagnostic)
	seed_frames(ctx, main)
	var old_path: String = capture.evidence_path
	block_output(ctx, old_path)
	lifecycle.defeat(ctx, main.coordinator, d)
	ctx.check(not capture.buffer_open and capture.profile_capture_outcome == "outstanding" and capture.capture_diagnostics.size() == 1, "real endpoint manifest write fault closes sampling but retains incomplete result")
	if lifecycle.restart(ctx, main):
		var old: Dictionary = capture.retained_attempts[0]
		ctx.check(old.evidence_path == old_path and old.profile_capture_outcome == "outstanding" and old.capture_diagnostics.size() == 1, "restart retains old write failure diagnostics")
		ctx.check(capture.buffer_open and capture.capture_diagnostics.is_empty() and capture.profile_capture_outcome == "outstanding", "valid fresh evidence has independent diagnostics without rewriting failed old result")
		var written := payload(ctx, old_path + ".outcomes.json")
		ctx.check(written.get("profile_capture_outcome") == "outstanding" and written.get("capture_diagnostics", []).size() == 1, "persisted sidecar preserves old failure")
	ctx.done()

func post300_death(ctx) -> void:
	var d = lifecycle.definition(ctx)
	d.spawn_interval = 1000.0
	var main = profile_main(ctx, d)
	var run = main.coordinator
	var capture = main.capture
	seed_frames(ctx, main)
	# Deterministic endpoint crossing, not five minutes of owner survival evidence.
	run.active_time = 299.5
	run.completed_step_count = 17999
	F.invoke(ctx, run, "step", [0.5])
	var old_path: String = capture.evidence_path
	var endpoint: Dictionary = capture._metadata()
	var manifest := payload(ctx, old_path)
	ctx.check(run.state == "Active" and capture.survival_window_outcome == "passed" and not capture.buffer_open, "300-second completed window alive is sealed")
	lifecycle.defeat(ctx, run, d, 0.125)
	ctx.check(run.active_time == 300.125 and run.state == "GameOver", "normal lethal combat after endpoint")
	ctx.check(run.survival_window_outcome == "passed" and capture.survival_window_outcome == "passed" and capture.continuation_outcome == "outstanding" and not capture.qualifies_attempt(), "later death preserves survival but cannot invent missing movement/view/spawn continuation")
	ctx.check(capture.t1 == endpoint.t1 and capture.completed_simulation_duration == 300.0 and capture.completed_step_count == 18000 and payload(ctx, old_path) == manifest, "post-300 death never rewrites endpoint timing or captured window")
	if lifecycle.restart(ctx, main):
		var old: Dictionary = capture.retained_attempts[0]
		var written := payload(ctx, old_path + ".outcomes.json")
		ctx.check(old.survival_window_outcome == "passed" and old.continuation_outcome == "outstanding" and old.profile_capture_outcome == "passed" and not old.acceptance_invalid, "restart retains distinct post-300 outcomes")
		ctx.check(written.get("survival_window_outcome") == "passed" and written.get("continuation_outcome") == "outstanding", "shutdown sidecar retains valid survival and missing continuation")
	ctx.done()
