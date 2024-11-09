@tool
extends Control

signal checked(isChecked: bool)

@export var icon: ColorRect
@export var checkbox: CheckBox 

@export_enum("blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String:
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
		if icon == null: return
		icon.color = element.main_color
		icon.get_child(0).text = element.name
var element: ElementalType

@export var pressed: bool:
	get():
		return checkbox.button_pressed
	set(value):
		checkbox.button_pressed = value


func _on_button_button_down() -> void:
	checkbox.button_pressed = !pressed
