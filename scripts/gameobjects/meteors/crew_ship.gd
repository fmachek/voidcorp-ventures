extends Node2D
class_name CrewShip

## Movement speed.
var speed: int = 45
## Current movement speed.
var current_speed: int = 0

## Direction the crew ship is flying in.
var direction: Vector2 = Vector2.ZERO

## The planet the ship originated from.
var source_planet: Planet = null
## The meteor on which the ship is mining.
var meteor: Meteor = null
## The resource extracted.
var resource: ResourceCurrency = null 
## Tells if the crew ship is flying back to the source planet.
var is_flying_back: bool = false

## Tween used for animating when the crew ship lands on the source planet.
var scale_tween: Tween = null

@onready var mine_timer: Timer = $MineTimer # Used to time resource mining
@onready var detonation_timer: Timer = $DetonationTimer # Used to time the flight back home when detonating
@onready var flame_sprite: AnimatedSprite2D = $FlameSprite # Animated flame

## Tells if the bonus resource upgrade is unlocked.
var mine_bonus_resources: bool = false
## Tells if the Detonation upgrade is unlocked.
var can_detonate: bool = false

## Meteor the crew ship is following.
var followed_meteor: Meteor = null


func _ready() -> void:
	var camera: MainCamera = $"/root/Game/MainCamera"
	camera.connect('zoom_changed', _handle_zoom_change)
	_handle_zoom_change(camera.zoom.x)
	check_upgrades()


## Every frame, the crew ship moves in the assigned direction.
## If the Better Captain upgrade is unlocked, the ship follows the meteor it
## started focusing on.
func _process(delta: float) -> void:
	# If there is a meteor being followed, adjust the direction
	if followed_meteor != null:
		direction = (followed_meteor.global_position - global_position).normalized()
		turn_to_direction(direction)
	
	if not meteor: # Move in direction
		global_position += direction * current_speed * delta
	else: # Stick to the meteor, with a small Y offset
		global_position = meteor.global_position + Vector2(0, -5)
	
	# Pause the scale tween when the process mode is disabled
	if process_mode == Node.PROCESS_MODE_DISABLED:
		if scale_tween:
			scale_tween.set_speed_scale(0)
	else:
		if scale_tween:
			scale_tween.set_speed_scale(1)


## Change the destination the crew ship is flying towards.
func fly_to(source: Planet, destination: Vector2) -> void:
	source_planet = source
	global_position = source_planet.global_position
	direction = (destination - global_position).normalized() # Calculate the direction
	current_speed = speed # Move at the normal speed
	turn_to_direction(direction) # Turn to the direction you are flying in
	
	# Show and play the flame animation
	flame_sprite.show()
	flame_sprite.play()
	
	scale = Vector2(0, 0)
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1, 1), 1)


## Makes the crew ship land on a given meteor.
## If it's a meteor with Warpite, it is mined.
## If the Detonation upgrade is unlocked, the meteor detonator
## is placed and the meteor explodes.
func land_on_meteor(meteor: Meteor) -> void:
	if followed_meteor:
		followed_meteor = null
	
	current_speed = 0 # Stop moving
	direction = Vector2.ZERO
	global_position = meteor.global_position
	self.meteor = meteor
	meteor.is_being_mined = true
	
	# Connect the meteor signals for when the meteor is destroyed or freed
	meteor.connect("destroyed", _on_meteor_destroyed)
	meteor.connect("tree_exited", _on_meteor_destroyed)
	
	# Get the meteor rare resource
	var meteor_resource: ResourceCurrency = meteor.rare_resource
	if not meteor_resource and not can_detonate:
		return
	
	if meteor_resource:
		# Set the current resource being carried to 0 and start the mine timer
		resource = ResourceCurrency.new(meteor_resource.name, 0)
		mine_timer.start()
	elif can_detonate:
		# Don't mine, just make the meteor explode
		detonation_timer.start()
	
	flame_sprite.hide()
	flame_sprite.stop()
	
	turn_to_direction(Vector2(0, -1)) # Make the crew ship face upwards


## The crew ship lands on a planet and deposits the mined resources.
## The ship is then freed.
func land_on_planet(planet: Planet) -> void:
	current_speed = 15 # Slows down
	scale_tween = get_tree().create_tween() # Creates the scale tween
	
	scale_tween.tween_property(self, "scale", Vector2(0, 0), 1) # Shrink the ship to nothing
	await scale_tween.finished # Wait for the tween to finish
	
	if resource:
		# Finally add the mined resource to the planet's inventory
		if not planet.is_home_planet:
			planet.inventory.add_resource(resource)
		else:
			GameManager.add_resource(resource.name, resource.amount)
			var text = "+ " + str(resource.amount) + " " + resource.name
			ResourceGainLabelSpawner.spawn_label(text, global_position + Vector2(-30, 0))
	
	queue_free() # Delete the ship


## When the meteor the ship is on currently explodes, the ship
## is freed.
func _on_meteor_destroyed() -> void:
	queue_free() # Delete the ship


## Mines meteor resources on timer timeout.
func _on_mine_timer_timeout() -> void:
	var drained_resource_amount = meteor.drain_rare_resource() # Drain some of the resource
	if drained_resource_amount == 0: # No resource was drained, fly back to planet
		mine_timer.disconnect("timeout", _on_mine_timer_timeout)
		if mine_bonus_resources:
			# If the player has the bonus resources upgrade unlocked,
			# add 1 bonus resource.
			resource.add(1)
		fly_back()
		print("Crew ship has drained 0 resource, heading back to source.")
	else: # Some resource was drained, add it to the carried resource
		resource.add(drained_resource_amount)
		print("A crew ship has collected " + str(drained_resource_amount) + " " + resource.name + " from a meteor.")


## Starts flying back to the source planet.
func fly_back() -> void:
	if is_flying_back:
		return
	
	if followed_meteor:
		followed_meteor.is_being_followed = false
	
	is_flying_back = true
	direction = (source_planet.global_position - global_position).normalized()
	current_speed = speed # Set the speed to normal
	
	if can_detonate:
		place_detonator()
	
	# Disconnect the meteor signals
	meteor.disconnect("destroyed", _on_meteor_destroyed)
	meteor.disconnect("tree_exited", _on_meteor_destroyed)
	meteor = null # Reset the meteor to null
	
	# Show and play the animated flame
	flame_sprite.show()
	flame_sprite.play()
	
	# Turn to the new direction
	turn_to_direction(direction)


## Handles Area2D detections.
func _on_area_2d_area_entered(area: Area2D) -> void:
	var object = area.get_parent() # Get the object that entered the area
	if object is Meteor:
		if meteor: # Ship is already on a meteor
			return
		if not object.rare_resource and not can_detonate: # Meteor has no resource and can't detonate
			return
		if is_flying_back: # Is already heading back to planet
			return
		if object.is_being_mined: # Meteor is already being mined
			return
		land_on_meteor(object) # If the above is false, land on the meteor
	elif object is Planet:
		# If the object is flying back and the planet that has entered the area
		# is the source planet, land on it.
		if source_planet == object and is_flying_back:
			land_on_planet(object)


## Turns to a given direction.
func turn_to_direction(direction: Vector2) -> void:
	rotation = direction.angle()


## Handles camera zoom changes. The ships are invisible if the camera is zoomed out.
func _handle_zoom_change(new_zoom: float) -> void:
	if new_zoom < 0.5:
		visible = false
	else:
		visible = true


## Increases movement speed.
func increase_speed() -> void:
	var old_speed = speed
	speed += 15
	if current_speed == old_speed:
		current_speed = speed


## Increases mining speed (timer wait time is decreased).
func increase_mining_speed() -> void:
	mine_timer.wait_time -= 0.5


## Unlocks the ability to mine bonus resources on meteors.
func unlock_bonus_resources() -> void:
	mine_bonus_resources = true


## Allows the ship to follow meteors.
func unlock_better_captain() -> void:
	var area: Area2D = $MeteorDetectionArea2D
	area.monitoring = true


## Allows the ship to place detonators on meteors.
func unlock_detonation() -> void:
	can_detonate = true


## Checks and applies upgrades.
func check_upgrades() -> void:
	# NOTE: The upgrades can only be applied to new crew ships
	
	# Speed upgrade
	var speed_upgrade: Upgrade = UpgradeManager.upgrades[6]
	if speed_upgrade.is_unlocked:
		increase_speed()
	
	# Mining speed upgrade
	var mining_speed_upgrade: Upgrade = UpgradeManager.upgrades[7]
	if mining_speed_upgrade.is_unlocked:
		increase_mining_speed()
	
	# Bonus resource upgrade
	var bonus_resources_upgrade: Upgrade = UpgradeManager.upgrades[8]
	if bonus_resources_upgrade.is_unlocked:
		unlock_bonus_resources()
	
	# Meteor follow upgrade
	var better_captain_upgrade: Upgrade = UpgradeManager.upgrades[9]
	if better_captain_upgrade.is_unlocked:
		unlock_better_captain()
	
	# Meteor detonation upgrade
	var detonation_upgrade: Upgrade = UpgradeManager.upgrades[10]
	if detonation_upgrade.is_unlocked:
		unlock_detonation()


## Handles the Better Captain upgrade Area2D detections.
## It starts following the meteor detected.
func _on_meteor_detection_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Meteor:
		if not followed_meteor and not parent.is_being_followed and not is_flying_back and not meteor:
			if parent.rare_resource:
				start_following_meteor(parent)
			else:
				if can_detonate:
					start_following_meteor(parent)


# Starts following a given meteor.
func start_following_meteor(meteor: Meteor) -> void:
	followed_meteor = meteor
	meteor.is_being_followed = true
	followed_meteor.connect("destroyed", _on_followed_meteor_destroyed)


## When the meteor being followed is destroyed,
## the ship stops following it.
func _on_followed_meteor_destroyed() -> void:
	followed_meteor = null


## When the detonator is placed, the ship flies back to the source planet.
func _on_detonation_timer_timeout() -> void:
	fly_back()


## Places a detonator on a meteor, which makes it explode after a certain
## amount of time passes.
func place_detonator() -> void:
	var detonator_scene = load("res://scenes/gameobjects/meteors/MeteorDetonator.tscn")
	var meteor_detonator: MeteorDetonator = detonator_scene.instantiate()
	meteor_detonator.set_meteor(meteor)
	meteor.add_child(meteor_detonator)
	meteor_detonator.start_countdown()
