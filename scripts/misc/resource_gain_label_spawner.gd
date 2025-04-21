extends Node


var label_scene = preload("res://scenes/ui/misc/CurrencyGainLabel.tscn")


func spawn_label(text: String, position: Vector2) -> void:
	if not SettingsManager.show_resource_gains:
		return
	var label = label_scene.instantiate()
	label.global_position = position
	$"/root/Game/Level".add_child(label)
	label.play_animation(text)
