@tool
extends Node3D

const Rails = preload("../Rails.gd")

@export var puzzle_block: PuzzleBlock
@export var base_instance: Rails:
	set(val):
		base_instance = val
		_update()
@export var instance_count := 1:
	set(val):
		instance_count = val
		_update()
@export var instance_offset: Vector3:
	set(val):
		instance_offset = val
		_update()
var _instances := []
var _index := -1


func _ready() -> void:
	if Engine.is_editor_hint(): return

	_instances.insert(0, base_instance)
	for instance in _instances:
		instance.point_a.get_child(0).visible = false
		instance.point_b.get_child(0).visible = false
	
	
	if puzzle_block:
		puzzle_block.on.connect(next)


func _update() -> void:
	for instance in _instances:
		remove_child(instance)
	_instances = []

	if not base_instance: return

	for i in instance_count - 1:
		var instance = base_instance.duplicate()
		_instances.append(instance)
		instance.position = instance_offset * (i + 1)
		add_child(instance)


func next(_v: Variant=null) -> void:
	if _index != -1:
		_instances[_index].slide()
	_index += 1
	_index %= len(_instances)
	_instances[_index].slide()
