extends Logger
## Observe engine errors without intercepting or suppressing original output.
## Logger callbacks may arrive from engine threads; protect the small buffers.

var guard := Mutex.new()
var errors: Array[String] = []
var warnings: Array[String] = []

func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
	var record := "%s:%d %s: %s %s" % [file, line, function, code, rationale]
	guard.lock()
	if error_type == Logger.ERROR_TYPE_WARNING:
		warnings.append(record)
	else:
		errors.append(record)
	guard.unlock()

func snapshot() -> Dictionary:
	guard.lock()
	var result := {"errors": errors.duplicate(), "warnings": warnings.duplicate()}
	guard.unlock()
	return result
