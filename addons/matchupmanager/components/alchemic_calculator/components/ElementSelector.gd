@tool
extends HBoxContainer

signal checked(isChecked: bool)

@export var icon: ElementIcon
@export var checkbox: CheckBox

@export_enum("blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String:
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
		if icon != null:
			icon._element = value
var element: ElementalType

@export var pressed: bool:
	get():
		return checkbox.button_pressed
	set(value):
		checkbox.button_pressed = value
