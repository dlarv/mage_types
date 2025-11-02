extends Node

signal battle_ended(endState: EndState)

enum EndState { WON, DEFEATED, FLED }
enum BattlefieldStateParams { COMBATANTS, ALLIES, ENEMIES, TEAM_0, TEAM_1, ATTACKS }

const BattleGUI := preload("res://src/battle_system/gui/battle_gui.tscn")
const RewardScreen := preload("res://src/battle_system/gui/battle_rewards/battle_reward_screen.tscn")
const MessageFeed := preload("res://src/battle_system/gui/message_feed/MessageFeed.gd")

@export var post_attack_delay := 0.1
@export var post_transmutation_delay := 0.2
@export var post_turn_delay := 1.0
@export var ai: OpponentController 
@export var _dialog_box: DialogueBox
var message_feed: MessageFeed:
	get:
		if not gui: return null
		return gui.get_node("%MessageFeed")
var gui: Node3D

var enemies: Array[BattleActor] = []
var allies: Array[BattleActor] = []

var _defeated_allies: int = 0
var _defeated_enemies: int = 0
var _turn_counter: int = 0
var _actions: Array[ActorTurnData] = []
var tie_breaker := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("create_log"):
		Logger.save_log()
	elif event.is_action_pressed("skip_dialog"):
		_dialog_box.stop()
	elif event.is_action_pressed("toggle_battle_feed"):
		message_feed.visible = not message_feed.visible
	

func start(allies: Array[BattleActor], allyItems: Array[RegularItem], enemies: Array[BattleActor], ai: OpponentController) -> void:
	_defeated_allies = 0
	_defeated_enemies = 0
	_turn_counter = 0

	self.allies = allies
	self.enemies = enemies
	self.ai = ai	

	for ally: BattleActor in allies:
		ally.setup()
		ally.was_just_defeated.connect(_increment_defeat_counter.bind(true))

	for enemy: BattleActor in enemies:
		enemy.setup()
		enemy.was_just_defeated.connect(_increment_defeat_counter.bind(false))

	ai.setup(enemies)

	if not battle_ended.is_connected(ai._on_battle_ended):
		battle_ended.connect(ai._on_battle_ended)

	if ai.dialog_resource != null:
		_dialog_box.data = ai.dialog_resource

	gui = BattleGUI.instantiate()
	add_child(gui)
	gui.actions_selected.connect(_on_player_actions_selected)
	gui.setup(allies, allyItems, enemies)

	_prep_next_turn()
	await _dialog(false)


func query_battlefield_state(asker: BattleActor, param: BattlefieldStateParams) -> Variant:
	match param:
		BattlefieldStateParams.COMBATANTS:
			return allies + enemies
		BattlefieldStateParams.ALLIES:
			if allies.has(asker):
				return allies
			else:
				return enemies
		BattlefieldStateParams.ENEMIES:
			if enemies.has(asker):
				return allies
			else:
				return enemies
		BattlefieldStateParams.ATTACKS:
			return _actions
		BattlefieldStateParams.TEAM_0:
			return allies
		BattlefieldStateParams.TEAM_1:
			return enemies

	return null


func _on_player_actions_selected(allyActions: Array[ActorTurnData]) -> void:
	_dialog_box.stop()
	gui.enable_player_controls(false)
	gui.show_enemy_intentions(false)

	_turn_counter += 1
	gui.turn_counter = _turn_counter
	message_feed.append_turn_header(_turn_counter)

	Logger.append_battle_log("\n********************************Turn %d********************************" 
			% _turn_counter)

	# If allyActions is empty, the player pressed the "Run" button.
	if len(allyActions) == 1 and allyActions[0].is_flee():
		StoryManager.set_variable("battle_result", "fled")
		Logger.append_battle_log("You ran away.")
		battle_ended.emit(EndState.FLED)
		_resolve_end_of_battle(false)
		return

	# Get actions for opponent's team.
	# var enemyActions = ai.get_actions(allies)
	# var _actions = allyActions
	_actions.append_array(allyActions)

	# Calculate turn order based on priority and actor speed.
	_actions.sort_custom(func(a: ActorTurnData, b: ActorTurnData) -> bool:
		if a == null: return false
		elif b == null: return true
		# Higher priority goes first.
		if a.priority != b.priority:
			return a.priority > b.priority
		# Then higher speed goes first.
		if a.user.speed != b.user.speed:
			return a.user.speed > b.user.speed
		return tie_breaker)

	await _dialog(false)

	for turnData in _actions:
		# This means a character is defeated.
		if turnData == null or turnData.user.is_defeated:
			continue
			
		var flinch := turnData.user.flinching
		if flinch != null:
			Logger.append_battle_log("%s flinched! They were unable to move." % turnData.user.name)
			gui.animate_status_activation(turnData.user, flinch)
			resolve_end_of_turn(turnData)
			await get_tree().create_timer(post_turn_delay).timeout
			continue

		Logger.append_battle_log("\nActors turn: %s" % turnData.user.name)
		message_feed.append_actor_header(turnData.user)
		
		# Apply action effects.
		var res := turnData.execute()
		var msg: Array[String] = []#res.msg
		var missed: bool = res.missed

		message_feed.append_action_message(turnData)
		# Display message and await input.
		Logger.append_battle_log(_build_msg(turnData))

		await gui.animate_action(turnData, missed)
		await get_tree().create_timer(post_attack_delay).timeout

		var defeatedActors := turnData.get_defeated()
		message_feed.append_defeated_message(defeatedActors)
		for actor in defeatedActors:
			Logger.append_battle_log("%s was defeated...." % actor.name)
		
		# Check if battle should end.
		if await _check_if_battle_ended(): return

		# Calculate target transmutations.
		if not missed:
			for target in turnData.targets:
				if target.is_defeated: continue
				_calculate_transmutations(target, turnData.action)
				await get_tree().create_timer(post_transmutation_delay).timeout

		# Check if battle should end.
		# This will trigger if final actor died to phobia.
		if await _check_if_battle_ended(): return

		# Calculate user transmutations.
		# If the user targeted themselves 
		# (e.g. Target = Allies || Self || Ally).
		# This only applies to melee attacks.
		if not missed and turnData.targets.find(turnData.user) == -1 \
				and turnData.action is Attack \
				and (turnData.action).attack_range == Attack.AttackRange.MELEE:
			_calculate_transmutations(turnData.user, turnData.action) 
		await get_tree().create_timer(post_transmutation_delay).timeout

		# Check if battle should end.
		# This will trigger if final actor died to phobia.
		if await _check_if_battle_ended(): return

		# Resolve user's status effects.
		resolve_end_of_turn(turnData)

		# Check if battle should end due to poison/etc.
		if await _check_if_battle_ended(): return

		# Pause before processing next turn.
		await get_tree().create_timer(post_turn_delay).timeout

	Logger.append_battle_log("\n\nPlayer is selecting actions...")
	await _dialog(true)
	_prep_next_turn()
	gui.enable_player_controls(true)


func _calculate_transmutations(target: BattleActor, action: _BattleAction) -> void:
	if target.stasis:
		Logger.append_battle_log("%s is in stasis! Transmutations were blocked!" % target.name)
		gui.animate_status_activation(target, target.stasis)
		return

 	# Calculate secondary + attack 
	_calculate_transmutation(target.element2, action.element, target, 1)
	# Return early if target died due to phobia.
	if target.is_defeated: return
	# Calculate internal transmutation.
	_calculate_transmutation(target.element1, target.element2, target, 1, true)


func _calculate_transmutation(e1: ElementalType, e2: ElementalType, target: BattleActor, id: int, isInternal:=false) -> bool:
	var newType := ElementManager.get_matchup(e1, e2)
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
	message_feed.append_transmutation_message(target, e1, newType, e2) 

	var buff := ElementManager.get_side_effect(e1, e2)

	if not buff.apply_effect(ActorTurnData.empty(target), target).is_empty():
		msg.append("This reaction had side effects!")
		msg.append_array(target.get_and_flush_msgs())

	target.set_element(id, newType)
	var msg2 := target.get_and_flush_msgs()
	if len(msg2) > 0:
		msg.append_array(msg2)

	Logger.append_battle_log(msg)
	return true


func _dialog(isAfterTurn: bool) -> void:
	var dialogId := ai.get_next_dialog_id(_turn_counter, isAfterTurn)

	if len(dialogId) > 0:
		_dialog_box.start(dialogId)
		await _dialog_box.dialogue_ended


func _check_if_battle_ended() -> bool:
	if _defeated_allies == len(allies):
		StoryManager.set_variable("battle_result", "defeated")
		Logger.append_battle_log("You were defeated...")
		await _resolve_end_of_battle()
		battle_ended.emit(EndState.DEFEATED)
		return true
	elif _defeated_enemies == len(enemies):
		StoryManager.set_variable("battle_result", "won")
		Logger.append_battle_log("You won!")
		await _resolve_end_of_battle()
		battle_ended.emit(EndState.WON)
		return true
	return false


func resolve_end_of_turn(turnData: ActorTurnData) -> void:
	var a := allies if turnData.team_index == 0 else enemies
	var o := enemies if turnData.team_index == 0 else allies
	turnData.resolve_end_of_turn(a, o)

	for effect: int in turnData.expired_status_effects:
		message_feed.append_removed_status_effect_message(turnData.user, effect)

	turnData.user.turn_ended.emit()


func _resolve_end_of_battle(pause:=true) -> void:
	for ally in allies:
		# TO BE DEPRECATED
		var msg: String = ally.resolve_end_of_battle(_turn_counter)
		ally.was_just_defeated.disconnect(_increment_defeat_counter)
		# await gui.display_message(msg)
	
	for enemy in enemies:
		enemy.resolve_end_of_battle(_turn_counter)
		enemy.was_just_defeated.disconnect(_increment_defeat_counter)
	
	remove_child(gui)

	if pause and len(allies) > _defeated_allies:
		var rewardScreen := RewardScreen.instantiate()
		$CanvasLayer.add_child(rewardScreen)
		$CanvasLayer.show()
		Inventory.add_items(ai.reward_items)
		rewardScreen.show_results(allies, ai.reward_xp, ai.reward_items)
		await rewardScreen.pressed
		$CanvasLayer.remove_child(rewardScreen)
		$CanvasLayer.hide()


func _prep_next_turn() -> void:
	Logger.append_battle_log("\n********************************AI********************************")
	_actions.assign(ai.get_actions(allies))
	Logger.append_battle_log("\n********************************END AI********************************")
	gui.show_enemy_intentions(true)
	tie_breaker = randf() < 0.5

	var speedRank := allies.duplicate()
	speedRank.append_array(enemies)
	speedRank.sort_custom(func(a: BattleActor, b: BattleActor) -> bool:
		if a.speed != b.speed:
			return a.speed > b.speed
		return tie_breaker)
	speedRank.map(func(a: BattleActor) -> String: return a.name)

	gui.display_turn_order(speedRank)


func _increment_defeat_counter(isAlly: bool) -> void:
	if isAlly:
		_defeated_allies += 1
	else:
		_defeated_enemies += 1


# To be DEPRECATED
func _build_msg(data: ActorTurnData) -> String:
	var targetName: String
	var TargetType := _BattleAction.TargetType
	match data.action.target:
		TargetType.ENEMY, TargetType.ALLY:
			targetName = data.targets[0].name
		TargetType.ENEMIES: 
			targetName = "the enemy team"
		TargetType.ALLIES:
			targetName = "their team"
		TargetType.SELF:
			targetName = "their team"

	var output := "%s used %s on %s!" % [data.user.name, data.action.name, targetName]
	if data.total_dmg > 0:
		output += "(%d dmg)" % data.total_dmg
	if data.recoil_dmg > 0:
		output += "\nThis attack had recoil (%d dmg)..." % data.recoil_dmg
	return output
