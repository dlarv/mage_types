@tool
extends PuzzleBlock

var _prev_val := -1
var _active_emitter: Node3D = null
var _active_receiver: Node3D = null
var _active_material: Material = null
var _is_emitting := false
var _material_2: Material

func _ready() -> void:
	_material_2 = $MeshInstance3D.get_active_material(0)
	super._ready()
	$SubEmitter1.stop()
	$SubEmitter2.stop()


func _on_sub_receiver_2_laser_received(laser:Laser, point:Vector3) -> void:
	if _is_emitting: 
		MyLogger.append_puzzle_log("Lens(%s) emitting laser of Element(%s), but was hit with a laser of Element(%s)."
				% [puzzle_name, _active_emitter.laser.element, laser.element ])
		# _flicker_collider()
		return
	$SubEmitter1.stop()
	$SubEmitter2.stop()
	_active_receiver = $SubReceiver2

	_active_material = _material
	_on_laser_received($SubEmitter1, laser, point)


func _on_sub_receiver_1_laser_received(laser:Laser, point:Vector3) -> void:
	if _is_emitting: 
		MyLogger.append_puzzle_log("Lens(%s) emitting laser of Element(%s), but was hit with a laser of Element(%s)."
				% [puzzle_name, _active_emitter.laser.element, laser.element])
		# _flicker_collider()
		return
	$SubEmitter1.stop()
	$SubEmitter2.stop()
	_active_receiver = $SubReceiver1

	_active_material = _material_2
	_on_laser_received($SubEmitter2, laser, point)


func _on_laser_received(subEmitter: Node3D, laser: Laser, point: Vector3) -> void:
	# if in_stasis: return
	_is_emitting = true
	subEmitter.global_position.y = point.y
	_active_emitter = subEmitter

	var e := ElementManager.get_matchup(element, laser.element)
	if in_stasis or not e:
		e = laser.element
	elif e:
		_active_material.albedo_color = e.main_color.darkened(0.5)
	else:
		_try_set_color()

	if laser.rand_val != _prev_val: 
		_prev_val = laser.rand_val
		create_log(self, e)


	subEmitter.laser.rand_val = laser.rand_val
	subEmitter.set_element(e)
	subEmitter.start()


# func set_stasis(val=null) -> void:
# 	super.set_stasis(val)
# 	flicker_collider()
# 	if not _active_emitter: return
#
# 	_active_emitter.pause(in_stasis)
# 	if not in_stasis:
# 		_active_material.albedo_color = _active_emitter.laser.element.main_color.darkened(0.5)


# Override
func flicker_collider() -> void:
	if Engine.is_editor_hint() or not is_inside_tree(): return
	block(true)
	await get_tree().create_timer(0.01).timeout
	block(false)


func block(val: bool) -> void:
	$Blocker.set_collision_layer_value(5, val)
	$Blocker.set_collision_layer_value(3, val)


func _on_laser_dropped() -> void:
	_is_emitting = false
	if _active_emitter:
		_active_emitter.stop()
		var e: String = _active_emitter.laser.element.name if _active_emitter != null else "null"
		MyLogger.append_puzzle_log("Lens(%s) stopped emitting laser of Element(%s)."
				% [puzzle_name, e])
		_active_emitter = null
		_active_receiver = null
		_active_material = null


func create_log(body: MagiClay, e: ElementalType) -> void:
	if in_stasis:
		MyLogger.append_puzzle_log("Lens(%s) in stasis collided with laser of Element(%s)."
			% [puzzle_name, body.element])
	elif e == null or e.is_blank():
		MyLogger.append_puzzle_log("Lens(%s) of Element(%s) collided with laser of Element(%s)."
			% [puzzle_name, element, body.element])
	else:
		MyLogger.append_puzzle_log("Lens(%s) of Element(%s) transmuted laser of Element(%s) into Element(%s)." 
			% [puzzle_name, element, body.element, e])




#override
func _try_set_color(color:Variant=null) -> bool:
	if not super._try_set_color(color): return false
	#if in_stasis: _material_2.albedo_color = Color.BLACK
	_material_2.set_shader_parameter("element_id", element.id)
	return true
