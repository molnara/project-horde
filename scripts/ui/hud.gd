extends CanvasLayer
## Value presentation and intents only; the coordinator owns the restart guard.
signal restart_requested
var presented_state: String = "ConfigurationError"

func _ready() -> void:
	move_child($GameOver, 0)
	move_child($Paused, 0)
	$GameOver/Panel/Restart.pressed.connect(_request_restart)

func _input(event: InputEvent) -> void:
	if presented_state == "GameOver" and event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
		get_viewport().set_input_as_handled()
		_request_restart()

func _request_restart() -> void:
	if presented_state == "GameOver" and not $GameOver/Panel/Restart.disabled:
		set_restart_enabled(false)
		restart_requested.emit()

func set_restart_enabled(enabled: bool) -> void:
	$GameOver/Panel/Restart.disabled = not enabled
func present_health(current: int, maximum: int) -> void:
	$Health.text = "Health: %d / %d" % [current, maximum]

func present_time(active_time: float) -> void:
	var seconds := int(floor(active_time))
	$Time.text = "%02d:%02d" % [seconds / 60, seconds % 60]
	$GameOver/Panel/FinalTime.text = "Survival time: " + $Time.text

func present_state(state: String) -> void:
	var entering := state == "GameOver" and presented_state != "GameOver"
	presented_state = state
	$Status.text = ""
	$GameOver.visible = state == "GameOver"
	$Paused.visible = state == "Paused"
	if entering:
		set_restart_enabled(true)
		$GameOver/Panel/Restart.grab_focus()

func present_configuration_error(records: Array[String]) -> void:
	present_state("ConfigurationError")
	$ConfigurationError.text = "Configuration failure\nCorrect the definition and relaunch Project Horde.\n" + "\n".join(records)
	$ConfigurationError.show()
