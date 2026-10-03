extends Node
## Instance health; no timers, regeneration or shared-resource mutation.
signal health_changed(current: int, maximum: int)
signal died
signal diagnostic(record: Dictionary)

var max_health: int = 0
var current_health: int = 0

func configure(maximum: int) -> void:
	assert(maximum > 0, "Health requires a validated positive maximum")
	max_health = maximum
	current_health = maximum

func is_alive() -> bool:
	return current_health > 0

func apply_damage(amount: Variant) -> int:
	if typeof(amount) != TYPE_INT or amount <= 0:
		diagnostic.emit({"source": "Health", "field": "amount", "observed": str(amount), "constraint": "positive integer damage", "cause": "Supply a positive integer; health was unchanged."})
		return 0
	var applied: int = mini(amount, current_health)
	if applied == 0:
		return 0
	current_health -= applied
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()
	return applied
