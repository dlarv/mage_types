@tool
@icon("res://addons/NpcIcon.png")
extends RigidBody3D

@export var _mesh_instance: MeshInstance3D
@export 
var tint := Color.WHITE: 
	set(value):
		tint = value
		_next_pass.albedo_color = tint
@export 
var use_tint := false:
	set(value):
		use_tint = value

		# Return material to original state.
		_mesh_instance.set_surface_override_material(0, null)
		if not value: return

		# Create new unique base texture.
		var material := _mesh_instance.get_active_material(0).duplicate(true)
		_mesh_instance.set_surface_override_material(0, material)
		material.next_pass = _next_pass
		_next_pass.blend_mode = BaseMaterial3D.BLEND_MODE_MUL


var _next_pass := StandardMaterial3D.new()
