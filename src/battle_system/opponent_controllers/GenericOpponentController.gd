extends OpponentController
class_name GenericOpponentController

const BASE_WEIGHT_UNIT: float = 10

## How much does this opponent value damage over setup.
@export_range(0, 1) var aggression: float
## How much should randomness influence this opponent's decisions.
@export_range(0, 1) var intelligence: float
## How much should opponent value causing transmutations.
@export_range(0, 1) var transmutation_bias: float

## Add extra weight to actions that will transmute an actor to this color. 
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _transmutation_pref: String = "blank":
	set(value):
		_transmutation_pref = value
		transmutation_pref = ElementManager.get_element_from_name(value)
var transmutation_pref: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		transmutation_pref = value 

var aggression_bias: float
var setup_bias: float

func setup(team: Array) -> void:
	super.setup(team)
	aggression_bias = aggression
	setup_bias = 1 - aggression


func get_actions(otherTeam: Array) -> Array:
	var actions := []

	for user in team:
		Logger.append_battle_log("\nChoosing action for user: %s" % user.name)
		var action := _get_action(user, otherTeam)
		actions.append(action)
		user.action_selected.emit(action.action)
	return actions;


func _get_action(user: BattleActor, targets: Array) -> ActorAction:
	var maxVal := 0.0
	var maxTarget: BattleActor = targets[0]
	var maxAction: _BattleAction = user.attacks[0]

	var currentTargets: Array

	for action in user.attacks:
		if action.target == _BattleAction.TargetType.ALLY \
				or action.target == _BattleAction.TargetType.ALLIES \
				or action.target == _BattleAction.TargetType.SELF:
			currentTargets = team
		else:
			currentTargets = targets

		# If attack is melee, calculate user's transmutations.
		var e0 = ElementManager.get_matchup(user.element2, action.element)
		var e1 = ElementManager.get_matchup(user.element1, e0)
		var pref := int(e0 == transmutation_pref) + int(e1 == transmutation_pref)
		var userTransCount := int(e0 != null) + int(e1 != null)

		for target in currentTargets:
			if target.is_defeated:
				Logger.append_battle_log("\nSkipping Target(%s), as they have been defeated." % target.name) 
				continue
			Logger.append_battle_log("\nEvaluating BattleAction(%s) against Target(%s)" 
					% [ action.name, target.name ])

			# Count number of transmutations.
			var e2 := ElementManager.get_matchup(target.element2, action.element)
			var e3 := ElementManager.get_matchup(target.element1, e2)
			var currTransCount: float = int(e2 != null) + int(e1 != null)
			Logger.append_battle_log("Total transmutations(%.2f) = Target(%d) + User(%d) + Pref(%.2f)." 
					% [currTransCount + userTransCount + pref, currTransCount, userTransCount, pref])
			currTransCount += userTransCount + pref

			var potential := _evaluate_setup_potential(user, target, action)

			# Check damage.
			var currDmg: int = potential[0]
			Logger.append_battle_log("This action will do ~%.2f base damage." % currDmg)

			# Check potential phobia damage.
			var phobiaDmg = int(target.has_phobia(e2))
			phobiaDmg += int(target.has_phobia(e3))
			Logger.append_battle_log("This action will do ~%.2f phobia damage." % phobiaDmg)
			currDmg += phobiaDmg
			Logger.append_battle_log("This action will do ~%.2f total damage." % currDmg)

			# Check non-damage related attack potential.
			var currStatusPotential: float = potential[1]
			Logger.append_battle_log("This attack has %.2f status potential." % currStatusPotential)

			var agg: float = currDmg * aggression_bias * action.accuracy / 10.0
			Logger.append_battle_log("Agg(%.2f) = Dmg(%.2f) * Aggression(%.2f) * Accuracy(%.2f) / 10.0" 
					% [agg, currDmg, aggression_bias, action.accuracy])

			# If damage is directed towards ally, its a negative factor.
			if currentTargets == team:
				agg *= -1
				Logger.append_battle_log("Damage is directed towards ally... Agg(%.2f)" % agg) 

			var tCount = currTransCount * transmutation_bias
			Logger.append_battle_log("TransmutationCount(%.2f) = Count(%.2f) * T_Bias(%.2f)" 
					% [tCount, currTransCount, transmutation_bias])
			var sPot := currStatusPotential * setup_bias * 2
			Logger.append_battle_log("StatusPotential(%.2f) = Potential(%.2f) * S_Bias(%.2f) * 2" 
					% [sPot, currStatusPotential, setup_bias])
			# Status only moves get +2 in order to compete.
			if action.attack_range == _BattleAction.AttackRange.STATUS:
				sPot += 2


			var val: float = agg + tCount + sPot
			# Get random influence.
			var rand := randf_range(intelligence, 1)
			Logger.append_battle_log("Rand(%.2f) = [Intelligence(%.2f), 1]" 
					% [rand, intelligence])
			
			val *= rand
			Logger.append_battle_log("VALUE(%.2f) = (Aggression(%.2f) + TransmutationCount(%.2f) + StatusPotential(%.2f)) * Random(%.2f)" 
					% [val, agg, tCount, sPot, rand])

			# Update maximum value.
			var prevMaxVal := maxVal
			var prevTarget := maxTarget
			var prevAction := maxAction
			if val > maxVal:
				maxVal = val
				maxTarget = target
				maxAction = action
			Logger.append_battle_log("PrevMaxVal(%.2f) vs CurrVal(%.2f) ---> MaxVal(%.2f)"
					% [prevMaxVal, val, maxVal])
			Logger.append_battle_log("PrevTarget(%s) vs CurrTarget(%s) ---> Target(%s)"
					% [prevTarget.name, target.name, maxTarget.name])
			Logger.append_battle_log("PrevAction(%s) vs CurrAction(%s) ---> Action(%s)"
					% [prevTarget.name, target.name, maxTarget.name])

	match maxAction.target:
		_BattleAction.TargetType.ALLIES:
			Logger.append_battle_log("%s is using %s on its team.\n"
					% [user.name, maxAction.name])
			return ActorAction.new(user, maxAction, team, TEAM_INDEX)
		_BattleAction.TargetType.ENEMIES:
			Logger.append_battle_log("%s is using %s against the opposing team.\n"
					% [user.name, maxAction.name])
			return ActorAction.new(user, maxAction, targets, TEAM_INDEX)
		_:
			Logger.append_battle_log("%s is using %s against %s.\n"
					% [user.name, maxAction.name, maxTarget.name])
			return ActorAction.new(user, maxAction, [maxTarget], TEAM_INDEX)


func _evaluate_setup_potential(user: BattleActor, target: BattleActor, action: _BattleAction) -> Array:
	var setupPotential := 0.0
	var dmg := 0

	for effect in action.effects:
		var isFriendly: bool = action.target == _BattleAction.TargetType.SELF \
				or action.target == _BattleAction.TargetType.ALLY \
				or action.target == _BattleAction.TargetType.ALLIES \
				or effect.effect_target == _BaseEffectSlot.EffectTarget.USER \
				or effect.effect_target == _BaseEffectSlot.EffectTarget.USER_ONCE

		var slot: EffectSlot = effect.get_effect_slot(user, target, action, 1.0)

		# ConditionalEffect, where effect will fail.
		if not slot:
			continue

		dmg += slot.attack_effect.get_dmg_potential(user, target, isFriendly, action)
		var pot: float = slot.attack_effect.get_setup_potential(user, target, isFriendly, dmg)
		var weight := _weighted_setup_potential(user, target, slot, isFriendly)
		var val: float =  pot * weight * effect.chance
		
		setupPotential += val

	return [dmg, setupPotential]


# All setup potential values should be [0, 1].
# Modify these weights so they can compete with damage numbers.
func _weighted_setup_potential(user: BattleActor, target: BattleActor, slot: EffectSlot, isFriendly: bool) -> float:
	var effect := slot.attack_effect
	# If opponent has low health, they will prioritize healing themselves if possible.
	if float(user.current_hp) < float(user.hp) / 3.0:
		var base := (float(user.hp) - float(user.current_hp)) * slot.chance

		if target == user and effect is InstantHealthChange :
			Logger.append_battle_log("BattleActor(%s) is low on health. Boosting Effect(%s) by %.2f" 
				% [user.name, effect.name, base])
			return base
		# Account for fact that target could block, etc.
		elif effect is DrainingDamage:
			Logger.append_battle_log("BattleActor(%s) is low on health. Boosting Effect(%s) by %.2f" 
				% [user.name, effect.name, base])
			return base

	return 1.0
