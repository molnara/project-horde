extends RefCounted
## CPU-observed callbacks, not GPU execution or display presentation timing.
func summarize(t0: float, t1: float, frame_seconds: Array, enemy_samples: Array = []) -> Dictionary:
	var wall := t1 - t0
	var timestamps := frame_seconds.duplicate()
	timestamps.sort()
	var inside: Array = []
	var intervals: Array = []
	var callback_count := 0
	var adjacent_before: Variant = null
	var adjacent_after: Variant = null
	for stamp in timestamps:
		if stamp < t0:
			adjacent_before = stamp
		elif stamp > t1:
			if adjacent_after == null:
				adjacent_after = stamp
		else:
			inside.append(stamp)
			if stamp > t0:
				callback_count += 1
	for index in range(1, inside.size()):
		var interval: float = inside[index] - inside[index - 1]
		if interval > 0:
			intervals.append(interval)
	var coverage := 0.0
	var stalls16 := 0
	var stalls33 := 0
	for interval in intervals:
		coverage += interval
		if interval * 1000 > 16.67:
			stalls16 += 1
		if interval * 1000 > 33.33:
			stalls33 += 1
	intervals.sort()
	var available := not intervals.is_empty()
	var initial: float = inside[0] - t0 if not inside.is_empty() else wall
	var final: float = t1 - inside[-1] if not inside.is_empty() else wall
	var enemy_min: Variant = null
	var enemy_max: Variant = null
	var enemy_total := 0.0
	for sample in enemy_samples:
		enemy_min = sample.count if enemy_min == null else mini(enemy_min, sample.count)
		enemy_max = sample.count if enemy_max == null else maxi(enemy_max, sample.count)
		enemy_total += sample.count
	return {
		"timing_kind": "CPU-observed frame-loop", "wall_duration": wall,
		"callback_count": callback_count, "whole_window_fps": callback_count / wall if wall > 0 else null,
		"interval_count": intervals.size(), "interval_coverage": coverage,
		"full_interval_fps": intervals.size() / coverage if coverage > 0 else null,
		"full_intervals_available": available,
		"unavailable_reason": "" if available else "No positive full intervals wholly contained in the window; distribution and minimum unavailable.",
		"minimum_fps": 1.0 / intervals[-1] if available else null,
		"p50_ms": _percentile(intervals, 0.50), "p95_ms": _percentile(intervals, 0.95), "p99_ms": _percentile(intervals, 0.99),
		"max_ms": intervals[-1] * 1000.0 if available else null,
		"percentile_method": "empirical nearest-rank",
		"stalls_over_16_67": stalls16, "stalls_over_33_33": stalls33,
		"initial_partial_seconds": initial, "final_partial_seconds": final,
		"initial_partial_stall": initial * 1000 > 33.33, "final_partial_stall": final * 1000 > 33.33,
		"uncovered_wall_seconds": maxf(0.0, wall - coverage), "adjacent_before": adjacent_before, "adjacent_after": adjacent_after,
		"enemy_min": enemy_min, "enemy_max": enemy_max,
		"enemy_mean": enemy_total / enemy_samples.size() if not enemy_samples.is_empty() else null,
		"enemy_samples": enemy_samples.duplicate(true),
	}

func _percentile(sorted: Array, fraction: float) -> Variant:
	if sorted.is_empty():
		return null
	return sorted[maxi(0, int(ceil(sorted.size() * fraction)) - 1)] * 1000.0

## Read one timestamp at a time. Exact microsecond frequency counts replace a
## sorted copy of every interval; raw float64 timestamps remain reproducible.
func summarize_file(t0: float, t1: float, path: String, expected_count: int, enemy_samples: Array = []) -> Dictionary:
	var result := summarize(t0, t1, [], enemy_samples)
	var input := FileAccess.open(path, FileAccess.READ)
	if input == null:
		result["capture_error"] = "Cannot reopen frame stream: %s" % FileAccess.get_open_error()
		return result
	if input.get_length() != expected_count * 8:
		result["capture_error"] = "Frame stream length does not match every recorded callback."
		input.close()
		return result
	var histogram: Dictionary = {}
	var previous: Variant = null
	var first: Variant = null
	var last: Variant = null
	var callback_count := 0
	var interval_count := 0
	var coverage := 0.0
	var stalls16 := 0
	var stalls33 := 0
	var previous_raw := -INF
	for index in expected_count:
		var stamp := input.get_double()
		if input.get_error() != OK or not is_finite(stamp) or stamp < previous_raw:
			result["capture_error"] = "Frame stream read failed or timestamps are not finite/monotonic at sample %d." % index
			break
		previous_raw = stamp
		if stamp < t0:
			result.adjacent_before = stamp
		elif stamp > t1:
			if result.adjacent_after == null:
				result.adjacent_after = stamp
		else:
			if first == null:
				first = stamp
			last = stamp
			if stamp > t0:
				callback_count += 1
			if previous != null:
				# Time.get_ticks_usec is the source clock. Recover its exact delta
				# rather than binning/rounding to milliseconds or estimating quantiles.
				var usec := int(round(stamp * 1000000.0)) - int(round(float(previous) * 1000000.0))
				if stamp > float(previous) and usec <= 0:
					result["capture_error"] = "Positive interval is below the source clock's microsecond resolution."
					break
				if usec > 0:
					histogram[usec] = int(histogram.get(usec, 0)) + 1
					interval_count += 1
					coverage += stamp - float(previous)
					if usec > 16670:
						stalls16 += 1
					if usec > 33330:
						stalls33 += 1
			previous = stamp
	input.close()
	var keys := histogram.keys()
	keys.sort()
	var available := interval_count > 0
	var wall := t1 - t0
	result.merge({"callback_count": callback_count, "whole_window_fps": callback_count / wall if wall > 0 else null,
		"interval_count": interval_count, "interval_coverage": coverage,
		"full_interval_fps": interval_count / coverage if coverage > 0 else null,
		"full_intervals_available": available, "unavailable_reason": "" if available else result.unavailable_reason,
		"minimum_fps": 1000000.0 / keys[-1] if available else null,
		"max_ms": keys[-1] / 1000.0 if available else null,
		"stalls_over_16_67": stalls16, "stalls_over_33_33": stalls33,
		"initial_partial_seconds": float(first) - t0 if first != null else wall,
		"final_partial_seconds": t1 - float(last) if last != null else wall,
		"uncovered_wall_seconds": maxf(0, wall - coverage),
		"interval_resolution": "Exact source-clock microseconds; empirical nearest-rank frequency counts, no sampling or millisecond bins",
		"histogram_distinct_intervals": keys.size()}, true)
	result.initial_partial_stall = result.initial_partial_seconds * 1000 > 33.33
	result.final_partial_stall = result.final_partial_seconds * 1000 > 33.33
	for pair in [["p50_ms", 0.50], ["p95_ms", 0.95], ["p99_ms", 0.99]]:
		result[pair[0]] = null
		var rank := int(ceil(interval_count * float(pair[1])))
		var cumulative := 0
		for key in keys:
			cumulative += int(histogram[key])
			if cumulative >= rank:
				result[pair[0]] = key / 1000.0
				break
	return result
