extends ColorRect

signal removed(control: Control)
signal clicked(control: Control)

enum MapIconShape { SQUARE } 

var shape: MapIconShape


func _init(shape: MapIconShape, color: Color, unitSize: float):
	set_deferred("size", Vector2(unitSize, unitSize))
	self.color = color
	self.shape = shape


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




