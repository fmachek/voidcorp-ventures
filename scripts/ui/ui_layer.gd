extends CanvasLayer
class_name UILayer
## This class represents the whole game UI.


## Preloaded [PlanetTooltip] scene.
var tooltip_scene = preload("res://scenes/ui/tooltips/PlanetTooltip.tscn")

## Dictionary of planet tooltips where the key is the [Planet] and the value is the
## [PlanetTooltip].
var planet_tooltips = {}


## This function generates a new tooltip for a [Planet] ([param planet]).
## It is added to the 'planet_tooltips' dictionary.
func generate_planet_tooltip(planet: Planet) -> void:
	var tooltip_instance = tooltip_scene.instantiate()
	tooltip_instance.set_planet(planet)
	var ui_layer_control = $"../UILayer/GameUI"
	ui_layer_control.add_child(tooltip_instance)
	planet_tooltips[planet] = tooltip_instance

## Shows the tooltip of a given [Planet] ([param planet]).
func show_planet_tooltip(planet: Planet) -> void:
	if not planet in planet_tooltips:
		generate_planet_tooltip(planet)
	var tooltip = planet_tooltips.get(planet)
	tooltip.show()

## Hides the tooltip of a given [Planet] ([param planet]).
func hide_planet_tooltip(planet: Planet) -> void:
	var tooltip = planet_tooltips.get(planet)
	if tooltip:
		tooltip.hide()

## Updates the tooltip of a given [Planet] ([param planet]).
func update_planet_tooltip(planet: Planet) -> void:
	var tooltip = planet_tooltips.get(planet)
	tooltip.update()


func reset() -> void:
	for tooltip in planet_tooltips.values():
		tooltip.queue_free()
	planet_tooltips.clear()
