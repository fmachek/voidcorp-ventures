extends Node2D
class_name SpaceshipRepair


## Tells if the repair has been picked up or not.
var is_picked_up: bool = false
## Rotation speed.
var rot_speed: int = 10

## Tween used to tween scale.
var scale_tween: Tween

## Timer which measures the time remaining until the repair disappears.
@onready var timer: Timer = $Timer

## Emitted when the repair is picked up.
signal picked_up()


## Called when the repair enters the scene tree. A scale animation
## is played and the camera zoom signal is connected. The timer starts.
func _ready() -> void:
	scale = Vector2.ZERO
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1, 1), 1)
	
	var camera: MainCamera = $"/root/Game/MainCamera"
	camera.connect("zoom_changed", _handle_zoom_change)
	_handle_zoom_change(camera.zoom.x)
	
	timer.start()


## Called every frame. The repair rotates.
func _process(delta: float) -> void:
	rotation_degrees += rot_speed * delta
	
	if scale_tween:
		if $"/root/Game/Level".process_mode == Node.PROCESS_MODE_DISABLED:
			scale_tween.set_speed_scale(0)
		else:
			scale_tween.set_speed_scale(1)


## Handles Area2D enter detections. If a spaceship enters it,
## it picks the repair up.
func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Spaceship:
		pick_up(parent)


## The repair is picked up by a given spaceship. The spaceship is repaired
## and visual effects are displayed. A sound is played. The repair
## is then freed.
func pick_up(spaceship: Spaceship) -> void:
	if not is_picked_up:
		is_picked_up = true
		spaceship.add_durability(25)
		emit_signal("picked_up")
		
		var pickup_sound_player: AudioStreamPlayer2D = $PickupSoundPlayer
		pickup_sound_player.play()
		
		var sprite: Sprite2D = $Sprite2D
		sprite.hide()
		
		var particles: CPUParticles2D = $PickUpParticles
		particles.emitting = true
		await particles.finished
		
		queue_free()


## When the timer times out, the repair disappears.
func _on_timer_timeout() -> void:
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(self, "scale", Vector2(0, 0), 1)
	await scale_tween.finished
	queue_free()


## Handles camera zoom changes. If the camera is zoomed out,
## the repair isn't visible.
func _handle_zoom_change(new_zoom: float) -> void:
	if new_zoom < 0.5:
		hide()
	else:
		show()
