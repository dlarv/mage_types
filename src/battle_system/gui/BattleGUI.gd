extends Node3D
## Facilitate action and target selection.
## Display messages.
## Play animations.

signal actions_selected(actions: Array)
signal target_selected(actor: BattleActor)

@export var message_box: RichTextLabel 
@export var team_display: TeamDisplay
@export var player_controls: Control
@export var turn_counter_display: Label
@export var turn_order_display: VBoxContainer

# BattleActor[]
var allies := []
var enemies := []
# String[]
var messages := []
var turn_counter: 
	set(value):
		turn_counter = value
		if turn_counter_display == null: return
		turn_counter_display.text = "Turn %d" % value

# ActorAction[]
var _selected_actions := []
var _finished_setup := false
var _accept_messages := true

func setup(allies: Array, items: Array, enemies: Array) -> void:
	# Init allies.
	self.allies = allies
	self.enemies = enemies
	_selected_actions = []
	_selected_actions.resize(len(allies))

	team_display.setup(allies, enemies)
	team_display.highlight(0)
	team_display.selected.connect(_on_target_selected)

	# Finish setup
	player_controls.setup(allies, items, enemies)
	_finished_setup = true
	$Camera3D.make_current()


func display_message(msg: Variant) -> void:
	if len(msg) == 0: return
	_accept_messages = false
	if msg is Array:
		msg = "\n".join(msg)

	Logger.append_battle_log(msg)
	await message_box.display_message_blocking(msg)
	_accept_messages = true


func display_message_non_blocking(msg: Variant, limitInfo:=false) -> void:
	if not _accept_messages: return
	var msgLog = msg

	if msg is Array:
		msg = "\n".join(msg)
		msgLog = msg
	elif msg is Resource and "name" in msg:
		msgLog = "Player viewed %s." % msg.name

	Logger.append_battle_log(msgLog)
	message_box.display_message_non_blocking(msg, limitInfo)


func enable_player_controls(enable: bool) -> void:
	player_controls.set_enabled(enable)


func _on_action_target_selection_cancelled() -> void:
	team_display.cancel_target_selection()


func _on_action_selected(index: int, action: _BattleAction) -> void:
	var targets = await select_targets(allies[index], action)
	if targets == null: return

	var actorAction = ActorAction.new(allies[index], action, targets, 0)
	_selected_actions[index] = actorAction
	message_box.clear_message()
	player_controls.next_character()


func select_targets(user: BattleActor, action:_BattleAction):
	var targets: Array

	match action.target:
		_BattleAction.TargetType.ALLIES:
			targets = allies

		_BattleAction.TargetType.ENEMIES:
			targets = enemies

		_BattleAction.TargetType.ALL:
			targets = allies + enemies

		_BattleAction.TargetType.RANDOM:
			targets = [ (allies + enemies).pick_random() ]

		_:
			team_display.select_target(user, action)
			targets = [ await target_selected ]

	
	if len(targets) == 1 and targets[0] == null:
		return null
	return targets


func show_enemy_intentions(val: bool) -> void:
	team_display.show_enemy_intentions(val)


func _on_active_actor_changed(index: int) -> void:
	team_display.highlight(index)

	# If player was selecting a target, but then hits prev/next, cancel selection.
	team_display.cancel_target_selection()
	

func _on_turn_ended(tryRunningAway: bool) -> void:
	if tryRunningAway:
		actions_selected.emit([ActorAction.flee()])
	else:
		actions_selected.emit(_selected_actions)
		_selected_actions = []
		_selected_actions.resize(len(allies))

		# If player was selecting a target, but then hits prev/next, cancel selection.
		team_display.cancel_target_selection()
	

func _on_show_info(action: Variant, limitInfo:=false) -> void:
	var msg = "Empty"
	if action is _BattleAction:
		msg = action.name
	elif (action is BattleActor):
		msg = action.name
	print(msg)
	
	display_message_non_blocking(action, limitInfo)


func display_turn_order(actors: Array) -> void:
	if not Settings.show_battle_turn_order:
		turn_order_display.get_parent().hide()
		return
	else:
		turn_order_display.get_parent().show()

	for child in turn_order_display.get_children():
		turn_order_display.remove_child(child)
	
	for actor in actors:
		var label := Label.new()
		label.text = actor.name
		turn_order_display.add_child(label)

		
func _on_target_selected(actor: BattleActor) -> void:
	target_selected.emit(actor)


## TO BE DEPRECATED.
func get_actor_display_position(actor: BattleActor) -> Vector2:
	if actor == null:
		return Vector2(team_display.global_position.x, team_display.global_position.y)
	
	var sprite = team_display.get_sprite(actor)
	return sprite.get_target_position()
