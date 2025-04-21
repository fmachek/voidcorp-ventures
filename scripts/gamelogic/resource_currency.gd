extends RefCounted
class_name ResourceCurrency
## This class represents a resource, for example one present on a planet or meteor.

## The name of the resource.
var name: String
## The amount of the resource.
var amount: int

## Emitted when the amount changes.
signal amount_changed(new_amount: int)

## This constructor takes a name and amount.
func _init(name: String, amount: int) -> void:
	self.name = name
	self.amount = amount

## This function subtracts a given [param amount] from the resource.
## It also returns the amount that was actually subtracted.
func subtract(amount: int) -> int:
	var subtracted = 0
	if self.amount - amount < 0:
		subtracted = self.amount
		self.amount = 0
	else:
		self.amount -= amount
		subtracted = amount
	emit_signal("amount_changed", self.amount)
	return subtracted

## Adds a given amount to the resource.
func add(amount: int) -> void:
	self.amount += amount
	emit_signal("amount_changed", self.amount)
