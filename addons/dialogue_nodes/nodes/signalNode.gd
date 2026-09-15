@tool
extends BaseDialogueNode

func _ready() -> void:
	%SignalSelector.undo_redo = undo_redo


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	dict['signal_value'] = %SignalSelector.to_dict()
	dict['auto_proceed'] = %CheckBox.button_pressed
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	%SignalSelector.from_dict(dict['signal_value'])

	if dict.has("auto_proceed"):
		%CheckBox.set_pressed_no_signal(dict["auto_proceed"])
	
	return [dict['link']]

