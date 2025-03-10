@tool
extends GraphNode


signal modified


# Set Node Properties
@onready var variable = $VBoxContainer/BoxContainer/Variable
@onready var variable_timer = $VBoxContainer/VariableTimer
@onready var type = $VBoxContainer/BoxContainer/Type
@onready var set_node_value = $VBoxContainer/BoxContainer/Value
@onready var value_timer = $VBoxContainer/ValueTimer

var last_variable : String
var last_type : int
var last_set_value: String

# Signal Node Properties
@onready var signal_timer = $VBoxContainer/SignalTimer
@onready var signal_value = $VBoxContainer/SignalValue
var last_signal_value: String


var undo_redo : EditorUndoRedoManager


func _to_dict(graph : GraphEdit):
	var dict := {}
	var connections : Array = graph.get_connections(name)
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	# Save SetNode data
	dict['variable'] = variable.text
	dict['type'] = type.selected
	dict['value'] = set_node_value.text

	# Save SignalNode data
	dict['signalValue'] = signal_value.text
	
	return dict


func _from_dict(dict : Dictionary):
	# SetNode data
	variable.text = dict['variable']
	type.selected = dict['type']
	set_node_value.text = dict['value']
	
	last_variable = variable.text
	last_type = type.selected
	last_set_value = set_node_value.text

	# SignalNode data
	signal_value.text = dict['signalValue']
	last_signal_value = signal_value.text
	
	return [dict['link']]


func _on_modified():
	modified.emit()


func _on_signal_timer_timeout() -> void:
	undo_redo.create_action('Set signal value')
	undo_redo.add_do_method(self, 'set_node_value', signal_value.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_node_value', last_signal_value)
	undo_redo.commit_action()


func _on_signal_value_text_changed(new_text:String) -> void:
	signal_timer.stop()
	signal_timer.start()


func set_value(new_value : String):
	if set_node_value.text != new_value:
		set_node_value.text = new_value
	last_set_value = new_value

func set_variable(new_variable : String):
	if variable.text != new_variable:
		variable.text = new_variable
	last_variable = new_variable

func _on_variable_timer_timeout():
	if not undo_redo: return
	
	undo_redo.create_action('Set variable name')
	undo_redo.add_do_method(self, 'set_variable', variable.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_variable', last_variable)
	undo_redo.commit_action()

func _on_value_timer_timeout():
	if not undo_redo: return
	
	undo_redo.create_action('Set value')
	undo_redo.add_do_method(self, 'set_node_value', set_node_value.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_node_value', last_set_value)
	undo_redo.commit_action()


func _on_variable_text_changed(new_text:String) -> void:
	variable_timer.stop()
	variable_timer.start()


func _on_type_item_selected(idx:int) -> void:
	if not undo_redo: return
	undo_redo.create_action('Set operator type')
	undo_redo.add_do_method(type, 'select', idx)
	undo_redo.add_do_property(self, 'last_type', idx)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(type, 'select', last_type)
	undo_redo.add_undo_property(self, 'last_type', last_type)
	undo_redo.commit_action()

func _on_value_text_changed(new_text:String) -> void:
	value_timer.stop()
	value_timer.start()

