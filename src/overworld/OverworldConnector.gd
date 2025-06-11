extends Node3D

@export var battle_scene: PackedScene 
@export var world: Node3D
@export var overworld: Node3D
@export var dialog_box: DialogueBox
@export var hud: CanvasLayer

# Amount of time to wait between a battle ending and a new one starting.
@export var battle_delay: float

@export var _player: Node3D
var _current_story_actor: StoryActor = null

@export_category("Demo")
@export_range(0, 3) var stencil_index := 0:
	set(val):
		stencil_index = val
		if Settings.use_graph_stencils:
			UIManager.matchup_chart.current_graphic = val

func _ready() -> void:
	var p = get_tree().get_nodes_in_group("player") 
	if len(p) > 0:
		_player = p[0]

	if not _player.battle_started.is_connected(_on_player_battle_started):
		_player.battle_started.connect(_on_player_battle_started)
	if not _player.cutscene_started.is_connected(_on_player_cutscene_started):
		_player.cutscene_started.connect(_on_player_cutscene_started)
	if not _player.dialog_started.is_connected(_on_player_dialog_started):
		_player.dialog_started.connect(_on_player_dialog_started)


	UIManager.setup()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("create_log"):
		Logger.save_log()
	if event.is_action_pressed("skip_dialog"):
		if _current_story_actor:
			_current_story_actor.skip_dialog()
		dialog_box.stop()

func _on_player_battle_started(allies: Array, enemy:EnemyActor) -> void:
	var battle := battle_scene.instantiate()

	# If an animation player messes with the player's team, they'll be removed from it.
	if not _player.battle_actor in allies:
		allies.insert(0, _player.battle_actor)

	world.process_mode = Node.PROCESS_MODE_DISABLED
	hud.hide()
	add_child(battle)
	battle.start(allies, Inventory.get_battle_items(), enemy.team, enemy.ai)
	UIManager.in_battle_mode = true
	await battle.battle_ended
	battle.queue_free()
	hud.show()
	UIManager.in_battle_mode = true
	
	for actor in allies:
		actor.current_hp = actor.hp

	if is_instance_valid(enemy):
		for actor in enemy.team:
			actor.current_hp = actor.hp
	
	world.process_mode = Node.PROCESS_MODE_INHERIT

	# Prevent player from getting mobbed by enemies.
	# Wild enemies (those that do not need a cooldown) will wait until this is called.
	await get_tree().create_timer(battle_delay).timeout
	get_tree().call_group("wild_enemies", "_end_battle_cooldown")

func _on_player_dialog_started(dialogId: String, npc) -> void:
	UIManager.is_in_dialog = true
	get_tree().paused = true
	_current_story_actor = npc.story_actor

	dialog_box.start(dialogId)

	var sigName: String
	while dialog_box.is_running():
		var val = await dialog_box.dialogue_signal
		if val == "play_cutscene": 
			await _play_cutscene(npc)
		elif val == "update_story":
			StoryManager.trigger_story_event(dialog_box.variables.get("story_event", ""))
		elif val != "dialogue_ended":
			sigName = val

	match sigName:
		"play_cutscene": 
			var id = dialog_box.variables["current_cutscene"]
			await npc.story_actor.play_cutscene(id)
			get_tree().paused = false
		"battle_started":
			get_tree().paused = false
			_on_player_battle_started(_player.team, npc.enemy_actor)
		"menu_opened":
			UIManager.open_vendor_menu(npc.vendor_actor)
			await UIManager.vendor_menu_closed
			get_tree().paused = false
		"dialogue_ended","pivot_declined",_: 
			get_tree().paused = false
	UIManager.is_in_dialog = false

	_current_story_actor = null

func _play_cutscene(npc) -> void:
	var id = dialog_box.variables["current_cutscene"]

	var prevProcessMode := dialog_box.process_mode
	# dialog_box.process_mode = PROCESS_MODE_DISABLED
	get_tree().paused = true
	dialog_box.hide()

	await npc.story_actor.play_cutscene(id)

	# If cutscene is last node of branch, the last dialog spoken will be stuck on screen.
	if dialog_box.is_running():
		dialog_box.show()
	# dialog_box.process_mode = prevProcessMode
	get_tree().paused = false

func _on_player_cutscene_started(player:AnimationPlayer, id:String) -> void:
	# overworld.process_mode = PROCESS_MODE_DISABLED
	get_tree().paused = true
	player.play(id)
	await player.animation_finished
	# overworld.process_mode = PROCESS_MODE_INHERIT
	get_tree().paused = false
