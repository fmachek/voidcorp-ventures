extends Node2D
class_name Star


@onready var sprite: Sprite2D = $Sprite2D
@onready var highlight: Sprite2D = $Highlight


func _ready() -> void:
	choose_random_texture()
	$"/root/Game/MainCamera".connect("zoom_changed", _on_camera_zoom_changed)


## Chooses a texture from the pool of star textures.
func choose_random_texture():
	var texture: Texture2D = TextureLoader.load_random_star_texture()
	if texture:
		sprite.texture = texture


func _on_camera_zoom_changed(new_zoom: float) -> void:
	if new_zoom > 0.5:
		highlight.hide()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var camera = $"/root/Game/MainCamera"
			if camera.zoom.x < 0.5:
				camera.target = null
				camera.zoom_in()
				camera.global_position = global_position
