@tool
extends PuzzleBlock

var _prev_val := -1
var _active_emitter: Node3D = null
var _active_receiver: Node3D = null

func _ready() -> void:
	super._ready()
	$SubEmitterX.stop()
	$SubEmitterZ.stop()

func _on_sub_receiver_z_laser_received(laser:Laser, point: Vector3) -> void:
	$SubEmitterX.stop()
	$SubEmitterZ.stop()
	_active_receiver = $SubReceiverZ
	_on_laser_received($SubEmitterX, laser, point)

func _on_sub_receiver_x_laser_received(laser:Laser, point: Vector3) -> void:
	$SubEmitterX.stop()
	$SubEmitterZ.stop()
	_active_receiver = $SubReceiverX

	_on_laser_received($SubEmitterZ, laser, point)

func _on_laser_received(subEmitter: Node3D, laser: Laser, point: Vector3) -> void:
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
		Logger.append_log(Logger.LogType.PUZZLE, "Mirror(%s) in stasis collided with laser of Element(%s)."
			% [puzzle_name, body.element.name])
	elif e == null or e.is_blank():
		Logger.append_log(Logger.LogType.PUZZLE, "Mirror(%s) of Element(%s) collided with laser of Element(%s)."
			% [puzzle_name, element.name, body.element.name])
	else:
		Logger.append_log(Logger.LogType.PUZZLE, "Mirror(%s) of Element(%s) transmuted laser of Element(%s) into Element(%s)." 
			% [puzzle_name, element.name, body.element.name, e.name])

func _on_laser_dropped() -> void:
	if _active_emitter:
		_active_emitter.stop()
		_active_emitter = null
		_active_receiver = null

# Override
func _flicker_collider() -> void:
	# Use case example:
	# 1. Object is Blue and is sitting on a Purple pressure plate.
	# 2. Object is transmuted into Purple.
	# 3. Collider is flickered, which re-triggers pressure plate.
	if not _active_receiver: return
	var val = _active_receiver.collision_layer
	_active_receiver.collision_layer = 1
	_active_emitter.stop()
	await get_tree().create_timer(0.01).timeout
	_active_receiver.collision_layer = val
	_active_emitter.start()
