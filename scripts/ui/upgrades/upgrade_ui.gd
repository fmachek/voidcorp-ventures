extends Control
class_name UpgradeUI
## This class represents the UI where the player can unlock different [Upgrade]s.

@onready var close_button: Button = $UpgradeUICloseButton
@onready var button_click_player: AudioStreamPlayer = $/root/Game/ButtonClickPlayer
@onready var scroll_container: ScrollContainer = $TextureRect/MarginContainer/ScrollContainer

signal opened()
signal closed()

func _ready() -> void:
	close_button.connect("pressed", _on_close_button_pressed)
	GamePauseManager.connect("game_paused", close_if_opened)
	GameManager.connect("game_won", hide)
	GameManager.connect("game_lost", hide)

## This function handles the close button click signal.
## The UI is closed.
func _on_close_button_pressed() -> void:
	close()
	button_click_player.play()

func open() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	visible = true
	emit_signal("opened")

func close_if_opened() -> void:
	if visible:
		close()

func close() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	visible = false
	emit_signal("closed")

func enable_scroll() -> void:
	scroll_container.mouse_filter = Control.MOUSE_FILTER_STOP

func disable_scroll() -> void:
	scroll_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
