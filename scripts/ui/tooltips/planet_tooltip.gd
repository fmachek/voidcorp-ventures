extends Node
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
	if planet != null and self.visible:
		var mouse_pos = get_viewport().get_mouse_position()
		$ColorRect.position.x = mouse_pos.x
		$ColorRect.position.y = mouse_pos.y - $ColorRect.size.y

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
