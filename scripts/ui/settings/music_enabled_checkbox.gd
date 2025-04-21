extends CheckBox
class_name MusicEnabledCheckbox


func _ready() -> void:
	button_pressed = SettingsManager.music_enabled


func _on_pressed() -> void:
	SettingsManager.set_music_enabled(button_pressed)
