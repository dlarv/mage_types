@tool
@icon("res://addons/NpcIcon.png")
extends RigidBody3D

@export var _mesh_instance: MeshInstance3D
var _next_pass: StandardMaterial3D

@export var color: Color:
	set(value):
		color = value
		if _next_pass == null: return
		_next_pass.albedo_color = value

func _enter_tree():
	# _mesh_instance.set_surface_override_material(0, StandardMaterial3D.new())
	# _mesh_instance.get_surface_override_material(0).albedo_color = color
	var mat = _mesh_instance.get_active_material(0).duplicate()
	_mesh_instance.set_surface_override_material(0, mat)
	_next_pass = mat.next_pass.duplicate()
	_mesh_instance.get_active_material(0).next_pass = _next_pass
	_next_pass.albedo_color = color
