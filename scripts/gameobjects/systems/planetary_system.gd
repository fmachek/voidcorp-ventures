extends Node2D
class_name PlanetarySystem

## The system center. Can be a star or black hole.
var center: Node2D
## The system center sprite.
var center_sprite: Sprite2D
## The center light. Could be null if the center is a black hole.
var center_light: PointLight2D
## Bool that tells if the system has been generated yet.
var is_generated: bool = false

## The amount of planets in the system.
var planet_amount: int

## Bool that tells if the camera is zoomed in or not.
var is_zoomed_in: bool

# Onready variables
@onready var planets: Node2D = $Planets
@onready var panel: Panel = $Panel

# Panel variables
var stylebox: StyleBoxFlat = null

# Signals
## Emitted when the camera zooms out.
signal zoomed_out()
## Emitted when the camera zooms in.
signal zoomed_in()


func _ready() -> void:
	connect_signals()
	load_panel_stylebox()
	var camera: MainCamera = $"/root/Game/MainCamera"
	_on_zoom_changed(camera.zoom.x)


## Redraws every frame.
func _process(delta: float) -> void:
	queue_redraw()


## Draws planet orbit trajectories.
func _draw() -> void:
	# Draw the orbit circles
	if planet_amount and is_zoomed_in:
		for i in range(planet_amount):
			draw_arc(center.position, (i + 1) * 75, 0, TAU, 128, Color("#0000004a"), 4)


## Loads the system. Must be implemented in subclasses.
func load_system() -> void:
	push_error("load_system() must be implemented in a subclass!")


## Loads the planets.
func load_planets():
	if not planet_amount:
		return
	
	var planet_scene = load("res://scenes/gameobjects/systems/objects/Planet.tscn")
	
	for i in range(planet_amount):
		var offset = (i + 1) * 75
		var planet: Planet = load_planet(planet_scene, offset)
		choose_planet_type_by_order(planet, i)
		planet.choose_resources()
		planet.choose_texture()


## Chooses a planet's type based on its index.
func choose_planet_type_by_order(planet: Planet, order: int) -> void:
	if order == 0:
		planet.planet_type = Planet.PlanetType.HOT
	elif order == 4:
		planet.planet_type = Planet.PlanetType.COLD
	else:
		planet.choose_planet_type()


## Loads a planet on its orbit, in a random position.
func load_planet(planet_scene: PackedScene, distance_from_center: int) -> Planet:
	var planet: Planet = planet_scene.instantiate()
	planets.add_child(planet)
	
	var random_degree: int = randi_range(0, 360)
	var angle_in_radians = deg_to_rad(random_degree)
	
	# From ChatGPT. Maths.
	var new_x: int = int(center.global_position.x + distance_from_center * cos(angle_in_radians))
	var new_y: int = int(center.global_position.y + distance_from_center * sin(angle_in_radians))
	
	planet.global_position = Vector2(new_x, new_y)
	
	return planet


## Loads a black hole in the system's center.
func load_black_hole() -> void:
	center = load("res://scenes/gameobjects/systems/objects/BlackHole.tscn").instantiate()
	center.position = Vector2(500, 500)
	add_child(center)
	center_sprite = center.get_node("Sprite2D")
	center_light = null


## Loads a star in the system's center.
func load_star():
	center = load("res://scenes/gameobjects/systems/objects/Star.tscn").instantiate()
	center.position = Vector2(500, 500)
	add_child(center)
	center_sprite = center.get_node("Sprite2D")
	center_light = center_sprite.get_node("PointLight2D")


## Connects the camera zoom signal.
func connect_signals() -> void:
	var camera: MainCamera = $"/root/Game/MainCamera"
	camera.connect("zoom_changed", _on_zoom_changed)


## Handles camera zoom changes.
func _on_zoom_changed(new_zoom: float) -> void:
	if new_zoom < 0.5:
		is_zoomed_in = false
		emit_signal("zoomed_out")
	else:
		is_zoomed_in = true
		emit_signal("zoomed_in")


## Handles Area2D input.
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			handle_left_click()


## Handles Area2D mouse enter.
func _on_area_2d_mouse_entered() -> void:
	handle_mouse_enter()


## Handles Area2D mouse exit.
func _on_area_2d_mouse_exited() -> void:
	handle_mouse_exit()


## This function must be implemented by nodes inheriting from PlanetarySystem.
func handle_left_click() -> void:
	push_error("handle_left_click() must be implemented in a subclass!")


## This function must be implemented by nodes inheriting from PlanetarySystem.
func handle_mouse_enter() -> void:
	push_error("handle_mouse_enter() must be implemented in a subclass!")


## This function must be implemented by nodes inheriting from PlanetarySystem.
func handle_mouse_exit() -> void:
	push_error("handle_mouse_exit() must be implemented in a subclass!")


## Loads the panel stylebox.
func load_panel_stylebox() -> void:
	stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color.TRANSPARENT
	stylebox.set_border_width_all(2)
	stylebox.border_color = Color("#0000004a")
	panel.add_theme_stylebox_override("panel", stylebox)


## Handles zoom in for clarity.
func zoom_in():
	var planet_nodes = planets.get_children()
	center_sprite.scale = Vector2(2,2)
	if center_light:
		center_light.enabled = true
	for planet in planet_nodes:
		planet.visible = true


## Handles zoom out for clarity.
func zoom_out():
	var planet_nodes = planets.get_children()
	center_sprite.scale = Vector2(8,8)
	if center_light:
		center_light.enabled = false
	for planet in planet_nodes:
		planet.visible = false
