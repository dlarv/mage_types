extends Area3D

@export var _collision_shape: CollisionShape3D
@export var size := Vector3(1, 1, 1):
	set(value):
		size = value
		if _collision_shape == null: return
		_collision_shape.size = size
@export var rewards: Array[Item]

var _already_triggered := false:
	set(value):
		_already_triggered = value
		if _collision_shape == null: return
		_collision_shape.disabled = _already_triggered



func _on_body_entered(body: Node3D) -> void:
	if _already_triggered or not body is Player: return
	_already_triggered = true

		
