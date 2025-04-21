extends Node2D
class_name BoostZone


## The boost zone radius.
var zone_radius: int = 120
## The speed boost amount.
var speed_boost: int = 50
## The meteor slowdown amount.
var meteor_slowdown: int = 5

## Tells if the boost zone should be shown.
var is_draw_allowed: bool

## Tells if the meteor slowdown upgrade is unlocked.
var can_slow_meteors_down: bool = false

@onready var area2D: Area2D = $Area2D
@onready var shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var particles: CPUParticles2D = $Particles


func _ready() -> void:
	shape.shape.radius = zone_radius
	is_draw_allowed = SettingsManager.show_boost_zones
	SettingsManager.connect("show_boost_zones_changed", _on_show_boost_zones_changed)
	
	if is_draw_allowed:
		particles.emitting = true
	else:
		particles.emitting = false
	
	connect_upgrades()


## Draws the boost zone.
func _draw() -> void:
	if is_draw_allowed:
		draw_circle(Vector2.ZERO, zone_radius - 1, Color("#fa02c420"))
		draw_arc(Vector2.ZERO, zone_radius, 0, TAU, 128, Color("#fa02c450"), 2)


## Handles Area2D enter detections. If a spaceship enters it, it is sped up.
## If a meteor enters it and the meteor slowdown upgrade is unlocked,
## the meteor is slowed down.
func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Spaceship:
		parent.add_boost_speed(speed_boost)
	elif parent is Meteor:
		if can_slow_meteors_down:
			parent.slow_down(meteor_slowdown)


## Handles Area2D exit detections. If a spaceship exits it, it is slowed down.
## If a meteor exits it and the meteor slowdown upgrade is unlocked,
## the meteor is sped up.
func _on_area_2d_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Spaceship:
		parent.reduce_boost_speed(speed_boost)
	elif parent is Meteor:
		if can_slow_meteors_down:
			parent.speed_up(meteor_slowdown)


## Handles the show boost zones setting changes.
func _on_show_boost_zones_changed(new_value: bool) -> void:
	self.is_draw_allowed = new_value
	queue_redraw()
	if is_draw_allowed:
		particles.emitting = true
	else:
		particles.emitting = false


## Connects the upgrade signals, or applies them right away if they're unlocked.
func connect_upgrades() -> void:
	var range_upgrade: Upgrade = UpgradeManager.upgrades[17]
	if range_upgrade.is_unlocked:
		unlock_range_upgrade()
	else:
		range_upgrade.connect("unlocked", unlock_range_upgrade)
	
	var slowdown_upgrade: Upgrade = UpgradeManager.upgrades[18]
	if slowdown_upgrade.is_unlocked:
		unlock_slowdown_upgrade()
	else:
		slowdown_upgrade.connect("unlocked", unlock_slowdown_upgrade)


## Increases the boost zone radius.
func unlock_range_upgrade() -> void:
	zone_radius *= 1.3
	shape.shape.radius = zone_radius
	particles.emission_sphere_radius = zone_radius - 40
	queue_redraw()


## Unlocks the meteor slowdown upgrade.
func unlock_slowdown_upgrade():
	can_slow_meteors_down = true
