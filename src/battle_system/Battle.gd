extends Node
class_name Battle 

signal battle_ended(playerWasDefeated: bool)

# BattleActor[]
var enemies := []
var allies := []

@export var gui: BattleGUI
@export var ai: OpponentController 
@export var _matchup_manager: CanvasLayer
@export var _dialog_box: DialogueBox

var _defeated_allies: int = 0
var _defeated_enemies: int = 0
var _turn_counter: int = 0

func _unhandled_input(event) -> void:
	if event.is_action_pressed("create_log"):
		Logger.save_log(Logger.LogType.BATTLE)
	if event.is_action_pressed("toggle_player_menu"):
		_matchup_manager.visible = !_matchup_manager.visible
	if event is InputEventKey and _matchup_manager.visible and event.keycode == KEY_ESCAPE:
		get_window().set_input_as_handled()
		_matchup_manager.visible = false 

func start(allies: Array, allyItems: Array, enemies: Array, ai: OpponentController) -> void:
	#ElementManager.load_from_default_csv(Settings.use_simplified_effects)
	self.allies = allies
	self.enemies = enemies

	for ally in allies:
		ally.was_just_defeated.connect(func(): _defeated_allies += 1)
	for enemy in enemies:
		enemy.was_just_defeated.connect(func(): _defeated_enemies += 1)

	ai.setup(enemies)
	battle_ended.connect(ai._on_battle_ended)
	self.ai = ai	
	if ai.dialog_resource != null:
		_dialog_box.data = ai.dialog_resource

	gui.setup(allies, allyItems, enemies)
	await dialog(false)
	_dialog_box.skip_input_action = "interact"

func on_player_actions_selected(allyActions: Array) -> void:
	_dialog_box.stop()
	gui.enable_player_controls(false)

	_turn_counter += 1
	gui.turn_counter = _turn_counter

	Logger.append_log(Logger.LogType.BATTLE, "\nTurn %d" % _turn_counter)

	# If allyActions is empty, the player pressed the "Run" button.
	if len(allyActions) == 1 and allyActions[0].is_flee():
		await gui.display_message("You ran away.")
		battle_ended.emit(true)
		return

	# Get actions for opponent's team.
	var enemyActions = ai.get_actions(allies)
	var actions = allyActions
	actions.append_array(enemyActions)

	# Calculate turn order based on priority and actor speed.
	var speedTieBreaker := randf() < 0.5
	actions.sort_custom(func(a, b):
		if a == null: return false
		elif b == null: return true
		# Higher priority goes first.
		if a.priority != b.priority:
			return a.priority > b.priority
		# Then higher speed goes first.
		if a.actor.speed != b.actor.speed:
			return a.actor.speed > b.actor.speed
		return speedTieBreaker)

	await dialog(false)

	for action in actions:
		Logger.append_log(Logger.LogType.BATTLE, "\nActors turn: %s" % action.actor.name)

		var flinch = action.actor.flinching
		if flinch != null:
			await gui.display_message("%s flinched! They were unable to move." % action.actor.name)
			continue

		# This means a character is defeated.
		if action == null:
			continue

		# Play animation.
		var userPosition = gui.get_actor_display_position(action.team_index, action.actor)
		var targetTeamIndex
		var teamDisplay
		# Target same team as user.
		if(action.action.target == BattleAction.TargetType.SELF \
				or action.action.target == BattleAction.TargetType.ALLY \
				or action.action.target == BattleAction.TargetType.ALLIES):
			targetTeamIndex = action.team_index
			teamDisplay =  gui.ally_display_parent if action.team_index == 0  else  gui.enemy_display_parent
		# Target opposite team from user.
		else:
			targetTeamIndex = (action.team_index + 1) % 2
			teamDisplay = gui.ally_display_parent if action.team_index == 1  else  gui.enemy_display_parent

		var targetPosition = gui.get_actor_display_position(targetTeamIndex, action.targets[0] if len(action.targets) == 1 else null)
		
		action.action.play_animation(userPosition, targetPosition, self)

		# Apply action effects.
		var msg = action.action.apply_effects(action.actor, action.targets)

		# Display message and await input.
		await gui.display_message(msg)
		
		# Check if battle should end.
		var endBattle := await _check_if_battle_ended()
		if endBattle: return

		# Calculate target transmutations.
		for target in action.targets:
			await calculate_transmutations(target, action.action)

		# Check if battle should end.
		# This will trigger if final actor died to phobia.
		endBattle = await _check_if_battle_ended()
		if endBattle: return

		# Calculate user transmutations.
		# If the user targeted themselves 
		# (e.g. Target = Allies || Self || Ally).
		# This only applies to melee attacks.
		if(action.targets.find(action.actor) == -1 \
				and action.action is Attack \
				and (action.action).attack_range == Attack.AttackRange.MELEE):
			await calculate_transmutations(action.actor, action.action) 

		# Check if battle should end.
		# This will trigger if final actor died to phobia.
		endBattle = await _check_if_battle_ended()
		if endBattle: return

		# Resolve user's status effects.
		action.actor.resolve_end_of_turn()
		msg = "\n".join(action.actor.get_and_flush_msgs())
		if len(msg) > 0:
			await gui.display_message(msg)
			# Check if battle should end.
			# e.g. if an actor was defeated by poison.
			endBattle = await _check_if_battle_ended()
			if endBattle: return
		# Pause before processing next turn.
		await get_tree().create_timer(0.5).timeout

	# Revert characters to biases.
	var biasMsg := []
	for ally in allies:
		if ally.try_revert_to_bias():
			biasMsg.append(ally.get_and_flush_msgs())
	if len(biasMsg) > 0:
		await gui.display_message(biasMsg)

	biasMsg = []
	for enemy in enemies:
		if enemy.try_revert_to_bias():
			biasMsg.append(enemy.get_and_flush_msgs())
	if len(biasMsg) > 0:
		await gui.display_message(biasMsg)

	Logger.append_log(Logger.LogType.BATTLE, "\n\nPlayer is selecting actions...")
	await dialog(true)
	gui.enable_player_controls(true)

func calculate_transmutations(target: BattleActor, action: BattleAction) -> void:
	var stasis = target.stasis
	if stasis != null:
		await gui.display_message(stasis.message)
		return

	var msg := []
	var e1 := target.element1.get_bb_code_name()
	var e2 := target.element2.get_bb_code_name()
	var ea := action.element.get_bb_code_name()

 	# Calculate primary + attack 
	var newType := ElementManager.get_matchup(target.element1, action.element)
	if newType != null:
		msg.append("The target %s's %s reacted with the attack's %s type to make %s." % [ target.name, e1, ea, newType.get_bb_code_name()])

		var vals := ElementManager.get_side_effect(target.element1, action.element)
		var buff = vals[0]
		# var debuff = vals[1]

		if buff != null:
			buff.apply_effect(target)
			msg.append("This reaction had side effects! %s" % "\n".join(target.get_and_flush_msgs()))
		# if debuff != null:
		# 	msg.append("This reaction had side effects! %s" % debuff.apply_effect(target))

		target.set_element(0, newType)
		var msg2 := "\n".join(target.get_and_flush_msgs())
		if len(msg2) > 0:
			msg.append(msg2)

		await gui.display_message(msg)

 	# Calculate secondary + attack 
	newType = ElementManager.get_matchup(target.element2, action.element)
	msg = []
	if newType != null:
		msg.append("The target %s's %s reacted with the attack's %s type to make %s." % [ target.name, e2, ea, newType.get_bb_code_name()])

		var vals := ElementManager.get_side_effect(target.element2, action.element)
		var buff = vals[0]
		# var debuff = vals[1]

		if buff != null:
			buff.apply_effect(target)
			msg.append("This reaction had side effects! %s" % "\n".join(target.get_and_flush_msgs()))
		# if debuff != null:
		# 	msg.append("This reaction had side effects! %s" % debuff.apply_effect(target))

		target.set_element(1, newType)
		var msg2 := "\n".join(target.get_and_flush_msgs())
		if len(msg2) > 0:
			msg.append(msg2)

		await gui.display_message(msg)

 	# Calculate primary + secondary.
	var dissonant := target.dissonant
	if dissonant != null:
		await gui.display_message(dissonant.message)
		return

	newType = ElementManager.get_matchup(target.element1, target.element2)
	msg = []
	if newType != null:
		e1 = target.element1.get_bb_code_name()
		e2 = target.element2.get_bb_code_name()
		msg.append("The target %s's %s reacted with it's %s type to make %s." % [target.name, e1, e2, newType.get_bb_code_name()])

		var vals := ElementManager.get_side_effect(target.element1, target.element2)
		var buff = vals[0]
		# var debuff = vals[1]
		if buff != null:
			buff.apply_effect(target)
			msg.append("This reaction had side effects! %s" % "\n".join(target.get_and_flush_msgs()))
		# if debuff != null:
		# 	msg.append("This reaction had side effects! %s" % debuff.apply_effect(target))

		target.set_element(0, newType)
		var msg2 := "\n".join(target.get_and_flush_msgs())
		target.set_element(1, ElementManager.Blank)
		if len(msg2) > 0:
			msg.append(msg2)
		
		await gui.display_message(msg)

func dialog(isAfterTurn: bool) -> void:
	var dialogId = ai.get_next_dialog_id(_turn_counter, isAfterTurn)

	if len(dialogId) > 0:
		_dialog_box.start(dialogId)
		await _dialog_box.dialogue_ended

func _check_if_battle_ended() -> bool:
	if _defeated_allies == len(allies):
		await gui.display_message("You were defeated...")
		battle_ended.emit(true)
		return true
	elif _defeated_enemies == len(enemies):
		await gui.display_message("You won!")
		battle_ended.emit(false)
		return true
	return false
