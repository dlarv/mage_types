extends StaticBody3D

var is_opened := false


func _on_grabbed(obj: Node3D, player: Node3D) -> void:
	if is_opened: return
	is_opened = true
	$Grabbable.set_disabled(true)
	_update_mesh()


func _update_mesh() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.BLACK
	$MeshInstance3D.set_surface_override_material(0, mat)
