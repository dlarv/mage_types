@tool
extends BaseDialogueNode

var last_value := -1

func _ready() -> void:
	# _register_timer($SignalValue, "text_changed", _on_signal_value_changed)
	pass


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	# To preserve backwards compatibility
	dict['signal_value'] = $SignalDropdown.selected
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	# To preserve backwards compatibility
	if dict.has('signal_value'):
		$SignalDropdown.selected = dict['signal_value']

	last_value = $SignalDropdown.selected
	
	return [dict['link']]


func set_value(new_value: int) -> void:
	if $SignalDropdown.selected != new_value:
		$SignalDropdown.selected = new_value
	last_value = new_value


func _on_item_selected(index: int) -> void:
	if not undo_redo:
		set_value($SignalDropdown.selected)
	
	undo_redo.create_action('Set signal SignalDropdown')
	undo_redo.add_do_method(self, 'set_value', $SignalDropdown.selected)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_value)
	undo_redo.commit_action()

