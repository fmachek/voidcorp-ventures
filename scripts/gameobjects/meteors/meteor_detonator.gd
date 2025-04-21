extends Node2D
class_name MeteorDetonator


## The meteor being detonated.
var meteor: Meteor


## Every frame, the detonator is moved to the meteor's position (it sticks to it).
func _process(delta: float) -> void:
	if meteor:
		self.global_position = meteor.global_position


## Starts the detonation countdown.
func start_countdown() -> void:
	if meteor:
		var detonation_timer: Timer = Timer.new()
		detonation_timer.wait_time = 2
		detonation_timer.one_shot = true
		add_child(detonation_timer)
		detonation_timer.connect("timeout", _on_detonation_timer_timeout)
		detonation_timer.start()


## When the detonation countdown ends, the meteor explodes.
func _on_detonation_timer_timeout() -> void:
	if meteor:
		meteor.explode()


## Sets the meteor being detonated.
func set_meteor(meteor: Meteor) -> void:
	var old_meteor: Meteor = self.meteor
	if old_meteor:
		if old_meteor.is_connected("destroyed", _on_meteor_destroyed):
			old_meteor.disconnect("destroyed", _on_meteor_destroyed)
	self.meteor = meteor
	meteor.connect("destroyed", _on_meteor_destroyed)


## When the meteor is destroyed, the detonator is freed.
func _on_meteor_destroyed() -> void:
	queue_free()
