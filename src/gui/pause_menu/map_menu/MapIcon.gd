extends ColorRect

signal removed(control: Control)
signal clicked(control: Control)

enum MapIconShape { SQUARE } 

var shape: MapIconShape
var element: ElementalType


func _init(shape: MapIconShape, element: ElementalType, unitSize: float) -> void:
	set_deferred("size", Vector2(unitSize, unitSize))
	self.shape = shape
	self.color = element.main_color
	self.element = element
	add_to_group("elemental_gui")
	add_to_group("%s_map_icon" % MapIconShape.keys()[shape].to_lower())
	set_meta("ELEMENT", element.name.substr(0, 1).to_upper())


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("remove_map_icon"):
		removed.emit(self)
	elif event.is_action_pressed("clicked_map_icon"):
		clicked.emit(self)


func serialize() -> Dictionary:
	return {
		"shape": shape,
		"element": ElementManager.get_index_from_name(element.name),
		"size": size.x,
		"position": position,
	}
