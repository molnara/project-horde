extends Node
## Explicit membership and synchronous death callbacks; no scene/group searches.
var members: Dictionary = {}
var used_ids: Dictionary = {}
var callbacks: Dictionary = {}

func add(enemy: Node3D, spawn_id: int) -> bool:
	if used_ids.has(spawn_id) or members.has(enemy) or not enemy.health.is_alive():
		return false
	used_ids[spawn_id] = true
	members[enemy] = spawn_id
	var callback := remove.bind(enemy)
	callbacks[enemy] = callback
	enemy.health.died.connect(callback)
	enemy.tree_exiting.connect(callback)
	return true

func remove(enemy: Node3D) -> void:
	if not members.has(enemy):
		return
	var callback: Callable = callbacks[enemy]
	if enemy.health.died.is_connected(callback):
		enemy.health.died.disconnect(callback)
	if enemy.tree_exiting.is_connected(callback):
		enemy.tree_exiting.disconnect(callback)
	callbacks.erase(enemy)
	members.erase(enemy)

func living_in_spawn_order() -> Array:
	var result: Array = []
	for enemy in members:
		if is_instance_valid(enemy) and enemy.health.is_alive() and not enemy.is_queued_for_deletion():
			result.append(enemy)
	result.sort_custom(func(a, b): return members[a] < members[b])
	return result

func _exit_tree() -> void:
	for enemy in members.keys():
		if is_instance_valid(enemy):
			remove(enemy)
