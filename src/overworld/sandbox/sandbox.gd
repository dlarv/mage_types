extends Node3D

@export var battle_scene: PackedScene 
@export var overworld: Node3D
@export var world: Node3D
@export var pause_menu: Control
@export var dialog_box: DialogueBox
@export var vendor_menu: VendorMenu

@export var _player: Player
@export var _rewards: Array[SpellScroll]

var _reward_already_triggered := false

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
			_on_player_battle_started(_player.party, Inventory.get_battle_items(), data)
		"menu_opened":
			vendor_menu.open_menu(data)
			await vendor_menu.menu_closed
			world.process_mode = Node.PROCESS_MODE_INHERIT
		"dialogue_ended","pivot_declined",_: 
			world.process_mode = Node.PROCESS_MODE_INHERIT


func _on_reward_trigger_body_entered(body:Node3D) -> void:
	if _reward_already_triggered or not body is Player: return
	print("Player was rewarded")
	_reward_already_triggered = true

	var actor: BattleActor = body.battle_actor
	var i = 1
	for reward in _rewards:
		actor.learn_spell(i, reward)
		(body as Player).player_menu.characters_menu.player_screen._spells_menu.set_moveset_slot(reward, i)
		i += 1
