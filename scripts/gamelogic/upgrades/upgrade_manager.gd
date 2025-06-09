extends Node
## This class acts as a manager for all upgrades.

## This dictionary is used to store upgrade ids as the keys and upgrades as
## the values.
var upgrades = {}
## Amount of unlocked upgrades.
var unlocked_upgrades: int = 0
## Crew ships unlocked (yes/no).
var are_crew_ships_unlocked := false

## This signal is emitted when the amount of unlocked upgrades changes.
signal upgrade_amount_changed(new_amount: int)
## Emitted when crew ships are unlocked.
signal unlocked_crew_ships()


## Loads all upgrades when ready.
func _ready() -> void:
	reset()
	GameManager.connect("planets_owned_changed", _on_planets_owned_changed)


## Attempts to unlock the upgrade with the given id. The prerequisite is also checked.
## It returns true if the upgrade was successfully unlocked, false otherwise.
func unlock_upgrade(upgrade_id: int) -> bool:
	if upgrade_id not in upgrades:
		return false
	var upgrade = upgrades[upgrade_id]
	var prerequisite = upgrade.prerequisite
	if prerequisite: # Check if the upgrade has a prerequisite
		if prerequisite.is_unlocked:
			var spent: bool = spend_costs(upgrade)
			if spent:
				upgrade.unlock()
				return true
			else:
				return false
		return false
	else:
		var spent: bool = spend_costs(upgrade)
		if spent:
			upgrade.unlock()
			return true
		else:
			return false


## Checks if the player can afford the upgrade. If so, the costs
## are spent.
func spend_costs(upgrade: Upgrade) -> bool:
	var has_costs: bool = true
	var money_costs = []
	var resource_costs = []
	for cost in upgrade.costs:
		if cost is int:
			if not GameManager.has_enough_money(cost):
				has_costs = false
				break
			else:
				money_costs.append(cost)
		elif cost is ResourceCurrency:
			if not GameManager.has_enough_resource(cost.name, cost.amount):
				has_costs = false
				break
			else:
				resource_costs.append(cost)
	if not has_costs:
		return false
			
	for money_cost in money_costs:
		GameManager.spend_money(money_cost)
			
	for resource_cost in resource_costs:
		GameManager.spend_resource(resource_cost.name, resource_cost.amount)
	
	return true


## Loads all upgrades and adds them to the 'upgrades' dictionary, where the key is the upgrade
## id and the value is the upgrade itself.
func load_upgrades() -> void:
	# Allows spaceships to land on cold planets
	var spaceship_row1_upgrade2 = Upgrade.new(2, 'Winter Coat', null, [ResourceCurrency.new('Lunar Ingot', 250)], "Allows your spaceships to handle the climate on planets of the Cold type. This allows you to gather new resources.")
	upgrades[2] = spaceship_row1_upgrade2
	# Allows spaceships to land on hot planets
	var spaceship_row1_upgrade3 = Upgrade.new(3, 'Supercooling', spaceship_row1_upgrade2, [ResourceCurrency.new('Freezium', 250)], "Allows your spaceships to handle the climate on planets of the Hot type. This allows you to gather new resources.")
	upgrades[3] = spaceship_row1_upgrade3
	
	# Increases spaceship travel speed by 25%
	var spaceship_row2_upgrade1 = Upgrade.new(100, 'Faster Travel I', null, [1500, ResourceCurrency.new('Lunar Ore', 25)], "Makes your spaceships travel 25% faster.")
	upgrades[100] = spaceship_row2_upgrade1
	# Increases spaceship travel speed by 25%
	var spaceship_row2_upgrade2 = Upgrade.new(101, 'Faster Travel II', spaceship_row2_upgrade1, [2500, ResourceCurrency.new('Lunar Ore', 50)], "Makes your spaceships travel 25% faster.")
	upgrades[101] = spaceship_row2_upgrade2
	# Increases spaceship travel speed by 25%
	var spaceship_row2_upgrade3 = Upgrade.new(102, 'Faster Travel III', spaceship_row2_upgrade2, [2500, ResourceCurrency.new('Lunar Ore', 75)], "Makes your spaceships travel 25% faster.")
	upgrades[102] = spaceship_row2_upgrade3
	
	# Lowers the fuel cost by 15%
	var spaceship_row3_upgrade1 = Upgrade.new(103, 'Cheaper Fuel I', null, [1500, ResourceCurrency.new('Solar Ore', 25)], "Makes your spaceships consume less fuel, which helps reduce the fuel cost by 15%.")
	upgrades[103] = spaceship_row3_upgrade1
	# Lowers the fuel cost by 15%
	var spaceship_row3_upgrade2 = Upgrade.new(104, 'Cheaper Fuel II', spaceship_row3_upgrade1, [1500, ResourceCurrency.new('Solar Ore', 50)], "Makes your spaceships consume less fuel, which helps reduce the fuel cost by 15%.")
	upgrades[104] = spaceship_row3_upgrade2
	# Lowers the fuel cost by 15%
	var spaceship_row3_upgrade3 = Upgrade.new(105, 'Cheaper Fuel III', spaceship_row3_upgrade2, [1500, ResourceCurrency.new('Solar Ore', 75)], "Makes your spaceships consume less fuel, which helps reduce the fuel cost by 15%.")
	upgrades[105] = spaceship_row3_upgrade3
	
	# Upgrades durability by 15%
	var spaceship_row4_upgrade1 = Upgrade.new(106, 'Durability I', null, [1500, ResourceCurrency.new('Solar Ingot', 25)], "Improves the durability of your spaceships by 15%.")
	upgrades[106] = spaceship_row4_upgrade1
	# Upgrades durability by 15%
	var spaceship_row4_upgrade2 = Upgrade.new(107, 'Durability II', spaceship_row4_upgrade1, [2500, ResourceCurrency.new('Solar Ingot', 50)], "Improves the durability of your spaceships by 15%.")
	upgrades[107] = spaceship_row4_upgrade2
	# Upgrades durability by 15%
	var spaceship_row4_upgrade3 = Upgrade.new(108, 'Durability III', spaceship_row4_upgrade2, [2500, ResourceCurrency.new('Solar Ingot', 75)], "Improves the durability of your spaceships by 15%.")
	upgrades[108] = spaceship_row4_upgrade3
	
	# Unlocks boost zones that increase the spaceships' speed while they're
	# flying through
	var spaceship_row5_upgrade1 = Upgrade.new(16, 'Boost Zones', null, [5000, ResourceCurrency.new('Warpite', 10)], "Unlocks boost zones which appear around planets you own. Spaceships that enter these zones travel faster while in it.")
	upgrades[16] = spaceship_row5_upgrade1
	# Increases the boost zone range
	var spaceship_row5_upgrade2 = Upgrade.new(17, 'Longer Range', spaceship_row5_upgrade1, [2500, ResourceCurrency.new('Warpite', 10)], "Increases the radius of your boost zones.")
	upgrades[17] = spaceship_row5_upgrade2
	# Allows the zones to slow meteors down while they're flying through
	var spaceship_row5_upgrade3 = Upgrade.new(18, 'Meteor Slowdown', spaceship_row5_upgrade2, [2500, ResourceCurrency.new('Warpite', 10)], "Makes your boost zones slow down meteors passing by.")
	upgrades[18] = spaceship_row5_upgrade3
	
	# Increases spaceship cargo size.
	var spaceship_row6_upgrade1 = Upgrade.new(19, 'Bigger Cargo I', null, [ResourceCurrency.new('Atomsteel', 30)], "Allows your spaceship cargo to hold 10 additional resources.")
	upgrades[19] = spaceship_row6_upgrade1
	var spaceship_row6_upgrade2 = Upgrade.new(20, 'Bigger Cargo II', spaceship_row6_upgrade1, [ResourceCurrency.new('Atomsteel', 30)], "Allows your spaceship cargo to hold 10 additional resources.")
	upgrades[20] = spaceship_row6_upgrade2
	var spaceship_row6_upgrade3 = Upgrade.new(21, 'Bigger Cargo III', spaceship_row6_upgrade2, [ResourceCurrency.new('Atomsteel', 30)], "Allows your spaceship cargo to hold 10 additional resources.")
	upgrades[21] = spaceship_row6_upgrade3
	
	# Makes system discovery cost less
	var research_row1_upgrade1 = Upgrade.new(5, 'Cheaper Research I', null, [2500, ResourceCurrency.new('Solar Ingot', 50)], "Reduces the system discovery cost by $250.")
	upgrades[5] = research_row1_upgrade1
	var research_row1_upgrade2 = Upgrade.new(14, 'Cheaper Research II', research_row1_upgrade1, [2500, ResourceCurrency.new('Solar Ingot', 50)], "Reduces the system discovery cost by $250.")
	upgrades[14] = research_row1_upgrade2
	var research_row1_upgrade3 = Upgrade.new(15, 'Cheaper Research III', research_row1_upgrade2, [2500, ResourceCurrency.new('Solar Ingot', 50)], "Reduces the system discovery cost by $250.")
	upgrades[15] = research_row1_upgrade3
	
	# Makes crew ships fly faster
	var crew_row1_upgrade1 = Upgrade.new(6, 'Faster Travel', null, [2500, ResourceCurrency.new('Warpite', 10)], "Makes your meteor crew ships travel faster.")
	upgrades[6] = crew_row1_upgrade1
	# Makes crews mine faster
	var crew_row1_upgrade2 = Upgrade.new(7, 'Faster Mining', crew_row1_upgrade1, [2500, ResourceCurrency.new('Warpite', 10)], "Makes your crews extract meteor resources faster.")
	upgrades[7] = crew_row1_upgrade2
	# Allows the crews to bring back one additional resource
	var crew_row1_upgrade3 = Upgrade.new(8, 'Bonus Resources', crew_row1_upgrade2, [2500, ResourceCurrency.new('Warpite', 10)], "Allows your crews to extract 1 additional resource from meteors.")
	upgrades[8] = crew_row1_upgrade3
	
	# Allows crew ships to follow meteors
	var crew_row2_upgrade1 = Upgrade.new(9, 'Better Captain', null, [5000, ResourceCurrency.new('Warpite', 10)], "Allows your crew ships to focus on and follow meteors when they get close enough.")
	upgrades[9] = crew_row2_upgrade1
	# Allows crew ships to make meteors explode either:
	# - after they depart from a meteor the crew mined
	# - when they land on a normal meteor
	# NOTE: the crew ship can follow and land on a normal meteor without a resource with this upgrade
	var crew_row2_upgrade2 = Upgrade.new(10, 'Detonation', crew_row2_upgrade1, [5000, ResourceCurrency.new('Gravitium', 10)], "Allows your crew ships to plant explosives on meteors, even ones with no resource. Can be used to prevent meteor impacts.")
	upgrades[10] = crew_row2_upgrade2
	
	# Unlocks passive mining on planets that persists even after the
	# resources are drained. A random resource of the two is chosen.
	var planet_row1_upgrade1 = Upgrade.new(11, 'Dig Deeper', null, [2500, ResourceCurrency.new('Atomite', 50)], "Allows your mines to generate additional resources, even after they've been depleted.")
	upgrades[11] = planet_row1_upgrade1
	# Passive mining is faster by 5 seconds
	var planet_row1_upgrade2 = Upgrade.new(12, 'Dig Faster', planet_row1_upgrade1, [2500, ResourceCurrency.new('Atomite', 50)], "Allows bonus resources to be generated more often.")
	upgrades[12] = planet_row1_upgrade2
	# Passive mining has a chance to yield one more of the bonus resource
	var planet_row1_upgrade3 = Upgrade.new(13, 'Dig More', planet_row1_upgrade2, [2500, ResourceCurrency.new('Atomite', 50)], "Grants a chance to mine one additional bonus resource.")
	upgrades[13] = planet_row1_upgrade3
	
	var planet_row2_upgrade1 = Upgrade.new(22, 'Hidden Gems', null, [2500, ResourceCurrency.new('Atomsteel', 25)], "Allows the mines on your planets to occasionally unearth 1 Gravitium per mining cycle. The chances for the amount of mines are: 0.5%, 1.5%, 3%, and 5% for more than 3 mines.")
	upgrades[22] = planet_row2_upgrade1
	var planet_row2_upgrade2 = Upgrade.new(23, 'Improved Scanning I', planet_row2_upgrade1, [1000, ResourceCurrency.new('Gravitium', 5)], "Increases the chance to find Gravitium by 0.5%.")
	upgrades[23] = planet_row2_upgrade2
	var planet_row2_upgrade3 = Upgrade.new(24, 'Improved Scanning II', planet_row2_upgrade2, [1000, ResourceCurrency.new('Gravitium', 5)], "Increases the chance to find Gravitium by 0.5%.")
	upgrades[24] = planet_row2_upgrade3
	var planet_row2_upgrade4 = Upgrade.new(25, 'Improved Scanning III', planet_row2_upgrade3, [1000, ResourceCurrency.new('Gravitium', 5)], "Increases the chance to find Gravitium by 0.5%.")
	upgrades[25] = planet_row2_upgrade4
	
	# Allow trader spaceships to arrive
	var event_row1_upgrade1 = Upgrade.new(26, 'Advertising I', null, [2500], "Advertise your company and attract traders who may have interesting offers for you.")
	upgrades[26] = event_row1_upgrade1
	# Make trader spaceships arrive more often
	var event_row1_upgrade2 = Upgrade.new(27, 'Advertising II', event_row1_upgrade1, [2500], "Advertise even more and attract traders more often.")
	upgrades[27] = event_row1_upgrade2
	# Make trader spaceships arrive more often
	var event_row1_upgrade3 = Upgrade.new(28, 'Advertising III', event_row1_upgrade2, [2500], "Advertise even more and attract traders more often.")
	upgrades[28] = event_row1_upgrade3
	


## Increases the amount of unlocked upgrades by 1.
func increase_unlocked_upgrades_amount() -> void:
	unlocked_upgrades += 1
	emit_signal("upgrade_amount_changed", unlocked_upgrades)


## Resets some variables to their original state.
func reset() -> void:
	unlocked_upgrades = 0
	are_crew_ships_unlocked = false
	
	upgrades.clear()
	load_upgrades()


func unlock_crew_ships() -> void:
	if not are_crew_ships_unlocked:
		are_crew_ships_unlocked = true
		emit_signal("unlocked_crew_ships")


func _on_planets_owned_changed(new_amount: int) -> void:
	if new_amount >= 3:
		unlock_crew_ships()
