extends Node
## This class is the main game script and is also a Singleton.

@onready var level_scene = preload("res://scenes/Level.tscn")
@onready var game = $"/root/Game"

## This variable represents the player's money. Default is 10,000.
var money: int = 10000
## Amount of planets owned by the player, 1 by default (home planet).
var planets_owned: int = 1
## Total money gained throughout the game.
var total_money_gained: int = 0
## This dictionary is used to store all resources the player can have.
var resources = {}

## This signal is emitted when the player's money changes.
signal money_changed(new_money: int)
## This signal is emitted when the amount of planets owned by the player changes.
signal planets_owned_changed(new_planets_owned: int)
## This signal is emitted when the game level is loaded.
signal level_loaded()
## This signal is emitted when the player wins the game.
signal game_won()
## This signal is emitted when the player loses the game.
signal game_lost()

## Currently loaded game level.
var level: Level = null

## Tells if the win animation is playing or not.
var is_animation_playing: bool = false
## Tells if the game is on the lose screen.
var is_game_lost: bool = false


func _ready() -> void:
	reset()
	GamePauseManager.connect("game_resumed", _handle_game_resumed)


## Increases the amount of owned planets by 1.
func planet_claimed() -> void:
	planets_owned += 1
	emit_signal("planets_owned_changed", planets_owned)


## Decreases the amount of owned planets by 1.
func planet_lost() -> void:
	planets_owned -= 1
	emit_signal("planets_owned_changed", planets_owned)


## When the game is resumed and no level is loaded, the level is loaded.
func _handle_game_resumed():
	if level == null:
		load_new_level()


## Loads a new game level.
func load_new_level() -> void:
	level = level_scene.instantiate()
	game.add_child(level)
	emit_signal("level_loaded")


## Attempts to spend a given [param amount] of the player's money.[br]
## Returns false if there is not enough money to spend,
## otherwise returns true.
func spend_money(amount:int) -> bool:
	if has_enough_money(amount):
		money -= amount
		emit_signal("money_changed", money)
		return true
	return false


## Adds a given amount to the player's money.
func add_money(amount: int):
	money += amount
	total_money_gained += amount
	emit_signal("money_changed", money)


## Checks if the player has a given amount of money.
func has_enough_money(amount: int):
	if money >= amount:
		return true
	return false


## Attempts to spend an amount of a resource with a given resource name.
func spend_resource(resource_name: String, amount: int):
	if amount > 0:
		if has_enough_resource(resource_name, amount):
			var resource: ResourceCurrency = resources[resource_name]
			resource.subtract(amount)
			return true
		else:
			return false
	else:
		return false


## Loads all resources using the resource manager.
func load_resources():
	var all_resources = ResourceManager.get_all_resources()
	for resource_name in all_resources:
		resources[resource_name] = ResourceCurrency.new(resource_name, 0)


## Adds a given amount to the resource with the given name.
func add_resource(resource_name: String, amount: int):
	if amount > 0:
		if resource_name in resources: # Find the resource with the name
			var resource = resources[resource_name]
			resource.add(amount) # Add the amount to the resource
			ConsoleMessageManager.add_info_message('You have gained ' + str(amount) + ' ' + resource.name + ".")
			return


## Checks if the player has enough of a resource.
func has_enough_resource(resource_name: String, amount: int):
	if resource_name in resources:
		var resource = resources[resource_name]
		if resource.amount < amount:
			return false # Not enough resources to spend
		return true
	return false # Resource not found


## Sells an amount of a resource with the given name.
func sell_resource(resource_name: String, amount: int) -> bool:
	var success = spend_resource(resource_name, amount)
	if success:
		var price = PriceHistoryManager.get_current_price(resource_name)
		add_money(price * amount)
		PriceHistoryManager.change_resource_demand(resource_name, -amount)
		ConsoleMessageManager.add_info_message("You sold " + str(amount) + " " + resource_name + " for $" + str(price*amount) + ".")
	return success


## This function handles game resetting. Some things have to be reset manually (especially autoloads).
func reset_game() -> void:
	# Reset self
	reset()
	
	# Reset camera
	$"/root/Game/MainCamera".reset()
	
	# Pause the game and reset game pause manager
	GamePauseManager.pause_game()
	GamePauseManager.reset()
	
	# Reset the time manager
	var time_manager: TimeManager = $"/root/Game/TimeManager"
	time_manager.reset()
	
	# Reset upgrades
	UpgradeManager.reset()
	# Reset input mode
	InputModeHandler.reset()
	# Reset price history
	PriceHistoryManager.reset()
	# Reset win requirements
	WinRequirementHandler.reset()
	
	# Reset soundtrack player
	$"/root/Game/SoundtrackPlayer".reset()
	
	reset_ui()


## Restarts the game.
func restart_game():
	reset_game()
	GamePauseManager.resume_game()


## Resets the UI.
func reset_ui() -> void:
	var ui_layer: UILayer = $"/root/Game/UILayer"
	ui_layer.reset()
	
	# We need to rename the old UI element first, because
	# it won't update in time before we add the new one.
	# So we rename it to avoid duplicate names, which would
	# cause problems.
	
	# Reset upgrade UI
	ui_layer.get_node("UpgradeUI").name = "OldUpgradeUI"
	ui_layer.get_node("OldUpgradeUI").queue_free()
	var upgrade_ui = load("res://scenes/ui/upgrades/UpgradeUI.tscn").instantiate()
	upgrade_ui.hide()
	ui_layer.add_child(upgrade_ui)
	upgrade_ui.name = "UpgradeUI"
	
	# Reset market UI
	ui_layer.get_node("MarketUI").name = "OldMarketUI"
	ui_layer.get_node("OldMarketUI").queue_free()
	var market_ui = load("res://scenes/ui/market/MarketUI.tscn").instantiate()
	market_ui.hide()
	ui_layer.add_child(market_ui)
	market_ui.name = "MarketUI"
	
	# Reset game UI
	ui_layer.get_node("GameUI").name = "OldGameUI"
	ui_layer.get_node("OldGameUI").queue_free()
	var game_ui = load("res://scenes/ui/game/GameUI.tscn").instantiate()
	ui_layer.add_child(game_ui)
	game_ui.name = "GameUI"
	
	# Reset spaceship tooltip
	ui_layer.get_node("SpaceshipTooltip").name = "OldSpaceshipTooltip"
	ui_layer.get_node("OldSpaceshipTooltip").queue_free()
	var spaceship_tooltip = load("res://scenes/ui/tooltips/SpaceshipTooltip.tscn").instantiate()
	spaceship_tooltip.hide()
	ui_layer.add_child(spaceship_tooltip)
	spaceship_tooltip.name = "SpaceshipTooltip"
	
	# Reset planetary system tooltip
	ui_layer.get_node("SystemTooltip").name = "OldSystemTooltip"
	ui_layer.get_node("OldSystemTooltip").queue_free()
	var system_tooltip = load("res://scenes/ui/tooltips/SystemTooltip.tscn").instantiate()
	ui_layer.add_child(system_tooltip)
	system_tooltip.name = "SystemTooltip"
	
	# Change the order of the UI elements
	ui_layer.move_child(game_ui, 0)
	ui_layer.move_child(upgrade_ui, 1)
	ui_layer.move_child(market_ui, 2)
	ui_layer.move_child(spaceship_tooltip, 3)
	ui_layer.move_child(system_tooltip, 4)
	
	var main_menu: MainMenu = ui_layer.get_node("MainMenu")
	ui_layer.get_node("MainMenu").move_child(main_menu, 4)
	
	var settings_menu: SettingsMenu = ui_layer.get_node("SettingsMenu")
	ui_layer.move_child(main_menu, 5)


## Resets itself. Sets the variables to their original values.
func reset() -> void:
	money = 10000 # Revert to default
	planets_owned = 1 # Always 1 by default (home planet)
	total_money_gained = 0
	is_animation_playing = false
	is_game_lost = false
	
	# Reload resources
	resources.clear()
	load_resources()
	resources['Atomsteel'].add(50)
	
	# Delete level
	if level:
		level.name = "RemovedLevel" # Rename to prevent duplicate name
		level.queue_free()
		level = null


## Starts the win cinematic.
func play_animation() -> void:
	is_animation_playing = true
	# The camera is moved to the animation area and stops moving on input
	var cinematic_pos = Vector2(0, 20000)
	
	var camera = $"/root/Game/MainCamera"
	camera.global_position = cinematic_pos
	camera.zoom = Vector2(2, 2)
	camera.target = null
	
	var cinematic = load("res://scenes/cinematic/CinematicScene.tscn").instantiate()
	$"/root/Game".add_child(cinematic)
	cinematic.global_position = cinematic_pos
	cinematic.play_cinematic()
	
	$"/root/Game/SoundtrackPlayer".play_win_soundtrack()
	
	# Game pausing is also disabled


## Called when the game is won by the player. Freezes the game level
## and plays the animation.
func win_game() -> void:
	emit_signal("game_won")
	level.process_mode = PROCESS_MODE_DISABLED # Stop processing level
	$"/root/Game/TimeManager".stop() # Stop measuring months
	play_animation()


## Shows the game results.
func show_results() -> void:
	var results_ui: ResultsUI = load("res://scenes/ui/results/ResultsUI.tscn").instantiate()
	$"/root/Game/UILayer".add_child(results_ui)
	
	var months_passed = $"/root/Game/TimeManager".current_month
	var upgrades_unlocked = UpgradeManager.unlocked_upgrades
	results_ui.load_results(months_passed, total_money_gained, planets_owned, upgrades_unlocked)


func lose_game() -> void:
	is_game_lost = true
	level.process_mode = PROCESS_MODE_DISABLED # Stop processing level
	$"/root/Game/TimeManager".stop() # Stop measuring months
	var loss_ui: LossUI = load("res://scenes/ui/loss/LossUI.tscn").instantiate()
	$"/root/Game/UILayer".add_child(loss_ui)
	emit_signal("game_lost")
