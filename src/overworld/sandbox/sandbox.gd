extends Node3D

@export var battle_scene: PackedScene 
@export var overworld: Node3D
@export var world: Node3D
@export var pause_menu: Control
@export var dialog_box: DialogueBox

@export var _player: Player

func _ready():
	for actor in get_tree().get_nodes_in_group("dialog"):
		if not actor.dialog_started.is_connected(_on_dialog_started) \
				and "dialog_started" in actor: 
			actor.dialog_started.connect(_on_dialog_started)

func _on_player_battle_started(allies:Array, items:Array, enemy:EnemyActor) -> void:
	var battle := battle_scene.instantiate()

	world.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(battle)
	battle.start(allies, items, enemy.team, enemy.ai)
	await battle.battle_ended
	battle.queue_free()
	world.process_mode = Node.PROCESS_MODE_INHERIT

func _on_dialog_started(dialogId: String, data: Variant) -> void:
	world.process_mode = Node.PROCESS_MODE_DISABLED
	dialog_box.start(dialogId)
	var val = await dialog_box.dialogue_signal
	match val:
		"combat_initiated":
			_on_player_battle_started(_player.party, _player.inventory.get_battle_items(), data)
		"menu_opened":
			pass
		"dialogue_ended","pivot_declined",_: 
			world.process_mode = Node.PROCESS_MODE_INHERIT
			return
