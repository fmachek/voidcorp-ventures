extends Control
class_name SettingsMenu


@onready var main_menu = $"/root/Game/UILayer/MainMenu"


func _ready() -> void:
	GamePauseManager.connect("game_resumed", _handle_game_resumed)


func _handle_game_resumed():
	if visible:
		hide()


func _on_menu_button_pressed() -> void:
	self.hide()
	main_menu.show()
	$"/root/Game/ButtonClickPlayer".play()
