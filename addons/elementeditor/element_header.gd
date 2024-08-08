@tool
extends Control
class_name ElementHeader

func init_header(element: ElementalType):
	var label = find_child("Label", true)
	var button = find_child("Button", true)
	var rect = find_child("ColorRect")
	rect.color = element.color
	label.text = element.type_name

	return button

func init_empty():
	var button = find_child("Button", true)
	var rect = find_child("ColorRect")
	rect.color = Color.hex(0xffffff00)
	button.hide()
