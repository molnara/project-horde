extends Node
signal diagnostic(record: Dictionary)
signal opportunity_failed(records: Array)
signal opportunity_consumed(t_end: float, outcome: String)

var arena: Node3D
var registry: Node
var enemy_definition: EnemyDefinition
var selection_callable: Callable
var enemy_factory: Callable
var rng := RandomNumberGenerator.new()
var run_generation: int
var spawn_interval: float
var max_live_enemies: int
var next_spawn_index: int = 1
var next_spawn_at: float

func configure(definition: RunDefinition, arena_component: Node3D, live_registry: Node, factory: Callable, generation: int) -> void:
	enemy_definition = definition.enemy.duplicate()
	spawn_interval = definition.spawn_interval
	max_live_enemies = definition.max_live_enemies
	arena = arena_component
	registry = live_registry
	enemy_factory = factory
	selection_callable = arena.choose_spawn
	run_generation = generation
	next_spawn_index = 1
	next_spawn_at = spawn_interval
	rng.randomize()

func step(t_end: float, player_position: Vector3, spawn_id: int) -> bool:
	if t_end < next_spawn_at:
		return false
	var index := next_spawn_index
	var scheduled := next_spawn_at
	# Division provides a bounded jump even after very long/sub-tick steps.
	next_spawn_index = maxi(index + 1, int(floor(t_end / spawn_interval)) + 1)
	next_spawn_at = next_spawn_index * spawn_interval
	# Multiplication rounding can put that multiple at t_end; never trigger early.
	if next_spawn_at <= t_end:
		next_spawn_index += 1
		next_spawn_at = next_spawn_index * spawn_interval
	if registry.living_in_spawn_order().size() >= max_live_enemies:
		opportunity_consumed.emit(t_end, "cap_skip")
		return false
	var selection: Dictionary = selection_callable.call(player_position, enemy_definition.visual_radius, enemy_definition.contact_distance, rng)
	if selection.get("success") != true:
		var records: Array = selection.get("diagnostics", [])
		if records.is_empty():
			records = [_fault("selection", "selection result lacks actionable failure diagnostics")]
		_fail(records, index, scheduled, t_end)
		return false
	# Read position only on explicit success. Reject malformed dependency outputs.
	if not selection.get("position") is Vector3 or not selection.position.is_finite() or not selection.get("diagnostics", []).is_empty():
		_fail([_fault("selection", "successful selection requires finite position and empty diagnostics")], index, scheduled, t_end)
		return false
	var selected: Vector3 = selection.position
	if selected != arena.clamp_position(selected, enemy_definition.visual_radius) or not arena.outside_contact(selected, player_position, enemy_definition.contact_distance):
		_fail([_fault("selection", "successful selection violates inset/floor/contact bounds")], index, scheduled, t_end)
		return false
	var enemy: Variant = enemy_factory.call()
	if not enemy is Node3D or not enemy.has_method("configure"):
		_dispose(enemy)
		_fail([_fault("instantiation", "factory must return an enemy with configure()")], index, scheduled, t_end)
		return false
	var configured: Variant = enemy.configure(enemy_definition, spawn_id)
	if configured != true or enemy.get("health") == null or not enemy.health.is_alive() or enemy.get("spawn_id") != spawn_id:
		_dispose(enemy)
		_fail([_fault("configuration", "enemy did not confirm complete configuration")], index, scheduled, t_end)
		return false
	enemy.position = selected
	add_child(enemy)
	if not registry.add(enemy, spawn_id):
		_dispose(enemy)
		_fail([_fault("publication", "live registry rejected enemy membership or reused ID")], index, scheduled, t_end)
		return false
	opportunity_consumed.emit(t_end, "spawned")
	return true

func _dispose(object: Variant) -> void:
	if object is Node and is_instance_valid(object):
		object.free()

func _fault(stage: String, cause: String) -> Dictionary:
	return {"stage": stage, "source": "EnemySpawner", "field": "enemy_factory", "observed": cause, "constraint": "fully configured enemy before registry publication", "cause": cause}

func _fail(records: Array, index: int, scheduled: float, t_end: float) -> void:
	var enriched: Array = []
	for original in records:
		var record: Dictionary = original.duplicate(true)
		record.merge({"run_generation": run_generation, "opportunity_index": index, "scheduled_at": scheduled, "t_end": t_end}, true)
		enriched.append(record)
		diagnostic.emit(record)
	opportunity_failed.emit(enriched)
	opportunity_consumed.emit(t_end, "failed")
