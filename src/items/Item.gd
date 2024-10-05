@tool
extends Resource
class_name Item 

var id: int 
@export var name: String: set = _set_name
@export var requirements: Array[ItemRequirement]: set = _set_requirement
@export
var details: String: set = _set_details
@export var tags = []
@export
var quantity: int: set = _set_quantity, get = _get_quantity
var _quantity: int

func update_id(id) -> void:
	self.id = id

# Checks whether the actor matches all of the requirements.
# If the actor does not meet the requirements, return an array containing the unmet requirements.
func check_requirements(actor: BattleActor) -> Array:
	var output := []
	for req in requirements:
		if not req.check(actor):
			output.append(req)
	return output

func _set_name(value: String) -> void:
	name = value

func _set_details(value: String) -> void:
	details = value

func _set_requirement(value: Array) -> void:
	requirements = value

func _set_quantity(value: int) -> void:
	if value > 1:
		_quantity = 1
	elif value < 0:
		_quantity = 0
	else:
		_quantity = value

func _get_quantity() -> int:
	return _quantity
