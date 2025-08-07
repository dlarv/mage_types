@tool
extends GraphNode


signal modified

@onready var dropdown := $Dropdown
@onready var timer := $Timer

var undo_redo: EditorUndoRedoManager
var last_value := ''
var curr_index: int


func _ready() -> void:
	dropdown.clear()
	for key in StoryManager.DialogSignal.keys():
		dropdown.add_item(key)


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	dict['curr_signal'] = curr_index
	dict['signal_value'] = last_value

	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	curr_index = dict['curr_signal']
	last_value = dict['signal_value']

		# Signal list has changed
	if last_value != StoryManager.DialogSignal.keys()[curr_index]:
		var index := StoryManager.DialogSignal.keys().find(last_value)
		if index != -1:
			curr_index = index
		else:
			curr_index = 0
	dropdown.select(curr_index)

	return [dict['link']]


func set_value(new_value: String) -> void:
	print("Signal Set %s" % new_value)
	last_value = new_value


func _on_signal_value_changed(_new_text) -> void:
	timer.stop()
	timer.start()


func _on_timer_timeout() -> void:
	if not undo_redo: return
	undo_redo.create_action('Set signal value')
	undo_redo.add_do_method(self, 'set_value', (dropdown as OptionButton).get_item_text(curr_index))
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_value)
	undo_redo.commit_action()


func _on_modified() -> void:
	modified.emit()


func _on_dropdown_item_selected(index: int) -> void:
	curr_index = index
	timer.stop()
	timer.start()
