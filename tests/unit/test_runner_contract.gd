extends RefCounted

const Manifest = preload("res://tests/case_manifest.gd")
const Context = preload("res://tests/support/test_context.gd")

func cases() -> Array[Dictionary]:
	return [{"id": "runner.reconciliation", "method": "reconciliation"}, {"id": "runner.context", "method": "context"}, {"id": "runner.diagnostics", "method": "diagnostics"}]

func reconciliation(ctx) -> void:
	var entry := {"id": "one", "script": "res://tests/unit/test_one.gd", "maps": ["fixture"], "seed": 42, "expected": []}
	var found := {"id": "one", "script": entry.script, "method": "one"}
	ctx.check(Manifest.reconcile([entry], [found], ["one"], true).is_empty(), "complete case reconciliation")
	for fixture in [
		{"manifest": [], "found": [], "executed": [], "error": "zero"},
		{"manifest": [entry, entry], "found": [found], "executed": ["one"], "error": "duplicate manifest"},
		{"manifest": [entry], "found": [found, found], "executed": ["one"], "error": "duplicate discovered"},
		{"manifest": [entry], "found": [], "executed": [], "error": "missing"},
		{"manifest": [], "found": [found], "executed": [], "error": "unregistered"},
		{"manifest": [entry], "found": [found], "executed": [], "error": "unexecuted"},
		{"manifest": [entry], "found": [found], "executed": ["one", "one"], "error": "duplicate executed"},
		{"manifest": [entry], "found": [{"id": "one", "script": "wrong"}], "executed": ["one"], "error": "wrong script"},
	]:
		var errors: Array[String] = Manifest.reconcile(fixture.manifest, fixture.found, fixture.executed, true)
		ctx.check("\n".join(errors).contains(fixture.error), "detect " + fixture.error)
	ctx.check(Manifest.discover("res://tests/support").is_empty(), "support files are not designated cases")
	ctx.check(Manifest.discover("res://tests/unit").has("res://tests/unit/test_runner_contract.gd"), "designated script discovered")
	ctx.done()

func context(ctx) -> void:
	var isolated := Context.new("isolated", 123)
	var first: RunDefinition = isolated.definitions()
	var second: RunDefinition = isolated.definitions()
	first.player.max_health = 1
	ctx.check(second.player.max_health == 100, "definition copies isolated")
	var other := RandomNumberGenerator.new()
	other.seed = 123
	ctx.check(isolated.rng.randi() == other.randi(), "fixed RNG seed reproducible")
	var node := Node.new()
	isolated.own(node)
	var calls := [0]
	var callback := func(): calls[0] += 1
	isolated.connect_callback(node.tree_exiting, callback)
	ctx.check(node.tree_exiting.is_connected(callback), "callback connected")
	isolated.cleanup()
	ctx.check(not is_instance_valid(node), "owned node disposed")
	ctx.check(isolated.connections.is_empty() and isolated.owned_nodes.is_empty(), "scene and callback records cleared")
	ctx.check(calls[0] == 0, "callback disconnected before teardown")
	var emitter := Node.new()
	isolated.connect_callback(emitter.tree_exiting, callback)
	isolated.cleanup()
	ctx.check(not emitter.tree_exiting.is_connected(callback), "external emitter callback disconnected")
	emitter.tree_exiting.emit()
	ctx.check(calls[0] == 0, "no callback after case cleanup")
	emitter.free()
	ctx.check(not isolated.completed, "missing completion remains detectable")
	isolated.done()
	ctx.check(isolated.completed, "explicit completion recorded")
	ctx.done()

func diagnostics(ctx) -> void:
	ctx.application_diagnostic({"source": "fixture/configuration", "field": "cap", "observed": "0", "constraint": "positive integer", "cause": "intentional fixture"})
	ctx.check(ctx.diagnostic_errors().is_empty(), "declared application fault matches exactly")
	var probe := Context.new("probe", 123, [{"source": "fixture", "constraint": "positive", "count": 1}])
	ctx.check(not probe.diagnostic_errors().is_empty(), "missing expected fault rejected")
	probe.observed = [{"case": "probe", "source": "fixture", "constraint": "positive"}]
	ctx.check(probe.diagnostic_errors().is_empty(), "exact case/source/constraint/count accepted")
	probe.observed.append(probe.observed[0])
	ctx.check(not probe.diagnostic_errors().is_empty(), "excess count rejected")
	probe.observed = [{"case": "another", "source": "fixture", "constraint": "positive"}]
	ctx.check(not probe.diagnostic_errors().is_empty(), "wrong case rejected")
	probe.observed = [{"case": "probe", "source": "other", "constraint": "positive"}]
	ctx.check(not probe.diagnostic_errors().is_empty(), "wrong source rejected")
	probe.observed = [{"case": "probe", "source": "fixture", "constraint": "other"}]
	ctx.check(not probe.diagnostic_errors().is_empty(), "wrong constraint rejected")
	probe.expected.append(probe.expected[0])
	probe.observed = [{"case": "probe", "source": "fixture", "constraint": "positive"}]
	ctx.check(not probe.diagnostic_errors().is_empty(), "duplicate declarations rejected")
	ctx.done()
