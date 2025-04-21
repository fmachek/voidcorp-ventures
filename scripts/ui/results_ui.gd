extends Control
class_name ResultsUI


@onready var months_passed_label: Label = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/VBoxContainer/Column/MonthsPassedLabel
@onready var total_money_gained_label: Label = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/VBoxContainer/Column/TotalMoneyGainedLabel
@onready var planets_owned_label: Label = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/VBoxContainer/Column/PlanetsOwnedLabel
@onready var upgrades_unlocked_label: Label = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/VBoxContainer/Column/UpgradesUnlockedLabel


func load_results(months_passed: int, total_money_gained: int, planets_owned: int, upgrades_unlocked: int) -> void:
	months_passed_label.text = "Months Passed: " + str(months_passed)
	total_money_gained_label.text = "Total Money Gained: " + str(total_money_gained)
	planets_owned_label.text = "Planets Owned: " + str(planets_owned)
	upgrades_unlocked_label.text = "Upgrades Unlocked: " + str(upgrades_unlocked)


func _on_menu_button_pressed() -> void:
	$"/root/Game/ButtonClickPlayer".play()
	GameManager.reset_game()
	queue_free()
