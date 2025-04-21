extends Button
class_name OpenMenuButton


@onready var button_click_player: AudioStreamPlayer = get_node("/root/Game/ButtonClickPlayer")


func _on_pressed() -> void:
	button_click_player.play()
	GamePauseManager.pause_game()
