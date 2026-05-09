@tool
extends MeshManager

const FresnelShader := preload("res://assets/shaders/battle_actor_shader/fresnel.gdshader")


@export var material: ShaderMaterial
@export_tool_button("Create Material") var create_material := func(grad:Gradient=null) -> void:
	material = ShaderMaterial.new()
	material.set_shader(FresnelShader.duplicate())

	var tex := GradientTexture1D.new()
	if not grad:
		_gradient = Gradient.new()
	else:
		_gradient = grad
	tex.gradient = _gradient

	material.set_shader_parameter("gradient", tex)
	material.set_shader_parameter("normal_map", normal_map)

	mesh.material_override = material

@export var normal_map: Texture2D

var _gradient: Gradient


func setup(actor: BattleActor) -> void: 
	var grad: Gradient = material.get_shader_parameter("gradient").gradient.duplicate()
	create_material.call(grad)

	_gradient.set_color(0, actor.element1.main_color)
	_gradient.set_color(1, actor.element2.main_color)


func set_element(id: int, element: ElementalType) -> void: 
	_gradient.set_color(id, element.main_color)


func set_defeated() -> void: 
	_gradient.set_color(0, Color.DARK_GRAY)
	_gradient.set_color(1, Color.GRAY)
