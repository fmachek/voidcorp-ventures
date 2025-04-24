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

## Emitted when the camera zoom changes.
signal zoom_changed(new_zoom: float)


## Handles different input such as zoom and movement.[br][br]
## The player can make the camera zoom in and out and move left, right, up and down.
func _process(delta: float) -> void:
	var zoom_x = zoom.x
	default_move_h = Vector2(5/zoom_x, 0)
	default_move_v = Vector2(0, 5/zoom_x)
	
	# Focus on the camera target
	if target:
		position = position.lerp(target.global_position, smoothness * delta)
	
	# Disable camera movement while the win animation is playing, or if the game
	# is on the lose screen.
	if GameManager.is_animation_playing or GameManager.is_game_lost:
		return
	
	# Move camera up
	if Input.is_action_pressed('camera_down'):
		target = null
		var new_pos = position + (default_move_v * delta * movement_muliplier)
		position = position.lerp(new_pos, smoothness)
	
	# Move camera down
	if Input.is_action_pressed('camera_up'):
		target = null
		var new_pos = position - (default_move_v * delta * movement_muliplier)
		position = position.lerp(new_pos, smoothness)
	
	# Move camera to the left
	if Input.is_action_pressed('camera_left'):
		target = null
		var new_pos = position - (default_move_h * delta * movement_muliplier)
		position = position.lerp(new_pos, smoothness)
	
	# Move camera to the right
	if Input.is_action_pressed('camera_right'):
		target = null
		var new_pos = position + (default_move_h * delta * movement_muliplier)
		position = position.lerp(new_pos, smoothness)


func _unhandled_input(event: InputEvent) -> void:
	# Handle camera zoom in and out
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()


## This function causes the camera to focus on the [param object].
func focus_on(object):
	target = object


func zoom_in() -> void:
	if GameManager.is_animation_playing or GameManager.is_game_lost:
		return
	if zoom == Vector2(1, 1):
		return
	var mouse_pos = get_global_mouse_position()
	global_position = mouse_pos
	zoom = Vector2(1, 1)
	
	zoom_background_in()
	
	emit_signal('zoom_changed', zoom.x)


func zoom_out() -> void:
	if GameManager.is_animation_playing or GameManager.is_game_lost:
		return
	zoom = Vector2(0.1, 0.1)
	target = null
	
	zoom_background_out()
	
	emit_signal('zoom_changed', zoom.x)


func zoom_background_out() -> void:
	$BackgroundSprite.scale = Vector2(10, 10)
	$StarsSprite.scale = Vector2(10, 10)
	$DarkenRect.scale = Vector2(10, 10)


func zoom_background_in() -> void:
	$BackgroundSprite.scale = Vector2(1, 1)
	$StarsSprite.scale = Vector2(1, 1)
	$DarkenRect.scale = Vector2(1, 1)


func reset() -> void:
	target = null
	zoom = Vector2(1, 1)
	zoom_background_in()
