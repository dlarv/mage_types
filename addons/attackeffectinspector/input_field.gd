@tool
extends EditorProperty

const Parser := preload("res://addons/attackeffectinspector/parser.gd")

var line_edit: LineEdit
var display_value := ""
var new_value := 0.0
# An internal value of the property.
var current_value := 0.0
# A guard against internal changes when the property is updated.
var updating := false
var use_advanced_syntax := false
var parser: Parser

func _init(value: String) -> void:
	line_edit = LineEdit.new()
	line_edit.text = value
	display_value = value
	add_child(line_edit)
	add_focusable(line_edit)

	line_edit.text_changed.connect(_on_text_changed)
	parser = Parser.new()


func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return

	# Update the control with the new value.
	updating = true
	current_value = new_value

	get_edited_object().read_from_buffer = use_advanced_syntax
	if use_advanced_syntax:
		get_edited_object().buffer_map[get_edited_property()] = parser.parse(display_value)

	if not display_value.is_empty():
		line_edit.text = display_value
	else:
		line_edit.text = str(current_value)

	updating = false


func _on_text_changed(text: String) -> void:
	var value: float
	if text.is_valid_float():
		use_advanced_syntax = false
		new_value =  float(value)
	else:
		use_advanced_syntax = true
		new_value = 0
		display_value = text
	emit_changed(get_edited_property(), new_value)
