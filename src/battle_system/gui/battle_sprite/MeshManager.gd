extends Node3D

const BattleActorShader := preload("res://assets/shaders/battle_actor_shader/battle_actor_shader.gdshader")

@export var mesh: MeshInstance3D
@export var complex_diffuse_1: Texture2D
@export var complex_diffuse_2: Texture2D

var _mat1: Material
var _mat2: Material

func setup(actor: BattleActor) -> void:
	if complex_diffuse_1:
		_mat1 = ShaderMaterial.new()
		mesh.set_surface_override_material(0, _mat1)
		#_mat1.shader = BattleActorShader.new()
		_mat1.shader =BattleActorShader.duplicate()
		_mat1.set_shader_parameter("element_id", int(actor.element1.id))
		_mat1.set_shader_parameter("diffuse_map", complex_diffuse_1)
	else:
		_mat1 = mesh.get_active_material(0)
		_mat1.albedo_color = actor.element1.main_color

	if complex_diffuse_2:
		_mat2 = ShaderMaterial.new()
		mesh.set_surface_override_material(1, _mat2)
		_mat2.shader =BattleActorShader.duplicate()
		_mat2.set_shader_parameter("element_id", int(actor.element2.id))
		_mat2.set_shader_parameter("diffuse_map", complex_diffuse_2)
	else:
		_mat2 = mesh.get_active_material(1)
		_mat2.albedo_color = actor.element2.main_color


func set_element(id: int, element: ElementalType) -> void:
	if id == 0:
		_set_mesh_color(_mat1, element)
	else:
		_set_mesh_color(_mat2, element)


func _set_mesh_color(mat: Material, element: ElementalType) -> void:
	if mat is ShaderMaterial:
		mat.set_shader_parameter("element_id", int(element.id))
	else:
		mat.albedo_color = element.main_color


func set_defeated() -> void:
	if _mat1 is ShaderMaterial:
		_mat1.set_shader_parameter("element_id", 8)
	else:
		_mat1.albedo_color = _mat1.albedo_color.darkened(0.5)
	if _mat2 is ShaderMaterial:
		_mat2.set_shader_parameter("element_id", 8)
	else:
		_mat2.albedo_color = _mat2.albedo_color.darkened(0.5)
