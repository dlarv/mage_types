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
		create_log(self, e)

	if in_stasis or e == null or e.is_blank():
		e = laser.element

	subEmitter.laser.rand_val = laser.rand_val
	subEmitter.set_element(e)
	subEmitter.start()
	
func create_log(body: MagiClay, e: ElementalType) -> void:
	if in_stasis:
		Logger.append_puzzle_log("Mirror(%s) in stasis collided with laser of Element(%s)."
			% [puzzle_name, body.element])
	elif e == null or e.is_blank():
		Logger.append_puzzle_log("Mirror(%s) of Element(%s) collided with laser of Element(%s)."
			% [puzzle_name, element, body.element])
	else:
		Logger.append_puzzle_log("Mirror(%s) of Element(%s) transmuted laser of Element(%s) into Element(%s)." 
			% [puzzle_name, element, body.element, e])

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
func _flicker_collider() -> void:
	block(true)
	await get_tree().create_timer(0.01).timeout
	block(false)

func block(val: bool) -> void:
	$Blocker.set_collision_layer_value(5, val)
