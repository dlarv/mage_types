@tool
extends Area3D
## Allows player to teleport between two locations.
## For a two-way door, add two CollisionShape3D as children. Each shape should be the parent to a Marker3D.
## For a one-way door, add one CollisionShape/Marker and one Marker3D as children.

var _player: Node3D = null
var door1: CollisionShape3D
var point1: Marker3D
var door2: CollisionShape3D
var point2: Marker3D

# Used by editor to know when to redraw gizmo.
var _prev_pos_1 := Vector3.ZERO
var _prev_pos_2 := Vector3.ZERO

func _enter_tree() -> void:
	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)
	child_entered_tree.connect(_on_child_entering_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)


func _ready() -> void:
	if door1 and not point1:
		point1 = door1.get_child(0)
	if door2 and not point2:
		point2 = door2.get_child(0)


func _process(delta: float) -> void:
	if not Engine.is_editor_hint(): return
	if not is_complete(): return

	var doRedraw := false
	if _prev_pos_1 != get_door_position(0):
		doRedraw = true
		_prev_pos_1 = get_door_position(0)
	if _prev_pos_2 != get_door_position(1):
		doRedraw = true
		_prev_pos_2 = get_door_position(1)

	if doRedraw:
		update_gizmos()


func _on_child_entering_tree(child: Node3D) -> void:
	if child is CollisionShape3D: 
		if not door1:
			door1 = child
		elif not door2:
			door2 = child
	elif child is Marker3D:
		if not door1 and not point1:
			point1 = child
		elif not door2 and not point2:
			point2 = child


func _on_child_exiting_tree(child: Node3D) -> void:
	if child == door1:
		door1 = null
	elif child == door2:
		door2 = null


func _on_body_shape_entered(bodyRid:RID, body:Node3D, bodyShapeIndex:int, localShapeIndex:int) -> void:
	_player = body

	var shapeOwner := shape_find_owner(localShapeIndex)
	var shapeNode := shape_owner_get_owner(shapeOwner)
	if shapeNode == door1:
		_player.global_position = point2.global_position
	else:
		_player.global_position = point1.global_position


func _on_body_shape_exited(bodyRid:RID, body:Node3D, bodyShapeIndex:int, localShapeIndex:int) -> void:
	if not _player or not body.is_in_group("player"): return
	_player = null


## Returns true if this portal is one way (e.g. RoomPortal's direct children are 1 CollisionShape and 1 Marker)
func is_one_way(doorIndex:=-1) -> bool:
	match doorIndex:
		0: return not door1 and point1
		1: return not door2 and point2
		-1,_: return (not door1 and point1) or (not door2 and point2)


## Returns true if both sides of portal have been set up.
func is_complete() -> bool:
	return (door1 and door2) or (door1 and point2) or (door2 and point1)

func get_door_position(doorIndex:=0) -> Vector3:
	if doorIndex == 0:
		if door1: return door1.position
		elif point1: return point1.position
	else:
		if door2: return door2.position
		elif point2: return point2.position
	push_warning("Portal(%s) is not complete!" % name)
	return Vector3.ZERO
		
