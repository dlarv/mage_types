extends Node3D

## Used to tell DialogueBox when battle/cutscene has finished
signal event_finished()

# @export var battle_scene: PackedScene 
@export var world: Node3D
@export var overworld: Node3D
@export var dialog_box: DialogueBox
@export var hud: CanvasLayer

@export var _player: Node3D

var _current_story_actor: StoryActor = null
var _paused_dialog := false

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")

	if not _player.battle_started.is_connected(_on_player_battle_started):
		_player.battle_started.connect(_on_player_battle_started)
	if not _player.cutscene_started.is_connected(_on_player_cutscene_started):
		_player.cutscene_started.connect(_on_player_cutscene_started)
	if not _player.dialog_started.is_connected(_on_player_dialog_started):
		_player.dialog_started.connect(_on_player_dialog_started)

	UIManager.setup()

	event_finished.connect(dialog_box._on_event_finished)
	dialog_box.auto_proceed = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("create_log"):
		Logger.save_log()
	if event.is_action_pressed("skip_dialog") and not _paused_dialog:
		if _current_story_actor:
			_current_story_actor.skip_dialog()
		dialog_box.stop()


func _on_player_battle_started(allies: Array[BattleActor], enemy:EnemyActor) -> void:
	# If an animation player messes with the player's team, they'll be removed from it.
	if not _player.battle_actor in allies:
		allies.insert(0, _player.battle_actor)

	var healPlayer := enemy.heal_player_after_battle

	world.process_mode = Node.PROCESS_MODE_DISABLED
	hud.hide()
	Battle.start(allies, Inventory.get_battle_items(), enemy.team, enemy.ai)
	UIManager.in_battle_mode = true
	await Battle.battle_ended
	hud.show()
	UIManager.in_battle_mode = false
	
	# Overridden for now bc there is no mechanism to heal player if they are defeated.
	if healPlayer or true:
		for actor in allies:
			actor.current_hp = actor.hp

	if is_instance_valid(enemy):
		for actor: BattleActor in enemy.team:
			actor.current_hp = actor.hp
	
	world.process_mode = Node.PROCESS_MODE_INHERIT

	# Prevent player from getting mobbed by enemies.
	get_tree().call_group("wild_enemies", "_end_battle_cooldown")


func _on_player_dialog_started(dialogId: String, npc: Variant) -> void:
	UIManager.is_in_dialog = true
	get_tree().paused = true
	_current_story_actor = npc.story_actor

	dialog_box.start(dialogId)

	const DialogSignal := StoryManager.DialogSignal
	var sigName := DialogSignal.DIALOG_ENDED
	while dialog_box.is_running():
		var val: DialogSignal = await dialog_box.dialogue_signal
		if val == DialogSignal.PLAY_CUTSCENE: 
			await _play_cutscene(npc)
		elif val == DialogSignal.BATTLE_STARTED:
			dialog_box.hide()
			get_tree().paused = false
			_paused_dialog = true
			await _on_player_battle_started(_player.team, npc.enemy_actor)
			if dialog_box.is_running():
				dialog_box.show()
			await get_tree().create_timer(0.1).timeout
			get_tree().paused = true
			_paused_dialog = false
		elif val == DialogSignal.ADD_ALLY:
			var ally: String = StoryManager.get_variable("target_ally")
			_player.add_ally(ally)
		elif val == DialogSignal.REMOVE_ALLY:
			var ally: String = StoryManager.get_variable("target_ally")
			_player.remove_ally(ally)
		elif val != DialogSignal.DIALOG_ENDED:
			sigName = val
		event_finished.emit()

	match sigName:
		DialogSignal.PLAY_CUTSCENE: 
			var id: String = StoryManager.get_variable("current_cutscene")
			await npc.story_actor.play_cutscene(id)
			get_tree().paused = false
		DialogSignal.BATTLE_STARTED: 
			get_tree().paused = false
			_on_player_battle_started(_player.team, npc.enemy_actor)
		DialogSignal.MENU_OPENED: 
			UIManager.open_vendor_menu(npc.vendor_actor)
			await UIManager.vendor_menu_closed
			get_tree().paused = false
		DialogSignal.ADD_ALLY:
			var ally: String = StoryManager.get_variable("target_ally")
			_player.add_ally(ally)
		DialogSignal.REMOVE_ALLY:
			var ally: String = StoryManager.get_variable("target_ally")
			_player.remove_ally(ally)
		_: 
			get_tree().paused = false
	UIManager.is_in_dialog = false

	_current_story_actor = null


func _play_cutscene(npc: Variant) -> void:
	var id: String = dialog_box.variables["current_cutscene"]

	var prevProcessMode := dialog_box.process_mode
	get_tree().paused = true
	dialog_box.hide()

	await npc.story_actor.play_cutscene(id)

	# If cutscene is last node of branch, the last dialog spoken will be stuck on screen.
	if dialog_box.is_running():
		dialog_box.show()
	get_tree().paused = false


func _on_player_cutscene_started(player:AnimationPlayer, id:String) -> void:
	get_tree().paused = true
	player.play(id)
	await player.animation_finished
	get_tree().paused = false
