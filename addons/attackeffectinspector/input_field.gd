@tool
extends EditorProperty

const Parser := preload("res://addons/attackeffectinspector/parser.gd")

var line_edit: LineEdit
var new_value := ""
# An internal value of the property.
var current_value := ""
# A guard against internal changes when the property is updated.
var updating := false

func _init(value: String) -> void:
	line_edit = LineEdit.new()
	line_edit.text = value
	add_child(line_edit)
	add_focusable(line_edit)

	line_edit.text_submitted.connect(_on_text_submitted)


func _update_property():
	var obj := get_edited_object()
	var prop := get_edited_property()
	var new_value = obj[prop]

	# Update the control with the new value.
	updating = true
	current_value = new_value

	var text := line_edit.text
	var use_advanced_syntax := not text.is_valid_float()
	if obj is _BaseEffectSlot:
		obj.get_chance = Parser.parse(text)
	else:
		if use_advanced_syntax:
			obj.buffer_map[prop] = Parser.parse(text)

	updating = false


func _on_text_submitted(text: String) -> void:
	new_value = text
	emit_changed(get_edited_property(), new_value)
