extends Sprite2D
class_name SpaceshipProp

## Movement speed.
var speed: int = 30
## The direction the prop is flying in.
var direction = null

## This signal is emitted when the prop enters the intergalactic portal.
signal entered_portal()


func _ready() -> void:
	var flame_sprite = $FlameSprite
	flame_sprite.play()


## The prop moves in the direction every frame.
func _process(delta: float) -> void:
	if direction:
		var movement = direction * speed * delta
		global_position += movement


## Changes the direction the prop moves in.
func fly_to(destination: Vector2) -> void:
	direction = (destination - global_position).normalized()


## When the prop enters the portal's area, it slows down
## and fades out.
func _on_area_entered(area: Area2D) -> void:
	speed = 15
	disappear()


## Fade out and emit the 'entered_portal' signal.
func disappear():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 2)
	emit_signal("entered_portal")
