extends Node2D

@export var character_builder: Control
@export var battle_scene: PackedScene

func _on_character_builder_setup_finished(team1:Array, items:Array, team2:Array, ai) -> void:
	var battle = battle_scene.instantiate()

	character_builder.hide()
	battle.Start(team1, items, team2, ai)
	add_child(battle)
	await battle.BattleEnded
	battle.queue_free()
	character_builder.show()
