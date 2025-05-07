extends Node3D
## There should only be one PuzzleBlock child, which will be the object moved.

signal slide_started()
signal slide_ended()

@export var point_a: Marker3D
@export var point_b: Marker3D
@export var speed := 300.0
@export var _buffer_offset := 0.1

var puzzle_name: String

var _puzzle_block: Node3D
var _in_motion := false
var _farther_point: Vector3


func _ready() -> void:
	puzzle_name = "%s.%s" % [ get_parent().name, name ]
	for child in get_children():
		if not child is Marker3D:
			_puzzle_block = child


func _process(delta: float) -> void:
	if not _in_motion: return

	if _puzzle_block.global_position.distance_squared_to(_farther_point) <= _buffer_offset:
		_in_motion = false
		_puzzle_block.global_position = _farther_point
		slide_ended.emit()
		return

	var dir := _puzzle_block.global_position.direction_to(_farther_point).normalized()
	_puzzle_block.global_position += dir * speed * delta


func _on_interactable_interacted(obj:Node3D) -> void:
	slide()


func slide(_v :Variant=null) -> void:
	_in_motion = true
	var d1 := _puzzle_block.global_position.distance_squared_to(point_a.global_position)
	var d2 := _puzzle_block.global_position.distance_squared_to(point_b.global_position)
	if d1 > d2:
		_farther_point = point_a.global_position
	elif d2 > d1:
		_farther_point = point_b.global_position
	elif _farther_point == point_a.global_position:
		_farther_point = point_b.global_position
	else:
		_farther_point = point_a.global_position
	slide_started.emit()
