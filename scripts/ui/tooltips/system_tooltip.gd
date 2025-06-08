extends Control
class_name SystemTooltip


@onready var planet_info_container_scene = preload("res://scenes/ui/tooltips/PlanetInfoContainer.tscn")
@onready var planets_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/VBoxContainer

var current_system: PlanetarySystem = null


func _ready() -> void:
	$"/root/Game/MainCamera".connect("zoom_changed", _on_camera_zoom_changed)
	GameManager.connect("game_won", hide)
	GameManager.connect("game_lost", hide)
	hide()


## Loads a new info container for a planet.
func load_planet_info(planet: Planet) -> void:
	var planet_info_container: PlanetInfoContainer = planet_info_container_scene.instantiate()
	planet_info_container.load_planet(planet)
	planets_container.add_child(planet_info_container)


## Loads info about all planets in a planetary system.
func load_all_planets(system: PlanetarySystem) -> void:
	var planet_node = system.get_node("Planets")
	var planets = planet_node.get_children()
	if planets:
		for planet in planets:
			load_planet_info(planet)


## Loads info about a planetary system.
func load_system(system: PlanetarySystem) -> void:
	var loaded_planet_info = planets_container.get_children()
	if loaded_planet_info: # Clear everything loaded
		for planet_info in loaded_planet_info:
			planet_info.queue_free()
	load_all_planets(system)
	current_system = system


## Handles camera zoom changes (disappears when the camera zooms in).
func _on_camera_zoom_changed(new_zoom: float) -> void:
	if new_zoom > 0.5:
		hide()
