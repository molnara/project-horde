extends SceneTree

const Manifest = preload("res://tests/case_manifest.gd")
const Context = preload("res://tests/support/test_context.gd")
const ErrorMonitor = preload("res://tests/support/error_monitor.gd")
var error_monitor := ErrorMonitor.new()

func _initialize() -> void:
	OS.add_logger(error_monitor)
	call_deferred("run")

func run() -> void:
	var manifest: Array[Dictionary] = Manifest.entries()
	var staged: Array[Dictionary] = Manifest.staged_entries()
	var authored: Array[Dictionary] = manifest.duplicate()
	authored.append_array(staged)
	var foundation_only := OS.get_cmdline_user_args().has("--foundation-only")
	print("HORDE_SUITE_SCOPE=" + ("foundation-only (gameplay excluded, not feature acceptance)" if foundation_only else "all required cases"))
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
	# Reconcile every authored method, including the explicit, unregistered US2
	# inventory. Missing/duplicate/unknown cases remain failures before scoping.
	failures.append_array(Manifest.reconcile(authored, discovered))
	for entry in staged:
		if entry.get("ready_after", []).is_empty():
			failures.append("staged case lacks implementation gate: " + entry.id)
		print("HORDE_CASE_DEFERRED=" + JSON.stringify({"case": entry.id, "script": entry.script, "ready_after": entry.get("ready_after", []), "status": "authored, unregistered, unrun", "seed": entry.seed}))
	# Always reconcile ALL authored cases before selecting an explicit limited run.
	var selected := Manifest.select_scope(manifest, foundation_only)
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
			print("HORDE_CASE_END=" + JSON.stringify({"case": entry.id, "assertions": ctx.assertions, "passed": ctx.failures.is_empty(), "completed": ctx.completed}))
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
	print("HORDE_SUITE_END=" + JSON.stringify({"required": selected.size(), "registered": manifest.size(), "authored": authored.size(), "deferred": staged.size(), "excluded": manifest.size() - selected.size(), "scope": "foundation" if foundation_only else "all", "pending": pending.size(), "executed": executed.size(), "assertions": assertion_count, "passed": failures.is_empty()}))
	OS.remove_logger(error_monitor)
	quit(0 if failures.is_empty() else 1)
