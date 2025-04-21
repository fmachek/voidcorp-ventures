extends Node


## Emitted when a requirement is fulfilled.
signal req_fulfilled(index: int)
## Emitted when a requirement is unfulfilled.
signal req_unfulfilled(index: int)
## Emitted when the first requirement is updated.
signal req_1_updated(new_amount: int)
## Emitted when the secondrequirement is updated.
signal req_2_updated(new_amount: int)
## Emitted when the third requirement is updated.
signal req_3_updated(new_amount: int)
## Emitted when the fourth requirement is updated.
signal req_4_updated(new_amount: int)
## Emitted when the fifth requirement is updated.
signal req_5_updated(new_amount: int)
## Emitted when the sixth requirement is updated.
signal req_6_updated(new_amount: int)

## Emitted when all requirements are fulfilled.
signal all_requirements_fulfilled()
## Emitted when some requirement was unfulfilled.
signal requirements_unfulfilled()

## Tells if the first requirement has been fullfilled.
var is_req_1_fulfilled: bool
## Tells if the second requirement has been fullfilled.
var is_req_2_fulfilled: bool
## Tells if the third requirement has been fullfilled.
var is_req_3_fulfilled: bool
## Tells if the fourth requirement has been fullfilled.
var is_req_4_fulfilled: bool
## Tells if the fifth requirement has been fullfilled.
var is_req_5_fulfilled: bool
## Tells if the sixth requirement has been fullfilled.
var is_req_6_fulfilled: bool

## Amount of upgrades required.
var upgrades_required: int = 10

## Amount of planets owned required.
var planets_required: int = 20

## Amount of money required.
var money_required: int = 25000

## Amount of Molten Ingots required.
var molten_ingots_required: int = 250
## Amount of Warpite required.
var warpite_required: int = 25
## Amount of Gravitium required.
var gravitium_required: int = 25


func reset() -> void:
	disconnect_signals()
	is_req_1_fulfilled = false
	is_req_2_fulfilled = false
	is_req_3_fulfilled = false
	is_req_4_fulfilled = false
	is_req_5_fulfilled = false
	is_req_6_fulfilled = false
	connect_signals()


func _ready() -> void:
	reset()


## Connects some signals.
func connect_signals() -> void:
	UpgradeManager.connect("upgrade_amount_changed", check_upgrade_req)
	GameManager.connect("planets_owned_changed", check_planet_req)
	GameManager.connect("money_changed", check_money_req)
	GameManager.resources["Molten Ingot"].connect("amount_changed", check_molten_ingot_req)
	GameManager.resources["Warpite"].connect("amount_changed", check_warpite_req)
	GameManager.resources["Gravitium"].connect("amount_changed", check_gravitium_req)


## Disconnects some signals.
func disconnect_signals() -> void:
	UpgradeManager.disconnect("upgrade_amount_changed", check_upgrade_req)
	GameManager.disconnect("planets_owned_changed", check_planet_req)
	GameManager.disconnect("money_changed", check_money_req)
	GameManager.resources["Molten Ingot"].disconnect("amount_changed", check_molten_ingot_req)
	GameManager.resources["Warpite"].disconnect("amount_changed", check_warpite_req)
	GameManager.resources["Gravitium"].disconnect("amount_changed", check_gravitium_req)


## Checks if the upgrade requirement has been fulfilled.
func check_upgrade_req(new_upgrade_amount: int) -> void:
	if new_upgrade_amount >= upgrades_required:
		is_req_1_fulfilled = true
		emit_signal("req_fulfilled", 1)
	emit_signal("req_1_updated", new_upgrade_amount)
	check_all_reqs()


## Checks if the planets owned requirement has been fulfilled.
func check_planet_req(new_amount: int) -> void:
	if new_amount >= planets_required:
		is_req_2_fulfilled = true
		emit_signal("req_fulfilled", 2)
	else:
		is_req_2_fulfilled = false
		emit_signal("req_unfulfilled", 2)
	emit_signal("req_2_updated", new_amount)
	check_all_reqs()


## Checks if the money requirement has been fulfilled.
func check_money_req(new_amount: int) -> void:
	if new_amount >= money_required:
		is_req_3_fulfilled = true
		emit_signal("req_fulfilled", 3)
	else:
		is_req_3_fulfilled = false
		emit_signal("req_unfulfilled", 3)
	emit_signal("req_3_updated", new_amount)
	check_all_reqs()


## Checks if the Molten Ingot requirement has been fulfilled.
func check_molten_ingot_req(new_amount: int) -> void:
	if new_amount >= molten_ingots_required:
		is_req_4_fulfilled = true
		emit_signal("req_fulfilled", 4)
	else:
		is_req_4_fulfilled = false
		emit_signal("req_unfulfilled", 4)
	emit_signal("req_4_updated", new_amount)
	check_all_reqs()


## Checks if the Warpite requirement has been fulfilled.
func check_warpite_req(new_amount: int) -> void:
	if new_amount >= warpite_required:
		is_req_5_fulfilled = true
		emit_signal("req_fulfilled", 5)
	else:
		is_req_5_fulfilled = false
		emit_signal("req_unfulfilled", 5)
	emit_signal("req_5_updated", new_amount)
	check_all_reqs()


## Checks if the Gravitium requirement has been fulfilled.
func check_gravitium_req(new_amount: int) -> void:
	if new_amount >= gravitium_required:
		is_req_6_fulfilled = true
		emit_signal("req_fulfilled", 6)
	else:
		is_req_6_fulfilled = false
		emit_signal("req_unfulfilled", 6)
	emit_signal("req_6_updated", new_amount)
	check_all_reqs()


## Checks if all requirements have been fulfilled.
func check_all_reqs() -> void:
	if is_req_1_fulfilled and is_req_2_fulfilled and is_req_3_fulfilled and is_req_4_fulfilled and is_req_5_fulfilled and is_req_6_fulfilled:
		emit_signal("all_requirements_fulfilled")
	else:
		emit_signal("requirements_unfulfilled")
