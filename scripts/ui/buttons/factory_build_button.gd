extends BuildButton
class_name FactoryBuildButton


func _ready() -> void:
	self.build_cost = 1000
	self.build_function = 'build_factory'
	super()
