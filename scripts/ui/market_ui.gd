extends Control
class_name MarketUI

@onready var button_click_player: AudioStreamPlayer = $"/root/Game/ButtonClickPlayer"
@onready var resource_vbox_container: VBoxContainer = $MainMarginContainer/GridContainer/LeftPanel/ResourceScrollContainer/ResourceVBoxContainer
@onready var resource_name_label: Label = $MainMarginContainer/GridContainer/RightPanel/MarginContainer/VBoxContainer/ResourceContainer/ResourceNameLabel
@onready var resource_icon: TextureRect = $MainMarginContainer/GridContainer/RightPanel/MarginContainer/VBoxContainer/ResourceContainer/ResourceIcon
@onready var sell_spin_box: SpinBox = $MainMarginContainer/GridContainer/RightPanel/MarginContainer/VBoxContainer/SellContainer/HBoxContainer/SellSpinBox
var graph: Graph
var graph_resource_name: String

var resource_container_scene = preload("res://scenes/ui/market/MarketResourceContainer.tscn")


func _ready() -> void:
	load_resource_container()
	
	graph = Graph.new(250, 150, 60, 5, 0, 100, "Month", "Price")
	var graph_container = $MainMarginContainer/GridContainer/RightPanel/MarginContainer/VBoxContainer/GraphContainer
	graph.position = Vector2(0, 500)
	graph_container.add_child(graph)
	
	PriceHistoryManager.connect("price_changed", _on_price_changed)
	
	set_graph_resource("Atomsteel")
	
	GamePauseManager.connect("game_paused", close_if_opened)
	GameManager.connect("game_lost", hide)


## Close the market UI when the close button is clicked.
func _on_close_button_pressed() -> void:
	button_click_player.play()
	mouse_filter = MOUSE_FILTER_IGNORE
	hide()


## Loads all currencies in the left panel.
func load_resource_container() -> void:
	var player_resources = GameManager.resources
	for resource_name in player_resources:
		var resource: ResourceCurrency = player_resources[resource_name]
		var resource_container: MarketResourceContainer = resource_container_scene.instantiate()
		resource_vbox_container.add_child(resource_container)
		resource_container.load_resource(resource)
		resource_container.connect("clicked", _on_resource_container_clicked)


## Load last 5 months of the price history on the graph.
func _on_price_changed(resource_name: String, new_price: int) -> void:
	if resource_name == graph_resource_name:
		graph.load_points(PriceHistoryManager.get_last_5_months_points(resource_name))


## Set the graph resource to the one detecting the click.
func _on_resource_container_clicked(container: MarketResourceContainer) -> void:
	var resource: ResourceCurrency = container.resource
	set_graph_resource(resource.name)


## Sets the resource being displayed on the graph.
func set_graph_resource(resource_name: String) -> void:
	if graph_resource_name != resource_name:
		# Check the current player resource, disconnect the signal
		if graph_resource_name:
			var resource: ResourceCurrency = GameManager.resources[graph_resource_name]
			if resource.is_connected("amount_changed", _on_graph_resource_amount_changed):
				resource.disconnect("amount_changed", _on_graph_resource_amount_changed)
		
		graph_resource_name = resource_name
		
		# Connect the signal from the new player currency
		var new_resource: ResourceCurrency = GameManager.resources[graph_resource_name]
		new_resource.connect("amount_changed", _on_graph_resource_amount_changed)
		
		_on_graph_resource_amount_changed(new_resource.amount)
		
		graph.load_points(PriceHistoryManager.get_last_5_months_points(graph_resource_name))
		resource_name_label.text = graph_resource_name + " Price History"
		
		# Load the resource icon texture
		load_resource_icon(graph_resource_name)


## Sell the resource. The amount is the current spin box value.
func _on_sell_button_pressed() -> void:
	var value = sell_spin_box.value
	GameManager.sell_resource(graph_resource_name, value)


## Change the spin box maximum value when the player resource amount changes.
func _on_graph_resource_amount_changed(new_amount: int) -> void:
	sell_spin_box.max_value = new_amount


## Close the UI if it's open.
func close_if_opened() -> void:
	if visible:
		hide()


## When the "Max" button is clicked, set the amount of the resource
## being sold to the maximum amount available.
func _on_max_button_pressed() -> void:
	sell_spin_box.value = sell_spin_box.max_value


## Loads a resource icon from the resources based on the resource name.
func load_resource_icon(resource_name: String) -> void:
	var texture: Texture2D = ResourceTextureLoader.get_resource_texture(resource_name)
	resource_icon.texture = texture


func play_button_click_sound() -> void:
	$"/root/Game/ButtonClickPlayer".play()
