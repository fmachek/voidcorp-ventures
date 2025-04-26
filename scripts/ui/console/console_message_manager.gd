extends Node


## Adds an info message to the console.
func add_info_message(message: String) -> void:
	var console: Console = $"/root/Game/UILayer/GameUI/Console"
	console.add_info(message)


## Adds a warning message to the console.
func add_warning_message(message: String, callable: Callable) -> void:
	var console: Console = $"/root/Game/UILayer/GameUI/Console"
	console.add_warning(message, callable)
