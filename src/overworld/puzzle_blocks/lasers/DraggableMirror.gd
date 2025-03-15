@tool
extends PuzzleBlock

var _prev_parent: Node3D = null
#
# func _ready() -> void:
# 	super._ready()
# 	position = position.snapped(Vector3(1, 1, 1))
# 	$Mirror.set_element(element)
# 	
# 	grabbable = find_child("Interactable", true)
# 	if not grabbable.is_connected("grabbed", _on_grabbable_grabbed):
# 		grabbable.interacted.connect(_on_grabbable_grabbed)
#
# func _on_grabbable_grabbed(obj:Node3D, player:Node3D) -> void:
# 	if _prev_parent == null:
# 		_prev_parent = get_parent()
# 		player.pickup_object(self, grabbable, true, Vector3.RIGHT)
# 		if not obj.is_connected("dropped",_on_grabbable_dropped):
# 			obj.call_deferred("connect", "dropped", _on_grabbable_dropped)
# 	else:
# 		_on_grabbable_dropped(obj, player)
#
# func _on_grabbable_dropped(obj:Node3D, player:Node3D) -> void:
# 	if not player: return
# 	if _prev_parent == null: return
# 	if player.held_object == self:
# 		call_deferred("drop")
# 		player.pickup_object(self, grabbable, false)


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
	$Mirror.in_stasis = in_stasis
	$Mirror._flicker_collider()

func drop() -> void:
	reparent(_prev_parent)
	_prev_parent = null
	var pos := global_position.snapped(Vector3(0.5, 0.5, 0.5))
	pos.y = global_position.y
	global_position = pos
