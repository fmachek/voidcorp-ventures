extends Node2D
class_name SpaceshipScraps


var scale_tween1: Tween
var scale_tween2: Tween

## Rotation speed.
var rot_speed: int = 10

@onready var timer = $Timer


func _ready() -> void:
	scale_tween1 = get_tree().create_tween()
	scale = Vector2(0, 0)
	scale_tween1.tween_property(self, 'scale', Vector2(1, 1), 0.25)
	
	timer.start()


## Every frame, the scraps rotate. Tweens are paused if the game is paused.
func _process(delta: float) -> void:
	rotation_degrees += rot_speed * delta
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


## On timer timeout, a scale tween is played and the scraps are freed.
func _on_timer_timeout() -> void:
	scale_tween2 = get_tree().create_tween()
	scale_tween2.tween_property(self, 'scale', Vector2(0, 0), 1)
	await scale_tween2.finished
	queue_free()
