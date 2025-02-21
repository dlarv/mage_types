extends MagiClay

var _objects_in_influence := []

func _on_body_exited(body:Node3D) -> void:
	var index := _objects_in_influence.find(body)
	if index != -1:
		_objects_in_influence.remove_at(index)


func _on_body_entered(body:Node3D) -> void:
	# if not body is MagiClay: return
	_objects_in_influence.append(body)
	print(body.name)

# func _get_mesh() -> MeshInstance3D:
# 	return null


