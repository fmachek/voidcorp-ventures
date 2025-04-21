extends TextureButton
class_name BuildButton

@onready var amount_label = $"../VBoxContainer/InfoContainer/AmountLabel"
@onready var button_click_player = $"/root/Game/ButtonClickPlayer"
@onready var label: Label = $ButtonLabel

var normal_green_texture = preload("res://assets/ui/buttons/buy/normal/normal.png")
var hover_green_texture = preload("res://assets/ui/buttons/buy/normal/hover.png")
var pressed_green_texture = preload("res://assets/ui/buttons/buy/normal/pressed.png")
var normal_red_texture = preload("res://assets/ui/buttons/buy/red/normal.png")
var hover_red_texture = preload("res://assets/ui/buttons/buy/red/hover.png")
var pressed_red_texture = preload("res://assets/ui/buttons/buy/red/pressed.png")

var build_cost: int
var planet: Planet
var build_function
var show_cost: bool = true

func _ready() -> void:
	if show_cost:
		label.text = "Build ($" + str(build_cost) + ")"
	GameManager.connect("money_changed", _handle_money_changed)


func _on_pressed() -> void:
	button_click_player.play()
	var spend_successful: bool = GameManager.spend_money(build_cost)
	if spend_successful:
		amount_label.text = str(planet.call(build_function))

func _handle_money_changed(new_money: int):
	if new_money >= build_cost:
		texture_normal = normal_green_texture
		texture_hover = hover_green_texture
		texture_pressed = pressed_green_texture
	else:
		texture_normal = normal_red_texture
		texture_hover = hover_red_texture
		texture_pressed = pressed_red_texture
