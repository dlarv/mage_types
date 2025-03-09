extends Menu

signal menu_closed(element: ElementalType)

var element: ElementalType = null

func open_menu(validElements: Dictionary) -> void:
	for child in %GridContainer.get_children():
		child.disabled = not validElements[child.name]
	
	element = null

func _on_element_button_pressed(element: ElementalType) -> void:
	self.element = element

func _on_close_button_pressed() -> void:
	menu_closed.emit(element)

