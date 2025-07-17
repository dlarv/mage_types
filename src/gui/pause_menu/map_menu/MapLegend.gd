extends MarginContainer

signal tool_tip_changed(shape: MapIcon.MapIconShape, element: ElementalType, msg: String)

const MapIcon := preload("res://src/gui/pause_menu/map_menu/MapIcon.gd")

func _ready() -> void:
	var elementIndex := 0
	for child in %GridContainer:
		child.get_child(1).text_changed.connect(func(msg: String):
			tool_tip_changed.emit(MapIcon.MapIconShape.SQUARE, ElementManager.elements[elementIndex], msg))

		elementIndex += 1



func serialize() -> Dictionary:
	return {}


func deserialize(data: Dictionary) -> void:
	pass
