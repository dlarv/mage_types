@tool
extends Control

signal pressed(element: ElementalType)
@export var _element := ElementalType.ElementId.BLANK:
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.elements[int(value)]
		$Button.text = element.name.capitalize()
var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 

var disabled: bool:
	set(val):
		$Button.disabled = val
	get:
		return $Button.disabled


func _draw() -> void:
	if Engine.is_editor_hint(): return
	var style_box := get_theme_stylebox(element.name.to_lower(), "Control")
	$Button.add_theme_stylebox_override("normal", style_box)


func _on_button_pressed() -> void:
	pressed.emit(element)

