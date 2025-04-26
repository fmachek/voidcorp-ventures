extends ConsoleMessage
class_name WarningMessage


## This function is called when the warning message is clicked on.
var click_function: Callable


## Set the label text and the click function.
func _init(message: String, click_function: Callable) -> void:
	text = message
	self.click_function = click_function


func _ready() -> void:
	super()
	# Warning messages are red
	add_theme_color_override("font_color", Color("#990000"))
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)


## Call the click function when clicked.
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if click_function.is_valid():
				click_function.call()


## Change the font color to bright red.
func _on_mouse_entered() -> void:
	add_theme_color_override("font_color", Color("#ff0000"))


## Change the font color to darker red.
func _on_mouse_exited() -> void:
	add_theme_color_override("font_color", Color("#990000"))
