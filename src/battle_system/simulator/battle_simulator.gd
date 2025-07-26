extends Node2D

@export var character_builder: Control
@export var battle_scene: PackedScene

func _on_character_builder_setup_finished(team1:Array[BattleActor], items:Array[RegularItem], team2:Array[BattleActor], ai: OpponentController) -> void:
	var battle := battle_scene.instantiate()

	character_builder.hide()
	battle.start(team1, items, team2, ai)
	add_child(battle)
	await battle.battle_ended
	battle.queue_free()
	character_builder.show()
