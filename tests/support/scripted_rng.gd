extends RefCounted
## Deterministic sampling input, not a reimplementation of arena selection.
var fractions: Array[float] = []
var calls: int = 0

func randf_range(from: float, to: float) -> float:
	var fraction: float = fractions[calls % fractions.size()] if not fractions.is_empty() else 0.5
	calls += 1
	return lerpf(from, to, fraction)
