# my_inspector_plugin.gd
extends EditorInspectorPlugin

const InputField := preload("res://addons/attackeffectinspector/input_field.gd")

func _can_handle(object: Object):
	return object is _AttackEffect or object is _BaseEffectSlot


func _parse_property(object: Object, type: int, name: String, hint_type: int, hint_string: String, usage_flags: int, wide: bool):
	# We handle properties of type integer.
	if object is _BaseEffectSlot and name == "chance":
		add_property_editor(name, InputField.new(object.get(name) as String))
		return true
	elif object is _AttackEffect and name == "strength":
		add_property_editor(name, InputField.new(object.get(name) as String))
		return true
	else:
		return false
