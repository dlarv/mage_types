@tool
extends Node3D

@export var element: ElementalType.ElementId:
	set(val):
		element = val
		if element == ElementalType.ElementId.BLANK:
			_element = ElementManager.Blank
		else:
			_element = ElementManager.elements[element]
			call_deferred("_change_icon")

var _element: ElementalType
@onready var _material: StandardMaterial3D = $Flag.get_surface_override_material(2).next_pass

func _change_icon() -> void:	
	_material.albedo_color = _element.main_color
	_material.albedo_texture = _element.icon
