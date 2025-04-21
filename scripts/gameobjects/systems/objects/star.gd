extends Node2D
class_name Star


@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	choose_random_texture()


## Chooses a texture from the pool of star textures.
func choose_random_texture():
	var texture: Texture2D = TextureLoader.load_random_star_texture()
	if texture:
		sprite.texture = texture
