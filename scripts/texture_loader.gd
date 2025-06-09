extends Node


var normal_planet_textures = [
	preload("res://assets/sprites/planets/normal/rocky1.png"),
	preload("res://assets/sprites/planets/normal/rocky2.png"),
	preload("res://assets/sprites/planets/normal/rocky3.png"),
	preload("res://assets/sprites/planets/normal/rocky4.png"),
	preload("res://assets/sprites/planets/normal/rocky5.png"),
	preload("res://assets/sprites/planets/normal/rocky6.png"),
	preload("res://assets/sprites/planets/normal/rocky7.png"),
	preload("res://assets/sprites/planets/normal/rocky8.png"),
	preload("res://assets/sprites/planets/normal/rocky9.png"),
	preload("res://assets/sprites/planets/normal/rocky10.png"),
	preload("res://assets/sprites/planets/normal/rocky11.png"),
	preload("res://assets/sprites/planets/normal/sandy.png")
]

var hot_planet_textures = [
	preload("res://assets/sprites/planets/hot/hot1.png"),
	preload("res://assets/sprites/planets/hot/hot2.png"),
	preload("res://assets/sprites/planets/hot/hot3.png"),
	preload("res://assets/sprites/planets/hot/hot4.png"),
	preload("res://assets/sprites/planets/hot/hot5.png"),
	preload("res://assets/sprites/planets/hot/hot6.png"),
	preload("res://assets/sprites/planets/hot/hot7.png")
]

var cold_planet_textures = [
	preload("res://assets/sprites/planets/cold/cold1.png"),
	preload("res://assets/sprites/planets/cold/cold2.png"),
	preload("res://assets/sprites/planets/cold/cold3.png"),
	preload("res://assets/sprites/planets/cold/cold4.png"),
	preload("res://assets/sprites/planets/cold/cold5.png"),
	preload("res://assets/sprites/planets/cold/cold6.png"),
	preload("res://assets/sprites/planets/cold/cold7.png"),
	preload("res://assets/sprites/planets/cold/cold8.png"),
	preload("res://assets/sprites/planets/cold/cold9.png"),
	preload("res://assets/sprites/planets/cold/cold10.png")
]

var life_planet_textures = [
	preload("res://assets/sprites/planets/life/life1.png"),
	preload("res://assets/sprites/planets/life/life2.png"),
	preload("res://assets/sprites/planets/life/life3.png"),
	preload("res://assets/sprites/planets/life/life4.png"),
	preload("res://assets/sprites/planets/life/life5.png"),
	preload("res://assets/sprites/planets/life/life6.png")
]

var star_textures = [
	preload("res://assets/sprites/stars/blue.png"),
	preload("res://assets/sprites/stars/orange.png"),
	preload("res://assets/sprites/stars/red.png"),
	preload("res://assets/sprites/stars/white.png"),
	preload("res://assets/sprites/stars/yellow.png")
]

var trader_textures = [
	load("res://assets/sprites/traderspaceship/trader_spaceship_cyan.png"),
	load("res://assets/sprites/traderspaceship/trader_spaceship_gray.png"),
	load("res://assets/sprites/traderspaceship/trader_spaceship_green.png"),
	load("res://assets/sprites/traderspaceship/trader_spaceship_pink.png"),
	load("res://assets/sprites/traderspaceship/trader_spaceship_red.png")
]


func load_random_texture(array: Array) -> Texture2D:
	if array.size() == 0:
		return null
	return array.pick_random()


func load_random_star_texture() -> Texture2D:
	return load_random_texture(star_textures)


func load_random_normal_planet_texture() -> Texture2D:
	return load_random_texture(normal_planet_textures)


func load_random_hot_planet_texture() -> Texture2D:
	return load_random_texture(hot_planet_textures)


func load_random_cold_planet_texture() -> Texture2D:
	return load_random_texture(cold_planet_textures)


func load_random_life_planet_texture() -> Texture2D:
	return load_random_texture(life_planet_textures)


func load_random_trader_spaceship_texture() -> Texture2D:
	return load_random_texture(trader_textures)
