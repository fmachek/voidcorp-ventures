extends Timer
class_name TimeManager

## Represents the current month in the timeline.
var current_month: int = 1

## A signal that is emitted when the month changes.
signal month_changed(new_month: int)


## Sets the wait time to 10 seconds.
func _ready() -> void:
	wait_time = 10
	reset()


## Starts measuring time in months.
func start_measuring() -> void:
	if not is_connected("timeout", _on_timeout):
		connect("timeout", _on_timeout)
	start()


## Increases the current month by 1 on timer timeout.
func _on_timeout() -> void:
	current_month += 1
	emit_signal("month_changed", current_month)


## Resets itself.
func reset() -> void:
	current_month = 1
	stop()
	start_measuring()
