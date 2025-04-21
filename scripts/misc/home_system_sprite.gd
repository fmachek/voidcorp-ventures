extends Sprite2D
class_name HomeSystemSprite


func _ready() -> void:
	var camera: MainCamera = $"/root/Game/MainCamera"
	_on_zoom_changed(camera.zoom.x)
	camera.connect("zoom_changed", _on_zoom_changed)


func _on_zoom_changed(new_zoom: float) -> void:
	if new_zoom < 0.5:
		show()
	else:
		hide()
