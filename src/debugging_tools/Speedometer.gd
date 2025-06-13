extends Node3D

var _parent: Node3D
var _property: String

func _ready() -> void:
	_parent = get_parent()

	if _parent is RigidBody3D:
		_property = "linear_velocity"
	elif _parent is CharacterBody3D:
		_property = "velocity"


func _process(delta: float) -> void:
	var p: Vector3 = _parent.get(_property)
	print("Speedometer: (%.3f, %.3f, %.3f)" % [p.x, p.y, p.z])
