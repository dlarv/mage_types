@tool
extends Node

const FresnelShader := preload("res://assets/shaders/battle_actor_shader/fresnel.gdshader")
const AURA_ALPHA := 0.5

@export var mesh: MeshInstance3D
@export var material: ShaderMaterial
@export var flicker_delay: float

var _gradient: Gradient


func setup(actor: BattleActor) -> void: 
	_gradient = material.get_shader_parameter("gradient").gradient
	%DefaultMesh.material_override = material
	%DefaultMesh.show()
	
	if mesh == %DefaultMesh:
		mesh.material_override = material
		material.set_shader_parameter("alpha", 1)
		return

	material.set_shader_parameter("alpha", AURA_ALPHA)

	set_element(0, actor.element1)
	set_element(1, actor.element2)

	if not Battle.selection_phase_started.is_connected(_on_selection_phase_started):
		Battle.selection_phase_started.connect(_on_selection_phase_started)
	if not Battle.action_phase_started.is_connected(_on_action_phase_started):
		Battle.action_phase_started.connect(_on_action_phase_started)


func play_intro() -> void:
	var shape: SphereMesh = %DefaultMesh.mesh

	var radius := shape.radius
	shape.radius = 0
	var height := shape.height
	shape.height = 0

	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(shape, "radius", radius, 1)
	tween.tween_property(shape, "height", height, 1)


func set_element(id: int, element: ElementalType) -> void: 
	_gradient.set_color(id, element.main_color)


func set_defeated() -> void: 
	await get_tree().create_timer(flicker_delay).timeout
	%DefaultMesh/AnimationPlayer.play("flicker")


func _flicker(alpha: int) -> void:
	material.set_shader_parameter("alpha", alpha)


func _on_selection_phase_started() -> void:
	%DefaultMesh/AnimationPlayer.play_backwards("fade_out")


func _on_action_phase_started() -> void:
	%DefaultMesh/AnimationPlayer.play("fade_out")
