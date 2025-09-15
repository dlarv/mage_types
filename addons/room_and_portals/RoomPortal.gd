@tool
extends Area3D
## Allows player to teleport between two locations.
## For a two-way door, add two CollisionShape3D as children. Each shape should be the parent to a Marker3D.
## For a one-way door, add one CollisionShape/Marker and one Marker3D as children.

var door_1: CollisionShape3D
var point_1: Marker3D
var door_2: CollisionShape3D
## This can be overridden if multiple oneway doors should share the same exit.
@export var point_2: Marker3D:
	set(val):
		if point_1 and val == point_1: return
		point_2 = val
		update_gizmos()

var _player: Node3D = null
# Used by editor to know when to redraw gizmo.
var _prev_pos_1 := Vector3.ZERO
var _prev_pos_2 := Vector3.ZERO

func _enter_tree() -> void:
	if not body_shape_entered.is_connected(_on_body_shape_entered):
		body_shape_entered.connect(_on_body_shape_entered)
	if not body_shape_exited.is_connected(_on_body_shape_exited):
		body_shape_exited.connect(_on_body_shape_exited)
	if not child_entered_tree.is_connected(_on_child_entering_tree):
		child_entered_tree.connect(_on_child_entering_tree)
	if not child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.connect(_on_child_exiting_tree)
	
func _ready() -> void:
	if door_1 and not point_1:
		point_1 = door_1.get_child(0)
	if door_2 and not point_2:
		point_2 = door_2.get_child(0)

	if not Engine.is_editor_hint() and door_2:
		point_1.position = point_2.position


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
		if not door_1:
			door_1 = child
		elif not door_2 and child != door_1:
			door_2 = child
	elif child is Marker3D:
		if not door_1 and not point_1:
			point_1 = child
		elif not door_2 and not point_2:
			point_2 = child


func _on_child_exiting_tree(child: Node3D) -> void:
	if child == door_1:
		door_1 = null
	elif child == door_2:
		door_2 = null
	elif child == point_1:
		point_1 = null
	elif child == point_2:
		point_2 = null


func _on_body_shape_entered(bodyRid:RID, body:Node3D, bodyShapeIndex:int, localShapeIndex:int) -> void:
	if not body.is_in_group("player"): return
	if not is_complete():
		push_warning("Portal is not complete!")
		return
	_player = body

	var shapeOwner := shape_find_owner(localShapeIndex)
	var shapeNode := shape_owner_get_owner(shapeOwner)
	if shapeNode == door_1:
		var diff := point_1.global_position.direction_to(_player.global_position)
		diff *= point_1.global_position.distance_to(_player.global_position)
		_player.global_position = point_2.global_position + diff
	else:
		var diff := point_2.global_position.direction_to(_player.global_position)
		diff *= point_2.global_position.distance_to(_player.global_position)
		_player.global_position = point_1.global_position + diff


func _on_body_shape_exited(bodyRid:RID, body:Node3D, bodyShapeIndex:int, localShapeIndex:int) -> void:
	if not _player or not body.is_in_group("player"): return
	_player = null


## Returns true if this portal is one way (e.g. RoomPortal's direct children are 1 CollisionShape and 1 Marker)
func is_one_way(doorIndex:=-1) -> bool:
	match doorIndex:
		0: return not door_1 and point_1
		1: return not door_2 and point_2
		-1,_: return (not door_1 and point_1) or (not door_2 and point_2)


## Returns true if both sides of portal have been set up.
func is_complete() -> bool:
	return (door_1 and door_2) or (door_1 and point_2) or (door_2 and point_1)


func get_door_position(doorIndex:=0) -> Vector3:
	if doorIndex == 0:
		if door_1: return door_1.position
		elif point_1: return point_1.position
	else:
		if door_2: return door_2.position
		elif point_2: 
			if point_2.get_parent() == self:
				return point_2.position
			# Point2 was overridden in editor. 
			return point_2.global_position - global_position
	push_warning("Portal(%s) is not complete!" % name)
	return Vector3.ZERO
		

static func create_door(pos1: Vector3, pos2: Vector3, size: Vector3) -> Node3D:
	var output: Node3D = preload("RoomPortal.gd").new()

	var collider := CollisionShape3D.new()
	output.add_child(collider, true, INTERNAL_MODE_DISABLED)
	collider.shape = BoxShape3D.new()
	collider.shape.size = size
	collider.global_position = pos1
	collider.position.y = size.y / 2

	var marker1 := Marker3D.new()
	collider.add_child(marker1, true, INTERNAL_MODE_DISABLED)
	marker1.position.x = 0.8
	marker1.position.y = size.y / 2

	# Instantiate second door
	var collider2 := CollisionShape3D.new()
	output.add_child(collider2, true, INTERNAL_MODE_DISABLED)
	collider2.shape = BoxShape3D.new()
	collider2.shape.size = size

	var marker2 := Marker3D.new()
	collider2.add_child(marker2, true, INTERNAL_MODE_DISABLED)
	marker2.position.x = 0.8
	marker2.position.y = size.y / 2

	return output


static func create_half_door(pos: Vector3, marker: Marker3D, size: Vector3) -> Node3D:
	var output: Node3D = preload("RoomPortal.gd").new()

	var collider := CollisionShape3D.new()
	output.add_child(collider, true, INTERNAL_MODE_DISABLED)
	collider.shape = BoxShape3D.new()
	collider.shape.size = size
	collider.position = pos
	collider.position.y = size.y / 2

	var marker1 := Marker3D.new()
	collider.add_child(marker1, true, INTERNAL_MODE_DISABLED)
	marker1.position.x = 0.8

	output.point_2 = marker

	return output

