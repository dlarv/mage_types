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

func _ready() -> void:
	if ai:
		ai.battle_ended.connect(_on_battle_ended)

func _on_battle_ended(endState: Battle.EndState) -> void: 
	if not Engine.is_editor_hint() and endState == Battle.EndState.WON and disappear_on_defeat:
		get_parent().queue_free()

	battle_ended.emit(endState)
