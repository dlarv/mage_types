extends MarginContainer

const MapIcon := preload("res://src/gui/pause_menu/map_menu/MapIcon.gd")

func _ready() -> void:
	var elementIndex := 0
	for child in %SquareGridContainer.get_children():
		child.get_child(1).text_changed.connect(func(msg: String) -> void:
			var el := ElementManager.elements[elementIndex]
			get_parent().tooltips[["square_map_icon", el.name]] = msg
			var icons := get_tree().get_nodes_in_group("square_map_icon")
			for icon in icons:
				if icon.element == el:
					icon.tooltip_text = msg
			)
		elementIndex += 1


func serialize() -> Dictionary: return {}


func deserialize(data: Dictionary, tooltips: Dictionary) -> void:
	var i := 0
	for child in %SquareGridContainer.get_children():
		child.get_child(1).text = tooltips.get(["square_map_icon", ElementManager.elements[i].name], "")
		i += 1
