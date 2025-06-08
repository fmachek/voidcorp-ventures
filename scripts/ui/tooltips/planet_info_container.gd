extends VBoxContainer
class_name PlanetInfoContainer


## The planet being displayed by the info container.
var displayed_planet: Planet = null


## Loads the planet name.
func load_title(planet: Planet) -> void:
	$Header/Label.text = planet.planet_name


## Loads the info about the planet.
func load_info(planet: Planet) -> void:
	$MarginContainer/InfoContainer/MinesLabel.text = "Mines: " + str(planet.mines)
	$MarginContainer/InfoContainer/FactoriesLabel.text = "Factories: " + str(planet.factories)
	$MarginContainer/InfoContainer/SpaceshipsLabel.text = "Spaceships: " + str(len(planet.spaceships))
	
	var total = 0
	for resource in planet.inventory.inventory:
		total += resource.amount
	
	$MarginContainer/InfoContainer/ResourcesLabel.text = "Resources in storage: " + str(total)


## Updates the label displaying the planet resources.
func load_resources(planet: Planet) -> void:
	$Header/ResourcesLabel.text = str(planet.resource1.amount) + "/" + str(planet.resource2.amount)


## Amount parameter isn't even used, but it has to be there in order to
## catch the planet event
func update_resources(amount: int) -> void:
	load_resources(displayed_planet)


## Loads the UI element that indicates whether the planet is owned,
## disrupted or not owned.
func load_indicator(planet: Planet) -> void:
	if not planet.owned:
		turn_indicator_gray()
		return
	
	if planet.is_production_halted:
		turn_indicator_red()
	else:
		turn_indicator_green()


## Connect the planet signals so that the info container can react
## to changes in real time.
func connect_planet_signals(planet: Planet) -> void:
	planet.connect("claimed", turn_indicator_green)
	planet.connect("lost", turn_indicator_gray)
	planet.connect("production_halted", turn_indicator_red)
	planet.connect("production_resumed", turn_indicator_green)
	planet.connect("mine_built", update_mines)
	planet.connect("mine_lost", update_mines)
	planet.connect("factory_built", update_factories)
	planet.connect("factory_lost", update_factories)
	planet.connect("resource1_changed", update_resources)
	planet.connect("resource2_changed", update_resources)
	planet.connect("spaceship_landed", _on_spaceship_landed_or_left)
	planet.connect("spaceship_left", _on_spaceship_landed_or_left)
	planet.inventory.connect("resource_amount_changed", update_resource_amount)


## Turns the planet indicator green.
func turn_indicator_green() -> void:
	$Header/Indicator.texture = load("res://assets/ui/systemindicators/owned.png")


## Turns the planet indicator red.
func turn_indicator_red() -> void:
	$Header/Indicator.texture = load("res://assets/ui/systemindicators/disrupted.png")


## Turns the planet indicator gray.
func turn_indicator_gray() -> void:
	$Header/Indicator.texture = load("res://assets/ui/systemindicators/free.png")


## Updates the label displaying the amount of mines on the planet.
func update_mines() -> void:
	$MarginContainer/InfoContainer/MinesLabel.text = "Mines: " + str(displayed_planet.mines)


## Updates the label displaying the amount of factories on the planet.
func update_factories() -> void:
	$MarginContainer/InfoContainer/FactoriesLabel.text = "Factories: " + str(displayed_planet.factories)


## Updates the label displaying the amount of resources being stored currently in the
## displayed planet's resource.
func update_resource_amount(new_resource_amount: int) -> void:
	$MarginContainer/InfoContainer/ResourcesLabel.text = "Resources in storage: " + str(new_resource_amount)


## Handles spaceship departures and arrivals on the displayed planet.
func _on_spaceship_landed_or_left(spaceship: Spaceship) -> void:
	update_spaceships()


## Updates the label displaying the amount of spaceships on the displayed planet.
func update_spaceships() -> void:
	$MarginContainer/InfoContainer/SpaceshipsLabel.text = "Spaceships: " + str(len(displayed_planet.spaceships))


## Loads the planet and displays the info about it.
func load_planet(planet: Planet) -> void:
	displayed_planet = planet
	load_title(planet)
	load_info(planet)
	load_resources(planet)
	load_indicator(planet)
	connect_planet_signals(planet)
