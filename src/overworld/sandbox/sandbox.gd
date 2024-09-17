extends Node3D

@export var battle_scene: PackedScene 
@export var overworld: Node3D
@export var world: Node3D

func _on_player_battle_started(allies:Array, items:Array, enemy:Node3D) -> void:
	var battle = battle_scene.instantiate()

	world.process_mode = Node.PROCESS_MODE_DISABLED
	battle.Start(allies, items, enemy.Team, enemy.Ai)
	add_child(battle)
	await battle.BattleEnded
	battle.queue_free()
	world.process_mode = Node.PROCESS_MODE_INHERIT

