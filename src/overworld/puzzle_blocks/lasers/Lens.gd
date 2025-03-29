@tool
extends PuzzleBlock

var _prev_val := -1
var _active_emitter: Node3D = null
var _active_receiver: Node3D = null
var _active_material: BaseMaterial3D = null
var _is_emitting := false
var _material_2: BaseMaterial3D

func _ready() -> void:
	_material_2 = StandardMaterial3D.new()
	super._ready()
	$SubEmitter1.stop()
	$SubEmitter2.stop()


func _on_sub_receiver_2_laser_received(laser:Laser, point:Vector3) -> void:
	if _is_emitting: 
		Logger.append_puzzle_log("Lens(%s) emitting laser of Element(%s), but was hit with a laser of Element(%s)."
				% [puzzle_name, _active_emitter.laser.element.name, laser.element.name])
		# _flicker_collider()
		return
	$SubEmitter1.stop()
	$SubEmitter2.stop()
	_active_receiver = $SubReceiver2

	_active_material = _material
	_on_laser_received($SubEmitter1, laser, point)


func _on_sub_receiver_1_laser_received(laser:Laser, point:Vector3) -> void:
	if _is_emitting: 
		Logger.append_puzzle_log("Lens(%s) emitting laser of Element(%s), but was hit with a laser of Element(%s)."
				% [puzzle_name, _active_emitter.laser.element.name, laser.element.name])
		# _flicker_collider()
		return
	$SubEmitter1.stop()
	$SubEmitter2.stop()
	_active_receiver = $SubReceiver1

	_active_material = _material_2
	_on_laser_received($SubEmitter2, laser, point)


func _on_laser_received(subEmitter: Node3D, laser: Laser, point: Vector3) -> void:
	if in_stasis: return
	_is_emitting = true
	subEmitter.global_position.y = point.y
	_active_emitter = subEmitter

	var e := ElementManager.get_matchup(element, laser.element)
	if e:
		_active_material.albedo_color = e.main_color.darkened(0.5)
	else:
		_try_set_color()

	if laser.rand_val != _prev_val: 
		_prev_val = laser.rand_val
		create_log(self, e)

	if in_stasis or e == null or e.is_blank():
		e = laser.element

	subEmitter.laser.rand_val = laser.rand_val
	subEmitter.set_element(e)
	subEmitter.start()


func set_stasis(val=null) -> void:
	super.set_stasis(val)
	if not _active_emitter: return
	
	_active_emitter.pause(in_stasis)
	if not in_stasis:
		_active_material.albedo_color = _active_emitter.laser.element.main_color.darkened(0.5)


func _flicker_collider() -> void:
	var val := collision_layer
	set_collision_layer_value(3, false)
	await get_tree().create_timer(0.01).timeout
	set_collision_layer_value(3, true)


func _on_laser_dropped() -> void:
	_is_emitting = false
	if _active_emitter:
		_active_emitter.stop()
		var e = _active_emitter.laser.element.name if _active_emitter != null else "null"
		Logger.append_puzzle_log("Lens(%s) stopped emitting laser of Element(%s)."
				% [puzzle_name, e])
		_active_emitter = null
		_active_receiver = null
		_active_material = null
		_try_set_color()


func create_log(body: MagiClay, e: ElementalType) -> void:
	if in_stasis:
		Logger.append_puzzle_log("Lens(%s) in stasis collided with laser of Element(%s)."
			% [puzzle_name, body.element.name])
	elif e == null or e.is_blank():
		Logger.append_puzzle_log("Lens(%s) of Element(%s) collided with laser of Element(%s)."
			% [puzzle_name, element.name, body.element.name])
	else:
		Logger.append_puzzle_log("Lens(%s) of Element(%s) transmuted laser of Element(%s) into Element(%s)." 
			% [puzzle_name, element.name, body.element.name, e.name])


func _set_material(mat: BaseMaterial3D) -> void:
	_material = mat 
	_material_2 = mat.duplicate(true)
	if _mesh_instance == null:
		push_warning("%s has no mesh!" % puzzle_name)
		return

	$MeshInstance3D.set_surface_override_material(0, _material)
	$MeshInstance3D2.set_surface_override_material(0, _material_2)
	_try_set_color()


func _try_set_color(color=null) -> bool:
	if not super._try_set_color(color): return false
	_material_2.albedo_color = _material.albedo_color
	return true
