extends Button
class_name HomeButton


@onready var button_click_player: AudioStreamPlayer = get_node("/root/Game/ButtonClickPlayer")


func _on_pressed() -> void:
	var home_planet: Planet = $"/root/Game/Level/PlanetarySystems/HomePlanetarySystem/Planets/Home Planet"
	home_planet.focus_camera_on_planet()
	button_click_player.play()
