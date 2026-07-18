@tool
extends Node3D 
class_name EnemyActor 

signal battle_ended(endState: Battle.EndState)

@export var ai: OpponentController 
@export var _team: Array[BattleActor]:
	set(value):
		_team = value
		team = value
var team: Array[BattleActor] = []
@export var disappear_on_defeat := true
@export var heal_player_after_battle := false

@export var _mesh: MeshInstance3D
@export var _defeat_fade_out_duration := 2.0

func _ready() -> void:
	if not Engine.is_editor_hint() and ai:
		ai.battle_ended.connect(_on_battle_ended)

func _on_battle_ended(endState: Battle.EndState) -> void: 

	if not Engine.is_editor_hint() and endState == Battle.EndState.WON:
		_animate_defeat()

	battle_ended.emit(endState)


func _animate_defeat() -> void:
	if not disappear_on_defeat: return
	elif not _mesh:
		get_parent().queue_free()
		return

	var mat := StandardMaterial3D.new()
	_mesh.material_override = mat
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
	mat.albedo_color = Color.BLACK

	var tween := create_tween()
	tween.tween_property(mat, "albedo_color:a", 0, _defeat_fade_out_duration)

	await tween.finished
	get_parent().queue_free()

