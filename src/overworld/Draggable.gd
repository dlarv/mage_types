extends CharacterBody3D

@export var scaling_factor: float:
	get:
		return $Interactable.scaling_factor
	set(val):
		$Interactable.scaling_factor = val
@export var restrict_axis := false
@export var weight := 1.0

var in_control := false
var puzzle_name := ""
var element := ElementManager.Blank
var parent: Node3D

var _handles: Array[Marker3D] = []
var _prev_parent: Node3D = null
var _prev_damp: float
var _prev_axis_lock: Array[bool] = [false, false, false]
var _player: Node3D = null
var _relative_direction := Vector3(INF, INF, INF)

var current_axis := Vector3.ONE
var current_handle: Marker3D = null

func _ready() -> void:
	parent = get_parent()

	_handles = []
	for child in get_children():
		if child is Marker3D:
			_handles.append(child)
	
	if parent is MagiClay:
		puzzle_name = parent.puzzle_name
		element = parent.element


func _input(event: InputEvent) -> void:
	if not in_control: return

	if event.is_action_released("interact"):
		var n := name
		if "puzzle_name" in get_parent():
			n = get_parent().puzzle_name
		MyLogger.append_puzzle_log("Player dropped Draggable(%s)." % n)

		drop()
		in_control = false
		

func _physics_process(delta: float) -> void:
	if not _player: return
	var dist := _player.global_position.distance_to(current_handle.global_position)
	if dist > 0.8:
		drop()


func _on_interactable_interacted(interactable: Node3D) -> void:
	if _player:
		drop()
		return
	# This means player tried to pick up two objects at once, which isn't allowed.
	elif not interactable.player.try_set_draggable(self):
		return

	pickup(interactable.player)


func pickup(player: Node3D) -> void:
	_player = player
	_player.global_position = _snap_player_to_handle(_player.global_position)
	_player.look_towards(global_position)

	if parent is RigidBody3D:
		if _player is RigidBody3D:
			_prev_damp = parent.linear_damp
			parent.linear_damp = _player.linear_damp
		_prev_axis_lock = [
			parent.axis_lock_angular_x,
			parent.axis_lock_angular_y,
			parent.axis_lock_angular_z]
		parent.axis_lock_angular_x = true
		parent.axis_lock_angular_y = true
		parent.axis_lock_angular_z = true

	_prev_parent = parent.get_parent()
	parent.reparent(_player)
	_player.draggable = self

	$Interactable.toggle_force_show(true)


func drop() -> void:
	_player.draggable = null
	_player = null
	parent.reparent(_prev_parent)
	if parent is RigidBody3D:
		parent.linear_damp = _prev_damp
		parent.axis_lock_angular_x = _prev_axis_lock[0]
		parent.axis_lock_angular_y = _prev_axis_lock[1]
		parent.axis_lock_angular_z = _prev_axis_lock[2]
	_relative_direction = Vector3.BACK

	$Interactable.toggle_force_show(false)


func move(velocity: Vector3) -> void:
	if parent is RigidBody3D:
		parent.linear_velocity = velocity


func _snap_player_to_handle(pos: Vector3) -> Vector3:
	if len(_handles) == 0: return pos

	var minDist := INF
	var minHandle: Marker3D

	for handle in _handles:
		var dist := handle.global_position.distance_to(pos)
		if dist < minDist:
			minDist = dist
			minHandle = handle
	
	var output := minHandle.global_position
	current_handle = minHandle
	output.y = pos.y

	# Calculate restricted axis, if applicable.
	var xPos: float = global_position.x - minHandle.global_position.x
	var zPos: float = global_position.z - minHandle.global_position.z
	if abs(xPos) > abs(zPos):
		current_axis = Vector3.RIGHT * xPos
	else:
		current_axis = Vector3.BACK * zPos
	current_axis = current_axis.normalized()
	print(current_axis)

	return output


func calculate_movement(d: Vector2) -> Vector3:
	var dir := Vector3(d.x, 0, d.y)

	if restrict_axis:
		return _calculate_restricted_movement(dir)
	elif d.length() == 0:
		return Vector3.ZERO

	var output: Vector3
	if dir.x > 0 or dir.x < 0:
		output = Vector3.RIGHT * sign(dir)
	else:
		output = Vector3.BACK * sign(dir)
	
	var dot := current_axis.dot(dir.normalized())
	if dot > 0.5:
		_relative_direction = Vector3.BACK
	elif dot < -0.5:
		_relative_direction = Vector3.FORWARD
	else:
		var angle := current_axis.signed_angle_to(dir, Vector3.UP)
		var invDot := dir.normalized().length() * current_axis.length() * sin(angle)
		if invDot > 0:
			_relative_direction = Vector3.LEFT
		else:
			_relative_direction = Vector3.RIGHT
	return output


func _calculate_restricted_movement(dir: Vector3) -> Vector3:
	var dot: float = current_axis.dot(dir.normalized())

	if abs(dot) < 0.5:
		_relative_direction = Vector3.ZERO
		return Vector3.ZERO

	if dot < 0: 
		_relative_direction = Vector3.BACK
	else:
		_relative_direction = Vector3.FORWARD

	return current_axis * sign(dir)


func get_relative_direction(dir: Vector3) -> Vector3:
	if not _relative_direction.is_finite(): 
		push_warning("Draggable(%s) relative direction read before write" % puzzle_name)
		return Vector3.ZERO

	return _relative_direction
