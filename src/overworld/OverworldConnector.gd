extends Node3D

@export var battle_scene: PackedScene 
@export var world: Node3D
@export var overworld: Node3D
@export var dialog_box: DialogueBox
@export var hud: CanvasLayer

# Amount of time to wait between a battle ending and a new one starting.
@export var battle_delay: float

@export var _player: Player
var _current_story_actor: StoryActor = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("create_log"):
		Logger.save_log(Logger.LogType.PUZZLE)
	if event.is_action_pressed("skip_dialog"):
		if _current_story_actor:
			_current_story_actor.skip_dialog()
		dialog_box.stop()

func _on_player_battle_started(allies: Array, enemy:EnemyActor) -> void:
	var battle := battle_scene.instantiate()

	world.process_mode = Node.PROCESS_MODE_DISABLED
	hud.hide()
	add_child(battle)
	battle.start(allies, Inventory.get_battle_items(), enemy.team, enemy.ai)
	await battle.battle_ended
	battle.queue_free()
	hud.show()
	
	for actor in allies:
		actor.current_hp = actor.hp
	for actor in enemy.team:
		actor.current_hp = actor.hp
	
	world.process_mode = Node.PROCESS_MODE_INHERIT

	# Prevent player from getting mobbed by enemies.
	# Wild enemies (those that do not need a cooldown) will wait until this is called.
	await get_tree().create_timer(battle_delay).timeout
	get_tree().call_group("wild_enemies", "_end_battle_cooldown")

func _on_dialog_started(dialogId: String, npc) -> void:
	world.process_mode = Node.PROCESS_MODE_DISABLED
	_current_story_actor = npc.story_actor

	dialog_box.start(dialogId)

	var sigName: String
	while dialog_box.is_running():
		var val = await dialog_box.dialogue_signal
		if val == "play_cutscene": 
			await _play_cutscene(npc)
		elif val == "change_emotion":
			var id = dialog_box.variables["current_emotion"]
			npc.story_actor.change_emotion(id)
		elif val != "dialogue_ended":
			sigName = val

	match sigName:
		"play_cutscene": 
			var id = dialog_box.variables["current_cutscene"]
			await npc.story_actor.play_cutscene(id)
			world.process_mode = Node.PROCESS_MODE_INHERIT
		"battle_started":
			_on_player_battle_started(_player.team, npc.enemy_actor)
		"menu_opened":
			UIManager.open_vendor_menu(npc.vendor_actor)
			await UIManager.vendor_menu_closed
			world.process_mode = Node.PROCESS_MODE_INHERIT
		"dialogue_ended","pivot_declined",_: 
			world.process_mode = Node.PROCESS_MODE_INHERIT

	_current_story_actor = null

func _play_cutscene(npc) -> void:
	var id = dialog_box.variables["current_cutscene"]

	dialog_box.process_mode = PROCESS_MODE_DISABLED
	dialog_box.hide()

	await npc.story_actor.play_cutscene(id)

	# If cutscene is last node of branch, the last dialog spoken will be stuck on screen.
	if dialog_box.is_running():
		dialog_box.show()
	dialog_box.process_mode = PROCESS_MODE_INHERIT

func _on_player_cutscene_started(player:AnimationPlayer, id:String) -> void:
	overworld.process_mode = PROCESS_MODE_DISABLED
	player.play(id)
	await player.animation_finished
	overworld.process_mode = PROCESS_MODE_INHERIT
