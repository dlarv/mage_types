# my_inspector_plugin.gd
extends EditorInspectorPlugin

const InputField := preload("res://addons/attackeffectinspector/input_field.gd")

func _can_handle(object: Object):
	return object is _AttackEffect or object is _BaseEffectSlot


func _parse_property(object: Object, type: int, name: String, hint_type: int, hint_string: String, usage_flags: int, wide: bool):
	# if object is _BaseEffectSlot and name == "chance":
	# 	add_property_editor(name, InputField.new(str(object.get(name))))
	# 	return true
	if type == TYPE_STRING and _evaluate_attack_effect(object, name):
		add_property_editor(name, InputField.new(str(object.get(name))))
		return true
	return false


func _evaluate_attack_effect(object: Object, name: String) -> bool:
	return name[0] == "_" and object.get(name.substr(1)) != null
