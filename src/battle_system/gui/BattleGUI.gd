extends Node3D
class_name BattleGUI

signal actions_selected(actions)

@export var message_box: RichTextLabel 
@export var ally_display_parent: TeamDisplay 
@export var enemy_display_parent: TeamDisplay 
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
	init_allies(allies)
	init_enemies(enemies)
	player_controls.setup(allies, items, enemies)
	_finished_setup = true
	$Camera3D.make_current()

func init_allies(allies: Array) -> void:
	self.allies = allies
	_selected_actions = []
	_selected_actions.resize(len(allies))

	for actor in allies:
		var display = ally_display_parent.add_display(actor)
	
	ally_display_parent.highlight(0)

func init_enemies(enemies: Array) -> void:
	self.enemies = enemies
	for actor in enemies:
		var display = enemy_display_parent.add_display(actor)

func display_message(msg: Variant) -> void:
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


func get_actor_display_position(teamIndex: int, actor=null) -> Vector2:
	var teamDisplay
	if teamIndex == 0:
		teamDisplay = ally_display_parent
	else:
		teamDisplay = enemy_display_parent
	
	if actor == null:
		return Vector2(teamDisplay.global_position.x, teamDisplay.global_position.y)
	
	var sprite = teamDisplay.get_sprite(actor)
	return sprite.get_target_position()

func enable_player_controls(enable: bool) -> void:
	player_controls.set_enabled(enable)

func _on_action_target_selection_cancelled() -> void:
	ally_display_parent.cancel_target_selection()
	enemy_display_parent.cancel_target_selection()

func _on_action_selected(index: int, action: _BattleAction) -> void:
	var targets = await select_targets(allies[index], action)
	if targets == null: return

	var actorAction = ActorAction.new(allies[index], action, targets, 0)
	_selected_actions[index] = actorAction
	message_box.clear_message()
	player_controls.next_character()

func select_targets(user: BattleActor, action:_BattleAction):
	var targets = null
	var target

	match action.target:
		_BattleAction.TargetType.SELF:
			targets = [ user ]
			# This pause is needed, otherwise the End turn button won't enable.
			ally_display_parent.select_specific_target(false, action, user)
			await ally_display_parent.selected
			# await get_tree().create_timer(.05).timeout
			
		_BattleAction.TargetType.ALLY:
			# if ally_display_parent.length == 1 and not Settings.enable_transmutation_hints:
			# 	targets = [ ally_display_parent.get_display(0).actor ]
			# 	# This pause is needed, otherwise the End turn button won't enable.
			# 	await get_tree().create_timer(.05).timeout
			# else:
				ally_display_parent.select_target(false, action)
				target = await ally_display_parent.selected
				targets = [ target ]
			
		_BattleAction.TargetType.ALLIES:
			# enemy_display_parent.select_all_as_target(false, action.element)
			targets = allies
			
		_BattleAction.TargetType.ENEMY:
			# if enemy_display_parent.length == 1 and not Settings.enable_transmutation_hints:
			# 	targets = [ enemy_display_parent.get_display(0).actor ]
			# 	# This pause is needed, otherwise the End turn button won't enable.
			# 	await get_tree().create_timer(.05).timeout
			# else:
				if action.attack_range == Attack.AttackRange.MELEE:
					# Checking if transmutation hints are enabled is the responsibility of TeamDisplay.
					ally_display_parent.enable_transmutation_hint(user, action)

				enemy_display_parent.select_target(true, action)
				target = await enemy_display_parent.selected
				targets = [ target ]

		_BattleAction.TargetType.ENEMIES:
			# ally_display_parent.select_all_as_target(true, action.element)
			targets = enemies
	
	if len(targets) == 1 and targets[0] == null:
		return null
	return targets


func show_enemy_intentions(val: bool) -> void:
	enemy_display_parent.show_intentions(val)


func _on_active_actor_changed(index: int) -> void:
	ally_display_parent.highlight(index)


func _on_turn_ended(tryRunningAway: bool) -> void:
	if tryRunningAway:
		actions_selected.emit([ActorAction.flee()])
	else:
		actions_selected.emit(_selected_actions)
		_selected_actions = []
		_selected_actions.resize(len(allies))
	

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

		
