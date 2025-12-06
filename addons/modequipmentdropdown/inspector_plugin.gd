# my_inspector_plugin.gd
extends EditorInspectorPlugin

const DropDown := preload("res://addons/modequipmentdropdown/dropdown.gd")

func _can_handle(object: Object):
	return object is ModEquipmentEffect


func _parse_property(object: Object, type: int, name: String, hint_type: int, hint_string: String, usage_flags: int, wide: bool):
	if name == "target_method":
		add_property_editor(name, DropDown.new(object))
		return true
	return false


