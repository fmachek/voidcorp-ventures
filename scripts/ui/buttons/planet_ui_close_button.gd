extends Node
class_name CloseButton

@onready var planet_ui = $"../.."
@onready var button_click_player: AudioStreamPlayer = $/root/Game/ButtonClickPlayer


func _ready() -> void:
	self.connect("pressed", _on_pressed)


func _on_pressed() -> void:
	button_click_player.play()
	planet_ui.slide_out()
	if InputModeHandler.current_input_mode == InputModeHandler.InputMode.SENDING_SPACESHIP:
		InputModeHandler.set_input_mode(InputModeHandler.InputMode.NORMAL)
