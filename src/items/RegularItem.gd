@tool
extends _Item
class_name RegularItem

@export var battle_item: BattleItem 

@export
var is_consumable: bool:
	get:
		return is_consumable 
	set(value):
		is_consumable = value
		if battle_item != null:
			battle_item.is_consumable = value

@export var max_quantity : int 

# func try_combine(other: _Item, amount: int) -> bool:
# 	if _quantity == max_quantity: return false
# 	if max_quantity == -1:
# 		quantity += other._quantity
# 		return true
#
# 	var total = _quantity + other._quantity
# 	_quantity = min(total, max_quantity)
# 	return true
#
# func try_remove(other: _Item, amount: int) -> bool:
# 	if _quantity == 0: return false
# 	if amount == -1: amount = _quantity
#
# 	var total = _quantity - amount
# 	_quantity = max(0, total)
# 	return true


func _set_name(value: String) -> void:
	super._set_name(value)
	if battle_item != null:
		battle_item.name = value

func _set_details(value: String) -> void:
	super._set_details(value)
	if battle_item != null:
		battle_item.details = value

func _set_requirement(value: Array[ItemRequirement]) -> void:
	super._set_requirement(value)
	if battle_item == null: return

	battle_item.requirements = []
	for req in value:
		if req.battle_relevant:
			battle_item.requirements.append(req)

