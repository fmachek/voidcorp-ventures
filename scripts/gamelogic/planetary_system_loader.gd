extends Node
class_name PlanetarySystemLoader


var system_scene = preload("res://scenes/gameobjects/systems/DiscoverablePlanetarySystem.tscn")

## Game level.
var level: Level


## Loads the 11x11 grid of planetary systems.
func initial_load() -> void:
	level = $"/root/Game/Level"
	for i in range(11):
		for j in range(11):
			var system: PlanetarySystem
			
			var area_pos = Vector2(i * 1500, j * 1500)
			var system_offset_x = randi_range(0, 500)
			var system_offset_y = randi_range(0, 500)
			var system_pos = area_pos + Vector2(system_offset_x, system_offset_y)
			
			# Load the home system in the middle
			if i == 5 and j == 5:
				system = load_home_system()
			else:
				system = load_system()
			
			level.get_node("PlanetarySystems").add_child(system)
			system.global_position = system_pos
			if system is HomePlanetarySystem:
				system.load_system() # Load the home system
				# Move the camera to the home planet
				$"/root/Game/MainCamera".global_position = system.get_node("Planets").get_node("Home Planet").global_position


## Loads a new system.
func load_system() -> PlanetarySystem:
	var system: PlanetarySystem = system_scene.instantiate()
	return system


## Loads the home system.
func load_home_system() -> HomePlanetarySystem:
	var scene = load("res://scenes/gameobjects/systems/HomePlanetarySystem.tscn")
	var system: HomePlanetarySystem = scene.instantiate()
	return system
