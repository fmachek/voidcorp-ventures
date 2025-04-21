extends Button
class_name OpenMarketButton


@onready var market_UI = get_node("/root/Game/UILayer/MarketUI")
@onready var button_click_player: AudioStreamPlayer = get_node("/root/Game/ButtonClickPlayer")


func _on_pressed() -> void:
	button_click_player.play()
	market_UI.show()
