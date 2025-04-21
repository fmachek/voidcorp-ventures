extends AudioStreamPlayer
class_name ButtonClickPlayer


func _ready() -> void:
	# Makes sure that the sound never gets paused when the game is paused
	self.process_mode = Node.PROCESS_MODE_ALWAYS
