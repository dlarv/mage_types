@tool
extends Node

signal variables_updated()

@onready var state: StoryState = preload("res://data/story/story_state.tres")

var variables: Dictionary[String, Variant]:
	get:
		return state.variables


func update_variable(varName: String, value: Variant, quiet:=false) -> void:
	print("StoryManager added var '%s'." % varName)
	state.update_variable(varName, value)
	if not quiet:
		variables_updated.emit()


func remove_variable(varName: String) -> void:
	if state.remove_variable(varName):
		print("StoryManager removed var '%s'." % varName)
		variables_updated.emit()
	else:
		print("StoryManager tried to remove var '%s', but no such var was found." % varName)


func rename_variable(oldName: String, newName: String) -> void:
	var value: Variant = variables.get(oldName, null)
	if state.rename_variable(oldName, newName):
		print("StoryManager renamed var '%s' to '%s'." % [oldName, newName])
		variables_updated.emit()
	else:
		print("StoryManager tried to rename var '%s' to '%s', but original var was not found." 
				% [oldName, newName])


func serialize() -> Dictionary:
	return {}


func deserialize(data: Dictionary) -> void:
	pass

