@tool
@icon("res://addons/NpcIcon.png")
extends RigidBody3D

@export var _mesh_instance: MeshInstance3D

@export var color: Color:
	set(value):
		color = value
		if _mesh_instance == null: return 
		var mat := _mesh_instance.get_surface_override_material(0)
		if mat == null: return
		mat.albedo_color = value

func _enter_tree():
	var mat := _mesh_instance.get_surface_override_material(0)
	if mat == null:
		_mesh_instance.set_surface_override_material(0, StandardMaterial3D.new())
	_mesh_instance.get_surface_override_material(0).albedo_color = color
