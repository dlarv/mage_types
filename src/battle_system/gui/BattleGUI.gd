extends Node3D
## Facilitate action and target selection.
## Display messages.
## Play animations.

signal actions_selected(actions: Array[ActorTurnData])
signal target_selected(actor: BattleActor)

const TeamDisplay := preload("res://src/battle_system/gui/components/TeamDisplay.gd")

@export var message_box: RichTextLabel 
@export var team_display: TeamDisplay
@export var player_controls: Control
@export var turn_order_display: VBoxContainer

var allies: Array[BattleActor] = []
var enemies: Array[BattleActor] = []
var messages: Array[String] = []
var turn_counter: int

# ActorTurnData[]
var _selected_actions: Array[ActorTurnData] = []
var _finished_setup := false
var _accept_messages := true

func setup(allies: Array[BattleActor], items: Array[RegularItem], enemies: Array[BattleActor]) -> void:
	self.allies = allies
	self.enemies = enemies
	_selected_actions = []
	_selected_actions.resize(len(allies))

	team_display.setup(allies, enemies)
	team_display.highlight(0)
	team_display.target_selected.connect(_on_target_selected)

	# Finish setup
	player_controls.setup(allies, items, enemies)
	_finished_setup = true
	$Camera3D.make_current()


func display_message_non_blocking(msg: Variant, limitInfo:=false) -> void:
	if not _accept_messages: return
	var msgLog: Variant = msg
	%DisplayContainer.current_tab = 0

	if msg is Array:
		msg = "\n".join(msg)
		msgLog = msg
	elif msg is Resource and "name" in msg:
		msgLog = "Player viewed %s." % msg.name

	Logger.append_battle_log(msgLog)
	message_box.display_message_non_blocking(msg, limitInfo)


func enable_player_controls(enable: bool) -> void:
	player_controls.set_enabled(enable)
	if not enable:
		%DisplayContainer.current_tab = 1


func _on_action_target_selection_cancelled() -> void:
	team_display.cancel_target_selection()
	%DisplayContainer.current_tab = 1


func _on_action_selected(index: int, action: _BattleAction) -> void:
	var targets: Array[BattleActor] = await select_targets(allies[index], action)
	if len(targets) == 0: return

	var actorAction := ActorTurnData.new(allies[index], action, targets, 0)
	_selected_actions[index] = actorAction
	message_box.clear_message()
	player_controls.next_character()


func select_targets(user: BattleActor, action:_BattleAction) -> Array[BattleActor]:
	var targets: Array[BattleActor] = []

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
		return []
	return targets


func show_enemy_intentions(val: bool) -> void:
	team_display.show_enemy_intentions(val)


func _on_active_actor_changed(index: int) -> void:
	team_display.highlight(index)

	# If player was selecting a target, but then hits prev/next, cancel selection.
	team_display.cancel_target_selection()
	

func _on_turn_ended(tryRunningAway: bool) -> void:
	if tryRunningAway:
		actions_selected.emit([ActorTurnData.flee()] as Array[ActorTurnData])
	else:
		actions_selected.emit(_selected_actions)
		_selected_actions = []
		_selected_actions.resize(len(allies))

		# If player was selecting a target, but then hits prev/next, cancel selection.
		team_display.cancel_target_selection()
	

func _on_show_info(action: Variant, limitInfo:=false) -> void:
	var msg := "Empty"
	if action is _BattleAction:
		msg = action.name
	elif (action is BattleActor):
		msg = action.name
	print(msg)
	
	%DisplayContainer.current_tab = 0
	display_message_non_blocking(action, limitInfo)


func display_turn_order(actors: Array[BattleActor]) -> void:
	if not Settings.show_battle_turn_order:
		turn_order_display.get_parent().hide()
		return
	else:
		turn_order_display.get_parent().show()

	for child in turn_order_display.get_children():
		turn_order_display.remove_child(child)
	
	for actor: BattleActor in actors:
		var label := Label.new()
		label.text = actor.name
		turn_order_display.add_child(label)

		
func _on_target_selected(actor: BattleActor) -> void:
	target_selected.emit(actor)


func animate_action(data: ActorTurnData, missed: bool) -> void:
	await $BattleAnimator.animate(data, missed)


func animate_status_activation(actor: BattleActor, effect: StatusEffect) -> void:
	team_display.animate_status_activation(actor, effect)
