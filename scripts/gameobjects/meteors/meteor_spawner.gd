extends Node2D
class_name MeteorSpawner


@onready var meteor_scene = preload("res://scenes/gameobjects/meteors/Meteor.tscn")

@onready var system: PlanetarySystem = $"../.."
@onready var time_manager: TimeManager = $"/root/Game/TimeManager"


## Starts spawning meteors if the planetary system is loaded. Otherwise, it will
## start spawning them when the system is discovered.
func _ready() -> void:
	if system is HomePlanetarySystem:
		start_spawning()
	elif system.is_generated:
		start_spawning()
	else:
		system.connect("discovered", _handle_discovery)


## Handles the discovery of the system.
func _handle_discovery():
	var star = system.get_node("Star")
	if star == null:
		star = system.get_node("BlackHole")
	system.disconnect("discovered", _handle_discovery)
	start_spawning()


## Spawns a meteor which flies toward the center, with a random offset angle.
func spawn_meteor() -> void:
	var system_center = system.center
	
	var pos = self.global_position
	var system_center_pos = system_center.global_position
	
	var variance: int = 30
	
	var direction = (system_center_pos - pos).normalized()
	var angle = direction.angle() + deg_to_rad(randf_range(-variance, variance))
	var new_direction = Vector2(cos(angle), sin(angle)).normalized() # From ChatGPT
	
	var meteor: Meteor = meteor_scene.instantiate()
	meteor.direction = new_direction
	meteor.global_position = pos
	$"/root/Game/Level".add_child(meteor)


## Starts spawning meteors every in-game month that passes.
func start_spawning() -> void:
	time_manager.connect("month_changed", _handle_month_changed)


## Every in-game month that passes, there is a chance that
## a meteor will spawn.
func _handle_month_changed(new_month: int):
	var chance: int = randi_range(0, 5)
	if chance == 0:
		spawn_meteor()
