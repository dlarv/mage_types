extends Node3D

@export var battle_scene: PackedScene 
@export var world: Node3D
@export var overworld: Node3D
@export var dialog_box: DialogueBox

# Amount of time to wait between a battle ending and a new one starting.
@export var battle_delay: float

@export var _player: Player

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("create_log"):
		Logger.save_log(Logger.LogType.PUZZLE)

func _on_player_battle_started(allies: Array, enemy:EnemyActor) -> void:
	var battle := battle_scene.instantiate()

	world.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(battle)
	battle.start(allies, Inventory.get_battle_items(), enemy.team, enemy.ai)
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

func _on_dialog_started(dialogId: String, enemy_actor: EnemyActor, vendor_actor: VendorActor) -> void:
	world.process_mode = Node.PROCESS_MODE_DISABLED

	dialog_box.start(dialogId)

	var val = await dialog_box.dialogue_signal
	match val:
		"battle_started":
			_on_player_battle_started(_player.team, enemy_actor)
		"menu_opened":
			UIManager.open_vendor_menu(vendor_actor)
			await UIManager.vendor_menu_closed
			world.process_mode = Node.PROCESS_MODE_INHERIT
		"dialogue_ended","pivot_declined",_: 
			world.process_mode = Node.PROCESS_MODE_INHERIT
