extends PuzzleBlock

var _prev_val := -1
var _is_emitting := false


func _enter_tree() -> void:
	$SubEmitter.stop()


func _on_laser_received(laser:Laser, point:Vector3) -> void:
	_is_emitting = true

	if laser.rand_val != _prev_val: 
		_prev_val = laser.rand_val
		Logger.append_puzzle_log("Bridge(%s) collided with laser of Element(%s)."
			% [puzzle_name, laser.element])

	if not set_element(laser.element): return

	$SubEmitter.laser.rand_val = laser.rand_val
	$SubEmitter.set_element(laser.element)
	$SubEmitter.start()


func _on_laser_dropped() -> void:
	_is_emitting = false
	element = ElementManager.Blank
	_try_set_color()
	$SubEmitter.stop()


func create_log(body: MagiClay, newElement: ElementalType, laser: Laser) -> void:
	pass
	# if in_stasis:
	# 	Logger.append_puzzle_log("Bridge(%s) in stasis collided with laser of Element(%s)."
	# 		% [puzzle_name, laser.element])
	# elif newElement == null or newElement.is_blank():
	# 	Logger.append_puzzle_log("Bridge(%s) of Element(%s) collided with laser of Element(%s)."
	# 		% [puzzle_name, element, laser.element])
	# else:
	# 	Logger.append_puzzle_log("Mirror(%s) of Element(%s) transmuted laser of Element(%s) into Element(%s)." 
	# 		% [puzzle_name, element, laser.element, newElement])

func _get_mesh() -> MeshInstance3D:
	return $Model/Bridge
