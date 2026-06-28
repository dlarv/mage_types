@tool
extends BaseDialogueNode

var last_name: String
var last_operator: int
var last_value: String
var last_type: int


func _ready() -> void:
	_register_timer(%ItemName, "text_changed", _on_item_changed)
	_register_timer(%Value, "text_changed", _on_value_changed)


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	dict['item_name'] = %ItemName.text
	dict['operator'] = %Operator.selected
	dict['value'] = %Value.text
	dict['type'] = %Type.selected
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	%ItemName.text = dict['item_name']
	%Operator.selected = dict['operator']
	%Value.text = dict['value']
	%Type.selected = dict['type']
	
	last_name = %ItemName.text
	last_operator = %Operator.selected
	last_value = %Value.text
	last_type = %Type.text
	
	return [dict['link']]


func _on_item_changed() -> void:
	if not undo_redo:
		set_item_name(%ItemName.text)
		return

	undo_redo.create_action('Set Item Name')
	undo_redo.add_do_method(self, 'set_item_name', %ItemName.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_item_name', last_name)
	undo_redo.commit_action()


func set_item_name(new_value: String) -> void:
	if %ItemName.text != new_value:
		%ItemName.text = new_value
	last_name = new_value


func _on_operator_selected(idx: int) -> void:
	if not undo_redo: return
	
	undo_redo.create_action('Set Item Operator')
	undo_redo.add_do_method(%Operator, 'select', idx)
	undo_redo.add_do_property(self, 'last_operator', idx)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(%Operator, 'select', last_operator)
	undo_redo.add_undo_property(self, 'last_operator', last_operator)
	undo_redo.commit_action()


func _on_value_changed() -> void:
	if not undo_redo:
		set_value(%Value.text)
		return

	undo_redo.create_action('Set Value')
	undo_redo.add_do_method(self, 'set_value', %Value.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_value)
	undo_redo.commit_action()


func set_value(new_value: String) -> void:
	if %Value.text != new_value:
		%Value.text = new_value
	last_value = new_value


func _on_type_selected(idx: int) -> void:
	if not undo_redo: return
	
	undo_redo.create_action('Set Item Type')
	undo_redo.add_do_method(%Type, 'select', idx)
	undo_redo.add_do_property(self, 'last_type', idx)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(%Type, 'select', last_type)
	undo_redo.add_undo_property(self, 'last_operator', last_type)
	undo_redo.commit_action()

