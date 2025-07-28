@tool
extends EditorProperty

const Parser := preload("res://addons/attackeffectinspector/parser.gd")

var line_edit: LineEdit
var new_value := ""
# An internal value of the property.
var current_value := ""
# A guard against internal changes when the property is updated.
var updating := false
var parser: Parser

func _init(value: String) -> void:
	line_edit = LineEdit.new()
	line_edit.text = value
	add_child(line_edit)
	add_focusable(line_edit)

	line_edit.text_submitted.connect(_on_text_submitted)
	parser = Parser.new()


func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]

	# Update the control with the new value.
	updating = true
	current_value = new_value

	var text := line_edit.text
	var use_advanced_syntax := not text.is_valid_float()
	get_edited_object().read_from_buffer = use_advanced_syntax
	if use_advanced_syntax:
		get_edited_object().buffer_map[get_edited_property()] = parser.parse(text)

	updating = false


func _on_text_submitted(text: String) -> void:
	new_value = text
	emit_changed(get_edited_property(), new_value)
