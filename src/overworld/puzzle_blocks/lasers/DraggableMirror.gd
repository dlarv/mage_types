@tool
extends PuzzleBlock

var _prev_parent: Node3D = null

func _ready() -> void:
	super._ready()
	position = position.snapped(Vector3(1, 1, 1))
	$Mirror.set_element(element)

func _on_child_entered_tree(node: Node) -> void:
	if node is Grabbable:
		if not node.is_connected("grabbed", _on_grabbable_grabbed):
			node.grabbed.connect(_on_grabbable_grabbed)
			
func _on_grabbable_grabbed(obj:Node3D, player:Node3D) -> void:
	if _prev_parent == null:
		_prev_parent = get_parent()
		# reparent(player)
		player.pickup_object(self, true, Vector3.RIGHT)
		if not obj.is_connected("dropped",_on_grabbable_dropped):
			obj.call_deferred("connect", "dropped", _on_grabbable_dropped)
	else:
		reparent(_prev_parent)
		_prev_parent = null
		player.pickup_object(self, false)
		if obj.is_connected("dropped",_on_grabbable_dropped):
			obj.call_deferred("disconnect", "dropped", _on_grabbable_dropped)

func _on_grabbable_dropped(obj:Node3D, player:Node3D) -> void:
	if player.held_object == self:
		call_deferred("reparent", _prev_parent)
		_prev_parent = null
		player.pickup_object(self, false)

		if obj.is_connected("dropped",_on_grabbable_dropped):
			obj.call_deferred("disconnect", "dropped", _on_grabbable_dropped)

		obj.position = obj.position.snapped(Vector3(1,1,1))

func _get_mesh() -> MeshInstance3D:
	return $Mirror/MeshInstance3D

# Override
func set_element(e: ElementalType, randVal:=-2) -> bool:
	if super.set_element(e, randVal):
		$Mirror.set_element(e, randVal)
		return true
	return false
