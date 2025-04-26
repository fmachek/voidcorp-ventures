extends Button
class_name HomeButton


func _on_pressed() -> void:
	var home_planet: Planet = $"/root/Game/Level/PlanetarySystems/HomePlanetarySystem/Planets/Home Planet"
	home_planet.focus_camera_on_planet()
