extends Node3D

@export var puzzle_block: PuzzleBlock
@export var amount_degrees := 15.0
@export var buffer_offset := 0.01
@export var speed := 5.0
@export var _rotation_buffer_delay := 0.8

@onready var axis := transform.basis.z.normalized()

var obj: Node3D
var _in_motion := false
var _rotation_buffer := false
var _target := 0.0
var _snap_degrees := Vector3.ZERO


func _ready() -> void:
	if Engine.is_editor_hint(): return
	if puzzle_block:
		puzzle_block.on.connect(turn)


func _physics_process(delta: float) -> void:
	if not _in_motion: return
	if _target <= buffer_offset:
		_in_motion = false
		rotation_degrees = _snap_degrees

		if _rotation_buffer:
			await get_tree().create_timer(_rotation_buffer_delay).timeout
			_rotation_buffer = false
			turn()
	else:
		var amt := speed * delta * _target
		rotate(axis, amt)
		_target -= amt


func turn(_v: Variant=null) -> void:
	if _in_motion: 
		_rotation_buffer = true
		return
	_in_motion = true
	_target = deg_to_rad(amount_degrees)
	rotate(axis, _target)
	_snap_degrees = rotation_degrees
	rotate(axis, -_target)
