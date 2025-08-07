@tool
extends GraphNode


signal modified

@onready var value := $HBoxContainer/SignalValue
@onready var dropdown := $HBoxContainer/Dropdown
@onready var check_box := $HBoxContainer/CheckBox
@onready var timer := $Timer

var undo_redo: EditorUndoRedoManager
var last_value := ''
var use_dropdown := false
var curr_index: int


func _ready() -> void:
	dropdown.clear()
	for key in StoryManager.DialogSignal.keys():
		dropdown.add_item(key)


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	if use_dropdown:
		dict['curr_index'] = curr_index
	else:
		dict['curr_index'] = -1

	dict['signalValue'] = last_value

	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	curr_index = dict['curr_index']
	last_value = dict['signalValue']

	if curr_index >= 0:
		check_box.button_pressed = true
		# Signal list has changed
		if last_value != StoryManager.DialogSignal.keys()[curr_index]:
			var index := StoryManager.DialogSignal.keys().find(last_value)
			if index != -1:
				curr_index = index
			else:
				curr_index = 0
		dropdown.select(curr_index)

	else:
		value.text = dict['signalValue']
		check_box.button_pressed = false

	
	return [dict['link']]


func set_value(new_value: String) -> void:
	if value.text != new_value:
		value.text = new_value
	print("Signal Set %s" % new_value)
	last_value = new_value


func _on_signal_value_changed(_new_text) -> void:
	timer.stop()
	timer.start()


func _on_timer_timeout() -> void:
	if not undo_redo: return
	var v: String
	if use_dropdown:
		v = (dropdown as OptionButton).get_item_text(curr_index)
	else:
		v = value.text
	
	undo_redo.create_action('Set signal value')
	undo_redo.add_do_method(self, 'set_value', v)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_value)
	undo_redo.commit_action()


func _on_modified() -> void:
	modified.emit()


func _on_check_box_toggled(toggledOn:bool) -> void:
	dropdown.visible = toggledOn
	use_dropdown = toggledOn
	value.visible = not toggledOn


func _on_dropdown_item_selected(index: int) -> void:
	# last_value = (dropdown as OptionButton).get_item_text(index)
	curr_index = index
	timer.stop()
	timer.start()
