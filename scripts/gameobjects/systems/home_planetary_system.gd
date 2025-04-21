extends PlanetarySystem
class_name HomePlanetarySystem


func _ready() -> void:
	super()
	
	# Connect camera zoom in and zoom out.
	connect("zoomed_in", _on_zoomed_in)
	connect("zoomed_out", _on_zoomed_out)


## Loads the system. In the home system, a star and planets are always loaded, unlike
## the discoverable systems.
func load_system() -> void:
	load_star()
	load_planets()
	var planet_indicator_panel: PlanetIndicatorPanel = $Panel/PlanetIndicatorPanel
	planet_indicator_panel.load_system(self)
	
	var spaceship_repair_spawner: SpaceshipRepairSpawner = $SpaceshipRepairSpawner
	spaceship_repair_spawner.start_spawning()
	
	is_generated = true


## Overloaded load_planets() PlanetarySystem function.
## In the home system, the planet types are more strictly controlled
## than in discoverable systems.
func load_planets() -> void:
	planet_amount = 5
	
	var planet_scene = load("res://scenes/gameobjects/systems/objects/Planet.tscn")
	
	for i in range(planet_amount):
		var offset = (i + 1) * 75
		var planet: Planet = load_planet(planet_scene, offset)
		
		if i == 2:
			planet.owned = true
			planet.set_to_home_planet()
		
		# Custom set types in the home system
		if i == 0:
			planet.planet_type = Planet.PlanetType.HOT
		elif i == 1 or i == 3:
			planet.planet_type = Planet.PlanetType.NORMAL
		elif i == 4:
			planet.planet_type = Planet.PlanetType.COLD
		elif i == 2:
			planet.planet_type = Planet.PlanetType.LIFE
		
		planet.choose_resources()
		planet.choose_texture()


## Nothing happens on left click.
func handle_left_click() -> void:
	pass


## Nothing happens on mouse enter.
func handle_mouse_enter() -> void:
	pass


## Nothing happens on mouse exit.
func handle_mouse_exit() -> void:
	pass


## Handles camera zoom in.
func _on_zoomed_in() -> void:
	zoom_in()


## Handles camera zoom out.
func _on_zoomed_out() -> void:
	zoom_out()
