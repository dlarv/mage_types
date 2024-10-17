@tool
@icon("res://addons/NpcIcon.png")
extends Node3D

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
@export var size := 1.0:
	set(value):
		size = value
		var s = Vector3(size, size, size)
		var h = (size - 1) * .5 + .25

		if _mesh_instance != null: 
			_mesh_instance.scale = s
			_mesh_instance.position.y = h
		if len(_actors) == 0:
			find_actors()
		resize_actors()

var _actors := []
var _next_pass := StandardMaterial3D.new()

func _ready():
	find_actors()
	resize_actors()

func find_actors() -> void:
	_actors = []
	for child in get_children(true):
		if child is StoryActor or child is EnemyActor:
			_actors.append(child)

func resize_actors() -> void:
	var s = Vector3(size, size, size)
	var h = (size - 1) * .5 + .25
	for actor in _actors:
		actor.set_size(s, h)
