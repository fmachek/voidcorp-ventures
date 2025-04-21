extends CheckBox
class_name ShowResourceGainsCheckbox


func _ready() -> void:
	button_pressed = SettingsManager.show_resource_gains


func _on_pressed() -> void:
	SettingsManager.set_show_resource_gains(button_pressed)
