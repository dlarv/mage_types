@tool
extends Node

# This is used in the editor, not during gameplay.
signal variables_updated()

enum DialogSignal { BATTLE_STARTED, PLAY_CUTSCENE, MENU_OPENED, DIALOG_ENDED, ADD_ALLY, REMOVE_ALLY, }

var state: StoryState = preload("res://data/story/story_state.tres")
var variables: Dictionary[String, Variant]:
	get:
		return state.variables


func add_variable(varName: String, value: Variant, quiet:=false) -> void:
	MyLogger.append_story_log("StoryManager added var '%s'." % varName)
	state.update_variable(varName, value)
	if not quiet:
		variables_updated.emit()


func update_value(varName: String, value: Variant) -> void:
	if not variables.has(varName):
		push_warning("StoryManager tried to change value of var '%s' with value '%s', but no such var was found."
				%[varName, str(value)])
		return
	MyLogger.append_story_log("StoryManager changed value of var '%s' with value '%s'." % [varName, str(value)])
	state.update_variable(varName, {"value": value, "type": variables[varName].type})


func update_type(varName: String, type: int) -> void:
	if not variables.has(varName):
		push_warning("StoryManager tried to change type of var '%s' to type '%d', but no such var was found."
				%[varName, type])
		return
	MyLogger.append_story_log("StoryManager changed type of var '%s' to type '%d'." % [varName, type])
	state.update_variable(varName, {"value": variables[varName].value, "type": type})


func remove_variable(varName: String) -> void:
	if state.remove_variable(varName):
		MyLogger.append_story_log("StoryManager removed var '%s'." % varName)
		variables_updated.emit()
	else:
		MyLogger.append_story_log("StoryManager tried to remove var '%s', but no such var was found." % varName)


func rename_variable(oldName: String, newName: String) -> void:
	var value: Variant = variables.get(oldName, null)
	if state.rename_variable(oldName, newName):
		MyLogger.append_story_log("StoryManager renamed var '%s' to '%s'." % [oldName, newName])
		variables_updated.emit()
	else:
		MyLogger.append_story_log("StoryManager tried to rename var '%s' to '%s', but original var was not found."
				% [oldName, newName])


func get_variable(varName: String) -> Variant:
	var output: Variant = state.get_variable(varName)
	if output != null:
		return output
	push_warning("Could not find StoryVariable %s" % varName)
	return null


func set_variable(varName: String, value: Variant) -> void:
	if not state.set_variable(varName, value):
		push_warning("Could not find StoryVariable %s." % varName)


func serialize() -> Dictionary:
	return {
		"path": get_path(),
		"vars": state.variables
	}


func deserialize(data: Dictionary) -> void:
	state.variables = data.vars
	
