extends SceneTree

const Manifest = preload("res://tests/case_manifest.gd")
const Context = preload("res://tests/support/test_context.gd")
const ErrorMonitor = preload("res://tests/support/error_monitor.gd")
var error_monitor := ErrorMonitor.new()

func _initialize() -> void:
	OS.add_logger(error_monitor)
	call_deferred("run")

func run() -> void:
	var suite_started := Time.get_ticks_usec()
	var manifest: Array[Dictionary] = Manifest.entries()
	var staged: Array[Dictionary] = Manifest.staged_entries()
	var authored: Array[Dictionary] = manifest.duplicate()
	authored.append_array(staged)
	var foundation_only := OS.get_cmdline_user_args().has("--foundation-only")
	var fast := OS.get_cmdline_user_args().has("--fast")
	var groups: Array[String] = []
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--case-group="):
			groups.append(argument.trim_prefix("--case-group="))
	var scope := "foundation" if foundation_only else ("fast" if fast else ("targeted" if not groups.is_empty() else "all"))
	print("HORDE_SUITE_SCOPE=" + scope + " (only all required cases can establish complete technical acceptance)")
	var discovered: Array[Dictionary] = []
	var fixtures := {}
	var failures: Array[String] = []
	for path in Manifest.discover("res://tests/unit") + Manifest.discover("res://tests/integration"):
		var script: GDScript = load(path)
		if script == null or not script.can_instantiate():
			failures.append("cannot instantiate case script: " + path)
			continue
		var fixture: RefCounted = script.new()
		if not fixture.has_method("cases"):
			failures.append("designated script has no cases(): " + path)
			continue
		fixtures[path] = fixture
		var entries: Variant = fixture.call("cases")
		if not entries is Array or entries.is_empty():
			failures.append("zero/invalid cases in designated script: " + path)
			continue
		for entry in entries:
			if not entry is Dictionary or not entry.has_all(["id", "method"]) or not fixture.has_method(entry.get("method", "")):
				failures.append("missing/invalid case method in " + path + ": " + str(entry))
				continue
			discovered.append({"id": entry.id, "script": path, "method": entry.method, "requires": entry.get("requires", [])})
	# Reconcile every authored method, including the explicit, unregistered story
	# inventory. Missing/duplicate/unknown cases remain failures before scoping.
	failures.append_array(Manifest.reconcile(authored, discovered))
	if int(foundation_only) + int(fast) + int(not groups.is_empty()) > 1:
		failures.append("conflicting native suite selections")
	if not groups.is_empty():
		failures.append_array(Manifest.selection_errors(manifest, groups))
	for entry in staged:
		if entry.get("ready_after", []).is_empty():
			failures.append("staged case lacks implementation gate: " + entry.id)
		print("HORDE_CASE_DEFERRED=" + JSON.stringify({"case": entry.id, "script": entry.script, "ready_after": entry.get("ready_after", []), "status": "authored, unregistered, unrun", "seed": entry.seed}))
	# Always reconcile ALL authored cases before selecting an explicit limited run.
	var selected := Manifest.select_scope(manifest, foundation_only)
	if fast or not groups.is_empty():
		selected = Manifest.select_tier(manifest, fast, groups)
	for entry in manifest:
		if not selected.has(entry):
			print("HORDE_CASE_EXCLUDED=" + JSON.stringify({"case": entry.id, "scope": scope, "status": "excluded, unrun; acceptance pending"}))
	var executed: Array[String] = []
	var pending: Array[Dictionary] = []
	var assertion_count := 0
	if failures.is_empty():
		for entry in selected:
			var method: String = ""
			var prerequisites: Array = []
			for found in discovered:
				if found.id == entry.id:
					method = found.method
					prerequisites = found.requires
			var missing := Manifest.missing_prerequisites(prerequisites)
			if not missing.is_empty():
				var record := {"case": entry.id, "missing": missing, "status": "pending", "seed": entry.seed}
				pending.append(record)
				print("HORDE_CASE_PENDING=" + JSON.stringify(record))
				continue
			var ctx := Context.new(entry.id, entry.seed, entry.expected)
			var case_started := Time.get_ticks_usec()
			print("HORDE_CASE_BEGIN=" + JSON.stringify({"case": entry.id, "seed": entry.seed, "expected": entry.expected}))
			await fixtures[entry.script].call(method, ctx)
			ctx.cleanup()
			ctx.failures.append_array(ctx.diagnostic_errors())
			if not ctx.completed:
				ctx.failures.append("unexecuted/incomplete case: explicit done() not reached")
			if ctx.assertions == 0:
				ctx.failures.append("zero assertions")
			if ctx.completed:
				executed.append(entry.id)
			assertion_count += ctx.assertions
			failures.append_array(ctx.failures)
			print("HORDE_CASE_END=" + JSON.stringify({"case": entry.id, "assertions": ctx.assertions, "passed": ctx.failures.is_empty(), "completed": ctx.completed, "elapsed_seconds": (Time.get_ticks_usec() - case_started) / 1000000.0}))
	var selected_discovery: Array[Dictionary] = []
	for found in discovered:
		for entry in selected:
			if found.id == entry.id:
				selected_discovery.append(found)
	failures.append_array(Manifest.reconcile(selected, selected_discovery, executed, true))
	var diagnostics := error_monitor.snapshot()
	for error in diagnostics.errors:
		failures.append("unexpected engine error: " + error)
	for warning in diagnostics.warnings:
		print("HORDE_RECORDED_WARNING=" + warning)
	for failure in failures:
		print("HORDE_SUITE_FAILURE=" + failure)
	print("HORDE_SUITE_END=" + JSON.stringify({"required": selected.size(), "registered": manifest.size(), "authored": authored.size(), "deferred": staged.size(), "excluded": manifest.size() - selected.size(), "scope": scope, "groups": groups, "pending": pending.size(), "executed": executed.size(), "assertions": assertion_count, "passed": failures.is_empty(), "elapsed_seconds": (Time.get_ticks_usec() - suite_started) / 1000000.0}))
	OS.remove_logger(error_monitor)
	quit(0 if failures.is_empty() else 1)
