@tool
extends Node

signal variables_updated()

@export var variables: Dictionary[String, Variant] = {}

func update_variable(varName: String, value: Variant) -> void:
	print("StoryManager added var '%s'." % varName)
	variables[varName] = value
	variables_updated.emit()


func remove_variable(varName: String) -> void:
	if variables.erase(varName):
		print("StoryManager removed var '%s'." % varName)
		variables_updated.emit()
	else:
		print("StoryManager tried to remove var '%s', but no such var was found." % varName)


func rename_variable(oldName: String, newName: String) -> void:
	pass


func serialize() -> Dictionary:
	return {}


func deserialize(data: Dictionary) -> void:
	pass
