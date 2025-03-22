@tool
extends Resource
class_name Item 

var id := -1
@export var name: String: set = _set_name
@export var requirements: Array[ItemRequirement]: set = _set_requirement
@export
var details: String: set = _set_details
@export var tags = []

# Checks whether the actor matches all of the requirements.
# If the actor does not meet the requirements, return an array containing the unmet requirements.
func check_requirements(actor: BattleActor) -> Array:
	var output := []
	for req in requirements:
		if not req.check(actor):
			output.append(req)
	return output

func try_combine(item: Item, amount: int) -> bool:
	return true

func _set_name(value: String) -> void:
	name = value

func _set_details(value: String) -> void:
	details = value

func _set_requirement(value: Array) -> void:
	requirements = value
