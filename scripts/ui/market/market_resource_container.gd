extends MarginContainer
class_name MarketResourceContainer


@onready var resource_name_label: Label = $MarginContainer/HBoxContainer/ResourceNameLabel
@onready var resource_amount_label: Label = $MarginContainer/ResourceAmountLabel
@onready var background: ColorRect = $BackgroundRect
@onready var resource_texture_rect: TextureRect = $MarginContainer/HBoxContainer/ResourceTextureRect

var resource: ResourceCurrency

signal clicked(container: MarketResourceContainer)


func load_resource(resource: ResourceCurrency) -> void:
	self.resource = resource
	resource_name_label.text = resource.name
	if not resource.is_connected("amount_changed", set_resource_amount):
		resource.connect("amount_changed", set_resource_amount)
	set_resource_amount(resource.amount)
	load_texture()


func set_resource_amount(resource_amount: int) -> void:
	resource_amount_label.text = str(resource_amount)


func _on_mouse_entered() -> void:
	background.color = Color("#00000083")


func _on_mouse_exited() -> void:
	background.color = Color("#00000054")


func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("clicked", self)


func load_texture() -> void:
	var resource_name = resource.name.replace(" ", "_")
	var texture = load("res://assets/ui/resources/" + resource_name + ".png")
	if texture:
		resource_texture_rect.texture = texture
	else:
		resource_texture_rect.texture = null
