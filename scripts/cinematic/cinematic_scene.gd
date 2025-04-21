extends Node2D
class_name Cinematic


## Spaceship sprite used in the animation.
@onready var spaceship = $SpaceshipProp


func _ready() -> void:
	spaceship.connect("entered_portal", fade_out)


## Starts playing the animation.
func play_cinematic() -> void:
	var portal: Node2D = $Portal
	spaceship.fly_to(portal.global_position)


## The black UI rectangle fades in and the game results are shown.
## The cinematic scene is freed.
func fade_out() -> void:
	var fade_rect = $FadeRect
	fade_rect.visible = true
	fade_rect.modulate.a = 0
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(fade_rect, "modulate:a", 1, 2)
	await get_tree().create_timer(5).timeout
	GameManager.show_results()
	queue_free()
