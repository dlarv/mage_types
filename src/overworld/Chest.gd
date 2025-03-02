extends StaticBody3D

@export var items: Array[ItemSlot]
var is_opened := false

func _on_grabbed(obj: Node3D, player: Node3D) -> void:
	if is_opened: return
	is_opened = true
	$Grabbable.set_disabled(true)
	var msg := "You opened a chest!"
	for item in items:
		msg += "[br]%s (x%d)" % [ item.item.name, item.quantity ]
		Inventory.add(item.item, item.quantity)
	await UIManager.show_dialog(msg)
	_update_mesh()



func _update_mesh() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.BLACK
	$MeshInstance3D.set_surface_override_material(0, mat)

func serialize() -> Dictionary:
	return {
		"path": get_path(),
		"opened": is_opened,
	}

func deserialize(data: Dictionary) -> void:
	if "opened" in data:
		is_opened = data["opened"]
		if is_opened:
			_update_mesh()
			$Grabbable.set_disabled(is_opened)
