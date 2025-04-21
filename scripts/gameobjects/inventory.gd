extends Node
class_name Inventory


## Array of resources.
var inventory: Array[ResourceCurrency] = []

## Emitted when a new resource is added to the inventory.
signal new_resource_added(resource: ResourceCurrency)
## Emitted when a resource is removed from the inventory.
signal resource_removed(resource: ResourceCurrency)


## Returns a resource in the inventory with a given name.
func get_resource_by_name(resource_name: String) -> ResourceCurrency:
	for resource in inventory:
		if resource.name == resource_name:
			return resource
	return null


## Adds a resource to the inventory.
func add_resource(resource: ResourceCurrency) -> void:
	if resource.amount == 0:
		return
	var resource_in_cargo: ResourceCurrency = get_resource_by_name(resource.name)
	if resource_in_cargo:
		resource_in_cargo.add(resource.amount)
	else:
		var new_resource: ResourceCurrency = ResourceCurrency.new(resource.name, resource.amount)
		inventory.append(new_resource)
		emit_signal("new_resource_added", new_resource)


## Removes a resource from the inventory.
func remove_resource(resource: ResourceCurrency) -> void:
	if resource in inventory:
		inventory.erase(resource)
		emit_signal("resource_removed", resource)


## Calculates the current cargo hold.
func calculate_inventory_hold() -> int:
	var total_hold: int = 0
	for resource in inventory:
		total_hold += resource.amount
	return total_hold


## Finds the resource with the highest amount in the inventory.
func get_highest_resource() -> ResourceCurrency:
	var highest_resource: ResourceCurrency = null
	for resource: ResourceCurrency in inventory:
		if highest_resource == null:
			highest_resource = resource
		elif resource.amount > highest_resource.amount:
			highest_resource = resource
	return highest_resource


## Withdraws a given amount of a resource from the inventory.
func withdraw_resource(resource: ResourceCurrency, amount: int) -> void:
	if resource == null:
		return
	resource.subtract(amount)
	if resource.amount == 0:
		remove_resource(resource)


## Empties the inventory.
func empty() -> void:
	inventory.clear()
