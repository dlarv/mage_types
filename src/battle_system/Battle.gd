extends Node
class_name Battle 

signal battle_ended(endState: EndState)

enum EndState { WON, DEFEATED, FLED }

# BattleActor[]
var enemies := []
var allies := []

@export var gui: BattleGUI
@export var ai: OpponentController 
@export var _dialog_box: DialogueBox

var _defeated_allies: int = 0
var _defeated_enemies: int = 0
var _turn_counter: int = 0
var _actions := []
var tie_breaker := false

func _unhandled_input(event) -> void:
	if event.is_action_pressed("create_log"):
		Logger.save_log(Logger.LogType.BATTLE)
	

func start(allies: Array, allyItems: Array, enemies: Array, ai: OpponentController) -> void:
	self.allies = allies
	self.enemies = enemies

	for ally in allies:
		ally.setup(self)
		ally.was_just_defeated.connect(func(): _defeated_allies += 1)
	for enemy in enemies:
		enemy.setup(self)
		enemy.was_just_defeated.connect(func(): _defeated_enemies += 1)

	ai.setup(enemies)
	battle_ended.connect(ai._on_battle_ended)

	self.ai = ai	
	if ai.dialog_resource != null:
		_dialog_box.data = ai.dialog_resource


	gui.setup(allies, allyItems, enemies)
	_prep_next_turn()
	await dialog(false)
	_dialog_box.skip_input_action = "interact"

func on_player_actions_selected(allyActions: Array) -> void:
	_dialog_box.stop()
	gui.enable_player_controls(false)
	gui.show_enemy_intentions(false)

	_turn_counter += 1
	gui.turn_counter = _turn_counter

	Logger.append_battle_log("\nTurn %d" % _turn_counter)

	# If allyActions is empty, the player pressed the "Run" button.
	if len(allyActions) == 1 and allyActions[0].is_flee():
		await gui.display_message("You ran away.")
		battle_ended.emit(EndState.FLED)
		return

	# Get actions for opponent's team.
	# var enemyActions = ai.get_actions(allies)
	# var _actions = allyActions
	_actions.append_array(allyActions)

	# Calculate turn order based on priority and actor speed.
	_actions.sort_custom(func(a, b):
		if a == null: return false
		elif b == null: return true
		# Higher priority goes first.
		if a.priority != b.priority:
			return a.priority > b.priority
		# Then higher speed goes first.
		if a.actor.speed != b.actor.speed:
			return a.actor.speed > b.actor.speed
		return tie_breaker)

	await dialog(false)

	for action in _actions:
		# This means a character is defeated.
		if action == null or action.actor.is_defeated:
			continue
			
		var flinch = action.actor.flinching
		if flinch != null:
			await gui.display_message("%s flinched! They were unable to move." % action.actor.name)
			action.actor.turn_ended.emit()
			continue

		Logger.append_battle_log("\nActors turn: %s" % action.actor.name)

		# Play animation.
		var userPosition = gui.get_actor_display_position(action.team_index, action.actor)
		var targetTeamIndex
		var teamDisplay
		# Target same team as user.
		if(action.action.target == _BattleAction.TargetType.SELF \
				or action.action.target == _BattleAction.TargetType.ALLY \
				or action.action.target == _BattleAction.TargetType.ALLIES):
			targetTeamIndex = action.team_index
			teamDisplay =  gui.ally_display_parent if action.team_index == 0  else  gui.enemy_display_parent
		# Target opposite team from user.
		else:
			targetTeamIndex = (action.team_index + 1) % 2
			teamDisplay = gui.ally_display_parent if action.team_index == 1  else  gui.enemy_display_parent

		var targetPosition = gui.get_actor_display_position(targetTeamIndex, action.targets[0] if len(action.targets) == 1 else null)
		
		# Apply action effects.
		var res: Dictionary = action.action.apply_effects(action.actor, action.targets)
		var msg = res.msg

		if not res.has("missed") or not res.missed:
			action.action.play_animation(userPosition, targetPosition, self)

		# Display message and await input.
		await gui.display_message(msg)
		
		# Check if battle should end.
		if await _check_if_battle_ended(): return

		# Calculate target transmutations.
		for target in action.targets:
			if target.is_defeated: continue
			await calculate_transmutations_2(target, action.action)

		# Check if battle should end.
		# This will trigger if final actor died to phobia.
		if await _check_if_battle_ended(): return

		# Change any of user's blank typing to match type of this attack.
		# var updatedType := false
		# msg = ""
		# if action.actor.element1.is_blank():
		# 	action.actor.set_element(0, action.action.element)
		# 	updatedType = true
		# 	msg = "Channeling the power of %s changed %s Blank typing." % [ action.action.element.get_bb_code_name(), action.actor.name]
		# elif action.actor.element2.is_blank():
		# 	action.actor.set_element(1, action.action.element)
		# 	updatedType = true
		# 	msg = "Channeling the power of %s changed %s Blank typing." % [ action.action.element.get_bb_code_name(), action.actor.name]

		if len(msg) > 0:
			await gui.display_message(msg)

		# Calculate user transmutations.
		# If the user targeted themselves 
		# (e.g. Target = Allies || Self || Ally).
		# This only applies to melee attacks.
		if action.targets.find(action.actor) == -1 \
				and action.action is Attack \
				and (action.action).attack_range == Attack.AttackRange.MELEE:
			await calculate_transmutations_2(action.actor, action.action) 

		# Check if battle should end.
		# This will trigger if final actor died to phobia.
		if await _check_if_battle_ended(): return

		# Resolve user's status effects.
		var a = allies if action.team_index == 0 else enemies
		var o = enemies if action.team_index == 0 else allies
		action.actor.resolve_end_of_turn(a, o)
		action.actor.turn_ended.emit()
		msg = action.actor.get_and_flush_msgs()
		if len(msg) > 0:
			await gui.display_message(msg)
			# Check if battle should end.
			# e.g. if an actor was defeated by poison.
			if await _check_if_battle_ended(): return

		# Pause before processing next turn.
		await get_tree().create_timer(0.5).timeout

	# Revert characters to biases.
	var biasMsg := []
	for ally in allies:
		if ally.try_revert_to_bias():
			biasMsg.append_array(ally.get_and_flush_msgs())
	if len(biasMsg) > 0:
		await gui.display_message(biasMsg)

	biasMsg = []
	for enemy in enemies:
		if enemy.try_revert_to_bias():
			biasMsg.append_array(enemy.get_and_flush_msgs())
	if len(biasMsg) > 0:
		await gui.display_message(biasMsg)

	Logger.append_battle_log("\n\nPlayer is selecting _actions...")
	await dialog(true)
	_prep_next_turn()
	gui.enable_player_controls(true)

func calculate_transmutations(target: BattleActor, action: _BattleAction) -> void:
	if target.stasis:
		await gui.display_message("%s is in stasis! Transmutations were blocked!" % target.name)
		return

 	# Calculate primary + attack 
	await _calculate_transmutation(target.element1, action.element, target, 0)
 	# Calculate secondary + attack 
	await _calculate_transmutation(target.element2, action.element, target, 1)
	# Calculate internal transmutation.
	if await _calculate_transmutation(target.element1, target.element2, target, 0, true):
		target.set_element(1, ElementManager.Blank)


func calculate_transmutations_2(target: BattleActor, action: _BattleAction) -> void:
	if target.stasis:
		await gui.display_message("%s is in stasis! Transmutations were blocked!" % target.name)
		return

 	# Calculate secondary + attack 
	await _calculate_transmutation(target.element2, action.element, target, 1)
	# Calculate internal transmutation.
	await _calculate_transmutation(target.element1, target.element2, target, 1, true)


func _calculate_transmutation(e1: ElementalType, e2: ElementalType, target: BattleActor, id: int, isInternal:=false) -> bool:
	var newType = ElementManager.get_matchup(e1, e2)
	if newType == null: return false

	var e1Name := e1.get_bb_code_name()
	var e2Name := e2.get_bb_code_name()
	var msg := []

	if isInternal:
		msg.append("The target %s's %s reacted with it's %s type to make %s." 
				% [ target.name, e1Name, e2Name, newType.get_bb_code_name()])
	else:
		msg.append("The target %s's %s reacted with the attack's %s type to make %s." 
				% [ target.name, e1Name, e2Name, newType.get_bb_code_name()])

	var buff = ElementManager.get_side_effect(e1, e2)

	# if buff != null:
	buff.apply_effect(target)
	msg.append("This reaction had side effects!")
	msg.append_array(target.get_and_flush_msgs())

	target.set_element(id, newType)
	var msg2 := target.get_and_flush_msgs()
	if len(msg2) > 0:
		msg.append_array(msg2)

	await gui.display_message(msg)
	return true


func dialog(isAfterTurn: bool) -> void:
	var dialogId = ai.get_next_dialog_id(_turn_counter, isAfterTurn)

	if len(dialogId) > 0:
		_dialog_box.start(dialogId)
		await _dialog_box.dialogue_ended


func _check_if_battle_ended() -> bool:
	if _defeated_allies == len(allies):
		await gui.display_message("You were defeated...")
		battle_ended.emit(EndState.DEFEATED)
		return true
	elif _defeated_enemies == len(enemies):
		await gui.display_message("You won!")
		battle_ended.emit(EndState.WON)
		return true
	return false


func _prep_next_turn() -> void:
	_actions = ai.get_actions(allies)
	gui.show_enemy_intentions(true)
	tie_breaker = randf() < 0.5

	var speedRank := allies.duplicate()
	speedRank.append_array(enemies)
	speedRank.sort_custom(func(a, b):
		if a.speed != b.speed:
			return a.speed > b.speed
		return tie_breaker)
	speedRank.map(func(a): return a.name)

	gui.display_turn_order(speedRank)
