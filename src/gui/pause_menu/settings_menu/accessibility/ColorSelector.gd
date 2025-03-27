extends MarginContainer

@export var element: ElementalType:
	set(val):
		element = val
		_set_color(element.main_color)
		$VBoxContainer/Label.text = element.name
		

func _on_color_changed(color:Color) -> void:
	ElementManager.modify_color(element, color)
	_set_color(color)

func _set_color(col: Color) -> void:
	$VBoxContainer/ColorRect.color = col
