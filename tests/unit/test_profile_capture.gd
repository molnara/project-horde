extends RefCounted

const F = preload("res://tests/support/gameplay_fixture.gd")

func cases() -> Array[Dictionary]:
	var result := F.cases_for("profile", ["boundaries", "sparse", "distribution"], ["res://scripts/run/profile_statistics.gd"])
	result.append_array(F.cases_for("profile", ["generations", "count_samples", "endpoint", "lethal_endpoint", "bounded_late_failure", "continuation"],
		["res://scripts/run/profile_capture.gd", "res://scripts/run/profile_statistics.gd", "res://scripts/run/main.gd", "res://scripts/run/run_coordinator.gd", "res://scenes/player.tscn", "res://scenes/enemy.tscn", "res://scenes/arena.tscn", "res://scenes/hud.tscn", "res://scenes/camera_rig.tscn"]))
	return result

func summarize(ctx, t0: float, t1: float, timestamps: Array, counts: Array = []) -> Dictionary:
	var statistics = F.instance(ctx, "res://scripts/run/profile_statistics.gd")
	return F.invoke(ctx, statistics, "summarize", [t0, t1, timestamps, counts])

func close_float(ctx, actual: float, expected: float, message: String) -> void:
	ctx.check(is_equal_approx(actual, expected), message + ": " + str(actual))

func boundaries(ctx) -> void:
	var result := summarize(ctx, 0.0, 1.0, [-0.5, 0.0, 0.25, 0.75, 1.0, 1.5])
	ctx.check(result.callback_count == 3 and result.interval_count == 3, "callbacks exclude t0/include t1; intervals wholly within window")
	close_float(ctx, result.wall_duration, 1.0, "whole window W")
	close_float(ctx, result.whole_window_fps, 3.0, "whole-window actual callback FPS")
	close_float(ctx, result.interval_coverage, 1.0, "full-interval coverage includes exact origin/endpoint")
	close_float(ctx, result.full_interval_fps, 3.0, "full-interval FPS")
	result = summarize(ctx, 0.0, 1.0, [-0.5, 0.125, 0.25, 0.5, 1.5])
	close_float(ctx, result.whole_window_fps, 3.0, "whole-window count includes boundary stalls")
	close_float(ctx, result.full_interval_fps, 2.0 / 0.375, "full-interval statistic has independent denominator")
	close_float(ctx, result.initial_partial_seconds, 0.125, "initial excluded stall reported")
	close_float(ctx, result.final_partial_seconds, 0.5, "final excluded stall reported")
	ctx.check(result.initial_partial_stall and result.final_partial_stall, "boundary stall flags retain both gaps")
	ctx.check(result.adjacent_before == -0.5 and result.adjacent_after == 1.5, "adjacent out-of-window callbacks describe boundaries only")
	ctx.done()

func count_samples(ctx) -> void:
	var object = capture(ctx)
	F.invoke(ctx, object, "open_attempt", [1, 10.0])
	F.invoke(ctx, object, "record_step", [1, 0.5, 1, 10.5, 2, true])
	ctx.check(object.enemy_samples.is_empty(), "count sample waits for completed one-second opportunity")
	F.invoke(ctx, object, "record_step", [1, 1.0, 2, 11.5, 3, true])
	F.invoke(ctx, object, "record_step", [1, 1.5, 3, 12.0, 4, true])
	ctx.check(object.enemy_samples == [{"active_time": 1.0, "wall_time": 11.5, "count": 3}], "one-second count carries actual completed simulation/wall timestamps")
	F.invoke(ctx, object, "record_step", [1, 2.0, 4, 12.5, 5, true])
	ctx.check(object.enemy_samples.size() == 2 and object.enemy_samples[1] == {"active_time": 2.0, "wall_time": 12.5, "count": 5}, "next completed count opportunity")
	ctx.done()

func sparse(ctx) -> void:
	for samples in [[], [0.5], [0.25, 0.75]]:
		var result := summarize(ctx, 0.0, 1.0, samples)
		ctx.check(result.callback_count == samples.size() and result.whole_window_fps == float(samples.size()), "zero/one/two callback whole-window evidence")
		if samples.size() < 2:
			ctx.check(result.interval_count == 0 and not result.full_intervals_available, "zero/one callback cannot invent interval")
			ctx.check(not str(result.unavailable_reason).is_empty() and result.minimum_fps == null and result.p50_ms == null, "unavailable distributions/minimum carry explicit reason")
			close_float(ctx, result.uncovered_wall_seconds, 1.0, "entire sparse window remains uncovered by full intervals")
		else:
			ctx.check(result.interval_count == 1 and result.full_intervals_available, "two callbacks suffice for one full interval")
			close_float(ctx, result.interval_coverage, 0.5, "single interval coverage")
			close_float(ctx, result.minimum_fps, 2.0, "single interval minimum")
			for field in ["p50_ms", "p95_ms", "p99_ms", "max_ms"]:
				close_float(ctx, result[field], 500.0, "single interval " + field)
	ctx.done()

func distribution(ctx) -> void:
	var timestamps: Array = [0.0]
	var elapsed := 0.0
	for index in range(1, 101):
		elapsed += float(index) / 1000.0
		timestamps.append(elapsed)
	var counts := [{"active_time": 1.0, "wall_time": 1.1, "count": 2}, {"active_time": 2.0, "wall_time": 2.2, "count": 4}, {"active_time": 3.0, "wall_time": 3.3, "count": 9}]
	var result := summarize(ctx, 0.0, elapsed, timestamps, counts)
	ctx.check(result.interval_count == 100 and result.callback_count == 100, "all full intervals/callbacks recorded")
	# Nearest-rank percentiles are the fixture's documented, provisional statistic seam.
	for row in [["p50_ms", 50.0], ["p95_ms", 95.0], ["p99_ms", 99.0], ["max_ms", 100.0], ["minimum_fps", 10.0]]:
		close_float(ctx, result[row[0]], row[1], "actual helper " + row[0])
	ctx.check(result.stalls_over_16_67 == 84 and result.stalls_over_33_33 == 67, "strict stall threshold counts")
	ctx.check(result.enemy_min == 2 and result.enemy_max == 9 and result.enemy_mean == 5.0, "enemy sample min/max/mean")
	ctx.check(result.enemy_samples == counts, "count evidence retains simulation and wall timestamps")
	ctx.check(result.timing_kind == "CPU-observed frame-loop", "statistics do not claim GPU/presentation timing")
	ctx.done()

func capture(ctx):
	var object = F.instance(ctx, "res://scripts/run/profile_capture.gd")
	var output: String = ProjectSettings.globalize_path("res://.cache/profile-fixtures/" + ctx.case_id)
	ctx.check(output.begins_with(ProjectSettings.globalize_path("res://.cache/")), "fixture output stays inside workspace cache")
	F.invoke(ctx, object, "configure", [output])
	return object

func generations(ctx) -> void:
	var object = capture(ctx)
	F.invoke(ctx, object, "open_attempt", [1, 10.0])
	F.invoke(ctx, object, "record_frame", [1, 10.25])
	F.invoke(ctx, object, "record_step", [1, 1.0, 1, 11.0, 2, true])
	F.invoke(ctx, object, "open_attempt", [2, 20.0])
	F.invoke(ctx, object, "record_frame", [1, 20.1])
	F.invoke(ctx, object, "record_step", [1, 300.0, 999, 20.2, 99, true])
	F.invoke(ctx, object, "record_spawn_failure", [1, {"cause": "old generation"}])
	ctx.check(object.run_generation == 2 and object.frame_timestamps.is_empty() and object.enemy_samples.is_empty(), "stale generation cannot contaminate new buffers")
	ctx.check(object.spawn_failure_count == 0 and not object.acceptance_invalid, "stale failure cannot invalidate new attempt")
	ctx.check(object.retained_attempts.size() == 1 and object.retained_attempts[0].run_generation == 1, "old attempt evidence retained before reset")
	F.invoke(ctx, object, "record_frame", [2, 20.5])
	ctx.check(object.frame_timestamps == [20.5], "new generation captures normally")
	ctx.done()

func endpoint(ctx) -> void:
	var object = capture(ctx)
	F.invoke(ctx, object, "open_attempt", [7, 10.0])
	F.invoke(ctx, object, "record_step", [7, 299.5, 1, 1000.0, 3, true])
	ctx.check(object.buffer_open and object.survival_window_outcome != "passed", "large wall duration cannot close survival window")
	F.invoke(ctx, object, "record_frame", [7, 1000.125])
	F.invoke(ctx, object, "record_step", [7, 300.0, 2, 1000.25, 4, true])
	ctx.check(not object.buffer_open and object.t1 == 1000.25 and object.completed_simulation_duration == 300.0 and object.completed_step_count == 2, "endpoint at first completed step >=300, exact t1/ticks")
	ctx.check(object.survival_window_outcome == "passed" and object.continuation_outcome != "passed", "survival completion alone never implies full continuation/acceptance")
	ctx.check(object.frame_timestamps.is_empty() and object.enemy_samples.is_empty(), "raw endpoint buffers flushed/released")
	ctx.check(object.profile_capture_outcome == "passed" and FileAccess.file_exists(object.evidence_path), "required evidence actually written inside workspace")
	ctx.done()

func lethal_endpoint(ctx) -> void:
	var object = capture(ctx)
	F.invoke(ctx, object, "open_attempt", [1, 0.0])
	F.invoke(ctx, object, "record_step", [1, 300.0, 18000, 400.0, 3, false])
	ctx.check(not object.buffer_open and object.t1 == 400.0 and object.survival_window_outcome != "passed", "lethal endpoint closes after combat result, never claims survival")
	ctx.check(object.completed_simulation_duration == 300 and object.completed_step_count == 18000, "lethal endpoint still retains final committed timestamp/ticks")
	# Also prove the production coordinator publishes the committed lethal result
	# to its actual helper after combat, rather than closing at step beginning.
	var d = ctx.definitions()
	d.player.max_health = 10
	d.spawn_interval = 1000.0
	var run = F.run(ctx, d)
	var integrated = capture(ctx)
	run.profile_capture = integrated
	F.invoke(ctx, integrated, "open_attempt", [run.run_generation, Time.get_ticks_usec() / 1000000.0])
	run.active_time = 299.5
	var enemy = F.enemy(ctx, d, 0, Vector3.ZERO)
	F.invoke(ctx, run.registry, "add", [enemy, 0])
	F.invoke(ctx, run, "step", [0.5])
	ctx.check(run.state == "GameOver" and run.active_time == 300.0 and integrated.completed_simulation_duration == 300.0, "coordinator commits lethal 300-second endpoint before recording helper outcomes")
	ctx.check(not integrated.buffer_open and integrated.survival_window_outcome != "passed", "actual lethal combat never qualifies survival-window success")
	ctx.done()

func bounded_late_failure(ctx) -> void:
	var object = capture(ctx)
	F.invoke(ctx, object, "open_attempt", [3, 0.0])
	F.invoke(ctx, object, "record_step", [3, 300.125, 1, 400.0, 3, true])
	for index in 1000:
		F.invoke(ctx, object, "record_frame", [3, 401.0 + index])
		F.invoke(ctx, object, "record_step", [3, 301.0 + index, 2 + index, 401.0 + index, 4, true])
	ctx.check(object.frame_timestamps.is_empty() and object.enemy_samples.is_empty(), "unlimited continuation cannot grow closed five-minute buffers")
	F.invoke(ctx, object, "record_spawn_failure", [3, {"cause": "late injected failure"}])
	ctx.check(object.spawn_failure_count == 1 and object.acceptance_invalid, "failure invalidates even after buffer closes")
	ctx.check(object.survival_window_outcome == "passed", "late fault preserves collected survival observation without granting attempt acceptance")
	ctx.done()

func continuation(ctx) -> void:
	var d = ctx.definitions()
	d.enemy.max_health = 1000
	d.weapon.attack_interval = 0.5
	d.enemy.contact_interval = 0.5
	var before := F.snapshot(d)
	var run = F.run(ctx, d)
	# Deterministic crossing fixture sets a committed starting time, not owner evidence.
	run.active_time = 299.5
	run.spawner.next_spawn_index = 200
	run.spawner.next_spawn_at = 300.0
	run.weapon.next_attack_at = 300.0
	var enemy = F.enemy(ctx, d, 0, Vector3.ZERO)
	enemy.next_contact_at = 300.0
	F.invoke(ctx, run.registry, "add", [enemy, 0])
	run.next_spawn_id = 1
	F.invoke(ctx, run, "step", [0.5])
	ctx.check(run.active_time == 300.0 and run.state == "Active" and population(ctx, run) == 2, "spawn and live gameplay continue at endpoint")
	ctx.check(enemy.health.current_health == 990 and run.player.health.current_health == 90, "eligible weapon/contact at exact 300")
	F.invoke(ctx, run.camera, "queue_mouse", [Vector2(10, -10)])
	Input.action_press("move_right")
	F.invoke(ctx, run, "step", [0.5])
	Input.action_release("move_right")
	ctx.check(run.active_time == 300.5 and run.state == "Active" and run.player.position != Vector3.ZERO and run.camera.yaw != 0, "post-300 movement/view/time responsive")
	# Keep a target eligible for deterministic post-endpoint attacks, without owner cheats.
	enemy.position = run.player.position
	F.invoke(ctx, run, "step", [1.0])
	ctx.check(run.active_time == 301.5 and population(ctx, run) == 3, "next ordinary scheduled spawn after endpoint")
	ctx.check(enemy.health.current_health <= 980 and run.player.health.current_health <= 80, "eligible weapon/contact scheduling persists beyond endpoint")
	ctx.check(F.snapshot(d) == before and run.player.health.max_health == 100, "tuning/vulnerability unchanged across 300")
	ctx.done()

func population(ctx, run) -> int:
	return F.invoke(ctx, run.registry, "living_in_spawn_order").size()
