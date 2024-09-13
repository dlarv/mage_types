extends Node3D

@export var battle_scene: PackedScene 
@export var world: Node3D

func _on_player_battle_started(allies:Array, items:Array, enemy:Node3D) -> void:
	var battle = battle_scene.instantiate()

	world.process_mode = Node.PROCESS_MODE_DISABLED
	battle.Start(allies, items, enemy.Team, enemy.Ai)
	add_child(battle)
	await battle.BattleEnded
	world.process_mode = Node.PROCESS_MODE_INHERIT

