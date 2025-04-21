extends Control
class_name HUD


func _ready() -> void:
	GameManager.connect("game_won", hide)
	GameManager.connect("game_lost", hide)
