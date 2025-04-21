extends Label
class_name MoneyLabel


func _ready() -> void:
	GameManager.connect("money_changed", _handle_money_changed)
	update_text(GameManager.money)


func _handle_money_changed(new_money: int):
	update_text(new_money)


func update_text(money: int):
	self.text = "$" + str(money)
	if money == 0:
		add_theme_color_override("font_color", Color.RED)
	else:
		add_theme_color_override("font_color", Color("#00b300"))
