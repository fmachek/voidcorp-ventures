extends Label
class_name InventoryResourceLabel


var resource: ResourceCurrency


func _init(resource: ResourceCurrency) -> void:
	self.resource = resource
	self.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	self.add_theme_font_size_override("font_size", 4)
	self.add_theme_color_override("font_color", Color("#bcbcbc"))
	resource.connect("amount_changed", update_text)
	update_text(resource.amount)


func update_text(new_amount: int) -> void:
	text = str(new_amount) + " " + resource.name
