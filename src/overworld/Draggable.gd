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
var parent: Node3D

# Array[Vector3]: Player is placed on the nearest one when they pick up this object.
var _handles := []
var _prev_parent: Node3D = null
var _player: Node3D = null
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
		var n = name
		if "puzzle_name" in get_parent():
			n = get_parent().puzzle_name
		Logger.append_log(Logger.LogType.PUZZLE, "Player dropped Draggable(%s)." % n)

		drop()
		in_control = false
		

func _physics_process(delta: float) -> void:
	if not _player: return
	var dist := _player.global_position.distance_to(current_handle.global_position)
	if dist > 1.0:
		drop()


func _on_interactable_interacted(interactable: Node3D) -> void:
	# This means player tried to pick up two objects at once, which isn't allowed.
	if not _player and interactable._player.is_dragging(): 
		interactable.ignore()
		return

	if not _player:
		pickup(interactable._player)
	else:
		drop()

func pickup(player: Node3D) -> void:
	_player = player
	_player.global_position = _snap_player_to_handle(_player.global_position)
	_player.look_towards(global_position)

	_prev_parent = parent.get_parent()
	parent.reparent(_player)
	_player.set_draggable(self)


func drop() -> void:
	_player.set_draggable(null)
	_player = null
	parent.reparent(_prev_parent)


func move(velocity: Vector3) -> void:
	if parent is RigidBody3D:
		parent.linear_velocity = velocity


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
	current_handle = minHandle
	output.y = pos.y

	# Calculate restricted axis, if applicable.
	var xPos = abs(global_position.x - minHandle.global_position.x)
	var zPos = abs(global_position.z - minHandle.global_position.z)
	if restrict_axis and xPos > zPos:
		current_axis = Vector3(1, 0, 0)
	elif restrict_axis:
		current_axis = Vector3(0, 0, 1)

	return output
