@tool
extends Resource
class_name Item 

var Id : int 
@export
var Name : String:
	get:
		return _name 
	set(value):
		_name = value
		if battle_item != null:
			battle_item.Name = value

var _name: String 
@export
var battle_item : BattleItem 
@export
var IsConsumable : bool:
	get:
		return _isConsumable 
	set(value):
		_isConsumable = value
		if battle_item != null:
			battle_item.IsConsumable = value

var _isConsumable: bool 
@export
var Quantity : int:
	get:
		if battle_item != null:
			return battle_item.Quantity
		else:
			return _quantity 
	set(value):
		_quantity = value
		if battle_item != null:
			battle_item.Quantity = value
var _quantity: int 
@export
var MaxQuantity : int 
@export
var Requirement : ItemRequirement:
	get: 
		return _reqs 
	set(value):
		_reqs = value
		if battle_item != null and value != null and value.BattleRelevant:
			battle_item.Requirement = value

var _reqs: ItemRequirement 
@export
var tags = []
@export_multiline
var Details : String: 
	get:
		return _details
	set(value):
		_details = value
		if battle_item != null:
			battle_item.Details = value

var _details: String 

func update_id(id):
	Id = id

func TryCombine(other: Item) -> bool:
	if Quantity == MaxQuantity: return false
	if MaxQuantity == -1:
		Quantity += other.Quantity
		return true
	

	var total = Quantity + other.Quantity
	Quantity = min(total, MaxQuantity)
	return true

func TryRemove(other: Item, amount: int) -> bool:
	if Quantity == 0: return false
	if amount == -1: amount = Quantity

	var total = Quantity - amount
	Quantity = max(0, total)
	return true

# public int CompareTo(Item other) {
# 	return this.Id.CompareTo(other.Id)
