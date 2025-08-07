@tool
extends Resource
class_name StoryState

@export var variables: Dictionary[String, Variant] = { }


func update_variable(varName: String, value: Variant) -> void:
	variables.set(varName, value)


func remove_variable(varName: String) -> bool:
	return variables.erase(varName)


func rename_variable(oldName: String, newName: String) -> bool:
	var value: Variant = variables.get(oldName, null)
	variables[newName] = value
	return variables.erase(oldName)


func get_variable(varName: String) -> Variant:
	var output: Variant = variables.get(varName)
	if output == null:
		return null

	if output.type == TYPE_INT:
		return int(output.get("value"))
	return output.get("value")


func set_variable(varName: String, value: Variant) -> bool:
	if not variables.has(varName): return false
	return variables[varName].set("value", value)
