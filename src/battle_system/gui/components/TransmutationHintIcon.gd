extends ColorRect

@export var label: TextureRect

func set_element(element: ElementalType) -> void:
	if element == null:
		element = ElementManager.Blank

	color = element.main_color
	label.visible = element.is_blank()
