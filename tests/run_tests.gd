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
			discovered.append({"id": entry.id, "script": path, "method": entry.method})
	failures.append_array(Manifest.reconcile(manifest, discovered))
	var executed: Array[String] = []
	var assertion_count := 0
	if failures.is_empty():
		for entry in manifest:
			var method: String = ""
			for found in discovered:
				if found.id == entry.id:
					method = found.method
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
	failures.append_array(Manifest.reconcile(manifest, discovered, executed, true))
	var diagnostics := error_monitor.snapshot()
	for error in diagnostics.errors:
		failures.append("unexpected engine error: " + error)
	for warning in diagnostics.warnings:
		print("HORDE_RECORDED_WARNING=" + warning)
	for failure in failures:
		print("HORDE_SUITE_FAILURE=" + failure)
	print("HORDE_SUITE_END=" + JSON.stringify({"required": manifest.size(), "executed": executed.size(), "assertions": assertion_count, "passed": failures.is_empty()}))
	OS.remove_logger(error_monitor)
	quit(0 if failures.is_empty() else 1)
