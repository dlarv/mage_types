@tool
extends PuzzleBlock

var _prev_val := -1

func _on_rotated(obj:Node3D, player:Node3D) -> void:
	rotation_degrees.y += 90

func _on_area_3d_x_body_entered(body:Node3D) -> void:
	_on_body_entered(body, global_transform.basis.z, $Marker3DZ)

func _on_area_3d_z_body_entered(body:Node3D) -> void:
	_on_body_entered(body, -global_transform.basis.x, $Marker3DX)

func _on_body_entered(body: Node3D, direction: Vector3, marker: Node3D) -> void:
	if not body.get_collision_layer_value(5): return
	
	var e := ElementManager.get_matchup(element, body.element)

	if body.rand_val != _prev_val: 
		_prev_val = body.rand_val
		create_log(self, e)

	if in_stasis or e == null or e.is_blank():
		e = body.element
	

	var laser := body.duplicate()
	body.linear_velocity = Vector3.ZERO
	var pos := marker.position
	laser.setup(pos, direction, e, _prev_val)
	add_child(laser)
	laser.global_position.y = body.global_position.y

func create_log(body: MagiClay, e: ElementalType) -> void:
	if in_stasis:
		Logger.append_log(Logger.LogType.PUZZLE, "Mirror(%s) in stasis collided with laser of Element(%s)."
			% [puzzle_name, body.element.name])
	elif e == null or e.is_blank():
		Logger.append_log(Logger.LogType.PUZZLE, "Mirror(%s) of Element(%s) collided with laser of Element(%s)."
			% [puzzle_name, element.name, body.element.name])
	else:
		Logger.append_log(Logger.LogType.PUZZLE, "Mirror(%s) of Element(%s) transmuted laser of Element(%s) into Element(%s)." 
			% [puzzle_name, element.name, body.element.name, e.name])
