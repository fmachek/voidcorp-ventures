extends Node
class_name UpgradeConnection
## This class represents an UI element which is displayed in the upgrade UI
## to indicate whether the previous [Upgrade] is unlocked.

## Button used to unlock the [Upgrade] this [UpgradeConnection] monitors.
@export var upgrade_button: UpgradeButton

## Connects to the upgrade button's 'upgraded' signal.
func _ready() -> void:
	if upgrade_button != null:
		upgrade_button.connect('upgraded', _on_upgrade_unlocked)

## This function handles the [Upgrade] unlock.
## The texture changes to indicate that the [Upgrade] is unlocked.
func _on_upgrade_unlocked():
	var unlocked_texture = load("res://assets/ui/upgrades/connection.png")
	self.texture = unlocked_texture
