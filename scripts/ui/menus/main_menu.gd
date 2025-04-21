extends Control
class_name MainMenu


@onready var play_button: TextureButton = $MarginContainer/MenuContainer/ButtonContainer/PlayButton
@onready var settings_button: TextureButton = $MarginContainer/MenuContainer/ButtonContainer/SettingsButton
@onready var restart_button: TextureButton = $MarginContainer/MenuContainer/ButtonContainer/RestartButton
@onready var button_click_player: AudioStreamPlayer = $"/root/Game/ButtonClickPlayer"

@onready var settings_menu = $"/root/Game/UILayer/SettingsMenu"


func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	GamePauseManager.connect("game_paused", _handle_game_paused)
	GamePauseManager.connect("game_resumed", _handle_game_resumed)
	
	show()


func _handle_game_paused():
	open_menu()


func _handle_game_resumed():
	close_menu()


func _on_play_button_pressed() -> void:
	button_click_player.play()
	close_menu()
	GamePauseManager.resume_game()


func _on_settings_button_pressed() -> void:
	button_click_player.play()
	hide()
	settings_menu.show()


## Opens the menu and pauses the game.
func open_menu():
	show()
	if GameManager.level == null:
		restart_button.hide()
		play_button.get_node("Label").text = "Play"
	else:
		restart_button.show()
		play_button.get_node("Label").text = "Resume"


## Closes the menu and resumes the game.
func close_menu():
	self.hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_restart_button_pressed() -> void:
	GameManager.restart_game()
