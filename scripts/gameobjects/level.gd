extends Node2D
class_name Level


func _ready() -> void:
	var system_loader = $"/root/Game/PlanetarySystemLoader"
	system_loader.initial_load()


## Handles input.
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Send crew ship if the input mode is SENDING_CREW
			if InputModeHandler.current_input_mode == InputModeHandler.InputMode.SENDING_CREW:
				var click_position: Vector2 = get_global_mouse_position()
				InputModeHandler.send_crew_to(click_position)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Reset the input mode if the input mode is SENDING_CREW
			if InputModeHandler.current_input_mode == InputModeHandler.InputMode.SENDING_CREW:
				InputModeHandler.set_input_mode(InputModeHandler.InputMode.NORMAL)
