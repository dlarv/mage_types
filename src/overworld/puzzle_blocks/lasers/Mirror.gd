@tool
extends PuzzleBlock

var _prev_val := -1
var _active_emitter: Node3D = null
var _active_receiver: Node3D = null
var _is_emitting := false

func _ready() -> void:
	super._ready()
	$SubEmitterX.stop()
	$SubEmitterZ.stop()


func _on_sub_receiver_z_laser_received(laser:Laser, point: Vector3) -> void:
	if _is_emitting:
		Logger.append_puzzle_log("Mirror(%s) emitting laser of Element(%s), but was hit with a laser of Element(%s)."
				% [puzzle_name, _active_emitter.laser.element, laser.element])
		# _flicker_collider()
		return
	$SubEmitterX.stop()
	$SubEmitterZ.stop()
	_active_receiver = $SubReceiverZ
	_on_laser_received($SubEmitterX, laser, point)


func _on_sub_receiver_x_laser_received(laser:Laser, point: Vector3) -> void:
	if _is_emitting: 
		Logger.append_puzzle_log("Mirror(%s) emitting laser of Element(%s), but was hit with a laser of Element(%s)."
				% [puzzle_name, _active_emitter.laser.element, laser.element])
		# _flicker_collider()
		return
	$SubEmitterX.stop()
	$SubEmitterZ.stop()
	_active_receiver = $SubReceiverX

	_on_laser_received($SubEmitterZ, laser, point)


func _on_laser_received(subEmitter: Node3D, laser: Laser, point: Vector3) -> void:
	_is_emitting = true
	subEmitter.global_position.y = point.y
	_active_emitter = subEmitter
	var e := ElementManager.get_matchup(element, laser.element)

	if laser.rand_val != _prev_val: 
		_prev_val = laser.rand_val
		create_log(self, e, laser)

	if in_stasis or e == null or e.is_blank():
		e = laser.element

	subEmitter.laser.rand_val = laser.rand_val
	subEmitter.set_element(e)
	subEmitter.start()
	

func create_log(body: MagiClay, newElement: ElementalType, laser: Laser) -> void:
	if in_stasis:
		Logger.append_puzzle_log("Mirror(%s) in stasis collided with laser of Element(%s)."
			% [puzzle_name, laser.element])
	elif newElement == null or newElement.is_blank():
		Logger.append_puzzle_log("Mirror(%s) of Element(%s) collided with laser of Element(%s)."
			% [puzzle_name, element, laser.element])
	else:
		Logger.append_puzzle_log("Mirror(%s) of Element(%s) transmuted laser of Element(%s) into Element(%s)." 
			% [puzzle_name, element, laser.element, newElement])


func _on_laser_dropped() -> void:
	_is_emitting = false
	if _active_emitter:
		_active_emitter.stop()
		var e = _active_emitter.laser.element.name if _active_emitter != null else "null"
		Logger.append_puzzle_log("Mirror(%s) stopped emitting laser of Element(%s)."
				% [puzzle_name, e])
		_active_emitter = null
		_active_receiver = null


# Override
func flicker_collider() -> void:
	if Engine.is_editor_hint() or not is_inside_tree(): return
	block(true)
	await get_tree().create_timer(0.01).timeout
	block(false)


func block(val: bool) -> void:
	$Blocker.set_collision_layer_value(5, val)


func _set_size() -> void:
	var scaling := base_size * scaling_factor

	var mesh = $MeshInstance3D.mesh.duplicate(true)
	$MeshInstance3D.mesh = mesh
	mesh.size.z = scaling.y
	$MeshInstance3D.position.y = scaling.y / 2.0

	# Adjust size of main collider.
	var shape = $CollisionShape3D.shape.duplicate(true)
	$CollisionShape3D.shape = shape
	for i in len(shape.points):
		if i < 3:
			shape.points[i].y = 0
		else:
			shape.points[i].y = scaling.y
	

	# Adjust size of size of extra blockers.
	shape = $Blocker/CollisionShape3D.shape.duplicate(true)
	$Blocker/CollisionShape3D.shape = shape
	$Blocker/CollisionShape3D.shape.size.y = scaling.y * 1.5
	$Blocker.position.y = scaling.y * 1.5 / 2.0

	shape = $SubReceiverX/CollisionShape3D.shape.duplicate(true)
	$SubReceiverX/CollisionShape3D.shape = shape
	$SubReceiverX/CollisionShape3D.shape.size.y = scaling.y
	$SubReceiverX.position.y = scaling.y / 2.0

	shape = $SubReceiverZ/CollisionShape3D.shape.duplicate(true)
	$SubReceiverZ/CollisionShape3D.shape = shape
	$SubReceiverZ/CollisionShape3D.shape.size.y = scaling.y
	$SubReceiverZ.position.y = scaling.y / 2.0

	shape = $Area3D/CollisionShape3D.shape.duplicate(true)
	$Area3D/CollisionShape3D.shape = shape
	$Area3D/CollisionShape3D.shape.size.y = scaling.y
	$Area3D.position.y = scaling.y / 2.0
