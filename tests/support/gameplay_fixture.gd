extends RefCounted
## Wiring only. No movement, targeting, scheduling or statistics algorithms here.
## See tests/README.md for the provisional construction/observation seam.

static func cases_for(prefix: String, methods: Array, requirements: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for method in methods:
		result.append({"id": prefix + "." + method, "method": method, "requires": requirements.duplicate()})
	return result

static func instance(ctx, path: String, properties: Dictionary = {}):
	ctx.check(ResourceLoader.exists(path), "real component exists: " + path)
	if not ResourceLoader.exists(path):
		return null
	var resource = load(path)
	var object = resource.instantiate() if resource is PackedScene else resource.new()
	for field in properties:
		object.set(field, properties[field])
	if object is Node:
		ctx.own(object)
		Engine.get_main_loop().root.add_child(object)
	return object

static func invoke(ctx, object, method: String, args: Array = []):
	ctx.check(object != null and object.has_method(method), "required real method: " + method)
	if object == null or not object.has_method(method):
		return null
	return object.callv(method, args)

static func arena(ctx, definition):
	var object = instance(ctx, "res://scenes/arena.tscn")
	invoke(ctx, object, "configure", [definition.arena])
	return object

static func player(ctx, definition):
	var object = instance(ctx, "res://scenes/player.tscn")
	invoke(ctx, object, "configure", [definition.player])
	return object

static func enemy(ctx, definition, id: int, position: Vector3):
	var object = instance(ctx, "res://scenes/enemy.tscn")
	invoke(ctx, object, "configure", [definition.enemy, id])
	object.position = position
	return object

static func health(ctx, maximum: int):
	var object = instance(ctx, "res://scripts/combat/health.gd")
	invoke(ctx, object, "configure", [maximum])
	return object

static func registry(ctx):
	return instance(ctx, "res://scripts/run/live_registry.gd")

static func weapon(ctx, definition):
	var object = instance(ctx, "res://scripts/combat/automatic_weapon.gd")
	invoke(ctx, object, "configure", [definition.weapon])
	return object

static func run(ctx, definition):
	# Main owns production wiring. Manual stepping disables only the coordinator's
	# automatic driver; components are still the actual production objects.
	var main = instance(ctx, "res://scenes/main.tscn", {"run_definition": definition})
	var coordinator = main.get("coordinator")
	ctx.check(coordinator != null, "main exposes its explicitly wired coordinator")
	if coordinator == null:
		return null
	coordinator.set_physics_process(false)
	# Definition is injected BEFORE Main's _ready, so invalid-startup fixtures
	# cannot accidentally create a valid encounter before testing rejection.
	if coordinator.get("spawner") != null:
		coordinator.spawner.rng = ctx.rng
	return coordinator

static func near(ctx, actual: Vector3, expected: Vector3, message: String) -> void:
	# Geometry tolerance only. Deadline/range checks use exact representable values.
	ctx.check(actual.is_equal_approx(expected), message + ": " + str(actual))

static func observe(ctx, object, signal_name: String) -> Array:
	var events: Array = []
	ctx.check(object.has_signal(signal_name), "required signal: " + signal_name)
	if object.has_signal(signal_name):
		var event := Signal(object, signal_name)
		var arity := 0
		for record in object.get_signal_list():
			if record.name == signal_name:
				arity = record.args.size()
		var callback: Callable
		match arity:
			0: callback = func(): events.append([])
			1: callback = func(a): events.append([a])
			2: callback = func(a, b): events.append([a, b])
			_: ctx.check(false, "fixture supports only 0–2 signal arguments"); return events
		ctx.connect_callback(event, callback)
	return events

static func snapshot(definition) -> Array:
	var result: Array = []
	for resource in [definition, definition.player, definition.enemy, definition.weapon, definition.arena]:
		var fields := {}
		for property in resource.get_property_list():
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				fields[property.name] = resource.get(property.name)
		result.append(fields)
	return result
