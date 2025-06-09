class_name TraderSpaceship
extends Node2D


var offer: Array = []

var destination: Vector2
var original_pos: Vector2
var distance_from_destination: float = 0

var speed := 50
var current_speed := speed
var direction := Vector2.ZERO
var returning := false
var arrived := false
var is_offer_active := false

var trade_offer_ui: TradeOfferUI = null
var fade_tween: Tween

var textures = []

@onready var return_timer := $ReturnTimer

signal offer_timeout()
signal offer_accepted()
signal offer_declined()


## Gets a random texture, fades in.
func _ready() -> void:
	$BodySprite.texture = TextureLoader.load_random_trader_spaceship_texture()
	modulate.a = 0
	fade_in()


## Called every frame, moves toward its destination. When close enough, it stops.
## If it arrived and it's not returning back to where it came from, an
## offer is generated. If it was returning, it fades out and is freed.
func _process(delta: float) -> void:
	if current_speed > 0:
		# Check if it's close enough
		if distance_from_destination > 40:
			var movement = direction * current_speed * delta
			global_position += movement
			distance_from_destination = global_position.distance_to(destination)
		# If it's not returning and has not arrived yet, then it arrives now
		elif not returning and not arrived:
			# Arrived, generate offer etc
			arrive_to_destination()
		elif returning:
			# Arrived back to where it came from, fade out and free
			await fade_out()
			queue_free()
	
	# Check for interact input when the trade UI is visible
	if is_offer_active:
		if trade_offer_ui.visible:
			if Input.is_action_just_pressed("interact1"):
				decline_offer()
			elif Input.is_action_just_pressed("interact2"):
				accept_offer()


## Starts flying toward a destination.
func fly_to(destination: Vector2) -> void:
	self.destination = destination
	original_pos = global_position
	
	direction = (destination - global_position).normalized()
	distance_from_destination = global_position.distance_to(destination)


## Discards the offer and flies back to the original position.
func leave() -> void:
	emit_signal("offer_timeout")
	returning = true
	is_offer_active = false
	return_timer.stop()
	fly_to(original_pos)


## Arrives to its destination and generates an offer to the player. Plays a notification
## sound and displays a console message.
func arrive_to_destination() -> void:
	arrived = true
	return_timer.start()
	make_offer()
	$NotificationSoundPlayer.play()
	ConsoleMessageManager.add_info_message("A trader has arrived to your home planet!")


## Gets the player's highest unlocked player type.
func get_highest_planet_type() -> Planet.PlanetType:
	var highest_planet_type: Planet.PlanetType
	if UpgradeManager.upgrades[3].is_unlocked:
		highest_planet_type = Planet.PlanetType.HOT
	elif UpgradeManager.upgrades[2].is_unlocked:
		highest_planet_type = Planet.PlanetType.COLD
	else:
		highest_planet_type = Planet.PlanetType.LIFE
	return highest_planet_type


## Generates a resource pool based on the player's highest planet type unlocked.
func get_resource_pool() -> Array:
	var highest_planet_type: Planet.PlanetType = get_highest_planet_type()
	var resource_pool: Array = []
	resource_pool.append_array(ResourceManager.get_planet_resources())
	
	if highest_planet_type >= Planet.PlanetType.COLD:
		resource_pool.append_array(ResourceManager.get_cold_planet_resources())
	
	if highest_planet_type >= Planet.PlanetType.HOT:
		resource_pool.append_array(ResourceManager.get_hot_planet_resources())
	
	return resource_pool


## Generates an offer for the player. It asks for a resource and the player
## gets another resource in return. Loads the UI element for the trade offer.
func make_offer() -> void:
	var resource_pool: Array = get_resource_pool()
	
	var player_resource_name = resource_pool.pick_random()
	resource_pool.erase(player_resource_name)
	var trader_resource_name = resource_pool.pick_random()
	
	var player_resource_amount = randi_range(30, 50)
	var trader_resource_amount = randi_range(30, 50)
	
	var player_resource: ResourceCurrency = ResourceCurrency.new(player_resource_name, player_resource_amount)
	var trader_resource: ResourceCurrency = ResourceCurrency.new(trader_resource_name, trader_resource_amount)
	
	offer.append(player_resource)
	offer.append(trader_resource)
		
	load_offer_ui()
	
	is_offer_active = true


## Loads the trade offer UI element, which is placed in the game world.
func load_offer_ui() -> void:
	trade_offer_ui = load("res://scenes/ui/events/TradeOffer.tscn").instantiate()
	trade_offer_ui.connect_offer_signals(self)
	trade_offer_ui.load_offer(offer[0], offer[1])
	
	$"/root/Game/Level".add_child(trade_offer_ui)
	trade_offer_ui.global_position = global_position + Vector2(16, -64)


## Accepts the trade offer. Transfers the resources, emits particles and returns back
## to the original position.
func accept_offer() -> void:
	if GameManager.has_enough_resource(offer[0].name, offer[0].amount):
		is_offer_active = false
		transfer_resources()
		emit_success_particles()
		
		emit_signal("offer_accepted")
		leave()


## Emits particles of the resource which the player has received from the trade.
func emit_success_particles() -> void:
	var success_particles: CPUParticles2D = get_node("SuccessParticles")
	success_particles.texture = ResourceTextureLoader.get_resource_texture(offer[1].name)
	success_particles.amount = offer[1].amount
	remove_child(success_particles)
	$"/root/Game/Level".add_child(success_particles)
	success_particles.global_position = global_position
	success_particles.emitting = true


## Transfers the resources in the offer.
func transfer_resources() -> void:
	GameManager.spend_resource(offer[0].name, offer[0].amount)
	GameManager.add_resource(offer[1].name, offer[1].amount)


## Declines the trade offer. Returns back.
func decline_offer() -> void:
	is_offer_active = false
	emit_signal("offer_declined")
	leave()


## Shows the trade offer UI and highlight on mouse enter.
func _on_area_2d_mouse_entered() -> void:
	if is_offer_active:
		trade_offer_ui.show()
		$HighlightSprite.show()


## Hides the trade offer UI and highlight on mouse enter.
func _on_area_2d_mouse_exited() -> void:
	if is_offer_active:
		trade_offer_ui.hide()
	$HighlightSprite.hide()


## Fades out using a tween.
func fade_out() -> void:
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 0, 0.5)
	await fade_tween.finished


## Fades in using a tween.
func fade_in() -> void:
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 1, 0.5)
