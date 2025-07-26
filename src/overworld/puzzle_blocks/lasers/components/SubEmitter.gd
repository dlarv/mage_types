@tool
extends Node3D

signal laser_broken()

var laser: Laser
var mesh: MeshInstance3D:
	get:
		return $Scalar/MeshInstance3D

var _mat: BaseMaterial3D

var _prev_body: Node3D
var _prev_clay: MagiClay

var is_on := true

func _ready() -> void:
	_mat = StandardMaterial3D.new()
	_mat.emission_enabled = true
	_mat.emission = Color.WHITE
	mesh.set_surface_override_material(0, _mat)
	laser = Laser.new()

func _physics_process(delta: float) -> void:
	if not is_on or Engine.is_editor_hint(): return
	$RayCast3D.force_raycast_update()
	var body: Object = $RayCast3D.get_collider()

	if _prev_body != null and _prev_body != body:
		_prev_body.clear_laser()
		_prev_body = null
	if _prev_clay != null and _prev_clay != body:
		# Reset hash when object is removed from emitter.
		_prev_clay = null
		laser.rand_val = Time.get_ticks_usec()
	
	var distance: float
	if body:
		distance = global_position.distance_to($RayCast3D.get_collision_point())
		if body.get_collision_layer_value(4):
			if _prev_body != body:
				_prev_body = body
				body.set_laser(laser, $RayCast3D.get_collision_point())
		elif not body.get_collision_layer_value(5) and body.get_collision_layer_value(3) and body is MagiClay:
			body.react(laser.element, laser.rand_val)
			laser_broken.emit()
			_prev_clay = body
	else:
		distance = $RayCast3D.target_position.z

	$Scalar.scale.z = distance


func start() -> void:
	is_on = true 
	laser.rand_val = Time.get_ticks_usec()
	$RayCast3D.enabled = true
	$Scalar.show()


func stop() -> void:
	if not is_on: return
	is_on = false
	$RayCast3D.enabled = false
	$Scalar.hide()
	if _prev_body != null:
		_prev_body.clear_laser()
		_prev_body = null


## Acts like start/stop, but preserves laser data.
func pause(val: bool) -> void:
	if val:
		stop()
	else:
		start()


func set_element(e: ElementalType) -> void:
	if Engine.is_editor_hint() or not is_inside_tree(): return
	laser.element = e
	_mat.albedo_color = e.main_color
	_mat.emission = e.main_color
	mesh.set_surface_override_material(0, _mat)
	laser.rand_val = Time.get_ticks_usec()

	if not is_on:
		return
	pause(true)
	await get_tree().create_timer(0.001).timeout
	pause(false)
