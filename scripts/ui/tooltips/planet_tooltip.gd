extends Control
class_name PlanetTooltip
## This class represents the tooltip that shows up when you hover over a [Planet].

## The [Planet] object this tooltip belongs to.
var planet: Planet
## Variable pointing to the name label.
@onready var planet_name_label = $ColorRect/GridContainer/PlanetInfoMarginContainer/PlanetInfoGridContainer/PlanetNameLabel
## Variable pointing to the owned label.
@onready var owned_label = $ColorRect/GridContainer/PlanetInfoMarginContainer/PlanetInfoGridContainer/OwnedLabel
@onready var type_label = $ColorRect/GridContainer/PlanetInfoMarginContainer/PlanetInfoGridContainer/TypeLabel
## Variable pointing to the resource container.
@onready var resource_grid_container = $ColorRect/GridContainer/MarginContainer/ResourceGridContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()

## Sets the [Planet] the tooltip belongs to. It also connects it to the planet's signals
## ([signal Planet.resource1_changed] and [signal Planet.resource2_changed]).
func set_planet(planet: Planet):
	self.planet = planet
	planet.connect('resource1_changed', _on_resource1_changed)
	planet.connect('resource2_changed', _on_resource2_changed)
	planet.connect('claimed', _on_claimed)
	planet.connect('lost', _on_lost)

## This function handles changes in the first resource.
func _on_resource1_changed(new_value: int):
	update_resources()
	
## This function handles changes in the second resource.
func _on_resource2_changed(new_value: int):
	update_resources()

## Moves the tooltip to the mouse position every frame, but only if it's currently visible.
func _process(delta: float) -> void:
	if planet != null and visible:
		var rect_width = $ColorRect.size.x
		var mouse_pos = get_global_mouse_position()
		
		var new_pos = mouse_pos
		
		var game_ui = $"/root/Game/UILayer/GameUI"
		var planet_ui = game_ui.get_node("PlanetUI")
		
		var limit_x
		if planet_ui.visible:
			limit_x = planet_ui.global_position.x
		else:
			limit_x = game_ui.global_position.x + game_ui.size.x
		
		if mouse_pos.x > limit_x:
			var x_difference = mouse_pos.x - limit_x
			new_pos.x -= x_difference
		
		if new_pos.x + rect_width > limit_x:
			new_pos.x -= rect_width
		
		var limit_y = planet_ui.global_position.y
		if mouse_pos.y - $ColorRect.size.y > limit_y:
			new_pos.y -= $ColorRect.size.y
		
		global_position = new_pos

## This function updates the tooltip contents such as the planet name label and
## owned label.
func update():
	var planet_name = planet.planet_name
	var owned = planet.owned
	planet_name_label.text = str(planet_name)
	type_label.text = "Type: " + str(planet.PlanetType.keys()[planet.planet_type]).to_lower().capitalize()
	if owned:
		owned_label.text = 'Owned'
	else:
		owned_label.text = 'Not Owned'
		
	update_resources()

func update_resources():
	resource_grid_container.load_planet(planet)

func _on_claimed():
	owned_label.text = 'Owned'

func _on_lost():
	owned_label.text = 'Not Owned'
