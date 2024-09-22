extends Node3D

@export var battle_scene: PackedScene 
@export var overworld: Node3D
@export var world: Node3D
@export var pause_menu: Control

func _on_player_battle_started(allies:Array, items:Array, enemy:Node3D) -> void:
	var battle = battle_scene.instantiate()

	world.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(battle)
	battle.start(allies, items, enemy.team, enemy.ai)
	await battle.battle_ended
	battle.queue_free()
	world.process_mode = Node.PROCESS_MODE_INHERIT
