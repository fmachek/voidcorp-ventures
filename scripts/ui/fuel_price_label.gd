extends Label
class_name FuelPriceLabel


func _ready() -> void:
	add_theme_font_size_override("font_size", 8)


func _process(delta: float) -> void:
	if self.visible:
		self.position = get_viewport().get_mouse_position() + Vector2(0, -self.size.y)


func show_price(price: int) -> void:
	self.visible = true
	self.text = "$" + str(price)
	
	if GameManager.has_enough_money(price):
		add_theme_color_override('font_color', Color(0, 200, 0))
	else:
		add_theme_color_override('font_color', Color(200, 0, 0))
