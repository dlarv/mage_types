@tool
extends PuzzleBlock


func _ready() -> void:
	_material = $MeshInstance3D.get_active_material(0)
	if _material != null:
		_material.albedo_color = Color.GRAY


#override
func set_stasis(val: Variant=null) -> void:
	super.set_stasis(val)
	if _material == null: return

	if in_stasis:
		on.emit(self)
		_material.albedo_color = Color.GREEN
	else:
		off.emit(self)
		_material.albedo_color = Color.GRAY


func _get_mesh() -> MeshInstance3D: return null
