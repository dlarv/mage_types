extends Node

signal battle_ended(endState: EndState)
signal selection_phase_started()
signal action_phase_started()

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
var simulator_mode := false
var enemies: Array[BattleActor] = []
var allies: Array[BattleActor] = []

var _defeated_allies: int = 0
var _defeated_enemies: int = 0
var _turn_counter: int = 0
var _actions: Array[ActorTurnData] = []
var tie_breaker := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("create_log"):
		MyLogger.save_log()
	elif event.is_action_pressed("skip_dialog"):
		_dialog_box.stop()
	elif event.is_action_pressed("toggle_battle_feed") and message_feed:
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

	message_feed.setup(allies + enemies)

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
	action_phase_started.emit()

	_turn_counter += 1
	gui.turn_counter = _turn_counter
	message_feed.append_turn_header(_turn_counter)

	MyLogger.append_battle_log("\n********************************Turn %d********************************" 
			% _turn_counter)

	# If allyActions is empty, the player pressed the "Run" button.
	if len(allyActions) == 1 and allyActions[0].is_flee():
		StoryManager.set_variable("battle_result", "fled")
		MyLogger.append_battle_log("You ran away.")
		battle_ended.emit(EndState.FLED)
		_resolve_end_of_battle(false)
		return

	# Get actions for opponent's team.
	# var enemyActions = ai.get_actions(allies)
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
		if turnData == null or turnData.user.is_defeated:
			continue
			
		var flinch := turnData.user.flinching
		if flinch != null:
			MyLogger.append_battle_log("%s flinched! They were unable to move." % turnData.user.name)
			gui.animate_status_activation(turnData.user, flinch)
			turnData.user.status_activated.emit(flinch, null)
			resolve_end_of_turn(turnData)
			await get_tree().create_timer(post_turn_delay).timeout
			continue

		MyLogger.append_battle_log("\nActors turn: %s" % turnData.user.name)
		
		# Apply action effects.
		var res := turnData.execute()
		var msg: Array[String] = []#res.msg
		var missed: bool = res.missed

		message_feed.append_action_message(turnData)

		await gui.animate_action(turnData, missed)
		await get_tree().create_timer(post_attack_delay).timeout

		var defeatedActors := turnData.get_defeated()
		
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
			_calculate_transmutations(turnData.user, turnData.action, true) 
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

	MyLogger.append_battle_log("\n\nPlayer is selecting actions...")
	await _dialog(true)
	_prep_next_turn()
	gui.enable_player_controls(true)


func _calculate_transmutations(target: BattleActor, action: _BattleAction, isMelee:=false) -> void:
	if target.stasis:
		target.status_activated.emit(target.stasis, null)
		gui.animate_status_activation(target, target.stasis)
		return

 	# Calculate secondary + attack 
	_calculate_transmutation(target.element2, action.element, target, 1, false, isMelee)
	# Return early if target died due to phobia.
	if target.is_defeated: return
	# Calculate internal transmutation.
	_calculate_transmutation(target.element1, target.element2, target, 1, true, isMelee)


func _calculate_transmutation(e1: ElementalType, e2: ElementalType, target: BattleActor, id: int, isInternal:=false, isMelee:=false) -> bool:
	var newType := ElementManager.get_matchup(e1, e2)
	if newType == null: return false

	if isMelee:
		message_feed.append_info("Melee attack's also cause transmutations in their user!")

	message_feed.append_transmutation_message(target, e1, newType, e2, isInternal) 

	var buff := ElementManager.get_side_effect(e1, e2)

	if not buff.apply_effect(ActorTurnData.empty(target), target).is_empty():
		message_feed.append_side_effect_message(target, buff)

	target.set_element(id, newType)

	return true


func _dialog(isAfterTurn: bool) -> void:
	var dialogId := ai.get_next_dialog_id(_turn_counter, isAfterTurn)

	if len(dialogId) > 0:
		_dialog_box.start(dialogId)
		await _dialog_box.dialogue_ended


func _check_if_battle_ended() -> bool:
	if _defeated_allies == len(allies):
		StoryManager.set_variable("battle_result", "defeated")
		MyLogger.append_battle_log("You were defeated...")
		await _resolve_end_of_battle()
		battle_ended.emit(EndState.DEFEATED)
		return true
	elif _defeated_enemies == len(enemies):
		StoryManager.set_variable("battle_result", "won")
		MyLogger.append_battle_log("You won!")
		await _resolve_end_of_battle()
		battle_ended.emit(EndState.WON)
		return true
	return false


func resolve_end_of_turn(turnData: ActorTurnData) -> void:
	var a := allies if turnData.team_index == 0 else enemies
	var o := enemies if turnData.team_index == 0 else allies
	turnData.resolve_end_of_turn(a, o)

	message_feed.append_expired_status_effects_message(turnData)
	message_feed.newline()

	turnData.user.turn_ended.emit()


func _resolve_end_of_battle(pause:=true) -> void:
	for ally in allies:
		ally.resolve_end_of_battle(_turn_counter)
		ally.was_just_defeated.disconnect(_increment_defeat_counter)
	
	for enemy in enemies:
		enemy.resolve_end_of_battle(_turn_counter)
		enemy.was_just_defeated.disconnect(_increment_defeat_counter)
	
	remove_child(gui)

	var rewardScreen := RewardScreen.instantiate()
	$CanvasLayer.add_child(rewardScreen)
	$CanvasLayer.show()
	if pause and len(allies) > _defeated_allies:
		Inventory.add_items(ai.reward_items)
		
		if not simulator_mode:
			rewardScreen.show_results(allies, ai.reward_xp, _dialog_box, ai.reward_items)
			await rewardScreen.pressed
	elif pause and not simulator_mode:
		rewardScreen.show_defeat(_dialog_box)
		await rewardScreen.pressed
	$CanvasLayer.remove_child(rewardScreen)
	$CanvasLayer.hide()


func _prep_next_turn() -> void:
	selection_phase_started.emit()

	MyLogger.append_battle_log("\n********************************AI********************************")
	_actions.assign(ai.get_actions(allies))
	MyLogger.append_battle_log("\n********************************END AI********************************")

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
