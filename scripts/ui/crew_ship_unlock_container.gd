extends MarginContainer
class_name CrewShipUnlockContainer


func _ready() -> void:
	UpgradeManager.connect("unlocked_crew_ships", queue_free)
	GameManager.connect("planets_owned_changed", update_progress)
	update_progress(GameManager.planets_owned)


func update_progress(new_amount: int) -> void:
	$VBoxContainer/Label.text = "Claim 3 planets to unlock meteor crew ships (" + str(new_amount) + "/3)"
