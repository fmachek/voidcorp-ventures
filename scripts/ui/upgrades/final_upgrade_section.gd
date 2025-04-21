extends MarginContainer
class_name FinalUpgradeSection


@onready var req1: HBoxContainer = $MainContainer/RequirementSectionContainer/RequirementColumn1/RequirementContainer1
@onready var req2: HBoxContainer = $MainContainer/RequirementSectionContainer/RequirementColumn1/RequirementContainer2
@onready var req3: HBoxContainer = $MainContainer/RequirementSectionContainer/RequirementColumn1/RequirementContainer3
@onready var req4: HBoxContainer = $MainContainer/RequirementSectionContainer/RequirementColumn2/RequirementContainer1
@onready var req5: HBoxContainer = $MainContainer/RequirementSectionContainer/RequirementColumn2/RequirementContainer2
@onready var req6: HBoxContainer = $MainContainer/RequirementSectionContainer/RequirementColumn2/RequirementContainer3


func _ready() -> void:
	connect_signals()
	
	update_req_1(UpgradeManager.unlocked_upgrades)
	update_req_2(GameManager.planets_owned)
	update_req_3(GameManager.money)
	update_req_4(GameManager.resources["Molten Ingot"].amount)
	update_req_5(GameManager.resources["Warpite"].amount)
	update_req_6(GameManager.resources["Gravitium"].amount)


func connect_signals() -> void:
	WinRequirementHandler.connect("req_fulfilled", handle_req_fulfilled)
	WinRequirementHandler.connect("req_unfulfilled", handle_req_unfulfilled)
	
	WinRequirementHandler.connect("req_1_updated", update_req_1)
	WinRequirementHandler.connect("req_2_updated", update_req_2)
	WinRequirementHandler.connect("req_3_updated", update_req_3)
	WinRequirementHandler.connect("req_4_updated", update_req_4)
	WinRequirementHandler.connect("req_5_updated", update_req_5)
	WinRequirementHandler.connect("req_6_updated", update_req_6)
	
	WinRequirementHandler.connect("all_requirements_fulfilled", allow_win)
	WinRequirementHandler.connect("requirements_unfulfilled", disallow_win)


func handle_req_fulfilled(index: int) -> void:
	if index < 1 or index > 6:
		return
	var req_name = "req" + str(index)
	var req = get(req_name)
	var req_indicator: TextureRect = req.get_node("RequirementIndicator")
	req_indicator.texture = load("res://assets/ui/upgrades/final_upgrade/requirements/unlocked.png")


func handle_req_unfulfilled(index: int) -> void:
	if index < 1 or index > 6:
		return
	var req_name = "req" + str(index)
	var req = get(req_name)
	var req_indicator: TextureRect = req.get_node("RequirementIndicator")
	req_indicator.texture = load("res://assets/ui/upgrades/final_upgrade/requirements/normal.png")


func update_req_1(new_upgrade_amount: int) -> void:
	var label: Label = req1.get_node("RequirementLabel")
	label.text = str(new_upgrade_amount) + "/" + str(WinRequirementHandler.upgrades_required) + " Upgrades Unlocked"


func update_req_2(new_planet_amount: int) -> void:
	var label: Label = req2.get_node("RequirementLabel")
	label.text = str(new_planet_amount) + "/" + str(WinRequirementHandler.planets_required) + " Planets Owned"


func update_req_3(new_amount: int) -> void:
	var label: Label = req3.get_node("RequirementLabel")
	label.text = str(new_amount) + "/" + str(WinRequirementHandler.money_required) + " Money"


func update_req_4(new_amount: int) -> void:
	var label: Label = req4.get_node("RequirementLabel")
	label.text = str(new_amount) + "/" + str(WinRequirementHandler.molten_ingots_required) + " Molten Ingots"


func update_req_5(new_amount: int) -> void:
	var label: Label = req5.get_node("RequirementLabel")
	label.text = str(new_amount) + "/" + str(WinRequirementHandler.warpite_required) + " Warpite"


func update_req_6(new_amount: int) -> void:
	var label: Label = req6.get_node("RequirementLabel")
	label.text = str(new_amount) + "/" + str(WinRequirementHandler.gravitium_required) + " Gravitium"


func allow_win() -> void:
	var button: TextureButton = $MainContainer/FinalUpgradeButton
	button.disabled = false


func disallow_win() -> void:
	var button: TextureButton = $MainContainer/FinalUpgradeButton
	button.disabled = true


func _on_final_upgrade_button_pressed() -> void:
	GameManager.win_game()
