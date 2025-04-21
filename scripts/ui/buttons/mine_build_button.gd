extends BuildButton
class_name MineBuildButton


func _ready() -> void:
	self.build_cost = 500
	self.build_function = 'build_mine'
	super()
