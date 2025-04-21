extends Camera2D
class_name MainCamera
## This class represents the main game camera.

## This variable is used to determine position transition smoothness.
var smoothness: int = 5
## This variable stores the current target of the camera.
var target: Node2D = null

## This is the default camera horizontal movement [Vector2].
var default_move_h: Vector2 = Vector2(5, 0)
## This is the default camera vertical movement [Vector2].
var default_move_v: Vector2 = Vector2(0, 5)
## This is the number used during movement to multiply the movement vector.
var movement_muliplier: int = 20

signal zoom_changed(new_zoom: float)

## Handles different input such as zoom and movement.[br][br]
## The player can make the camera zoom in and out and move left, right, up and down.
func _process(delta: float) -> void:
	var zoom_x = self.zoom.x
	default_move_h = Vector2(5/zoom_x, 0)
	default_move_v = Vector2(0, 5/zoom_x)
	if target:
		self.position = self.position.lerp(target.global_position, smoothness * delta)
	
	if Input.is_action_pressed('camera_down') and not GameManager.is_animation_playing and not GameManager.is_game_lost:
		target = null
		var new_pos = self.position + (default_move_v * delta * movement_muliplier)
		self.position = self.position.lerp(new_pos, smoothness)
	
	if Input.is_action_pressed('camera_up') and not GameManager.is_animation_playing and not GameManager.is_game_lost:
		target = null
		var new_pos = self.position - (default_move_v * delta * movement_muliplier)
		self.position = self.position.lerp(new_pos, smoothness)
	
	if Input.is_action_pressed('camera_left') and not GameManager.is_animation_playing and not GameManager.is_game_lost:
		target = null
		var new_pos = self.position - (default_move_h * delta * movement_muliplier)
		self.position = self.position.lerp(new_pos, smoothness)
	
	if Input.is_action_pressed('camera_right') and not GameManager.is_animation_playing and not GameManager.is_game_lost:
		target = null
		var new_pos = self.position + (default_move_h * delta * movement_muliplier)
		self.position = self.position.lerp(new_pos, smoothness)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()


## This function causes the camera to "focus" on the [param object], playing
## a zoom animation to adjust to it.
func focus_on(object):
	target = object


func zoom_in() -> void:
	if GameManager.is_animation_playing or GameManager.is_game_lost:
		return
	if self.zoom == Vector2(1, 1):
		return
	var mouse_pos = get_global_mouse_position()
	self.global_position = mouse_pos
	self.zoom = Vector2(1, 1)
	emit_signal('zoom_changed', self.zoom.x)


func zoom_out() -> void:
	if GameManager.is_animation_playing or GameManager.is_game_lost:
		return
	self.zoom = Vector2(0.1, 0.1)
	target = null
	emit_signal('zoom_changed', self.zoom.x)


func reset() -> void:
	target = null
	zoom = Vector2(1, 1)
