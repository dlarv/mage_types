@tool
extends Resource
class_name Item 

var id : int 
@export
var name : String:
	get:
		return _name 
	set(value):
		_name = value
		if battle_item != null:
			battle_item.name = value

var _name: String 
@export
var battle_item: BattleItem 

@export
var is_consumable: bool:
	get:
		return _isConsumable 
	set(value):
		_isConsumable = value
		if battle_item != null:
			battle_item.is_consumable = value
var _isConsumable: bool 

@export
var quantity: int:
	get:
		if battle_item != null:
			return battle_item.quantity
		else:
			return _quantity 
	set(value):
		_quantity = value
		if battle_item != null:
			battle_item.quantity = value
var _quantity: int 

@export
var max_quantity : int 
@export
var requirement : ItemRequirement:
	get: 
		return _reqs 
	set(value):
		_reqs = value
		if battle_item != null and value != null and value.battle_relevant:
			battle_item.requirement = value

var _reqs: ItemRequirement 
@export
var tags = []
@export_multiline
var details : String: 
	get:
		return _details
	set(value):
		_details = value
		if battle_item != null:
			battle_item.details = value

var _details: String 

func update_id(id):
	self.id = id

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

# public int CompareTo(Item other) {
# 	return this.Id.CompareTo(other.Id)
