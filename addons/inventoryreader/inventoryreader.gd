@tool
extends EditorInspectorPlugin 

var inventory

func _can_handle(object):
	return object is Inventory

func _parse_begin(object: Object) -> void:
	var button = Button.new()
	button.text = "Load items"

	button.pressed.connect(func():
		object.LoadFromFS())
	add_custom_control(button)
