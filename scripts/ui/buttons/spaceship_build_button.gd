extends BuildButton
class_name SpaceshipBuildButton


func _ready():
	self.build_cost = 1000
	self.show_cost = false
	self.label.text = "Build"
	super()
	
	GameManager.resources["Atomsteel"].connect("amount_changed", _handle_atomsteel_change)


func _on_pressed() -> void:
	button_click_player.play()
	build_spaceship()


func build_spaceship():
	var planet_ui = get_node('/root/Game/UILayer/GameUI/PlanetUI')
	var current_planet: Planet = planet_ui.current_planet
	
	# Spend money and resources
	var resource_name = 'Atomsteel'
	if not GameManager.has_enough_resource(resource_name, 10):
		print('Player does not have enough ' + resource_name + ' to build a spaceship.')
		return
	if not GameManager.has_enough_money(1000):
		print('Player does not have enough money to build a spaceship.')
		return
	
	GameManager.spend_resource(resource_name, 10)
	GameManager.spend_money(1000)
		
	var spaceship = current_planet.build_spaceship()


func _handle_money_changed(new_money: int) -> void:
	check_costs(new_money, GameManager.resources["Atomsteel"].amount)


func _handle_atomsteel_change(new_atomsteel: int) -> void:
	check_costs(GameManager.money, new_atomsteel)


func check_costs(money: int, atomsteel: int) -> void:
	if money >= build_cost and atomsteel >= 10:
		texture_normal = normal_green_texture
		texture_hover = hover_green_texture
		texture_pressed = pressed_green_texture
	else:
		texture_normal = normal_red_texture
		texture_hover = hover_red_texture
		texture_pressed = pressed_red_texture
