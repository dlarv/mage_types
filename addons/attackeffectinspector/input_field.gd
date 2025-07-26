extends EditorProperty

var new_value := 0.0
# An internal value of the property.
var current_value := 0.0
# A guard against internal changes when the property is updated.
var updating := false

func _init(value: String) -> void:
	var lineEdit := LineEdit.new()
	lineEdit.text = value
	add_child(lineEdit)
	add_focusable(lineEdit)

	lineEdit.text_changed.connect(_on_text_changed)


func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return

	# Update the control with the new value.
	updating = true
	current_value = new_value
	# refresh_control_text()
	updating = false


func _on_text_changed(text: String) -> void:
	var value: float
	if text.is_valid_float():
		new_value =  float(value)
	else:
		new_value = 0.0
	emit_changed(get_edited_property(), new_value)
