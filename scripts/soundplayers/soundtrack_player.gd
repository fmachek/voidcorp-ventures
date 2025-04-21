extends AudioStreamPlayer
class_name SoundtrackPlayer


var started: bool = false
var soundtracks: Array = [load("res://assets/audio/soundtrack/Stars.wav"), load("res://assets/audio/soundtrack/Warpite.wav"), load("res://assets/audio/soundtrack/Planets.wav"), load("res://assets/audio/soundtrack/Excitement.wav")]
var win_soundtrack = load("res://assets/audio/soundtrack/Galaxies.wav")
var soundtrack_index: int = 0


func _ready() -> void:
	SettingsManager.connect("music_volume_changed", _handle_volume_changed)
	SettingsManager.connect("music_enabled_changed", _handle_music_enabled_changed)
	reset()
	
	_handle_music_enabled_changed(SettingsManager.music_enabled)


func _handle_music_enabled_changed(new_value: bool):
	if new_value == true:
		volume_db = 0
	else:
		volume_db = -80


func _handle_game_resumed():
	if not started:
		started = true
		GamePauseManager.disconnect("game_resumed", _handle_game_resumed)
		play_soundtrack()


func _handle_volume_changed(new_volume: int):
	var calculated_volume = linear_to_db(new_volume)
	print(calculated_volume)
	volume_db = calculated_volume


func _on_finished() -> void:
	play_soundtrack()


func play_soundtrack():
	var soundtrack = soundtracks[soundtrack_index]
	if soundtrack_index == len(soundtracks) - 1:
		soundtrack_index = 0 # Go from the start again
	else:
		soundtrack_index += 1
	
	stream = soundtrack
	play()
	print("Soundtrack started")


func reset() -> void:
	soundtrack_index = 0
	started = false
	stop()
	stream = null
	GamePauseManager.connect("game_resumed", _handle_game_resumed)


func play_win_soundtrack() -> void:
	stop()
	stream = win_soundtrack
	play()
