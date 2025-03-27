extends MarginContainer

signal item_selected(item: Item)

var _buttons := []
var _current_selected_item: Item = null

func setup(items: Array) -> void:
	for item in items:
		var button := Button.new()
		button.text = _format_name(item)
		button.visible = item.quantity > 0
		button.pressed.connect(_on_item_pressed.bind(item))

		_buttons.append(button)
		%SpellsScroller.add_child(button)


func change_quantity(item: ItemSlot) -> void:
	_buttons[item.id].text = _format_name(item)
	_buttons[item.id].visible = item.quantity > 0


func _on_item_pressed(item: ItemSlot) -> void:
	_current_selected_item = item.item
	%InfoDisplay.display_message_non_blocking(item)
	%Controls_HBox.show()


func _format_name(item: ItemSlot) -> String:
	return "(x%03d) %s" % [ item.quantity, item.item.name]


func _on_alnum_check_box_toggled(toggledOn: bool) -> void:
	pass # Replace with function body.


func _on_id_check_box_toggled(toggledOn: bool) -> void:
	pass # Replace with function body.

func _on_item_selected() -> void:
	item_selected.emit(_current_selected_item)
	%InfoDisplay.clear_message()
	%Controls_HBox.hide()

func _on_item_canceled() -> void:
	%InfoDisplay.clear_message()
	_current_selected_item = null
	%Controls_HBox.hide()
