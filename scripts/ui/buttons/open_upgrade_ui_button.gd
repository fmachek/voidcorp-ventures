extends Button
class_name OpenUpgradeUIButton


@onready var upgrade_ui = get_node("/root/Game/UILayer/UpgradeUI")
@onready var button_click_player: AudioStreamPlayer = get_node("/root/Game/ButtonClickPlayer")


func _on_pressed() -> void:
	button_click_player.play()
	upgrade_ui.open()
