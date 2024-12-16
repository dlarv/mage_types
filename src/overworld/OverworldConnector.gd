extends Node3D

@export var battle_scene: PackedScene 
@export var world: Node3D
@export var overworld: Node3D

# Amount of time to wait between a battle ending and a new one starting.
@export var battle_delay: float

func _on_player_battle_started(allies: Array, items:Array, enemy:EnemyActor) -> void:
	var battle := battle_scene.instantiate()

	world.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(battle)
	battle.start(allies, items, enemy.team, enemy.ai)
	await battle.battle_ended
	battle.queue_free()
	
	for actor in allies:
		actor.current_hp = actor.hp
	for actor in enemy.team:
		actor.current_hp = actor.hp
	
	world.process_mode = Node.PROCESS_MODE_INHERIT

	# Prevent player from getting mobbed by enemies.
	# Wild enemies (those that do not need a cooldown) will wait until this is called.
	await get_tree().create_timer(battle_delay).timeout
	get_tree().call_group("wild_enemies", "_end_battle_cooldown")

func _on_player_pause_world(value: bool) -> void:
	overworld.process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED
