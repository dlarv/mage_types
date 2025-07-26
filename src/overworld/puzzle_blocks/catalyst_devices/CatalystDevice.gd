extends Node3D

signal element_selected(element: ElementalType, v: int, force: bool)

@export var elements := {
	# "Blank": false,
	"Blue": true,
	"Purple": true,
	"Magenta": true,
	"Red": true,
	"Orange": true,
	"Yellow": true,
	"Green": true,
	"Cyan": true,
}
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blue":
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType = ElementManager.Blue:
	set(value):
		if value == null:
			value = ElementManager.Blank
		element = value 


func _ready() -> void:
	# This script randomly started throwing an error where this value was
	# not initialized. I'm not sure why.
	element = ElementManager.get_element_from_name(_element)
	_rotate_wheel(element)


func _rotate_wheel(element: ElementalType) -> void:
	var tween := get_tree().create_tween()
	var degrees: float
	match element.name:
		"Blue": degrees = 0
		"Purple": degrees = 45
		"Magenta": degrees = 45 * 2
		"Red": degrees = 45 * 3
		"Orange": degrees = 45 * 4
		"Yellow": degrees = 45 * 5
		"Green": degrees = 45 * 6
		"Cyan": degrees = 45 * 7
	
	tween.tween_property($catalyst_device/Plane, "rotation_degrees", Vector3(0, 0, degrees), 1) 


func _on_interactable_interacted(obj:Node3D) -> void:
	UIManager.open_catalyst_menu(elements)
	var e: ElementalType = await UIManager.catalyst_menu_closed
	if e:
		element = e
		_rotate_wheel(element)
		element_selected.emit(element, -2, true)

