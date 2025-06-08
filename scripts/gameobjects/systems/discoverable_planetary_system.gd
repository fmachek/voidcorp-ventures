extends PlanetarySystem
class_name DiscoverablePlanetarySystem


## Indicates if the system has been discovered or not.
var is_discovered: bool = false
## Indicates if the system is being unlocked or not.
var is_unlocking: bool = false

## The discovery progress out of 100.
var discovery_progress: int = 0
## The price of discovery.
var discovery_price: int = 1500

# Onready variables
@onready var discovery_timer: Timer = $DiscoveryTimer
@onready var unlock_container: VBoxContainer = $Panel/UnlockContainer
@onready var cloud_sprite: AnimatedSprite2D = $CloudSprite
@onready var progress_bar: ProgressBar = $Panel/UnlockContainer/ProgressBar
@onready var discover_label: Label = $Panel/UnlockContainer/DiscoverLabel

# Root Game variables
@onready var button_click_player = $"/root/Game/ButtonClickPlayer"

# Signals
## Emitted when the system is discovered.
signal discovered()


func _ready() -> void:
	super()
	update_discovery_price(discovery_price)
	connect_upgrade_signals()
	
	connect("zoomed_in", _on_zoomed_in)
	connect("zoomed_out", _on_zoomed_out)
	
	unlock_container.hide()
	cloud_sprite.play()
	
	var rand_rots = [0, 90, 180, 270]
	cloud_sprite.rotation = deg_to_rad(rand_rots.pick_random())


## Loads the system content. Usually, a star along with planets are generated.
## Sometimes though, a black hole can generate instead.
## The spaceship repair spawner starts spawning.
func load_system():
	var chance: int = randi_range(0, 10)
	if chance == 0:
		load_black_hole()
	else:
		planet_amount = randi_range(4, 5)
		load_star()
		load_planets()
		var planet_indicator_panel: PlanetIndicatorPanel = $Panel/PlanetIndicatorPanel
		planet_indicator_panel.load_system(self)
	
	var repair_spawner: SpaceshipRepairSpawner = $SpaceshipRepairSpawner
	repair_spawner.start_spawning()


## The system is discovered.
func discover():
	is_discovered = true
	unlock_container.hide()
	load_system()
	var camera: MainCamera = $"/root/Game/MainCamera"
	_on_zoom_changed(camera.zoom.x)
	cloud_sprite.queue_free()
	cloud_sprite = null
	discovery_timer.stop()
	emit_signal("discovered")


## When the discovery timer times out, progress is added. When progress hits
## 100, the system is discovered. An animation is played.
func _on_discovery_timer_timeout():
	discovery_progress += 4
	progress_bar.value = discovery_progress
	if discovery_progress == 100:
		discover()
		var disappearing_cloud_sprite: AnimatedSprite2D = $DisappearingCloudSprite
		disappearing_cloud_sprite.visible = true
		disappearing_cloud_sprite.play()
		await disappearing_cloud_sprite.animation_finished
		disappearing_cloud_sprite.queue_free()


## Connects upgrade unlocked signals.
func connect_upgrade_signals():
	var discovery_price_upgrade1 = UpgradeManager.upgrades[5]
	discovery_price_upgrade1.connect("unlocked", lower_discovery_price)
	var discovery_price_upgrade2 = UpgradeManager.upgrades[14]
	discovery_price_upgrade2.connect("unlocked", lower_discovery_price)
	var discovery_price_upgrade3 = UpgradeManager.upgrades[15]
	discovery_price_upgrade3.connect("unlocked", lower_discovery_price)


## Updates the discovery price.
func update_discovery_price(new_price: int):
	discovery_price = new_price
	var discover_label: Label = $Panel/UnlockContainer/DiscoverLabel
	discover_label.text = "Discover ($" + str(discovery_price) + ")"


## Lowers the discovery price by $250.
func lower_discovery_price() -> void:
	var new_price: int = discovery_price - 250
	update_discovery_price(new_price)


## Handles camera zoom in.
func _on_zoomed_in() -> void:
	if is_discovered:
		zoom_in()
	else:
		unlock_container.hide()


## Handles camera zoom out.
func _on_zoomed_out() -> void:
	if is_discovered:
		zoom_out()
	else:
		unlock_container.show()


## Handles left mouse click. When the system is clicked,
## and it has not been discovered, camera is not zoomed in and
## the system isn't being unlocked already, the money is spent.
## If the player can't afford it, nothing happens instead.
func handle_left_click() -> void:
	if not is_discovered and not is_zoomed_in and not is_unlocking:
		var has_money: bool = GameManager.spend_money(discovery_price)
		if has_money:
			start_unlocking()


## Starts unlocking the system.
func start_unlocking() -> void:
	is_unlocking = true
	discovery_timer.start()
	discover_label.hide()
	progress_bar.show()
	set_normal_stylebox()
	button_click_player.play()


## Handles mouse enter.
func handle_mouse_enter() -> void:
	if not is_discovered and not is_zoomed_in and not is_unlocking:
		set_selected_stylebox()
	elif is_discovered and not is_zoomed_in:
		show_tooltip()


## Handles mouse exit.
func handle_mouse_exit() -> void:
	if not is_discovered:
		set_normal_stylebox()
	elif is_discovered and not is_zoomed_in:
		hide_tooltip()


## Sets the stylebox to normal.
func set_normal_stylebox():
	stylebox.border_color = Color("#0000004a")
	discover_label.add_theme_color_override("font_color", Color.WHITE)


## Sets the stylebox to selected.
func set_selected_stylebox():
	if GameManager.has_enough_money(discovery_price):
		stylebox.border_color = Color.GREEN
		discover_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		stylebox.border_color = Color.RED
		discover_label.add_theme_color_override("font_color", Color.RED)
