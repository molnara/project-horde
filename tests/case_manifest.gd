extends RefCounted
## Only designated test_*.gd files under unit/integration are discoverable.
## Helpers live under support/; add story cases here as their tasks ship.

static func entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in ["defaults", "references", "numbers", "vectors", "geometry", "camera", "boundaries", "nonmutation"]:
		result.append({"id": "definitions." + id, "script": "res://tests/unit/test_definitions.gd", "maps": ["definition-contract", "FR-002", "FR-003", "FR-004", "FR-005", "FR-006", "FR-008", "invalid-data/" + id], "seed": 4702001, "expected": []})
	for id in ["reconciliation", "context", "diagnostics"]:
		result.append({"id": "runner." + id, "script": "res://tests/unit/test_runner_contract.gd", "maps": ["A-G/G", "harness/" + id], "seed": 4702012, "expected": [{"source": "fixture/configuration", "constraint": "positive integer", "count": 1}] if id == "diagnostics" else []})
	return result

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
