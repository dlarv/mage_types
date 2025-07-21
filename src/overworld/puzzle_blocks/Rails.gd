extends Node3D
## There should only be one PuzzleBlock child, which will be the object moved.

signal slide_started()
signal slide_ended()

@export var puzzle_block: PuzzleBlock = null
@export var point_a: Marker3D
@export var point_b: Marker3D
@export var speed := 300.0
@export var _buffer_offset := 0.1

var puzzle_name: String
var obj: Node3D

var _in_motion := false
var _farther_point: Vector3
var _slide_buffer := false
var _slide_buffer_delay := 0.8


func _enter_tree() -> void:
	puzzle_name = "%s.%s" % [ get_parent().name, name ]
	for child in get_children():
		if not child is Marker3D:
			obj = child
	
	if Engine.is_editor_hint(): return

	if puzzle_block:
		puzzle_block.on.connect(slide)
		puzzle_block.off.connect(slide)


func _process(delta: float) -> void:
	if not _in_motion: return

	if obj.global_position.distance_squared_to(_farther_point) <= _buffer_offset:
		_in_motion = false
		obj.global_position = _farther_point
		slide_ended.emit()

		if _slide_buffer:
			await get_tree().create_timer(_slide_buffer_delay).timeout
			_slide_buffer = false
			slide()
		return

	var dir := obj.global_position.direction_to(_farther_point).normalized()
	obj.global_position += dir * speed * delta


func _on_interactable_interacted(obj:Node3D) -> void:
	slide()


func slide(_v: Variant=null) -> void:
	if _in_motion: 
		_slide_buffer = true
		return
	_in_motion = true
	var d1 := obj.global_position.distance_squared_to(point_a.global_position)
	var d2 := obj.global_position.distance_squared_to(point_b.global_position)
	if d1 > d2:
		_farther_point = point_a.global_position
	elif d2 > d1:
		_farther_point = point_b.global_position
	elif _farther_point == point_a.global_position:
		_farther_point = point_b.global_position
	else:
		_farther_point = point_a.global_position
	slide_started.emit()
