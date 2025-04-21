extends TextureButton
class_name UpgradeButton


@export var is_unlocked = false
@export var upgrade_id: int
@export var tooltip: UpgradeTooltip
signal upgraded()

@onready var label: Label = $Label


func _ready() -> void:
	if is_unlocked:
		set_unlocked_stylebox()
	var upgrade = UpgradeManager.upgrades[upgrade_id]
	load_upgrade(upgrade)


func _on_pressed() -> void:
	if not is_unlocked:
		var unlock_successful = UpgradeManager.unlock_upgrade(upgrade_id)
		if unlock_successful:
			is_unlocked = true
			emit_signal('upgraded')
			set_unlocked_stylebox()
			var split_text = label.text.split('\n')
			label.text = split_text[0] + '\n(Unlocked)'


func set_unlocked_stylebox():
	var unlocked_normal_texture = load("res://assets/ui/buttons/upgrade/unlocked/normal.png")
	var unlocked_hover_texture = load("res://assets/ui/buttons/upgrade/unlocked/hover.png")
	var unlocked_pressed_texture = load("res://assets/ui/buttons/upgrade/unlocked/pressed.png")
	texture_normal = unlocked_normal_texture
	texture_hover = unlocked_hover_texture
	texture_pressed = unlocked_pressed_texture


func load_upgrade(upgrade: Upgrade):
	var new_text = upgrade.upgrade_name
	new_text += '\n('
	var costs = upgrade.get_cost_string()
	new_text += costs + ')'
	label.text = new_text


func _on_mouse_entered() -> void:
	if tooltip:
		tooltip.load_upgrade(UpgradeManager.upgrades[upgrade_id])
		tooltip.show()


func _on_mouse_exited() -> void:
	if tooltip:
		tooltip.hide()
