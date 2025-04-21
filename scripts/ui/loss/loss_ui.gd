extends Control
class_name LossUI


func _on_menu_button_pressed() -> void:
	$"/root/Game/ButtonClickPlayer".play()
	GameManager.reset_game()
	queue_free()
