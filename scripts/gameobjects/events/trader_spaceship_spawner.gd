class_name TraderSpaceshipSpawner
extends Node2D


## Starts spawning when it enters the scene tree.
func _ready() -> void:
	start_spawning()


## Starts spawning trader spaceships.
func start_spawning() -> void:
	$SpawnTimer.start()


## Spawns a trader spaceship at one of the home system corners. The spaceship flies
## toward the home planet.
func spawn_trader_spaceship() -> void:
	var home_system = $".."
	
	var pos_pool = [0, 1000]
	var pos: Vector2 = Vector2(pos_pool.pick_random(), pos_pool.pick_random())
	var spaceship_spawn_pos = home_system.global_position + pos
	
	var trader_spaceship: TraderSpaceship = load("res://scenes/gameobjects/events/TraderSpaceship.tscn").instantiate()
	GameManager.level.add_child(trader_spaceship)
	
	trader_spaceship.global_position = spaceship_spawn_pos
	trader_spaceship.fly_to(home_system.get_node("Planets").get_node("Home Planet").global_position)
