extends Node
## This class represents a resource manager which can, for example, generate two random resources.

## Dictionary of common planet resources and their refined versions.
var planet_resources = {'Atomite': 'Atomsteel', 'Voidium Ore': 'Voidium Ingot', 'Solar Ore': 'Solar Ingot', 'Lunar Ore': 'Lunar Ingot'}
## Dictionary of cold planet resources and their refined versions.
var cold_planet_resources = {'Freezing Ore': 'Freezium', 'Iciclite': 'Iciclium'}
## Dictionary of hot planet resources and their refined versions.
var hot_planet_resources = {'Ashium Ore': 'Flamesteel', 'Molten Ore': 'Molten Ingot'}
## Array of rare/special resources.
var special_resources = ['Warpite', 'Gravitium']


## Returns an array of all resources.
func get_all_resources() -> Array:
	var all_resources = []
	
	var resource_dicts = [planet_resources, cold_planet_resources, hot_planet_resources]
	for resource_dict in resource_dicts:
		for key in resource_dict.keys():
			all_resources.append(key)
			all_resources.append(resource_dict[key])

	for resource in special_resources:
		all_resources.append(resource)
	
	return all_resources


## Returns an array of common planet resources.
func get_planet_resources():
	return resource_dict_to_array(planet_resources)


## Returns an array of cold planet resources.
func get_cold_planet_resources():
	return resource_dict_to_array(cold_planet_resources)


## Returns an array of hot planet resources.
func get_hot_planet_resources():
	return resource_dict_to_array(hot_planet_resources)


## Turns a dictionary of resources into an array.
func resource_dict_to_array(dict: Dictionary) -> Array:
	var resources = []
	for key in dict.keys():
		resources.append(key)
		resources.append(dict[key])
	return resources
	
## This function picks two random resources from the array of planet resources
## and returns a new array with the two resources. A random amount is assigned
## to them (between 60 and 100).
func choose_normal_resources() -> Array:
	var resource_pool = []
	for key in planet_resources.keys():
		resource_pool.append(key)
	var resources = []
	
	var random_index = randi_range(0, len(resource_pool) - 1)
	var resource1_name = resource_pool[random_index]
	
	resource_pool.remove_at(random_index)
	
	var random_index2 = randi_range(0, len(resource_pool) - 1)
	var resource2_name = resource_pool[random_index2]
	
	var resource1_amount = randi_range(60, 100)
	var resource2_amount = randi_range(60, 100)
	
	var resource1 = ResourceCurrency.new(resource1_name, resource1_amount)
	var resource2 = ResourceCurrency.new(resource2_name, resource2_amount)
	
	resources.append(resource1)
	resources.append(resource2)
	
	return resources


## Picks one common resource and one cold planet resource. Returns an array
## of the two resources. The common resource is assigned an amount between
## 60 and 100, and the cold resource is assigned an amount between 80 and 100.
func choose_cold_resources() -> Array:
	var normal_resource_pool = planet_resources.keys()
	var normal_resource_name = normal_resource_pool.pick_random()
	
	var cold_resource_pool = cold_planet_resources.keys()
	var cold_resource_name = cold_resource_pool.pick_random()
	
	var normal_resource = ResourceCurrency.new(normal_resource_name, randi_range(60, 100))
	var cold_resource = ResourceCurrency.new(cold_resource_name, randi_range(80, 100))
	
	return [normal_resource, cold_resource]


## Picks one common resource and one hot planet resource. Returns an array
## of the two resources. The common resource is assigned an amount between
## 60 and 100, and the hot resource is assigned an amount between 80 and 100.
func choose_hot_resources() -> Array:
	var normal_resource_pool = planet_resources.keys()
	var normal_resource_name = normal_resource_pool.pick_random()
	
	var hot_resource_pool = hot_planet_resources.keys()
	var hot_resource_name = hot_resource_pool.pick_random()
	
	var normal_resource = ResourceCurrency.new(normal_resource_name, randi_range(60, 100))
	var hot_resource = ResourceCurrency.new(hot_resource_name, randi_range(80, 100))
	
	return [normal_resource, hot_resource]


## Returns the name of the refined version of a given resource.
func get_refined_resource_name(resource: ResourceCurrency):
	var resource_name = resource.name
	if resource_name in planet_resources:
		return planet_resources[resource_name]
	elif resource_name in cold_planet_resources:
		return cold_planet_resources[resource_name]
	elif resource_name in hot_planet_resources:
		return hot_planet_resources[resource_name]
	else:
		return null
