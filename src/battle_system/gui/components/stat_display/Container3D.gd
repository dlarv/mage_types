@tool
extends Control

func _draw() -> void:
	var child: Node3D
	for c in get_children():
		if c is Node3D:
			child = c
			break

	child.global_position = get_viewport().get_camera_3d().project_position(global_position, 0)
