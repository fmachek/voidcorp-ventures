extends Node2D
class_name Meteor


@onready var area2D: Area2D = $Area2D
@onready var meteor_body: Sprite2D = $MeteorBody
@onready var timer: Timer = $EndTimer
@onready var explosion_audio_player: AudioStreamPlayer2D = $ExplosionAudioPlayer
@onready var explosion_particles: CPUParticles2D = $ExplosionParticles
@onready var meteor_particles: CPUParticles2D = $MeteorParticles

var scale_tween1: Tween
var scale_tween2: Tween

## The direction the meteor is moving in.
var direction: Vector2 = Vector2.ZERO

## Movement speed.
var speed: int = 25
## Current movement speed.
var current_speed: int = 25
## Rotation speed.
var rot_speed: int = 10

## Resource found on the meteor.
var rare_resource: ResourceCurrency = null
## Tells if the meteor is being mined by a crew ship.
var is_being_mined: bool = false
## Tells if the meteor is being followed.
var is_being_followed: bool = false
## Tells if the meteor has exploded.
var exploded: bool = false

## Emitted when the meteor is destroyed.
signal destroyed()


## Chooses the meteor type, connects the camera zoom signal, starts the
## destroy timer and plays a tween animation.
func _ready() -> void:
	choose_type()
	var camera: MainCamera = $"/root/Game/MainCamera"
	camera.connect('zoom_changed', _handle_zoom_change)
	timer.start()
	scale = Vector2(0, 0)
	scale_tween1 = get_tree().create_tween()
	scale_tween1.tween_property(self, 'scale', Vector2(1, 1), 2)
	_handle_zoom_change(camera.zoom.x)


## Chooses the meteor type. The meteor can either be normal,
## or contain Warpite.
func choose_type():
	var type_chance: int = randi_range(0, 4)
	if type_chance == 0:
		var resource_name = ResourceManager.special_resources[0]
		rare_resource = ResourceCurrency.new(resource_name, 5)
		
		var textures = [load("res://assets/sprites/meteors/meteor2.png"), load("res://assets/sprites/meteors/meteor3.png"), load("res://assets/sprites/meteors/meteor4.png")]
		meteor_body.texture = textures.pick_random()


## Every frame, the meteor moves in the assigned direction and rotates.
func _process(delta: float) -> void:
	position += direction * current_speed * delta
	meteor_body.rotation_degrees += rot_speed * delta
	meteor_particles.direction = -direction
	
	if process_mode == Node.PROCESS_MODE_DISABLED:
		if scale_tween1:
			scale_tween1.set_speed_scale(0)
		if scale_tween2:
			scale_tween2.set_speed_scale(0)
	else:
		if scale_tween1:
			scale_tween1.set_speed_scale(1)
		if scale_tween2:
			scale_tween2.set_speed_scale(1)


## Handles Area2D detections. The meteor can explode on impact with other meteors,
## spaceships and planets.
func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Spaceship:
		if parent.current_planet == null:
			parent.destroy()
			explode()
	elif parent is Planet:
		parent.handle_meteor_collision()
		explode()
	elif parent is Meteor:
		explode()


## Makes the meteor explode and emit explosion particles. An explosion sound
## is also played.
func explode() -> void:
	if not exploded:
		exploded = true
		area2D.monitoring = false
		area2D.set_collision_layer_value(3, false)
		area2D.set_collision_layer_value(2, false)
		area2D.set_collision_layer_value(5, false)
		speed = 0
		
		emit_signal("destroyed")
		
		explosion_audio_player.play()
		explosion_particles.emitting = true
		meteor_particles.emitting = false

		meteor_body.visible = false
		
		await explosion_audio_player.finished and explosion_particles.finished
		
		queue_free()


## When the end timer times out, the meteor shrinks and disappears.
func _on_end_timer_timeout() -> void:
	if not exploded:
		meteor_particles.emitting = false
		scale_tween2 = get_tree().create_tween()
		scale_tween2.tween_property(self, 'scale', Vector2(0, 0), 3)
		await scale_tween2.finished
		queue_free()


## Hides the meteor when the camera is zoomed out.
func _handle_zoom_change(new_zoom: float) -> void:
	if new_zoom < 0.5:
		visible = false
	else:
		visible = true


## Drains the rare resource present on the meteor.
func drain_rare_resource() -> int:
	if not rare_resource:
		return 0
	if rare_resource.amount == 0:
		# Change texture to normal meteor
		meteor_body.texture = load("res://assets/sprites/meteors/meteor.png")
		return 0
	else:
		var drain_amount: int = 1
		rare_resource.subtract(drain_amount)
		return drain_amount


## The meteor slows down. This can happen when it passes through a boost zone.
func slow_down(amount: int) -> void:
	if current_speed - amount < 0:
		current_speed = 0
	else:
		current_speed -= amount


## The meteor speeds up.
func speed_up(amount: int) -> void:
	current_speed += amount
