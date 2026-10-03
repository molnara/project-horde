extends RefCounted
## Only designated test_*.gd files under unit/integration are discoverable.
## Helpers live under support/; add story cases here as their tasks ship.

static func entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in ["defaults", "references", "numbers", "vectors", "geometry", "camera", "boundaries", "nonmutation"]:
		result.append({"id": "definitions." + id, "script": "res://tests/unit/test_definitions.gd", "maps": ["definition-contract", "FR-002", "FR-003", "FR-004", "FR-005", "FR-006", "FR-008", "invalid-data/" + id], "seed": 4702001, "expected": []})
	for id in ["reconciliation", "context", "diagnostics"]:
		result.append({"id": "runner." + id, "script": "res://tests/unit/test_runner_contract.gd", "maps": ["A-G/G", "harness/" + id], "seed": 4702012, "expected": [{"source": "fixture/configuration", "constraint": "positive integer", "count": 1}] if id == "diagnostics" else []})
	result.append({"id": "runner.prerequisites", "script": "res://tests/unit/test_runner_contract.gd", "maps": ["A-G/G", "pending-is-not-passed", "full-discovery-before-scoping"], "seed": 4702014, "expected": []})
	result.append({"id": "runner.fixtures", "script": "res://tests/unit/test_runner_contract.gd", "maps": ["T014", "T016", "A-G/G", "scripted-sampling", "selection-without-position", "partial-instance-teardown"], "seed": 4702014, "expected": []})
	for id in ["directions", "mouse_follow", "containment", "selection", "selection_failure", "pursuit"]:
		result.append({"id": "movement." + id, "script": "res://tests/unit/test_movement_arena.gd", "maps": ["T014", "FR-001", "FR-002", "FR-003", "FR-004", "movement/" + id], "seed": 4702014, "expected": []})
	for id in ["health", "invalid_damage", "registry_death", "targeting", "weapon_readiness", "contact", "feedback"]:
		var expected: Array = [{"source": "Health", "constraint": "positive integer damage", "count": 8}] if id == "invalid_damage" else []
		result.append({"id": "combat." + id, "script": "res://tests/unit/test_combat.gd", "maps": ["T015", "FR-005", "FR-006", "FR-007", "FR-008", "combat/" + id], "seed": 4702015, "expected": expected})
	for id in ["fresh", "cadence_cap", "default_custom_cap", "deadlines", "subtick_long_step", "wall_stall", "order", "lethal", "hud", "startup_failure", "selection_fault", "instantiation_fault", "partial_fault"]:
		var expected: Array = []
		if id == "selection_fault":
			expected = [{"source": "fixture/arena", "constraint": "strictly outside contact distance", "count": 2}]
		elif id in ["partial_fault", "instantiation_fault"]:
			expected = [{"source": "EnemySpawner", "constraint": "fully configured enemy before registry publication", "count": 1}]
		elif id == "startup_failure":
			expected = [{"source": "PlayerDefinition", "constraint": "positive integer", "count": 1}]
		result.append({"id": "survival." + id, "script": "res://tests/integration/test_survival_loop.gd", "maps": ["T016", "FR-001", "FR-004", "FR-005", "FR-006", "FR-007", "FR-008", "FR-009", "A-G/B", "A-G/C", "survival/" + id], "seed": 4702016, "expected": expected})
	for id in ["boundaries", "sparse", "distribution", "generations", "count_samples", "endpoint", "lethal_endpoint", "bounded_late_failure", "continuation"]:
		result.append({"id": "profile." + id, "script": "res://tests/unit/test_profile_capture.gd", "maps": ["T017", "SC-006", "SC-007", "A-G/A", "A-G/E", "A-G/F", "profile/" + id], "seed": 4702017, "expected": []})
	for id in ["lethal_commit", "freeze_escape", "final_hud"]:
		result.append({"id": "defeat." + id, "script": "res://tests/integration/test_defeat_restart.gd", "maps": ["T034", "FR-009", "FR-010", "defeat/" + id], "seed": 4702034, "expected": []})
	# Batch 2 promotes the authored cases as T036–T040 dependencies are ready.
	for id in ["game_over_control", "three_cycles", "guarded_requests", "stale_callbacks_removal", "invalid_restart", "failure_isolation"]:
		var expected: Array = []
		if id == "invalid_restart":
			expected = [{"source": "PlayerDefinition", "constraint": "positive integer", "count": 1}]
		elif id == "failure_isolation":
			expected = [{"source": "fixture/arena", "constraint": "strictly outside contact distance", "count": 2}]
		result.append({"id": "defeat." + id, "script": "res://tests/integration/test_defeat_restart.gd", "maps": ["T034", "FR-010", "FR-011", "SC-002", "defeat/" + id], "seed": 4702034, "expected": expected, "ready_after": ["T036", "T037", "T038", "T039"]})
	for id in ["seal_before_teardown", "stale_generations", "valid_open", "invalid_no_open", "shutdown_fault", "write_fault", "post300_death"]:
		var expected: Array = []
		if id == "invalid_no_open":
			expected = [{"source": "PlayerDefinition", "constraint": "positive integer", "count": 1}]
		elif id in ["shutdown_fault", "write_fault"]:
			expected = [{"source": "ProfileCapture", "constraint": "required output written successfully", "count": 1}]
		result.append({"id": "restart_evidence." + id, "script": "res://tests/integration/test_restart_evidence.gd", "maps": ["T035", "FR-011", "SC-006", "SC-007", "evidence/" + id], "seed": 4702035, "expected": expected, "ready_after": ["T039", "T040"]})
	return result

static func staged_entries() -> Array[Dictionary]:
	return []

static func missing_prerequisites(paths: Array) -> Array[String]:
	var missing: Array[String] = []
	for path in paths:
		if not path is String or not path.begins_with("res://") or not FileAccess.file_exists(path):
			missing.append(str(path))
	return missing

static func select_scope(manifest: Array[Dictionary], foundation_only: bool) -> Array[Dictionary]:
	var selected: Array[Dictionary] = []
	for entry in manifest:
		if not foundation_only or entry.id.begins_with("definitions.") or entry.id.begins_with("runner."):
			selected.append(entry)
	return selected

static func discover(directory: String) -> Array[String]:
	var result: Array[String] = []
	if not (directory == "res://tests/unit" or directory.begins_with("res://tests/unit/") or directory == "res://tests/integration" or directory.begins_with("res://tests/integration/")):
		return result
	# integration/ is optional until its first scene tests are authored.
	if not DirAccess.dir_exists_absolute(directory):
		return result
	var access := DirAccess.open(directory)
	if access == null:
		push_error("Cannot enumerate designated case directory: " + directory)
		return result
	for name in access.get_files():
		if name.begins_with("test_") and name.ends_with(".gd"):
			result.append(directory.path_join(name))
	for child in access.get_directories():
		result.append_array(discover(directory.path_join(child)))
	result.sort()
	return result

static func reconcile(manifest: Array, discovered: Array, executed: Array = [], require_execution: bool = false) -> Array[String]:
	var errors: Array[String] = []
	var required := {}
	var found := {}
	var ran := {}
	if manifest.is_empty() or discovered.is_empty():
		errors.append("zero cases: manifest and discovery must both be nonempty")
	for entry in manifest:
		if not entry is Dictionary or not entry.has_all(["id", "script", "maps", "seed", "expected"]) or str(entry.get("id", "")).is_empty() or entry.get("maps", []).is_empty():
			errors.append("malformed manifest entry: " + str(entry))
			continue
		if required.has(entry.id):
			errors.append("duplicate manifest case: " + entry.id)
		required[entry.id] = entry
	for entry in discovered:
		if found.has(entry.id):
			errors.append("duplicate discovered case: " + entry.id)
		found[entry.id] = entry
		if not required.has(entry.id):
			errors.append("unregistered case: " + entry.id)
		elif required[entry.id].script != entry.script:
			errors.append("wrong script path for case: " + entry.id)
	for id in required:
		if not found.has(id):
			errors.append("missing discovered case: " + id + " in " + required[id].script)
	for id in executed:
		if ran.has(id):
			errors.append("duplicate executed case: " + id)
		if not required.has(id):
			errors.append("unregistered executed case: " + id)
		ran[id] = true
	if require_execution:
		for id in required:
			if not ran.has(id):
				errors.append("unexecuted case: " + id)
	return errors
