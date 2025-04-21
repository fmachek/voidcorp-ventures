extends GridContainer
class_name ResourceGridContainer
## This class represents a GridContainer which is used to display
## information about two [ResourceCurrency] objects.

## The [ProgressBar] showing how much of the first [ResourceCurrency] there is left.
@onready var resource1_bar: ProgressBar = $ResourceBar1
## The [ProgressBar] showing how much of the second [ResourceCurrency] there is left.
@onready var resource2_bar: ProgressBar = $ResourceBar2

## The [Label] showing the name of the first [ResourceCurrency].
@onready var resource1_label: Label = $ResourceLabel1
## The [Label] showing the name of the second [ResourceCurrency].
@onready var resource2_label: Label = $ResourceLabel2

## The [Planet] whose resources are being displayed.
var planet: Planet


## Creates foreground styles for the resource bars.
func _ready() -> void:
	var fg_style1 = StyleBoxFlat.new()
	var fg_style2 = StyleBoxFlat.new()
	resource1_bar.add_theme_stylebox_override("fill", fg_style1)
	resource2_bar.add_theme_stylebox_override("fill", fg_style2)


## Sets the current [Planet] being displayed to [param planet] and
## loads information about its resources.
func load_planet(planet: Planet):
	self.planet = planet
	load_resources()


## Loads information about the resources on the [Planet] currently being displayed.
func load_resources():
	var resource1 = planet.resource1
	var resource2 = planet.resource2
	
	resource1_label.text = resource1.name
	update_resource_bar(1, resource1.amount)
	
	resource2_label.text = resource2.name
	update_resource_bar(2, resource2.amount)


## This function updates the resource bar with the given [param index].
## The bar's value is changed to [param amount].
func update_resource_bar(index: int, amount: int) -> void:
	var bar: ProgressBar
	if index == 1:
		bar = resource1_bar
	elif index == 2:
		bar = resource2_bar
	else:
		print('Attempted to change resource bar with invalid index ' + str(index) + '.')
	bar.value = amount
	update_resource_bar_fill(bar)


## This function updates the fill of a given [ProgressBar] ([param bar]).
## The background color is determined by the [ProgressBar] value.
func update_resource_bar_fill(bar: ProgressBar) -> void:
	var fg_style = bar.get_theme_stylebox('fill')
	if fg_style == null:
		print('No fill theme found.')
		return
	var value = bar.value
	if value > 85:
		fg_style.bg_color = Color(0, 0.6, 0)
		return
	elif value > 70:
		fg_style.bg_color = Color(0.4, 0.5, 0)
		return
	elif value > 55:
		fg_style.bg_color = Color(0.5, 0.55, 0)
		return
	elif value > 40:
		fg_style.bg_color = Color(0.6, 0.5, 0)
		return
	elif value > 25:
		fg_style.bg_color = Color(0.7, 0.5, 0)
		return
	else:
		fg_style.bg_color = Color(0.7, 0.25, 0)
		return
