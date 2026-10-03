extends CanvasLayer
## Value presentation only. Pause/restart overlays are later-story tasks.
func present_health(current: int, maximum: int) -> void:
	$Health.text = "Health: %d / %d" % [current, maximum]

func present_time(active_time: float) -> void:
	var seconds := int(floor(active_time))
	$Time.text = "%02d:%02d" % [seconds / 60, seconds % 60]

func present_state(state: String) -> void:
	$Status.text = "Run ended — relaunch for a fresh attempt" if state == "GameOver" else ""

func present_configuration_error(records: Array[String]) -> void:
	$ConfigurationError.text = "Configuration failure\n" + "\n".join(records)
	$ConfigurationError.show()
