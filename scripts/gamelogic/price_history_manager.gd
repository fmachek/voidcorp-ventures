extends Node

# History of the prices of resources
var history: Dictionary = {
	#"resource_name": {
	#   1: 150,
	#   2: 164,
	#   ...
	#},
}

# Default prices for all resources
var default_prices = {
	# Normal resources
	"Atomite": 35,
	"Atomsteel": 45,
	"Voidium Ore": 35,
	"Voidium Ingot": 45,
	"Solar Ore": 35,
	"Solar Ingot": 45,
	"Lunar Ore": 35,
	"Lunar Ingot": 45,
	# Cold planet resources - a bit more expensive
	"Freezing Ore": 45,
	"Freezium": 55,
	"Iciclite": 45,
	"Iciclium": 55,
	# Hot planet resources - even more expensive
	"Ashium Ore": 55,
	"Flamesteel": 60,
	"Molten Ore": 55,
	"Molten Ingot": 60,
	# Special resources - very expensive and rare
	"Warpite": 200,
	"Gravitium": 200
}

## Dictionary storing the demand for all resources.
var resource_demand: Dictionary = {}

## Controls how much the demand changes the current price.
var fluctuation: float = 0.01
## Minimum threshold of resource demand
var minimum_demand: int = 10
## Maximum threshold of resource demand
var maximum_demand: int = 100

## Time manager, measuring time passed.
@onready var time_manager: TimeManager = $"/root/Game/TimeManager"

## Emitted when the demand for a resource changes.
signal demand_changed(resource_name: String, new_demand: int)
## Emitted when the price for a resource changes.
signal price_changed(resource_name: String, new_price: int)


func _ready() -> void:
	time_manager.connect("month_changed", calculate_new_prices)
	reset()


## Initializes the history of prices.
func initialize_history() -> void:
	var month: int = 1
	var resources = ResourceManager.get_all_resources()
	
	# Load the default prices in the history
	for resource_name in resources:
		calculate_price(resource_name, month)


## Initializes the demand for resources.
func initialize_demand() -> void:
	var resources = ResourceManager.get_all_resources()
	for resource_name in resources:
		# Resources start at 100 demand by default
		resource_demand[resource_name] = 100


## Every month that passes, new demand and prices are calculated.
func _on_month_changed(new_month: int) -> void:
	calculate_new_demand()
	calculate_new_prices(new_month)


## Calculates new demand for all resources.
func calculate_new_demand() -> void:
	var resources = ResourceManager.get_all_resources()
	for resource_name in resources:
		var demand = resource_demand[resource_name]
		var difference
		var variety = 5
		if demand >= 25:
			difference = randi_range(-variety, variety)
		else:
			difference = randi_range(0, variety)
		change_resource_demand(resource_name, difference)


## Calculates new prices for all resources.
func calculate_new_prices(new_month: int) -> void:
	var resources = ResourceManager.get_all_resources()
	for resource_name in resources:
		calculate_price(resource_name, new_month)


## Calculates a new price for a given resource.
func calculate_price(resource_name: String, new_month: int) -> void:
	var default_price = default_prices[resource_name]
	var demand = resource_demand[resource_name]
	
	# Random fluctuations of 1/10 of the default price
	var random = randi_range(-default_price/10, default_price/10)
	
	# Price increases based on the demand.
	var new_price: int = default_price * (1 + demand * fluctuation) + random
	
	if new_price < default_price: # Minimum price is default price
		new_price = default_price
	if not resource_name in history:
		history[resource_name] = {}
	history[resource_name][new_month] = new_price
	emit_signal("price_changed", resource_name, new_price)


## Change the demand for a given resource.
func change_resource_demand(resource_name: String, amount: int) -> void:
	var demand: int = resource_demand[resource_name]
	if demand + amount < minimum_demand:
		demand = minimum_demand
	elif demand + amount > maximum_demand:
		demand = maximum_demand
	else:
		demand = demand + amount
	resource_demand[resource_name] = demand
	emit_signal("demand_changed", demand)


## Generates points for the UI graph displaying the price history.
func get_last_5_months_points(resource_name: String) -> Array[Vector2]:
	var resource_history = history[resource_name]
	var months: Array = resource_history.keys()
	var points: Array[Vector2] = []
	months.sort()
	months.reverse()
	var months_checked = 0
	for month in months:
		if months_checked == len(months) or months_checked == 5:
			break
		var price = resource_history[month]
		points.append(Vector2(month, price))
		months_checked += 1
	points.reverse()
	return points


## Gets the current price for a given resource.
func get_current_price(resource_name: String) -> int:
	var current_month = time_manager.current_month
	var current_price = history[resource_name][current_month]
	return current_price


## Resets itself.
func reset() -> void:
	history.clear()
	resource_demand.clear()
	initialize_demand()
	initialize_history()
