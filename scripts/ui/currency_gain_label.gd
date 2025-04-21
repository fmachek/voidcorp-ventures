extends Label
class_name CurrencyGainLabel

var tween: Tween

func _ready() -> void:
	var camera: MainCamera = $"/root/Game/MainCamera"
	camera.connect('zoom_changed', _handle_zoom_change)
	_handle_zoom_change(camera.zoom.x)


func play_animation(text: String) -> void:
	self.text = text
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(0, -15), 1)
	await tween.finished
	var tween2 = get_tree().create_tween()
	tween2.tween_property(self, "modulate:a", 0.0, 1)
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(0, -15), 1)
	await tween.finished
	queue_free()


func _handle_zoom_change(new_zoom: float) -> void:
	if new_zoom < 0.5:
		visible = false
	else:
		visible = true
