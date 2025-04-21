extends Node

## Tells if the game is paused or not.
var paused: bool = true
## Tells if the game level is loaded or not.
var level_loaded: bool = false

## Emitted when the game is paused.
signal game_paused()
## Emitted when the game is resumed.
signal game_resumed()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.connect("level_loaded", _on_level_loaded)
	reset()


## Handles the pause input (escape key). Resumes or pauses the game.
func _input(event):
	# Detect ESC click for menu
	if event.is_action_pressed("pause"):
		if paused and level_loaded:
			resume_game()
		else:
			pause_game()


## Pauses the game if the win animation isn't playing and the game isn't on the lose screen.
func pause_game():
	if GameManager.is_animation_playing or GameManager.is_game_lost:
		return
	paused = true
	emit_signal("game_paused")
	get_tree().paused = true


## Resumes the game if the win animation isn't playing and the game isn't on the lose screen.
func resume_game():
	if GameManager.is_animation_playing or GameManager.is_game_lost:
		return
	paused = false
	emit_signal("game_resumed")
	get_tree().paused = false
	print("Game resumed!")


## Resumes the game when the game level is loaded.
func _on_level_loaded() -> void:
	level_loaded = true
	if paused:
		resume_game()


## Resets itself.
func reset() -> void:
	paused = true
	level_loaded = false
