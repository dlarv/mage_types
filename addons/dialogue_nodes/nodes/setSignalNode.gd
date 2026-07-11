@tool
extends BaseDialogueNode

var last_type: int
var last_variable_value: String
var last_signal_value: int


func _ready() -> void:
	_register_timer(%Value, "text_changed", _on_variable_changed)
	%Variable.undo_redo = undo_redo


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	# Set
	dict['variable'] = %Variable.curr_variable
	dict['type'] = %Type.selected
	dict['value'] = %Value.text
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'

	# Signal
	dict['signal_value'] = $SignalDropdown.selected
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	# Set Value
	%Variable.setup(dict['variable'])

	%Type.selected = dict['type']
	%Value.text = dict['value']
	
	last_type = %Type.selected
	last_variable_value = %Value.text


	# Signal Value
	# To preserve backwards compatibility
	if dict.has('signalValue'):
		$SignalDropdown.selected = dict['signalValue']
	elif dict.has('signal_value'):
		$SignalDropdown.selected = dict['signal_value']

	last_signal_value = $SignalDropdown.selected
	
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


func set_signal(new_value: int) -> void:
	if $SignalDropdown.selected != new_value:
		$SignalDropdown.selected = new_value
	last_signal_value = new_value


func _on_signal_value_changed() -> void:
	if not undo_redo:
		set_value($SignalDropdown.selected)
	
	undo_redo.create_action('Set signal SignalValue')
	undo_redo.add_do_method(self, 'set_value', $SignalDropdown.selected)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_signal_value)
	undo_redo.commit_action()

