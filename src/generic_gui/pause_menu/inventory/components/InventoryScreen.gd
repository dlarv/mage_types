extends MarginContainer

var _buttons := []

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


func _on_item_pressed(item: ItemSlot) -> void:
	pass


func _format_name(item: ItemSlot) -> String:
	return "(x%03d) %s" % [ item.quantity, item.item.name]
