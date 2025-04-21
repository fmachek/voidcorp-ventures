extends TextureButton
class_name MainMenuButton


@export var label_text: String


func _ready() -> void:
	var label = $Label
	label.text = label_text
