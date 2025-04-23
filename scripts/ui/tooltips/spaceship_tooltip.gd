extends Control
class_name SpaceshipTooltip


var spaceship: Spaceship = null

@onready var resource_container: VBoxContainer = $MarginContainer/VBoxContainer/ResourceContainer


func _process(delta: float) -> void:
	if spaceship != null:
		var rect_width = $ColorRect.size.x
		var mouse_pos = get_global_mouse_position()
		
		var new_pos = mouse_pos
		
		var game_ui = $"/root/Game/UILayer/GameUI"
		var planet_ui = game_ui.get_node("PlanetUI")
		
		var limit_x = game_ui.global_position.x + game_ui.size.x
		
		if new_pos.x + rect_width > limit_x:
			new_pos.x -= rect_width
		
		new_pos.y -= $ColorRect.size.y
		
		global_position = new_pos


func load_spaceship(spaceship: Spaceship) -> void:
	self.spaceship = spaceship
	var cargo: SpaceshipCargo = spaceship.cargo
	for resource: ResourceCurrency in cargo.inventory:
		load_label(resource)
	var y_height = 25
	for label in resource_container.get_children():
		y_height += 7
	self.size = Vector2(150, y_height)
	
	var max_hold_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/MaxHoldLabel
	max_hold_label.text = "Max hold: " + str(spaceship.cargo.max_cargo_hold)
	
	show()


func unload_spaceship(spaceship: Spaceship) -> void:
	if self.spaceship == spaceship:
		self.spaceship = null
		for label in resource_container.get_children():
			label.queue_free()
		hide()


func load_label(resource: ResourceCurrency) -> void:
	var label: Label = Label.new()
	label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	label.add_theme_font_size_override("font_size", 6)
	label.add_theme_color_override("font_color", Color("#adadad"))
	label.text = str(resource.amount) + " " + resource.name
	resource_container.add_child(label)
