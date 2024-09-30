extends Node
class_name Battle 

signal battle_ended()

# BattleActor[]
var enemies = []
var allies = []

@export
var gui: BattleGUI
@export
var ai: OpponentController 
@export
var matchupManager: CanvasLayer

var defeatedAllies : int = 0
var defeatedEnemies : int = 0

func _unhandled_input(event) -> void:
	if event.is_action_pressed("open_player_menu"):
		matchupManager.visible = !matchupManager.visible

func start(allies, allyItems, enemies, ai) -> void:
	self.allies = allies
	self.enemies = enemies

	for ally in allies:
		ally.was_just_defeated.connect(func(): defeatedAllies += 1)
	for enemy in enemies:
		enemy.was_just_defeated.connect(func(): defeatedEnemies += 1)

	gui.setup(allies, allyItems, enemies)

func on_player_actions_selected(allyActions) -> void:
	# If allyActions is empty, the player pressed the "Run" button.
	if allyActions == null or len(allyActions) == 0:
		await gui.display_message("You ran away.")
		battle_ended.emit()
		return

	gui.enable_player_controls(false)
	var enemyActions = ai.get_actions(enemies, allies)
	var actions = allyActions
	actions.append_array(enemyActions)

	# Calculate turn order based on priority and actor speed.
	actions.sort()

	for action in actions:
		# This means a character is defeated or flinched.
		if action == null:
			continue

		if action.actor.is_flinching:
			continue

		action.action.apply_cost(action.actor)

		# Play animation.
		var userPosition = gui.get_actor_display_position(action.team_index, action.actor)
		var targetTeamIndex
		var teamDisplay
		# Target same team as user.
		if(action.action.target == BattleAction.TargetType.SELF \
				or action.action.target == BattleAction.TargetType.ALLY \
				or action.action.target == BattleAction.TargetType.ALLIES):
			targetTeamIndex = action.team_index
			teamDisplay =  gui.ally_display_parent  if action.team_index == 0  else  gui.enemy_display_parent
		# Target opposite team from user.
		else:
			targetTeamIndex = (action.team_index + 1) % 2
			teamDisplay =  gui.ally_display_parent  if action.team_index == 1  else  gui.enemy_display_parent
		var targetPosition = gui.get_actor_display_position( targetTeamIndex, action.targets[0] if len(action.targets) == 1 else null)
		
		var animation = action.action.play_animation(userPosition, targetPosition)
		add_child(animation)

		# Apply action effects.
		var msg = action.action.apply_effects(action.actor, action.targets)

		# Display message and await input.
		await gui.display_message(msg)

		# Calculate target transmutations.
		for target in action.targets:
			await calculate_transmutations(target, action.action)

		# Calculate user transmutations.
		# If the user targeted themselves 
		# (e.g. Target = Allies || Self || Ally).
		# This only applies to melee attacks.
		if(action.targets.find(action.actor) == -1 \
				and action.action is Attack \
				and (action.action).attack_range == Attack.AttackRange.MELEE):
			await calculate_transmutations(action.actor, action.action) 

		# Resolve user's status effects.
		msg = action.actor.resolve_end_of_turn()		
		if len(msg) > 0:
			await gui.display_message(msg)

		# Check if battle should end.
		if defeatedAllies == len(allies):
			await gui.display_message("You were defeated...")
			battle_ended.emit()
		elif defeatedEnemies == len(enemies):
			await gui.display_message("You won!")
			battle_ended.emit()
		# Pause before processing next turn.
		await get_tree().create_timer(0.5).timeout
	gui.enable_player_controls(true)

func calculate_transmutations(target: BattleActor, action: BattleAction) -> void:
	var msg = ""
	var e1 = target.element1.name.to_lower()
	var e2 = target.element2.name.to_lower()
	var ea = action.element.name.to_lower()

 	# Calculate primary + attack 
	var newType = ElementManager.get_matchup(target.element1, action.element)
	if newType != null and not target.in_stasis:
		msg += "The target %s's [color=%s]%s[/color] reacted with the attack's [color=%s]%s[/color] type to make [color=%s]%s[/color].\n" % [target.name, e1, e1, ea, ea, newType.name.to_lower(), newType.name.to_lower()]

		var vals = ElementManager.get_side_effect(target.element1, action.element)
		var buff = vals[0]
		var debuff = vals[1]

		if buff != null:
			msg += "\nThis reaction had side effects! %s" % buff.apply_effect(target)
		if debuff != null:
			msg += "\nThis reaction had side effects! %s" % debuff.apply_effect(target)

		var msg2 = target.set_element(0, newType)
		if len(msg2) > 0:
			msg += "\n%s" % msg2

 	# Calculate secondary + attack 
	newType = ElementManager.get_matchup(target.element2, action.element)
	if newType != null and not target.in_stasis:
		msg += "The target %s's [color=%s]%s[/color] reacted with the attack's [color=%s]%s[/color] type to make [color=%s]%s[/color].\n" % [ target.name, e2, e2, ea, ea, newType.name.to_lower(), newType.name.to_lower()]

		var vals = ElementManager.get_side_effect(target.element2, action.element)
		var buff = vals[0]
		var debuff = vals[1]

		if buff != null:
			msg += "\nThis reaction had side effects! %s" % buff.apply_effect(target)
		if debuff != null:
			msg += "\nThis reaction had side effects! %s" % debuff.apply_effect(target)

		var msg2 = target.set_element(1, newType)
		if len(msg2) > 0:
			msg += "\n%s" % msg2


	# Only display message if applicable.
	# If no changes occurred, iteration can end here.
	if len(msg) > 0:
		await gui.display_message(msg)
	else: return

 	# Calculate primary + secondary.
	newType = ElementManager.get_matchup(target.element1, target.element2)
	if newType != null and not target.is_dissonant:
		e1 = target.element1.name.to_lower()
		e2 = target.element2.name.to_lower()
		msg = "The target %s's [color=%s]%s[/color] reacted with it's [color=%s]%s[/color] type to make [color=%s]%s[/color]." % [target.name, e1, e1, e2, e2, newType.name.to_lower(), newType.name.to_lower()]

		var vals = ElementManager.get_side_effect(target.element1, target.element2)
		var buff = vals[0]
		var debuff = vals[1]
		if buff != null:
			msg += "\nThis reaction had side effects! %s" % buff.apply_effect(target)
		if debuff != null:
			msg += "\nThis reaction had side effects! %s" % debuff.apply_effect(target)

		var msg2 = target.set_element(0, newType)
		target.set_element(1, ElementManager.Blank)
		if len(msg2) > 0:
			msg += "\n%s" % msg2
		
		await gui.display_message(msg)
