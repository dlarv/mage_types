@tool
extends Node3D

const FresnelShader := preload("res://assets/shaders/battle_actor_shader/fresnel.gdshader")
const AURA_ALPHA := 0.5
const TRANS_FADE_OUT_DELAY := .3

@export var mesh: MeshInstance3D
@export var material: ShaderMaterial
@export var flicker_delay: float

var _gradient: Gradient


func setup(actor: BattleActor) -> void: 
	material = material.duplicate_deep()

	_gradient = material.get_shader_parameter("gradient").gradient
	%DefaultMesh.material_override = material
	%DefaultMesh.show()

	set_element(0, actor.element1)
	set_element(1, actor.element2)

	if mesh == %DefaultMesh:
		material.set_shader_parameter("alpha", 1)
		return 

	material.set_shader_parameter("alpha", AURA_ALPHA)

	if not Battle.selection_phase_started.is_connected(_on_selection_phase_started):
		Battle.selection_phase_started.connect(_on_selection_phase_started)
	if not Battle.action_phase_started.is_connected(_on_action_phase_started):
		Battle.action_phase_started.connect(_on_action_phase_started)


func play_intro() -> void:
	if mesh == %DefaultMesh: return

	var shape: SphereMesh = %DefaultMesh.mesh

	var radius := shape.radius
	shape.radius = 0
	var height := shape.height
	shape.height = 0

	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(shape, "radius", radius, 1)
	tween.tween_property(shape, "height", height, 1)

	await tween.finished
	%DefaultMesh/AnimationPlayer.play_backwards("fade_out")


func set_element(id: int, element: ElementalType) -> void: 
	_gradient.set_color(id, element.main_color)


func fade_aura(fadeIn: bool) -> void:
	if mesh == %DefaultMesh: return

	if fadeIn:
		%DefaultMesh/AnimationPlayer.play_backwards("fade_out")
		await %DefaultMesh/AnimationPlayer.animation_finished
	else:
		await get_tree().create_timer(TRANS_FADE_OUT_DELAY).timeout
		%DefaultMesh/AnimationPlayer.play("fade_out")


func set_defeated() -> void: 
	await get_tree().create_timer(flicker_delay).timeout
	%DefaultMesh/AnimationPlayer.play("flicker")


func _flicker(alpha: int) -> void:
	material.set_shader_parameter("alpha", alpha)


func _on_selection_phase_started() -> void:
	if mesh == %DefaultMesh: return
	%DefaultMesh/AnimationPlayer.play_backwards("fade_out")


func _on_action_phase_started() -> void:
	if mesh == %DefaultMesh: return
	%DefaultMesh/AnimationPlayer.play("fade_out")
