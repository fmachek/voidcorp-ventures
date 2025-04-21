extends Inventory
class_name SpaceshipCargo


## The spaceship this cargo belongs to.
var spaceship: Spaceship
## Maximum amount of resources the cargo can carry.
var max_cargo_hold: int = 50


## This constructor sets the spaceship variable.
func _init(spaceship: Spaceship) -> void:
	self.spaceship = spaceship


## Adds a resource to the cargo.
func add_resource_to_cargo(resource: ResourceCurrency) -> int:
	if resource == null:
		return 0
	
	var cargo_hold: int = calculate_inventory_hold()
	var gain_amount: int = 0
	
	if cargo_hold == max_cargo_hold or resource.amount == 0:
		return 0
	
	# Calculate gain amount
	if cargo_hold + resource.amount > max_cargo_hold:
		gain_amount = max_cargo_hold - cargo_hold
	else:
		gain_amount = resource.amount
	
	add_resource(ResourceCurrency.new(resource.name, gain_amount))
	return gain_amount


## Deposits the cargo to the player's inventory and spawns
## some labels for clarity.
func deposit() -> void:
	var label_y_offset: int = 9
	var i: int = 1
	for resource: ResourceCurrency in inventory:
		GameManager.add_resource(resource.name, resource.amount)
		var label_text: String = "+" + str(resource.amount) + " " + resource.name
		ResourceGainLabelSpawner.spawn_label(label_text, spaceship.global_position + Vector2(0, label_y_offset * i))
		i += 1
	inventory.clear()


## Increases the maximum hold by a given amount.
func increase_max_hold(amount: int) -> void:
	max_cargo_hold += amount
