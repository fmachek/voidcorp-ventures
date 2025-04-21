extends RefCounted
class_name Upgrade
## This class represents an upgrade which grant different abilities and improvements.

## Integer used to identify the upgrade.
var upgrade_id: int
## Name of the upgrade.
var upgrade_name: String
## The upgrade required before the player is allowed to unlock this upgrade.
## Can be null.
var prerequisite: Upgrade
## This bool is true if the upgrade is unlocked, otherwise it's false.
var is_unlocked: bool
## An array of all costs. For example, it can contain money and resources.
var costs = [] # Array of all costs (money or resources)
## Description of the upgrade
var description: String

## This signal is emitted when the upgrade is unlocked.
signal unlocked()

## This constructor sets the upgrade id, name, prerequisite, costs and description.
func _init(upgrade_id: int, upgrade_name: String, prerequisite: Upgrade, costs: Array, description: String):
	self.upgrade_id = upgrade_id
	self.upgrade_name = upgrade_name
	self.prerequisite = prerequisite
	self.costs = costs
	self.description = description

## This function returns a String generated from all the upgrade costs. For example,
## if an upgrade costs 100 money and 10 Resource, the output will be "$100, 10 Resource".
func get_cost_string():
	var output = ''
	for i in range(len(costs)):
		var cost = costs[i]
		if cost is int:
			output += '$' + str(cost)
		elif cost is ResourceCurrency:
			output += str(cost.amount) + ' ' + cost.name
		if i != len(costs) - 1:
			output += ', '
	return output

## Unlocks the upgrade.
func unlock():
	if not is_unlocked:
		is_unlocked = true
		emit_signal('unlocked')
		UpgradeManager.increase_unlocked_upgrades_amount()
