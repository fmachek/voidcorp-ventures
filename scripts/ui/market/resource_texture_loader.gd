extends Node
class_name ResourceTextureLoader


static var resource_textures: Dictionary = {
	"Ashium Ore": preload("res://assets/ui/resources/ashium_ore.png"),
	"Atomite": preload("res://assets/ui/resources/atomite.png"),
	"Atomsteel": preload("res://assets/ui/resources/atomsteel.png"),
	"Flamesteel": preload("res://assets/ui/resources/flamesteel.png"),
	"Freezing Ore": preload("res://assets/ui/resources/freezing_ore.png"),
	"Freezium": preload("res://assets/ui/resources/freezium.png"),
	"Gravitium": preload("res://assets/ui/resources/gravitium.png"),
	"Iciclite": preload("res://assets/ui/resources/iciclite.png"),
	"Iciclium": preload("res://assets/ui/resources/iciclium.png"),
	"Lunar Ingot": preload("res://assets/ui/resources/lunar_ingot.png"),
	"Lunar Ore": preload("res://assets/ui/resources/lunar_ore.png"),
	"Molten Ingot": preload("res://assets/ui/resources/molten_ingot.png"),
	"Molten Ore": preload("res://assets/ui/resources/molten_ore.png"),
	"Solar Ingot": preload("res://assets/ui/resources/solar_ingot.png"),
	"Solar Ore": preload("res://assets/ui/resources/solar_ore.png"),
	"Voidium Ingot": preload("res://assets/ui/resources/voidium_ingot.png"),
	"Voidium Ore": preload("res://assets/ui/resources/voidium_ore.png"),
	"Warpite": preload("res://assets/ui/resources/warpite.png")
}


static func get_resource_texture(resource_name: String) -> Texture2D:
	if not resource_name in resource_textures.keys():
		return null
	return resource_textures[resource_name]
