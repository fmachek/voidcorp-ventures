extends MarginContainer
class_name PlanetIndicatorPanel


var system: PlanetarySystem = null

@onready var hbox = $HBoxContainer


func _ready() -> void:
	var camera: MainCamera = $"/root/Game/MainCamera"
	_on_zoom_changed(camera.zoom.x)
	camera.connect("zoom_changed", _on_zoom_changed)


func load_system(system: PlanetarySystem) -> void:
	if self.system != null:
		return
	
	self.system = system
	var planets_node: Node2D = system.get_node("Planets")
	var planets = planets_node.get_children()
	for planet: Planet in planets:
		load_planet_indicator(planet)


func load_planet_indicator(planet: Planet) -> void:
	var indicator = PlanetIndicator.new(planet)
	hbox.add_child(indicator)


func _on_zoom_changed(new_zoom: float) -> void:
	if new_zoom < 0.5:
		show()
	else:
		hide()
