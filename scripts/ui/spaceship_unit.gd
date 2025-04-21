extends MarginContainer
class_name SpaceshipUnit

var spaceship: Spaceship
@onready var durability_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var outline_panel = $OutlinePanel
@onready var button_click_player = $"/root/Game/ButtonClickPlayer"
@onready var spaceship_texture = $VBoxContainer/TextureRect/SpaceshipTexture


func _ready() -> void:
	durability_bar.value = spaceship.durability
	update_texture(spaceship.max_planet_type)


func update_texture(type: Planet.PlanetType) -> void:
	spaceship_texture.texture = spaceship.get_node("SpaceshipBody").texture


func load_spaceship(spaceship: Spaceship):
	self.spaceship = spaceship
	spaceship.connect('durability_changed', _on_durability_changed)
	spaceship.connect("max_planet_type_changed", update_texture)


func _on_durability_changed(new_durability: int):
	durability_bar.value = spaceship.durability


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			button_click_player.play()
			if InputModeHandler.current_input_mode == InputModeHandler.InputMode.NORMAL:
				InputModeHandler.set_input_mode(InputModeHandler.InputMode.SENDING_SPACESHIP)
				var planet_ui = get_node('/root/Game/UILayer/GameUI/PlanetUI')
				InputModeHandler.spaceship_source = planet_ui.current_planet
				
				InputModeHandler.set_spaceship_controlled(spaceship)
				set_selected_border()
				InputModeHandler.connect('input_mode_changed', _on_input_mode_changed)
				InputModeHandler.connect('spaceship_controlled_changed', _on_spaceship_controlled_changed)
			else:
				if InputModeHandler.current_spaceship_controlled == spaceship:
					InputModeHandler.set_input_mode(InputModeHandler.InputMode.NORMAL)
				else:
					InputModeHandler.set_spaceship_controlled(spaceship)
					set_selected_border()
					InputModeHandler.connect('input_mode_changed', _on_input_mode_changed)
					InputModeHandler.connect('spaceship_controlled_changed', _on_spaceship_controlled_changed)


func set_selected_border():
	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(1)
	stylebox.border_color = Color(1, 1, 1)
	stylebox.bg_color = Color(0, 0, 0, 0)
	outline_panel.add_theme_stylebox_override('panel', stylebox)


func set_normal_border():
	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(0)
	stylebox.bg_color = Color(0, 0, 0, 0)
	outline_panel.add_theme_stylebox_override('panel', stylebox)


func _on_input_mode_changed(input_mode):
	if input_mode != InputModeHandler.InputMode.SENDING_SPACESHIP:
		set_normal_border()


func _on_spaceship_controlled_changed(new_spaceship: Spaceship):
	if spaceship == new_spaceship:
		set_selected_border()
	else:
		set_normal_border()


func _on_mouse_entered() -> void:
	if len(spaceship.cargo.inventory) > 0:
		var tooltip: SpaceshipTooltip = $"/root/Game/UILayer/SpaceshipTooltip"
		tooltip.load_spaceship(spaceship)


func _on_mouse_exited() -> void:
	var tooltip: SpaceshipTooltip = $"/root/Game/UILayer/SpaceshipTooltip"
	tooltip.unload_spaceship(spaceship)
