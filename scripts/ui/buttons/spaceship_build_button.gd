extends BuildButton
class_name SpaceshipBuildButton


func _ready():
	self.build_cost = 1000
	self.show_cost = false
	self.label.text = "Build"
	super()


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
