extends RefCounted

var case_id: String
var seed_value: int
var rng := RandomNumberGenerator.new()
var failures: Array[String] = []
var assertions: int = 0
var completed: bool = false
var expected: Array = []
var observed: Array = []
var owned_nodes: Array[Node] = []
var connections: Array[Dictionary] = []

func _init(id: String, fixed_seed: int, expectations: Array = []) -> void:
	case_id = id
	seed_value = fixed_seed
	rng.seed = fixed_seed
	expected = expectations.duplicate(true)

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
		print("HORDE_ASSERTION_FAILED=" + JSON.stringify({"case": case_id, "message": message}))

func done() -> void:
	completed = true

func definitions() -> RunDefinition:
	var shared: RunDefinition = load("res://resources/definitions/run.tres")
	# Explicitly copy references too; duplication semantics must never share tuning.
	var copy: RunDefinition = shared.duplicate()
	for field in ["player", "enemy", "weapon", "arena"]:
		copy.set(field, shared.get(field).duplicate())
	return copy

func own(node: Node) -> Node:
	owned_nodes.append(node)
	return node

func connect_callback(event: Signal, callback: Callable) -> void:
	event.connect(callback)
	connections.append({"signal": event, "callback": callback})

func cleanup() -> void:
	# Even a genuine component exception must not leave synthetic key state behind.
	for action in ["move_forward", "move_backward", "move_left", "move_right", "pause_toggle"]:
		if InputMap.has_action(action):
			Input.action_release(action)
	for connection in connections:
		var event: Signal = connection.signal
		if not event.is_null() and is_instance_id_valid(event.get_object_id()) and event.is_connected(connection.callback):
			event.disconnect(connection.callback)
	connections.clear()
	for node in owned_nodes:
		if is_instance_valid(node):
			node.free()
	owned_nodes.clear()

func application_diagnostic(record: Dictionary) -> void:
	var payload := record.duplicate(true)
	payload["case"] = case_id
	observed.append(payload)
	print("HORDE_APP_DIAGNOSTIC=" + JSON.stringify(payload))

func diagnostic_errors() -> Array[String]:
	var errors: Array[String] = []
	var counts := {}
	for record in observed:
		var matches := 0
		for index in expected.size():
			var declaration: Dictionary = expected[index]
			if record.get("case") == case_id and record.get("source") == declaration.get("source") and record.get("constraint") == declaration.get("constraint"):
				matches += 1
				counts[index] = counts.get(index, 0) + 1
		if matches != 1:
			errors.append("unexpected/ambiguous application diagnostic: " + str(record))
	for index in expected.size():
		if counts.get(index, 0) != expected[index].count:
			errors.append("application diagnostic count mismatch: " + str(expected[index]))
	return errors
