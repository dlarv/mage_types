@tool
extends Node3D

@export var battle_actor: BattleActor
@export var mesh: MeshInstance3D
@export_tool_button("Recolor") var recolor := func() -> void:
	if not mesh or not battle_actor or not _special_material: 
		push_warning("Missing data! Mesh(%b), BattleActor(%b), SpecialShader(%b)"
			%[mesh != null, battle_actor != null, _special_material != null])
		return

	_special_material.set_shader_parameter("color_1", battle_actor.element1.main_color)
	_special_material.set_shader_parameter("color_2", battle_actor.element2.main_color)

@export var use_special_shader := true

@export var _special_material: ShaderMaterial
var _standard_material: StandardMaterial3D
var _active_material: Material


func _ready() -> void:
	if Engine.is_editor_hint(): return
	if not mesh or not battle_actor or not _special_material: 
		push_warning("Missing data! Mesh(%b), BattleActor(%b), SpecialShader(%b)"
			%[mesh != null, battle_actor != null, _special_material != null])
		use_special_shader = false
		return

	_standard_material = mesh.get_active_material(0)

	if not use_special_shader and not _standard_material:
		push_warning("Character(%s).use_special_shader is false, but no Standard Material found. Forced to use special" % battle_actor.name)
		_active_material = _special_material
	elif use_special_shader:
		_active_material = _special_material
	else:
		_active_material = _standard_material
		return

	battle_actor.element_changed.connect(_change_element)
	mesh.material_override = _active_material

	_change_element(0, battle_actor.element1)
	_change_element(1, battle_actor.element2)

		
func _switch_material() -> void:
	if not use_special_shader: return
	if _active_material == _standard_material:
		_active_material = _special_material
	else:
		_active_material = _standard_material
	
	mesh.material_override = _active_material


func _change_element(id: int, element: ElementalType) -> void:
	_special_material.set_shader_parameter("color_%d" % (id+1), element.main_color)
