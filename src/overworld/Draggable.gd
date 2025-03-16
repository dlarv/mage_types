extends CharacterBody3D

@export var scaling_factor: float:
	get:
		return $Interactable.scaling_factor
	set(val):
		$Interactable.scaling_factor = val
@export var drag_speed := 10.0
@export var restrict_axis := false

var in_control := false
var puzzle_name := ""
var element := ElementManager.Blank
var player_collider: CollisionShape3D

# Array[Vector3]: Player is placed on the nearest one when they pick up this object.
var _handles := []
var _prev_player_parent: Node3D = null
var _prev_parent: Node3D = null
var _player: Node3D = null
var _current_axis := Vector3.ONE
var _initial_axis_linear_y = null

func _ready() -> void:
	player_collider = $PlayerCollider

	_handles = []
	for child in get_children():
		if child is Marker3D:
			_handles.append(child)
	
	var parent = get_parent()
	if  parent is MagiClay:
		puzzle_name = parent.puzzle_name
		element = parent.element

func _input(event: InputEvent) -> void:
	if not in_control: return

	if event.is_action_released("interact"):
		var n = name
		if "puzzle_name" in get_parent():
			n = get_parent().puzzle_name
		Logger.append_log(Logger.LogType.PUZZLE, "Player dropped Draggable(%s)." % n)

		drop()
		in_control = false
		

func _physics_process(delta: float) -> void:
	if not in_control: return
	velocity = Vector3.ZERO

	if Input.is_action_pressed("ui_up") and _current_axis.z > 0:
		velocity.z -= drag_speed
	elif Input.is_action_pressed("ui_down") and _current_axis.z > 0:
		velocity.z += drag_speed
	elif Input.is_action_pressed("ui_left") and _current_axis.x > 0:
		velocity.x -= drag_speed
	elif Input.is_action_pressed("ui_right") and _current_axis.x > 0:
		velocity.x += drag_speed

	# Snap to grid.
	if velocity == Vector3.ZERO:
		global_position = global_position.snapped(Vector3(0.5, 0.5, 0.5))
	else:
		move_and_slide()


func _on_interactable_interacted(interactable: Node3D) -> void:
	# This means player tried to pick up two objects at once, which isn't allowed.
	if not _player and not interactable._player.in_control: 
		interactable.ignore()
		return

	in_control = not in_control

	if in_control:
		_pickup(interactable._player)
	else:
		drop()

func _pickup(player: Node3D) -> void:
	_player = player
	_player.global_position = _snap_player_to_handle(_player.global_position)
	_player.look_towards(global_position)

	_make_root(_player)

	_player.in_control = false
	$CollisionShape3D.disabled = false
	player_collider.global_position = _player.global_position
	player_collider.global_position.y += 1
	player_collider.disabled = false

func drop() -> void:
	$CollisionShape3D.disabled = true
	player_collider.disabled = true

	_player.in_control = true
	_restore_root(_player)

func _snap_player_to_handle(pos: Vector3) -> Vector3:
	if len(_handles) == 0: return pos

	var minDist := INF
	var minHandle: Marker3D

	for handle in _handles:
		var dist = handle.global_position.distance_to(pos)
		if dist < minDist:
			minDist = dist
			minHandle = handle
	
	var output = minHandle.global_position
	output.y = pos.y

	# Calculate restricted axis, if applicable.
	var xPos = abs(global_position.x - minHandle.global_position.x)
	var zPos = abs(global_position.z - minHandle.global_position.z)
	if restrict_axis and xPos > zPos:
		_current_axis = Vector3(1, 0, 0)
	elif restrict_axis:
		_current_axis = Vector3(0, 0, 1)

	return output


func _make_root(player: Node3D) -> void:
	# Swap parent and Draggable w/o creating a cyclical dependency.
	var grandparent = get_parent().get_parent()
	var parent = get_parent()
	reparent(grandparent)
	parent.reparent(self)
	_prev_parent = parent

	# Prevent parent's physics body from colliding/altering state.
	if parent is RigidBody3D:
		_initial_axis_linear_y = parent.axis_lock_linear_y
		parent.axis_lock_linear_y = true
	_prev_parent.set_collision_layer_value(1, false)

	# Preserve player's initial state and reparent.
	_prev_player_parent = player.get_parent()
	player.reparent(self)
	player.set_collision_layer_value(1, false)

	# Allows draggable to activate chunks.
	set_collision_layer_value(6, true)


func _restore_root(player: Node3D) -> void:
	_prev_parent.reparent(get_parent())
	reparent(_prev_parent)

	# Restore control to parent's physics body.
	_prev_parent.set_collision_layer_value(1, true)
	if _prev_parent is RigidBody3D:
		_prev_parent.axis_lock_linear_y = _initial_axis_linear_y
		_initial_axis_linear_y = null

	# Restore player's state from before they picked up this item.
	player.reparent(_prev_player_parent)
	player.set_collision_layer_value(1, true)
	_player = null

	# Draggable can no longer activate chunks.
	set_collision_layer_value(6, false)
