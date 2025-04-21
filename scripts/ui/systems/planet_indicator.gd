extends TextureRect
class_name PlanetIndicator


var planet: Planet = null


func _init(planet: Planet) -> void:
	self.planet = planet
	self.scale = Vector2(10, 10)
	self.custom_minimum_size = Vector2(80, 80)
	self.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	update_texture()
	connect_planet_signals()


func update_texture() -> void:
	if not planet.owned:
		texture = load("res://assets/ui/systemindicators/free.png")
		return
	
	if planet.is_production_halted:
		texture = load("res://assets/ui/systemindicators/disrupted.png")
	else:
		texture = load("res://assets/ui/systemindicators/owned.png")


func connect_planet_signals() -> void:
	planet.connect("claimed", update_texture)
	planet.connect("lost", update_texture)
	planet.connect("production_halted", update_texture)
	planet.connect("production_resumed", update_texture)
