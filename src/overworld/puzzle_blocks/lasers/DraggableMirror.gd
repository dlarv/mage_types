@tool
extends PuzzleBlock

func _ready() -> void:
	super._ready()
	$Mirror.set_element(element, -2, true)


func _get_mesh() -> MeshInstance3D:
	return $Mirror/MeshInstance3D

# Override
func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	if super.set_element(e, randVal, force):
		$Mirror.set_element(e, randVal, force)
		$Mirror._original_element = e
		$Mirror._flicker_collider()
		return true
	return false

# Override
func set_stasis(val=null) -> void:
	super.set_stasis(val)
	# $Mirror.in_stasis = in_stasis
	# $Mirror._flicker_collider()
