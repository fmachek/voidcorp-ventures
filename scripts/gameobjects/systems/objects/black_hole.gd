extends Node2D
class_name BlackHole


func _ready() -> void:
	queue_redraw()


## Draws the black hole area.
func _draw():
	draw_circle(Vector2(0, 0), 400, Color("#fc03030e"), true)


## Handles Area2D enter detection.
## If the detected object is a spaceship, crew ship or meteor,
## their direction is changed and they start moving toward the black hole.
func _on_area_2d_area_entered(area: Area2D) -> void:
	var object = area.get_parent()
	if object is Spaceship or object is CrewShip or object is Meteor:
		object.direction = (global_position - object.global_position).normalized()
		if object is CrewShip:
			# Make sure that the crew ship can't fly back when it's being
			# captured by the black hole
			object.is_flying_back = true


## Consumes an object when it touches the consumation Area2D.
func _on_consume_area_2d_area_entered(area: Area2D) -> void:
	var object = area.get_parent()
	object.queue_free()
