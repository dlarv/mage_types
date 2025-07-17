extends ColorRect

signal removed(control: Control)
signal clicked(control: Control)

enum MapIconShape { SQUARE } 

var shape: MapIconShape


func _init(shape: MapIconShape, element: ElementalType, unitSize: float):
	set_deferred("size", Vector2(unitSize, unitSize))
	self.shape = shape
	self.color = element.main_color
	add_to_group("elemental_gui")
	set_meta("ELEMENT", element.name.substr(0, 1).to_upper())


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("remove_map_icon"):
		removed.emit(self)
	elif event.is_action_pressed("clicked_map_icon"):
		clicked.emit(self)


func serialize() -> Dictionary:
	return {
		"shape": shape,
		"color": color,
		"size": size.x,
		"position": position,
	}




