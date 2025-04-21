extends Line2D
class_name ConnectingLine


var point1: Vector2
var point2: Vector2
var is_following_mouse: bool = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_following_mouse:
		clear_points()
		add_point(point1)
		point2 = get_global_mouse_position()
		add_point(point2)


func set_connection_points(point1: Vector2, point2: Vector2) -> void:
	self.point1 = point1
	self.point2 = point2
	clear_points()
	add_point(point1)
	add_point(point2)


func set_point1(point1: Vector2):
	self.point1 = point1
	add_point(point1)


func follow_mouse() -> void:
	is_following_mouse = true
