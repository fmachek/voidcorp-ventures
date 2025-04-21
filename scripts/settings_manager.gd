extends Node


var music_enabled: bool = true
var show_resource_gains: bool = true
var show_boost_zones: bool = true

signal music_enabled_changed(new_value: bool)
signal show_resource_gains_changed(new_value: bool)
signal show_boost_zones_changed(new_value: bool)


func set_music_enabled(new_value: bool):
	music_enabled = new_value
	emit_signal("music_enabled_changed", music_enabled)


func set_show_resource_gains(new_value: bool) -> void:
	show_resource_gains = new_value
	emit_signal("show_resource_gains_changed", show_resource_gains)


func set_show_boost_zones(new_value: bool) -> void:
	show_boost_zones = new_value
	emit_signal("show_boost_zones_changed", show_boost_zones)
