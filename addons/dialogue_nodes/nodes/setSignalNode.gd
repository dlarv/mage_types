@tool
extends BaseDialogueNode

var last_type: int
var last_variable_value: String
var last_signal_value: Variant


func _ready() -> void:
	_register_timer(%Value, "text_changed", _on_variable_changed)
	%Variable.undo_redo = undo_redo

	%SignalSelector.undo_redo = undo_redo


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	# Set
	dict['variable'] = %Variable.curr_variable
	dict['type'] = %Type.selected
	dict['value'] = %Value.text
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'

	# Signal
	dict['signal_value'] = %SignalSelector.to_dict()
	dict['auto_proceed'] = %CheckBox.button_pressed
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	# Set Value
	%Variable.setup(dict['variable'])

	%Type.selected = dict['type']
	%Value.text = dict['value']
	
	last_type = %Type.selected
	last_variable_value = %Value.text


	# Signal Value
	%SignalSelector.from_dict(dict['signal_value'])
	
	# Preserve backwards compatibility
	if dict.has("auto_proceed"):
		%CheckBox.set_pressed_no_signal(dict['auto_proceed'])
	else:
		%CheckBox.set_pressed_no_signal(true)
	
	return [dict['link']]


func set_value(new_value: String) -> void:
	if %Value.text != new_value:
		%Value.text = new_value
	last_variable_value = new_value


func _on_type_selected(idx: int) -> void:
	if not undo_redo: return
	
	undo_redo.create_action('Set operator %Type')
	undo_redo.add_do_method(%Type, 'select', idx)
	undo_redo.add_do_property(self, 'last_type', idx)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(%Type, 'select', last_type)
	undo_redo.add_undo_property(self, 'last_type', last_type)
	undo_redo.commit_action()


func _on_variable_changed() -> void:
	if not undo_redo:
		set_value(%Value.text)
		return

	undo_redo.create_action('Set %Value')
	undo_redo.add_do_method(self, 'set_value', %Value.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_variable_value)
	undo_redo.commit_action()


func _on_variables_updated(variables_list: Array[String]) -> void:
	%Variable.update_variables(variables_list)


func subscribe_to_variables() -> bool: return true


