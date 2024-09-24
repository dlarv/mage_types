@tool
extends Item
class_name RegularItem

@export
var battle_item: BattleItem 

@export
var is_consumable: bool:
	get:
		return is_consumable 
	set(value):
		is_consumable = value
		if battle_item != null:
			battle_item.is_consumable = value

@export
var quantity: int:
	get:
		if battle_item != null:
			return battle_item.quantity
		else:
			return quantity 
	set(value):
		quantity = value
		if battle_item != null:
			battle_item.quantity = value

@export
var max_quantity : int 

func try_combine(other: Item) -> bool:
	if quantity == max_quantity: return false
	if max_quantity == -1:
		quantity += other.quantity
		return true

	var total = quantity + other.quantity
	quantity = min(total, max_quantity)
	return true

func try_remove(other: Item, amount: int) -> bool:
	if quantity == 0: return false
	if amount == -1: amount = quantity

	var total = quantity - amount
	quantity = max(0, total)
	return true


func _set_name(value: String):
	super._set_name(value)
	if battle_item != null:
		battle_item.name = value

func _set_details(value):
	super._set_details(value)
	if battle_item != null:
		battle_item.details = value

func _set_requirement(value):
	super._set_requirement(value)
	if battle_item != null and value.battle_relevant:
		battle_item.requirement = value
