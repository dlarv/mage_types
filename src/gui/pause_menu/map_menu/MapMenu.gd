extends Menu

func serialize() -> Dictionary:
	var data := {}
	for child in get_children():
		# All maps are first/only grandchildren of this node.
		data[child.name] = child.get_child(0).serialize()

	return {
		"path": get_path(),
		"data": data
	}


func deserialize(data: Dictionary) -> void:
	for child in get_children():
		if child.name in data.data:
			child.get_child(0).deserialize(data.data[child.name])
