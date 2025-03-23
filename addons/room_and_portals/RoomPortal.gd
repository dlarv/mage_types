@tool
extends Area3D

var _player: Node3D = null
var door1: CollisionShape3D
var point1: Vector3
var door2: CollisionShape3D
var point2: Vector3

func _enter_tree() -> void:
	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)
	child_entered_tree.connect(_on_child_entering_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)


func _on_child_entering_tree(child: Node3D) -> void:
	if not child is CollisionShape3D: return
	if not door1:
		door1 = child
	elif not door2:
		door2 = child

func _on_child_exiting_tree(child: Node3D) -> void:
	if child == door1:
		door1 = null
	elif child == door2:
		door2 = null


func _ready() -> void:
	if door1:
		point1 = door1.get_child(0).global_position
	if door2:
		point2 = door2.get_child(0).global_position


func _on_body_shape_entered(bodyRid:RID, body:Node3D, bodyShapeIndex:int, localShapeIndex:int) -> void:
	_player = body

	var shapeOwner := shape_find_owner(localShapeIndex)
	var shapeNode := shape_owner_get_owner(shapeOwner)
	if shapeNode == door1:
		_player.global_position = point2
	else:
		_player.global_position = point1


func _on_body_shape_exited(bodyRid:RID, body:Node3D, bodyShapeIndex:int, localShapeIndex:int) -> void:
	if not _player or not body.is_in_group("player"): return
	_player = null

