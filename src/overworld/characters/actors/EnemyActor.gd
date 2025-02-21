extends Node3D 
class_name EnemyActor 

@export var ai: OpponentController 
@export var team: Array[BattleActor]
@export var disappear_on_defeat := true


func _enter_tree() -> void:
	ai.battle_ended.connect(_on_battle_ended)

func _on_battle_ended(endState: Battle.EndState) -> void: 
	if not Engine.is_editor_hint() and endState == Battle.EndState.WON and disappear_on_defeat:
		get_parent().queue_free()

