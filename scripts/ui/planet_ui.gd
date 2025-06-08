extends Control
class_name PlanetUI
## This class represents the UI you see on the right when you click on a [Planet] you own.
## It displays information about the [Planet] and allows actions such as
## building mines and so on.

## This bool is true when you are not allowed to open it.
## It is false when you are allowed to.
var cooldown: bool = false

## The [Planet] currently displayed on the [PlanetUI].
var current_planet: Planet

var spaceship_units = {}

## Variable pointing to the planet name label.
@onready var planet_name_label = $ColorRect/MarginContainer/VBoxContainer/PlanetNameLabel
## Variable pointing to the [ColorRect].
@onready var color_rect = $ColorRect
## Variable pointing to the resource container.
@onready var resource_grid_container = $ColorRect/MarginContainer/VBoxContainer/ResourceGridContainer

## Variable pointing to the mine build button.
@onready var mine_build_button = $ColorRect/MarginContainer/VBoxContainer/BuildContainer/MineBuildContainer/MineBuildButton
## Variable pointing to the factory build button.
@onready var factory_build_button = $ColorRect/MarginContainer/VBoxContainer/BuildContainer/FactoryBuildContainer/FactoryBuildButton
## Variable pointing to the label showing the amount of mines on the [Planet].
@onready var mine_amount_label = $ColorRect/MarginContainer/VBoxContainer/BuildContainer/MineBuildContainer/VBoxContainer/InfoContainer/AmountLabel
## Variable pointing to the label showing the amount of factories on the [Planet].
@onready var factory_amount_label = $ColorRect/MarginContainer/VBoxContainer/BuildContainer/FactoryBuildContainer/VBoxContainer/InfoContainer/AmountLabel
@onready var spaceship_grid_container: GridContainer = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/SpaceshipGridContainer
@onready var spaceship_build_container: HBoxContainer = $ColorRect/MarginContainer/VBoxContainer/BuildContainer/SpaceshipBuildContainer

@onready var production_halted_overlay: ColorRect = $ColorRect/ProductionHaltedOverlay
@onready var loss_timer_progress_bar: ProgressBar = $ColorRect/ProductionHaltedOverlay/MarginContainer/VBoxContainer/LossTimerProgressBar

## This variable stores the original position of the [PlanetUI].
@onready var original_pos = color_rect.position
## This variable stores the new position of the [PlanetUI] at the start of the slide in tween.
@onready var new_pos = original_pos + Vector2(color_rect.size.x, 0)

@onready var camera = $"/root/Game/MainCamera"

signal planet_changed(new_planet: Planet)


func _ready() -> void:
	GameManager.connect("game_won", hide_quickly)
	GameManager.connect("game_lost", hide_quickly)
	
	camera.connect("zoom_changed", _on_camera_zoom_changed)


## Loads the [param planet] to display it.[br][br]
## The [PlanetUI] disconnects from the [Planet] signals [signal Planet.resource1_changed]
## and [signal Planet.resource2_changed] and connects to the new ones.[br][br]
## The UI slides in from the right. It is on cooldown until the tween finishes, meaning
## the UI cannot be opened until the cooldown ends.
func load_ui(planet: Planet):
	if not cooldown:
		cooldown = true
		
		if current_planet:
			current_planet.disconnect('resource1_changed', _on_resource1_changed)
			current_planet.disconnect('resource2_changed', _on_resource2_changed)
			current_planet.disconnect('spaceship_landed', _on_spaceship_landed)
			current_planet.disconnect('spaceship_left', _on_spaceship_left)
			current_planet.disconnect('production_halted', _on_production_halted)
			current_planet.disconnect('production_resumed', _on_production_resumed)
			current_planet.disconnect('downtime_passed', _on_downtime_passed)
			current_planet.disconnect('lost', _on_planet_lost)
		
		current_planet = planet
		emit_signal('planet_changed', current_planet)
		planet.connect('resource1_changed', _on_resource1_changed)
		planet.connect('resource2_changed', _on_resource2_changed)
		planet.connect('spaceship_landed', _on_spaceship_landed)
		planet.connect('spaceship_left', _on_spaceship_left)
		planet.connect('production_halted', _on_production_halted)
		planet.connect('production_resumed', _on_production_resumed)
		planet.connect('downtime_passed', _on_downtime_passed)
		planet.connect('lost', _on_planet_lost)
		
		planet_name_label.text = planet.planet_name
		resource_grid_container.load_planet(planet)
		load_buttons(planet)
		load_spaceships(planet)
		
		if planet.is_production_halted:
			production_halted_overlay.show()
		else:
			production_halted_overlay.hide()
		loss_timer_progress_bar.value = planet.downtime_seconds
		
		slide_in()
	else:
		print('Attempted to open planet UI, but it is on cooldown.')


## This function loads the buttons and labels for buildings to display
## correct information about the [param planet].
func load_buttons(planet: Planet):
	mine_build_button.planet = planet
	mine_amount_label.text = str(planet.mines)
	factory_build_button.planet = planet
	factory_amount_label.text = str(planet.factories)


## This function handles changes in the first [ResourceCurrency] in the [Planet] object.
func _on_resource1_changed(new_value: int):
	resource_grid_container.load_planet(current_planet)


## This function handles changes in the second [ResourceCurrency] in the [Planet] object.
func _on_resource2_changed(new_value: int):
	resource_grid_container.load_planet(current_planet)


## Handles spaceships landing on the planet.
func _on_spaceship_landed(spaceship: Spaceship):
	load_spaceship_unit(spaceship)


## Handles spaceship departures from the planet.
func _on_spaceship_left(spaceship: Spaceship):
	if spaceship in spaceship_units:
		var spaceship_unit = spaceship_units[spaceship]
		spaceship_unit.queue_free()
		spaceship_units.erase(spaceship)


func _handle_spaceship_unlock() -> void:
	spaceship_build_container.show()


## This function plays a 'slide in' tween. The UI is moved to the right, outside the screen,
## and it slides back in. The cooldown ends when the tween is finished.
func slide_in():
	color_rect.position = new_pos
	
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, 'position', original_pos, 0.5).set_trans(Tween.TRANS_QUINT)
	
	self.visible = true
	
	await tween.finished
	cooldown = false


## This function plays a 'slide out' tween. The UI slides to the right, outside the screen.
## The cooldown ends when the tween is finished.
func slide_out():
	if not cooldown:
		cooldown = true

		var tween = get_tree().create_tween()
		tween.tween_property(color_rect, 'position', new_pos, 0.25).set_trans(Tween.TRANS_LINEAR)
		
		await tween.finished
		self.visible = false
		cooldown = false


## Loads UI elements for all spaceships on a planet.
func load_spaceships(planet: Planet):
	# Remove the ones currently loaded
	for child in spaceship_grid_container.get_children():
		spaceship_grid_container.remove_child(child)
		child.queue_free()
	# Load new ones
	var spaceships = planet.spaceships
	for spaceship in spaceships:
		load_spaceship_unit(spaceship)


## Loads an UI element for a spaceship.
func load_spaceship_unit(spaceship: Spaceship):
	var spaceship_unit_scene = load("res://scenes/ui/spaceships/SpaceshipUnit.tscn")
	var spaceship_unit = spaceship_unit_scene.instantiate()
	spaceship_unit.load_spaceship(spaceship)
	spaceship_grid_container.add_child(spaceship_unit)
	spaceship_units[spaceship] = spaceship_unit


## Handles production on the planet halting.
func _on_production_halted() -> void:
	production_halted_overlay.show()


## Handles production on the planet resuming.
func _on_production_resumed() -> void:
	production_halted_overlay.hide()


## Handles the production halted button presses.
func _on_pay_button_pressed() -> void:
	if GameManager.spend_money(1000):
		current_planet.resume_production()


## Handles planet downtime passing.
func _on_downtime_passed(new_downtime: int) -> void:
	loss_timer_progress_bar.value = new_downtime


## Handles planet loss (disappears).
func _on_planet_lost() -> void:
	hide_quickly()


## Plays the slide out animation, but disappears instantly.
func hide_quickly() -> void:
	hide()
	slide_out()


## Handles camera zoom changes (disappears when the camera zooms out).
func _on_camera_zoom_changed(new_zoom: float) -> void:
	if new_zoom < 0.5:
		hide_quickly()
