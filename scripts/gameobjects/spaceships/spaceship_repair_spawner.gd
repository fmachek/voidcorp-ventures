extends Node2D
class_name SpaceshipRepairSpawner


## Node containing all planets in the planetary system.
@export var planets_node: Node2D
## Spawn timer.
@onready var timer: Timer = $Timer

var repair_scene = preload("res://scenes/gameobjects/spaceships/SpaceshipRepair.tscn")

## Array of all possible planet connections.
var planet_connections: Array


## Starts spawning the spaceship repairs.
func start_spawning() -> void:
	planet_connections = generate_connections()
	timer.start()


## Spawns a spaceship repair. It is spawned
## between two random planets.
func spawn_repair() -> void:
	if len(planet_connections) == 0:
		return
	
	var connection = planet_connections.pick_random()
	var planet1: Planet = connection[0]
	var planet2: Planet = connection[1]
	
	var t: float = randf()
	var repair_position: Vector2 = planet1.global_position.lerp(planet2.global_position, t)
	
	var repair: SpaceshipRepair = repair_scene.instantiate()
	repair.global_position = repair_position
	$"/root/Game/Level".add_child(repair)


## Generates all possible planet connections.
func generate_connections() -> Array:
	var planets = planets_node.get_children()
	if len(planets) <= 1:
		return []
	var connections: Array = []
	for i in range(len(planets) - 1):
		var planet: Planet = planets[i]
		for j in range(i + 1, len(planets)):
			var other_planet: Planet = planets[j]
			connections.append([planet, other_planet])
	return connections


## Spawns a repair on timer timeout.
func _on_timer_timeout() -> void:
	spawn_repair()
