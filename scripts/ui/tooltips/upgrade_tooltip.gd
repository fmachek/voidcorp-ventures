extends Control
class_name UpgradeTooltip

@onready var upgrade_name_label: Label = $Panel/MarginContainer/VBoxContainer/UpgradeNameLabel
@onready var description_label: Label = $Panel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var panel: Panel = $Panel


func _process(delta: float) -> void:
	if visible:
		var panel_height = panel.size.y
		var mouse_pos = get_global_mouse_position()
		
		var new_pos = mouse_pos
		
		var upgrade_ui = $".."
		var limit_y = upgrade_ui.global_position.y + upgrade_ui.size.y
		
		if new_pos.y + panel_height > limit_y:
			new_pos.y -= panel_height
		
		global_position = new_pos


func load_upgrade(upgrade: Upgrade) -> void:
	upgrade_name_label.text = upgrade.upgrade_name
	description_label.text = upgrade.description
