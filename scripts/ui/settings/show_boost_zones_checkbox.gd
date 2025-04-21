extends CheckBox
class_name ShowBoostZonesCheckbox


func _ready() -> void:
	button_pressed = SettingsManager.show_boost_zones


func _on_pressed() -> void:
	SettingsManager.set_show_boost_zones(button_pressed)
