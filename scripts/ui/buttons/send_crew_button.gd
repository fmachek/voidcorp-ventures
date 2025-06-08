extends TextureButton
class_name SendCrewButton


@onready var timer: Timer = $Timer
@onready var label: Label = $ButtonLabel

var price: int = 500


func _ready() -> void:
	InputModeHandler.connect("no_money_for_crew", show_error_message)
	InputModeHandler.connect("input_mode_changed", _on_input_mode_changed)
	GameManager.connect("money_changed", _on_money_changed)
	UpgradeManager.connect("unlocked_crew_ships", show)


func _on_pressed() -> void:
	InputModeHandler.set_input_mode(InputModeHandler.InputMode.SENDING_CREW)
	InputModeHandler.set_current_crew_planet($"/root/Game/UILayer/GameUI/PlanetUI".current_planet)


func show_error_message() -> void:
	label.text = "Not enough money!"
	timer.start()


func _on_timer_timeout() -> void:
	label.text = "Send Meteor Crew ($" + str(price) + ")"


func set_selected() -> void:
	pass


func set_unselected() -> void:
	pass


func _on_input_mode_changed(mode) -> void:
	if mode == InputModeHandler.InputMode.SENDING_CREW:
		set_selected()
	else:
		set_unselected()


func _on_money_changed(new_money: int) -> void:
	if new_money >= price:
		set_green_textures()
	else:
		set_red_textures()


func set_green_textures() -> void:
	texture_normal = load("res://assets/ui/buttons/buildcrew/normal/normal.png")
	texture_hover = load("res://assets/ui/buttons/buildcrew/normal/hover.png")
	texture_pressed = load("res://assets/ui/buttons/buildcrew/normal/pressed.png")


func set_red_textures() -> void:
	texture_normal = load("res://assets/ui/buttons/buildcrew/red/normal.png")
	texture_hover = load("res://assets/ui/buttons/buildcrew/red/hover.png")
	texture_pressed = load("res://assets/ui/buttons/buildcrew/red/pressed.png")
