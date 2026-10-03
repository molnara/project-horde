extends RefCounted

const Manifest = preload("res://tests/case_manifest.gd")
const Context = preload("res://tests/support/test_context.gd")
const Sampling = preload("res://tests/support/scripted_rng.gd")
const Faults = preload("res://tests/support/spawn_faults.gd")
const F = preload("res://tests/support/gameplay_fixture.gd")

func cases() -> Array[Dictionary]:
	return [{"id": "runner.reconciliation", "method": "reconciliation"}, {"id": "runner.context", "method": "context"}, {"id": "runner.diagnostics", "method": "diagnostics"}, {"id": "runner.prerequisites", "method": "prerequisites"}, {"id": "runner.fixtures", "method": "fixtures"}]

func prerequisites(ctx) -> void:
	ctx.check(Manifest.missing_prerequisites(["res://tests/support/gameplay_fixture.gd"]).is_empty(), "existing fixture is executable prerequisite")
	ctx.check(Manifest.missing_prerequisites(["res://tests/support/absent-component.fixture"]) == ["res://tests/support/absent-component.fixture"], "expected absence is reported without load/error")
	ctx.check(Manifest.missing_prerequisites(["outside-workspace.gd"]) == ["outside-workspace.gd"], "non-project prerequisite rejected")
	var entries := Manifest.entries()
	var selected := Manifest.select_scope(entries, true)
	ctx.check(selected.size() == 13 and entries.size() == 51, "explicit foundation scope preserves all registered required cases")
	var staged := Manifest.staged_entries()
	ctx.check(staged.size() == 13, "explicit Phase 4 inventory reports all deferred cases")
	for entry in staged:
		ctx.check(not entries.any(func(registered): return registered.id == entry.id), "deferred case is not registered for execution: " + entry.id)
		ctx.check(not entry.ready_after.is_empty(), "deferred case has a documented implementation gate")
		if entry.id.begins_with("restart_evidence."):
			ctx.check(entry.ready_after.has("T039") and entry.ready_after.has("T040"), "T035 registration waits for both T039 and T040")
	var inventory: Array[Dictionary] = entries.duplicate()
	inventory.append_array(staged)
	var discovered_inventory: Array[Dictionary] = []
	for entry in inventory:
		discovered_inventory.append({"id": entry.id, "script": entry.script})
	ctx.check(Manifest.reconcile(inventory, discovered_inventory).is_empty(), "complete staged/registered inventory reconciles")
	discovered_inventory.pop_back()
	ctx.check(not Manifest.reconcile(inventory, discovered_inventory).is_empty(), "missing staged case fails discovery reconciliation")
	ctx.check(not Manifest.reconcile(entries, [{"id": staged[0].id, "script": staged[0].script}]).is_empty(), "staging does not waive unregistered-case checks")
	ctx.check(Manifest.select_scope(entries, false).size() == entries.size(), "default includes every gameplay case")
	var gameplay := {"id": "movement.example", "script": "res://tests/unit/test_movement_arena.gd", "maps": ["FR-001"], "seed": 1, "expected": []}
	ctx.check(not Manifest.reconcile([gameplay], [{"id": gameplay.id, "script": gameplay.script}], [], true).is_empty(), "pending prerequisite cannot satisfy execution reconciliation")
	ctx.done()

func fixtures(ctx) -> void:
	var sampling := Sampling.new()
	ctx.check(sampling.randf_range(-2, 2) == 0.0 and sampling.calls == 1, "scripted midpoint generates valid zero coordinate")
	sampling.fractions.assign([0.0, 1.0])
	sampling.calls = 0
	ctx.check(sampling.randf_range(-2, 2) == -2.0 and sampling.randf_range(-2, 2) == 2.0 and sampling.calls == 2, "candidate draws/counter reproducible")
	var faults := Faults.new()
	var failure := faults.choose_spawn(Vector3.ZERO, 0.4, 1.2, ctx.rng)
	ctx.check(not failure.success and not failure.has("position") and failure.diagnostics.size() == 2, "fault fixture deliberately forbids position reads and supplies two records")
	ctx.check(faults.selection_calls == 1 and faults.factory_calls == 0, "selection fixture has no instantiation/scheduling algorithm")
	faults.mode = "instantiate"
	ctx.check(faults.create_enemy() == null and faults.factory_calls == 1, "null instantiation fault is explicit")
	faults.mode = "partial"
	ctx.own(faults.create_enemy())
	ctx.check(is_instance_valid(faults.partial) and not faults.partial.has_method("configure"), "partial instance cannot satisfy configuration contract")
	var isolated := Context.new("fixture-teardown", 4702014)
	isolated.own(faults.partial)
	isolated.cleanup()
	ctx.check(not is_instance_valid(faults.partial), "partial fixture supports disposal checks without leaks")
	var entries := F.cases_for("example", ["one", "two"], ["res://missing.scene"])
	ctx.check(entries.size() == 2 and entries[0].id == "example.one" and entries[0].requires == ["res://missing.scene"], "case factory preserves explicit ID/method/prerequisites")
	entries[0].requires.clear()
	ctx.check(entries[1].requires == ["res://missing.scene"], "case prerequisite lists independent")
	ctx.done()

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
