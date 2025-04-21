extends Node2D
class_name Spaceship
## This class represents a spaceship unit.

@onready var flame_sprite: AnimatedSprite2D = $FlameSprite
@onready var flight_sound_player: AudioStreamPlayer2D = $FlightSoundPlayer
var scale_tween: Tween

## Spaceship durability in %. Default is 100%.
var durability: int = 100
## Durability loss stat.
var durability_loss: int = 100

## Spaceship base speed in %. Default is 100%.
var base_speed: int = 100
## Spaceship boost speed.
var boost_speed: int = 0
## Spaceship current speed.
var current_speed: int = 0

## Spaceship fuel consumption in %. Default is 100%.
var fuel_consumption: int = 100
## The direction the spaceship is flying in.
var direction: Vector2 = Vector2.ZERO
## The spaceship cargo.
var cargo: SpaceshipCargo = SpaceshipCargo.new(self)

## The maximum type of planet the spaceship can handle.
var max_planet_type: Planet.PlanetType = Planet.PlanetType.LIFE

## The planet the spaceship is currently on.
var current_planet: Planet
## Tells if the spaceship is currently flying or not.
var is_flying: bool = false
## Tells if the spaceship is currently landing or not.
var is_landing: bool = false
## The destination planet.
var current_destination_planet: Planet

## The game level.
@onready var level: Node = get_node("/root/Game/Level")

## Emitted when the durability changes.
signal durability_changed(new_durability: int)
## Emitted when the spaceship is destroyed.
signal destroyed()
## Emitted when the maximum type of planet the spaceship can handle changes.
signal max_planet_type_changed(new_type: Planet.PlanetType)

## Distance accumulated during movement, used to reduce durability.
var distance_accumulated: float = 0


func _ready() -> void:
	$"/root/Game/MainCamera".connect('zoom_changed', _handle_zoom_change)
	connect_upgrades()
	flame_sprite.play()


## Every frame, the spaceship moves in the assigned direction.
## The distance accumulates every frame until the durability loss
## threshold is hit. The durability loss stat increases this threshold.
func _process(delta):
	if current_speed > 0:
		var movement = (direction * current_speed) / 2 * delta
		global_position += movement
	
		var movement_distance = movement.length()
		distance_accumulated += movement_distance
	
		# Less durability loss => durability decreases less often
		var durability_loss_distance: float = 160 * float(100 / float(durability_loss))
		if distance_accumulated >= durability_loss_distance:
			reduce_durability(1)
			# Reset accumulated distance
			distance_accumulated = distance_accumulated - durability_loss_distance
	
	# Pause tweens if the game is paused
	if scale_tween:
		if level.process_mode == Node.PROCESS_MODE_DISABLED:
			scale_tween.set_speed_scale(0)
		else:
			scale_tween.set_speed_scale(1)
	
	# Force the indicator sprite to not rotate
	var indicator_sprite: Sprite2D = $IndicatorSprite
	indicator_sprite.global_rotation = 0.0


## The fuel cost is calculated, and if the player can afford it,
## the spaceship flies from the source planet to a destination planet.
func fly(source: Planet, destination: Planet) -> void:
	var fuel_required = calculate_fuel(source, destination)
	var fuel_price = fuel_required

	if GameManager.spend_money(fuel_price):
		# Deposit planet inventory to cargo
		current_planet.depsoit_inventory_to_spaceship(self)
		
		# Remove the spaceship from the planet
		current_planet.takeoff_spaceship(self)
		current_planet = null
		current_destination_planet = destination
		
		visible = true
		global_position = source.global_position
		var destination_pos = destination.global_position
		direction = (destination_pos - global_position).normalized()
		rotation = global_position.angle_to_point(destination_pos)

		is_flying = true
		calculate_current_speed()
		
		scale_tween = get_tree().create_tween()
		scale_tween.tween_property(self, "scale", Vector2(1, 1), 1)
	else:
		print('Player does not have enough money to purchase fuel required (cost: ' + str(fuel_price) + ', balance: ' + str(GameManager.money) + ').')


## Calculates the fuel based on the distance between the [param source] and
## [param destination] and the fuel consumption.
func calculate_fuel(source: Planet, destination: Planet) -> int:
	var distance = source.global_position.distance_to(destination.global_position)
	return ceil(distance * fuel_consumption/500)


## Lands on the destination planet. If the spaceship can't handle that type
## of planet, it explodes. If the planet is the home planet, the spaceship
## deposits its cargo.
func land_on_planet(planet: Planet):
	is_landing = true
	current_speed = 35
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(self, "scale", Vector2(0, 0), 1)
	await scale_tween.finished
	is_flying = false
	current_speed = 0
	
	if not can_land_on_planet_type(planet):
		destroy()
		return
	
	planet.land_spaceship(self)
	is_landing = false
	# Deposit cargo if on home planet
	if planet.is_home_planet:
		cargo.deposit()


## Checks if the spaceship can land on a given planet.
func can_land_on_planet_type(planet: Planet) -> bool:
	return max_planet_type >= planet.planet_type


## Reduces the durability by a given amount.
func reduce_durability(amount: int):
	if durability - amount < 0:
		durability = 0
	else:
		durability -= amount
	emit_signal('durability_changed', durability)
	
	if durability == 0:
		destroy()


## Increases the durability by a given amount.
func add_durability(amount: int):
	if durability + amount > 100:
		durability = 100
	else:
		durability += amount
	emit_signal('durability_changed', durability)


## Upgrades the durability.
func _handle_durability_upgrade() -> void:
	upgrade_durability()


## Upgrades the durability by 15%.
func upgrade_durability() -> void:
	durability_loss -= 15


## Destroys the spaceship. Spaceship scraps are spawned as a visual effect.
func destroy():
	var spaceship_scraps_scene = load("res://scenes/gameobjects/spaceships/SpaceshipScraps.tscn")
	var spaceship_scraps = spaceship_scraps_scene.instantiate()
	spaceship_scraps.position = global_position
	$"/root/Game/Level".add_child(spaceship_scraps)
	emit_signal("destroyed")
	queue_free()


## Increases movement speed.
func _handle_speed_upgrade():
	increase_speed()


## Increases movement speed by 25% and recalculates the current speed.
func increase_speed():
	base_speed += 25
	calculate_current_speed()


## Lowers fuel consumption by 15%
func lower_fuel_consumption():
	fuel_consumption -= 15


## Handles the fuel upgrade unlock.
func _handle_fuel_upgrade():
	lower_fuel_consumption()


## Handles camera zoom changes. The spaceships are invisible when the
## camera zooms out. Instead, an indicator is shown to improve clarity.
func _handle_zoom_change(new_zoom: float) -> void:
	var body_sprite: Sprite2D = $SpaceshipBody
	var flame_sprite: AnimatedSprite2D = $FlameSprite
	var indicator_sprite: Sprite2D = $IndicatorSprite
	if new_zoom < 0.5:
		body_sprite.hide()
		flame_sprite.hide()
		indicator_sprite.show()
		indicator_sprite.scale = Vector2(10, 10)
	else:
		body_sprite.show()
		flame_sprite.show()
		indicator_sprite.hide()
		indicator_sprite.scale = Vector2(0, 0)


## Handles Area2D detections. If the destination planet
## is detected, the spaceship lands on it.
func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	
	if parent is Planet:
		if parent == current_destination_planet:
			land_on_planet(parent)


## Boosts the spaceship, adding boost speed.
func add_boost_speed(speed: int) -> void:
	boost_speed += speed
	calculate_current_speed()


## Reduces the boost speed.
func reduce_boost_speed(speed: int) -> void:
	boost_speed -= speed
	calculate_current_speed()


## Calculates the current speed based on the base speed and boost speed.
func calculate_current_speed() -> void:
	if is_flying and not is_landing:
		var new_speed = base_speed + boost_speed
		current_speed = new_speed


## Connects upgrade unlock signals, and if they're already unlocked, they're applied
## right away.
func connect_upgrades() -> void:
	var speed_upgrades = [UpgradeManager.upgrades[100], UpgradeManager.upgrades[101], UpgradeManager.upgrades[102]]
	for upgrade: Upgrade in speed_upgrades:
		if upgrade.is_unlocked:
			_handle_speed_upgrade()
		elif not upgrade.is_connected("unlocked", _handle_speed_upgrade):
			upgrade.connect("unlocked", _handle_speed_upgrade)
	
	var fuel_upgrades = [UpgradeManager.upgrades[103], UpgradeManager.upgrades[104], UpgradeManager.upgrades[105]]
	for fuel_upgrade in fuel_upgrades:
		if fuel_upgrade.is_unlocked:
			lower_fuel_consumption()
		elif not fuel_upgrade.is_connected("unlocked", _handle_fuel_upgrade):
			fuel_upgrade.connect("unlocked", _handle_fuel_upgrade)
	
	var durability_upgrades = [UpgradeManager.upgrades[106], UpgradeManager.upgrades[107], UpgradeManager.upgrades[108]]
	for durability_upgrade: Upgrade in durability_upgrades:
		if durability_upgrade.is_unlocked:
			upgrade_durability()
		elif not durability_upgrade.is_connected("unlocked", _handle_durability_upgrade):
			durability_upgrade.connect("unlocked", _handle_durability_upgrade)
	
	var cargo_upgrades = [UpgradeManager.upgrades[19], UpgradeManager.upgrades[20], UpgradeManager.upgrades[21]]
	for cargo_upgrade: Upgrade in cargo_upgrades:
		if cargo_upgrade.is_unlocked:
			upgrade_cargo()
		elif not cargo_upgrade.is_connected("unlocked", upgrade_cargo):
			cargo_upgrade.connect("unlocked", upgrade_cargo)
	
	var max_type_upgrades = [UpgradeManager.upgrades[2], UpgradeManager.upgrades[3]]
	for upgrade: Upgrade in max_type_upgrades:
		if upgrade.is_unlocked:
			upgrade_max_planet_type()
		elif not upgrade.is_connected("unlocked", upgrade_max_planet_type):
			upgrade.connect("unlocked", upgrade_max_planet_type)


## Upgrades the spaceship cargo. The max hold increases by 10.
func upgrade_cargo() -> void:
	cargo.increase_max_hold(10)


## Upgrades the maximum planet type, and changes the spaceship texture based on the
## type of planet it can handle.
func upgrade_max_planet_type() -> void:
	max_planet_type += 1
	var sprite: Sprite2D = $SpaceshipBody
	if max_planet_type == 2:
		sprite.texture = load("res://assets/sprites/spaceships/spaceship2.png")
	elif max_planet_type == 3:
		sprite.texture = load("res://assets/sprites/spaceships/spaceship3.png")
	emit_signal("max_planet_type_changed", max_planet_type)
