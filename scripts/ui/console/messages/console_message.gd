extends Label
class_name ConsoleMessage


## Sets the label text.
func _init(message: String) -> void:
	text = message


## Sets the font size to 4 and makes the text autowrap.
func _ready() -> void:
	add_theme_font_size_override("font_size", 4)
	autowrap_mode = TextServer.AUTOWRAP_WORD
