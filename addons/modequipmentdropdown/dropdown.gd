@tool
extends EditorProperty

var dropdown: OptionButton
var new_value := ""
# An internal value of the property.
var current_value := ""
# A guard against internal changes when the property is updated.
var updating := false

func _init(obj: ModEquipmentEffect) -> void:
	dropdown = OptionButton.new()

	for method in obj.TARGET_METHODS:
		dropdown.add_item(method)

	dropdown.item_selected.connect(_on_text_submitted)
	dropdown.selected = obj.TARGET_METHODS.find(obj.target_method)

	add_child(dropdown)
	add_focusable(dropdown)


func _update_property():
	var obj := get_edited_object()
	var prop := get_edited_property()
	var new_value = obj[prop]

	# Update the control with the new value.
	updating = true
	current_value = new_value

	obj.target_method = current_value

	updating = false


func _on_text_submitted(index: int) -> void:
	var text: StringName = get_edited_object().TARGET_METHODS[index]
	new_value = text
	emit_changed(get_edited_property(), new_value)
