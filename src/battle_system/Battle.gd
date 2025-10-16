extends Node

signal battle_ended(endState: EndState)

enum EndState { WON, DEFEATED, FLED }
enum BattlefieldStateParams { COMBATANTS, ALLIES, ENEMIES, TEAM_0, TEAM_1, ATTACKS }

const BattleGUI := preload("res://src/battle_system/gui/battle_gui.tscn")
const ActorTurnData := preload("res://src/battle_system/ActorTurnData.gd")
const RewardScreen := preload("res://src/battle_system/gui/battle_rewards/battle_reward_screen.tscn")

@export var ai: OpponentController 
@export var _dialog_box: DialogueBox
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

	Logger.append_battle_log("\n********************************Turn %d********************************" 
			% _turn_counter)

	# If allyActions is empty, the player pressed the "Run" button.
	if len(allyActions) == 1 and allyActions[0].is_flee():
		StoryManager.set_variable("battle_result", "fled")
		await gui.display_message("You ran away.")
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
		if a.actor.speed != b.actor.speed:
			return a.actor.speed > b.actor.speed
		return tie_breaker)

	await _dialog(false)

	for turnData in _actions:
		# This means a character is defeated.
		if turnData == null or turnData.actor.is_defeated:
			continue
			
		var flinch := turnData.actor.flinching
		if flinch != null:
			await gui.display_message("%s flinched! They were unable to move." % turnData.actor.name)
			turnData.actor.turn_ended.emit()
			continue

		Logger.append_battle_log("\nActors turn: %s" % turnData.actor.name)
		
		# Apply action effects.
		var res: Dictionary = turnData.action.apply_effects(turnData.actor, turnData.targets)
		turnData.actor.action_used.emit(turnData.action)
		var msg: Array[String] = res.msg
		var missed: bool = res.get("missed", false)

		gui.animate_action(turnData, missed)

		# Display message and await input.
		await gui.display_message(msg)
		
		# Check if battle should end.
		if await _check_if_battle_ended(): return

		# Calculate target transmutations.
		if not missed:
			for target in turnData.targets:
				if target.is_defeated: continue
				await _calculate_transmutations(target, turnData.action)

		# Check if battle should end.
		# This will trigger if final actor died to phobia.
		if await _check_if_battle_ended(): return

		# Calculate user transmutations.
		# If the user targeted themselves 
		# (e.g. Target = Allies || Self || Ally).
		# This only applies to melee attacks.
		if not missed and turnData.targets.find(turnData.actor) == -1 \
				and turnData.action is Attack \
				and (turnData.action).attack_range == Attack.AttackRange.MELEE:
			await _calculate_transmutations(turnData.actor, turnData.action) 

		# Check if battle should end.
		# This will trigger if final actor died to phobia.
		if await _check_if_battle_ended(): return

		# Resolve user's status effects.
		var a := allies if turnData.team_index == 0 else enemies
		var o := enemies if turnData.team_index == 0 else allies
		turnData.actor.resolve_end_of_turn(a, o)
		turnData.actor.turn_ended.emit()
		msg = turnData.actor.get_and_flush_msgs()
		await gui.display_message(msg)
		# Check if battle should end.
		# e.g. if an actor was defeated by poison.
		if await _check_if_battle_ended(): return

		# Pause before processing next turn.
		await get_tree().create_timer(0.5).timeout

	# if await _check_if_battle_ended(): return
	
	Logger.append_battle_log("\n\nPlayer is selecting actions...")
	await _dialog(true)
	_prep_next_turn()
	gui.enable_player_controls(true)


func _calculate_transmutations(target: BattleActor, action: _BattleAction) -> void:
	if target.stasis:
		await gui.display_message("%s is in stasis! Transmutations were blocked!" % target.name)
		return

 	# Calculate secondary + attack 
	await _calculate_transmutation(target.element2, action.element, target, 1)
	# Return early if target died due to phobia.
	if target.is_defeated: return
	# Calculate internal transmutation.
	await _calculate_transmutation(target.element1, target.element2, target, 1, true)


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

	var buff := ElementManager.get_side_effect(e1, e2)

	if not buff.apply_effect(target, target).is_empty():
		msg.append("This reaction had side effects!")
		msg.append_array(target.get_and_flush_msgs())

	target.set_element(id, newType)
	var msg2 := target.get_and_flush_msgs()
	if len(msg2) > 0:
		msg.append_array(msg2)

	await gui.display_message(msg)
	return true


func _dialog(isAfterTurn: bool) -> void:
	var dialogId := ai.get_next_dialog_id(_turn_counter, isAfterTurn)

	if len(dialogId) > 0:
		_dialog_box.start(dialogId)
		await _dialog_box.dialogue_ended


func _check_if_battle_ended() -> bool:
	if _defeated_allies == len(allies):
		StoryManager.set_variable("battle_result", "defeated")
		await gui.display_message("You were defeated...")
		await _resolve_end_of_battle()
		battle_ended.emit(EndState.DEFEATED)
		return true
	elif _defeated_enemies == len(enemies):
		StoryManager.set_variable("battle_result", "won")
		await gui.display_message("You won!")
		await _resolve_end_of_battle()
		battle_ended.emit(EndState.WON)
		return true
	return false


func _resolve_end_of_battle(pause:=true) -> void:
	for ally in allies:
		var msg: String = ally.resolve_end_of_battle(_turn_counter)
		ally.was_just_defeated.disconnect(_increment_defeat_counter)
		await gui.display_message(msg)
	
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
func _play_animation(data: ActorTurnData) -> void:
	var userPosition: Vector2 = gui.get_actor_display_position(data.actor)
	var targetPosition: Vector2 = gui.get_actor_display_position(data.targets[0])
	data.action.play_animation(userPosition, targetPosition, self)
