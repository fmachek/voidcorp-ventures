class_name TradeOfferUI
extends ColorRect


var player_resource: ResourceCurrency
var r1: ResourceCurrency
var r2: ResourceCurrency


func _ready() -> void:
	hide()


## Connects some signals from the trader spaceship.
func connect_offer_signals(trader_spaceship: TraderSpaceship) -> void:
	trader_spaceship.connect("offer_timeout", queue_free)
	trader_spaceship.connect("offer_accepted", queue_free)
	trader_spaceship.connect("offer_declined", queue_free)


## Loads a trade offer.
func load_offer(r1: ResourceCurrency, r2: ResourceCurrency) -> void:
	$MarginContainer/VBoxContainer/TradeOfferContainer/ResourceTexture1.texture = ResourceTextureLoader.get_resource_texture(r1.name)
	$MarginContainer/VBoxContainer/TradeOfferContainer/ResourceTexture2.texture = ResourceTextureLoader.get_resource_texture(r2.name)
	$MarginContainer/VBoxContainer/TradeOfferContainer/ResourceLabel1.text = str(r1.amount)
	$MarginContainer/VBoxContainer/TradeOfferContainer/ResourceLabel2.text = str(r2.amount)
	
	player_resource = GameManager.resources[r1.name]
	player_resource.connect("amount_changed", update_r1_label_color)
	
	self.r1 = r1
	self.r2 = r2
	
	update_r1_label_color(player_resource.amount)


## Updates the text color of the label displaying the player's resource in the offer.
## It signifies whether the player has enough of it or not.
func update_r1_label_color(amount: int) -> void:
	var r1_label: Label = $MarginContainer/VBoxContainer/TradeOfferContainer/ResourceLabel1
	if amount >= r1.amount:
		r1_label.add_theme_color_override("font_color", "#ffffff")
	else:
		r1_label.add_theme_color_override("font_color", "#cb0000")
