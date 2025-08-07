@tool
extends Control

signal modified

# SetNode variables
@onready var variable := $BoxContainer/Variable
@onready var variable_timer := $VariableTimer
@onready var type := $BoxContainer/Type
@onready var value := $BoxContainer/Value
@onready var value_timer := $ValueTimer

var undo_redo: EditorUndoRedoManager
var last_variable: String
var last_type: int
var cur_variable := -1
var curr_signal: int
var last_signal: String

# SignalNode variables
@onready var dropdown := $SignalDropdown
@onready var timer := $Timer

var last_signal_value := ''


func _ready() -> void:
	if not StoryManager.variables_updated.is_connected(_on_variables_updated):
		StoryManager.variables_updated.connect(_on_variables_updated)
	_on_variables_updated()

	dropdown.clear()
	for key in StoryManager.DialogSignal.keys():
		dropdown.add_item(key)


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	dict['variable'] = last_variable
	dict['type'] = type.selected
	dict['value'] = value.text

	dict['curr_signal'] = curr_signal
	dict['signal_value'] = last_signal

	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	cur_variable = StoryManager.variables.keys().find(dict['variable'])
	last_variable = dict['variable']
	variable.select(cur_variable)

	type.selected = dict['type']
	value.text = dict['value']
	last_type = type.selected
	
	last_signal = dict['signal_value']
	curr_signal = dict['curr_signal']

	# Signal list has changed
	if last_signal != StoryManager.DialogSignal.keys()[curr_signal]:
		var index := StoryManager.DialogSignal.keys().find(last_signal)
		if index != -1:
			curr_signal = index
		else:
			curr_signal = 0
	dropdown.select(curr_signal)
	
	return [dict['link']]


func set_variable(new_variable: String) -> void:
	if variable.text != new_variable:
		variable.text = new_variable
	last_variable = new_variable


func set_value(new_value: String) -> void:
	if value.text != new_value:
		value.text = new_value
	last_signal = new_value


func _on_variable_changed(_new_text) -> void:
	variable_timer.stop()
	variable_timer.start()


func _on_variable_timer_timeout() -> void:
	if not undo_redo: return
	
	undo_redo.create_action('Set variable name')
	undo_redo.add_do_method(self, 'set_variable', variable.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_variable', last_variable)
	undo_redo.commit_action()


func _on_type_selected(idx: int) -> void:
	if not undo_redo: return
	
	undo_redo.create_action('Set operator type')
	undo_redo.add_do_method(type, 'select', idx)
	undo_redo.add_do_property(self, 'last_type', idx)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(type, 'select', last_type)
	undo_redo.add_undo_property(self, 'last_type', last_type)
	undo_redo.commit_action()


func _on_value_changed(_new_text) -> void:
	value_timer.stop()
	value_timer.start()


func _on_value_timer_timeout() -> void:
	if not undo_redo: return
	
	undo_redo.create_action('Set value')
	undo_redo.add_do_method(self, 'set_value', value.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_signal)
	undo_redo.commit_action()


func _on_modified() -> void:
	modified.emit()

func _on_variable_selected(idx: int) -> void:
	last_variable = variable.get_item_text(idx)
	if not undo_redo: 
		cur_variable = idx
		variable.select(idx)
		_on_modified()
		return
	
	undo_redo.create_action('Set variable')
	undo_redo.add_do_property(self, 'cur_variable', idx)
	undo_redo.add_do_method(variable, 'select', idx)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_property(self, 'cur_variable', cur_variable)
	undo_redo.add_undo_method(variable, 'select', cur_variable)
	undo_redo.commit_action()

func set_signal_value(new_value: String) -> void:
	print("Signal Set %s" % new_value)
	last_signal = new_value


func _on_signal_value_changed(_new_text) -> void:
	timer.stop()
	timer.start()


func _on_timer_timeout() -> void:
	if not undo_redo: return
	undo_redo.create_action('Set signal value')
	undo_redo.add_do_method(self, 'set_signal_value', (dropdown as OptionButton).get_item_text(curr_signal))
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_signal_value', last_signal)
	undo_redo.commit_action()


func _on_variables_updated() -> void:
	var variable_list: Array[String] = StoryManager.variables.keys()
	var prevValue: String = variable.get_item_text(variable.selected)
		
	variable.clear()
	for variable_name in variable_list:
		variable.add_item(variable_name)
	
	if variable_list.size() > 0:
		# Try to find old value first
		var index := variable_list.find(prevValue)
		if index != -1:
			cur_variable = index
		elif cur_variable > variable_list.size() or cur_variable < 0:
			cur_variable = 0
		variable.select(cur_variable)
	else:
		variable.select(-1)


func _on_option_button_item_selected(index:int) -> void:
	curr_signal = index
	timer.stop()
	timer.start()

