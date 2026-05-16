@tool
extends Node3D

@export var battle_actor: BattleActor
@export var mesh: MeshInstance3D
@export_tool_button("Recolor") var recolor := func() -> void:
	if not mesh or not battle_actor: 
		push_warning("No mesh or battle actor assigned")
		return

	var mat: ShaderMaterial = mesh.get_active_material(0)
	mat.set_shader_parameter("color_1", battle_actor.element1.main_color)
	mat.set_shader_parameter("color_2", battle_actor.element2.main_color)
