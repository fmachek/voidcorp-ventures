extends Button
class_name HomeButton


func _on_pressed() -> void:
	var camera: MainCamera = $"/root/Game/MainCamera"
	var home_planet: Planet = $"/root/Game/Level/PlanetarySystems/HomePlanetarySystem/Planets/Home Planet"
	camera.target = null
	camera.zoom_in()
	camera.global_position = home_planet.global_position
