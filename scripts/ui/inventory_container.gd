extends VBoxContainer
class_name InventoryContainer


@onready var planet_ui: PlanetUI = $"/root/Game/UILayer/GameUI/PlanetUI"
@onready var label_container: VBoxContainer = $ScrollContainer/CurrencyLabelContainer

## Planet whose inventory is currently being displayed.
var current_planet: Planet = null

## Dictionary of resource labels.
var resource_labels: Dictionary = {}


func _ready() -> void:
	planet_ui.connect("planet_changed", _on_planet_changed)
	hide()


## Disconnects signals from the previously loaded planet and
## connects the new ones. The inventory UI is also reloaded.
func _on_planet_changed(new_planet: Planet) -> void:
	# Disconnect old signals from old loaded planet
	if current_planet != null:
		if current_planet.inventory.is_connected("new_resource_added", _on_new_resource_added):
			current_planet.inventory.disconnect("new_resource_added", _on_new_resource_added)
		if current_planet.inventory.is_connected("resource_removed", _on_resource_removed):
			current_planet.inventory.disconnect("resource_removed", _on_resource_removed)
	current_planet = new_planet
	# Free the old labels
	var labels = label_container.get_children()
	for label in labels:
		label.queue_free()
	resource_labels.clear()
	load_new_inventory()
	# Connect new signals
	current_planet.inventory.connect("new_resource_added", _on_new_resource_added)
	current_planet.inventory.connect("resource_removed", _on_resource_removed)


## Loads the inventory of the newly loaded planet.
func load_new_inventory() -> void:
	if not current_planet:
		return
	
	hide()
	
	var inventory: Inventory = current_planet.inventory
	var resources: Array[ResourceCurrency] = inventory.inventory
	
	for resource: ResourceCurrency in resources:
		create_new_label(resource)


## Creates a new resource label and adds it to the UI.
func create_new_label(resource: ResourceCurrency) -> void:
	var label: InventoryResourceLabel = InventoryResourceLabel.new(resource)
	label_container.add_child(label)
	resource_labels[resource.name] = label
	if len(resource_labels) > 0 and not visible:
		show()


## Adds a new label for a resource if the resource isn't in the UI yet.
func _on_new_resource_added(new_resource: ResourceCurrency) -> void:
	if not new_resource.name in resource_labels:
		create_new_label(new_resource)


## Removes a resource label assigned to a given resource.
func _on_resource_removed(resource: ResourceCurrency) -> void:
	if resource.name in resource_labels:
		var label: InventoryResourceLabel = resource_labels[resource.name]
		label.queue_free()
		resource_labels.erase(resource.name)
	if len(resource_labels) == 0:
		hide()
