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
