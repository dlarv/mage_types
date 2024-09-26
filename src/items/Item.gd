@tool
extends Resource
class_name Item 

var id : int 
@export 
var name: String: set = _set_name
@export
var requirement: ItemRequirement: set = _set_requirement
@export
var details: String: set = _set_details
@export
var tags = []
@export
var quantity: int: set = _set_quantity, get = _get_quantity
var _quantity: int

func update_id(id):
	self.id = id


# public int CompareTo(Item other) {
# 	return this.Id.CompareTo(other.Id)

func _set_name(value):
	name = value

func _set_details(value):
	details = value

func _set_requirement(value):
	requirement = value

func _set_quantity(value):
	if value > 1:
		_quantity = 1
	elif value < 0:
		_quantity = 0
	else:
		_quantity = value

func _get_quantity():
	return _quantity
