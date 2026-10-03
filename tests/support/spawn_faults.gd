extends RefCounted
## Narrow injected selection/factory callables; all opportunity handling is real.
var selection_calls: int = 0
var factory_calls: int = 0
var partial: Node
var mode: String = "selection"

func choose_spawn(_position, _radius, _distance, _rng) -> Dictionary:
	selection_calls += 1
	if mode != "selection":
		return {"success": true, "position": Vector3(10, 0, 10), "diagnostics": []}
	var records: Array = []
	for field in ["contact_distance", "enemy_radius"]:
		records.append({"stage": "selection", "source": "fixture/arena", "field": field,
			"observed": {"bounds": Vector2(20, 20), "player_position": _position, "enemy_radius": _radius, "contact_distance": _distance},
			"constraint": "strictly outside contact distance", "cause": "injected exhausted selection"})
	return {"success": false, "diagnostics": records}

func create_enemy():
	factory_calls += 1
	if mode == "instantiate":
		return null
	# Deliberately lacks configure(); production must dispose before publication.
	partial = Node3D.new()
	return partial
