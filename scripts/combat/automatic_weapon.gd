extends Node
const Arena = preload("res://scripts/arena/arena.gd")
signal attacked(spawn_id: int, amount: int)
signal attack_feedback(t_end: float, attacker_position: Vector3, target: Node3D)
var range_squared: float
var damage: int
var attack_interval: float
var next_attack_at: float = 0.0

func configure(definition: WeaponDefinition) -> void:
	range_squared = definition.range * definition.range
	damage = definition.damage
	attack_interval = definition.attack_interval
	next_attack_at = 0.0

func step(t_end: float, player_position: Vector3, living_enemies: Array) -> void:
	if t_end < next_attack_at:
		return
	var target: Node3D = null
	var nearest := INF
	for enemy in living_enemies:
		if not is_instance_valid(enemy) or not enemy.health.is_alive() or enemy.is_queued_for_deletion():
			continue
		var squared := Arena.distance_squared_xz(player_position, enemy.position)
		if squared <= range_squared and (squared < nearest or (squared == nearest and (target == null or enemy.spawn_id < target.spawn_id))):
			target = enemy
			nearest = squared
	if target == null:
		return
	var applied: int = target.health.apply_damage(damage)
	if applied > 0:
		next_attack_at = t_end + attack_interval
		attacked.emit(target.spawn_id, applied)
		attack_feedback.emit(t_end, player_position, target)
