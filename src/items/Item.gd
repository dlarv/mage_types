@tool
extends Resource
class_name _Item 

@export var id := -1
@export var name: String: set = _set_name
@export var requirements: Array[ItemRequirement]: set = _set_requirement
@export_multiline
var details: String: set = _set_details

# Checks whether the actor matches all of the requirements.
# If the actor does not meet the requirements, return an array containing the unmet requirements.
func check_requirements(actor: BattleActor) -> Array[ItemRequirement]:
	var output: Array[ItemRequirement] = []
	for req in requirements:
		if not req.check(actor):
			output.append(req)
	return output

func try_combine(item: _Item, amount: int) -> bool:
	return true

func _set_name(value: String) -> void:
	name = value

func _set_details(value: String) -> void:
	details = value

func _set_requirement(value: Array[ItemRequirement]) -> void:
	requirements = value
