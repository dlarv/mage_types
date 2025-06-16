@tool
extends PuzzleBlock


func _enter_tree() -> void:
	var mat := StandardMaterial3D.new()
	if Engine.is_editor_hint():
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.blend_mode = BaseMaterial3D.BLEND_MODE_MUL
	else:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	$MeshInstance3D.set_surface_override_material(0, mat)

	$LaserReceiver.on.connect(func(obj: PuzzleBlock): on.emit(self))
	$LaserReceiver.off.connect(func(obj: PuzzleBlock): off.emit(self))
	$LaserReceiver.invalid_off.connect(func(obj: PuzzleBlock): invalid_off.emit(self))


func set_element(e: ElementalType, r:=-2, f:=false) -> bool:
	return $LaserReceiver.set_element(e, r, f)


func _get_mesh() -> MeshInstance3D:
	return null

func flicker_collider() -> void:
	pass
