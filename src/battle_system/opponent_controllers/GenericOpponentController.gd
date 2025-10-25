@tool
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

var _user_transmutation_count := -1
var _pref := -1

func setup(team: Array[BattleActor]) -> void:
	super.setup(team)
	aggression_bias = aggression
	setup_bias = 1 - aggression


func get_actions(otherTeam: Array[BattleActor]) -> Array[ActorTurnData]:
	var actions: Array[ActorTurnData] = []

	for user: BattleActor in team:
		var action := _get_action(user, otherTeam)
		actions.append(action)
		user.action_selected.emit(action.action)
	return actions;


func _get_action(user: BattleActor, targets: Array[BattleActor]) -> ActorTurnData:
	var maxVal := 0.0
	var maxTarget: BattleActor = targets[0]
	var maxAction: _BattleAction = user.attacks[0]

	var currentTargets: Array

	for action in user.attacks:
		Logger.append_battle_ai_log("\n\nEVALUATING ACTION(%s)" % action.name)

		# If attack is melee, calculate user's transmutations.
		var e0 := ElementManager.get_matchup(user.element2, action.element)
		var e1 := ElementManager.get_matchup(user.element1, e0)
		_pref = int(e0 == transmutation_pref) + int(e1 == transmutation_pref)
		_user_transmutation_count = int(e0 != null) + int(e1 != null)

		var res: Array
		match action.target:
			_BattleAction.TargetType.ALLY:
				res = _evaluate_single_target(user, team, action)
			_BattleAction.TargetType.ENEMY:
				res = _evaluate_single_target(user, targets, action)
			_BattleAction.TargetType.SELF:
				res = [ _evaluate_target(user, user, action, true), user ]
			_BattleAction.TargetType.ALLIES:
				res = _evaluate_team_target(user, team, action)
			_BattleAction.TargetType.ENEMIES:
				res = _evaluate_team_target(user, targets, action)
			_BattleAction.TargetType.ALL:
				res = _evaluate_all(user, team + targets, action)
			_BattleAction.TargetType.ANY:
				res = _evaluate_single_target(user, targets + team, action)
			_BattleAction.TargetType.ALL:
				res = _evaluate_all(user, targets + team, action)
			_BattleAction.TargetType.RANDOM:
				res = _evaluate_random(user, targets + team, action)

		# Update maximum value.
		var prevMaxVal := maxVal
		var prevTarget := maxTarget
		var prevAction := maxAction
		if res[0] > maxVal:
			maxVal = res[0]
			maxTarget = res[1]
			maxAction = action
			
		Logger.append_battle_ai_log("\nPrevMaxVal(%.2f) vs CurrVal(%.2f) ---> MaxVal(%.2f)"
				% [prevMaxVal, res[0], maxVal])
		Logger.append_battle_ai_log("PrevTarget(%s) vs CurrTarget(%s) ---> Target(%s)"
				% [prevTarget.name, res[1].name, maxTarget.name])
		Logger.append_battle_ai_log("PrevAction(%s) vs CurrAction(%s) ---> Action(%s)"
				% [prevTarget.name, res[1].name, maxTarget.name])


	match maxAction.target:
		_BattleAction.TargetType.ALLIES:
			Logger.append_battle_ai_log("%s is using %s on its team.\n"
					% [user.name, maxAction.name])
			return ActorTurnData.new(user, maxAction, team, TEAM_INDEX)
		_BattleAction.TargetType.ENEMIES:
			Logger.append_battle_ai_log("%s is using %s against the opposing team.\n"
					% [user.name, maxAction.name])
			return ActorTurnData.new(user, maxAction, targets, TEAM_INDEX)
		_BattleAction.TargetType.ALL:
			Logger.append_battle_ai_log("%s is using %s on everyone.\n"
					% [user.name, maxAction.name])
			return ActorTurnData.new(user, maxAction, team + targets, TEAM_INDEX)
		_BattleAction.TargetType.RANDOM:
			var target: BattleActor = (team + targets).pick_random()
			Logger.append_battle_ai_log("%s is using on %s.\n"
					% [user.name, maxAction.name, target.name])
			return ActorTurnData.new(user, maxAction, [target], TEAM_INDEX)
		_:
			Logger.append_battle_ai_log("%s is using %s against %s.\n"
					% [user.name, maxAction.name, maxTarget.name])
			return ActorTurnData.new(user, maxAction, [maxTarget], TEAM_INDEX)


func _evaluate_target(user: BattleActor, target: BattleActor, action: _BattleAction, isAlly: bool) -> float:
	Logger.append_battle_ai_log("\nEvaluating BattleAction(%s) against Target(%s)" 
				% [ action.name, target.name ])

	# Count number of transmutations.
	var e2 := ElementManager.get_matchup(target.element2, action.element)
	var e3 := ElementManager.get_matchup(target.element1, e2)
	var currTransCount: float = int(e2 != null) + int(e3 != null)
	Logger.append_battle_ai_log("TotalTransmutations(%.2f) = Target(%d) + User(%d) + Pref(%.2f)." 
			% [currTransCount + _user_transmutation_count + _pref, currTransCount, _user_transmutation_count, _pref])
	currTransCount += _user_transmutation_count + _pref
	var tCount := currTransCount * transmutation_bias
	Logger.append_battle_ai_log("TransmutationCount(%.2f) = Count(%.2f) * T_Bias(%.2f)" 
			% [tCount, currTransCount, transmutation_bias])

	var potential := _evaluate_setup_potential(user, target, action)

	# Check damage.
	var currDmg: int = potential[0]

	# Check potential phobia damage.
	var phobiaDmg := int(target.has_phobia(e2))
	phobiaDmg += int(target.has_phobia(e3))

	Logger.append_battle_ai_log("TotalDmg(%.2f) = BaseDmg(%.2f) + PhobiaDmg(%.2f)" 
			% [ currDmg + phobiaDmg, currDmg, phobiaDmg ])
	currDmg += phobiaDmg

	# Check non-damage related attack potential.
	var currStatusPotential: float = potential[1]

	# If damage is directed towards ally, its a negative factor.
	# Vice versa for setup.
	if isAlly:
		currDmg *= -1
		Logger.append_battle_ai_log("Damage is directed towards ally... Dmg(%.2f)" % currDmg) 

	var agg: float = currDmg * aggression_bias * action.accuracy / 10.0
	Logger.append_battle_ai_log("Agg(%.2f) = Dmg(%.2f) * Aggression(%.2f) * Accuracy(%.2f) / 10.0" 
			% [agg, currDmg, aggression_bias, action.accuracy])

	var sPot := currStatusPotential * setup_bias * 2
	Logger.append_battle_ai_log("SetupPotential(%.2f) = Potential(%.2f) * S_Bias(%.2f) * 2" 
			% [sPot, currStatusPotential, setup_bias])
	# Status only moves get +2 in order to compete.
	if action.attack_range == _BattleAction.AttackRange.STATUS:
		sPot += 2


	var val: float = agg + tCount + sPot
	# Get random influence.
	var rand := randf_range(intelligence, 1)
	Logger.append_battle_ai_log("Rand(%.2f) = [Intelligence(%.2f), 1]" 
			% [rand, intelligence])

	val *= rand
	Logger.append_battle_ai_log("VALUE(%.2f) = (Aggression(%.2f) + TransmutationCount(%.2f) + StatusPotential(%.2f)) * Random(%.2f)" 
			% [val, agg, tCount, sPot, rand])

	return val

func _evaluate_single_target(user: BattleActor, targets: Array[BattleActor], action: _BattleAction) -> Array:
	var maxVal := 0.0
	var maxTarget: BattleActor = targets[0]

	for target in targets:
		if target.is_defeated: continue

		var val := _evaluate_target(user, target, action, targets == team)
		if val > maxVal:
			maxVal = val
			maxTarget = target

	return [maxVal, maxTarget]

func _evaluate_team_target(user: BattleActor, targets: Array[BattleActor], action: _BattleAction) -> Array:
	var ACTOR := BattleActor.new()
	ACTOR.name = "TEAM"

	var maxVal := 0.0
	var maxTarget: BattleActor = targets[0]

	for target in targets:
		if target.is_defeated: continue

		maxVal += _evaluate_target(user, target, action, targets == team)

	return [maxVal, ACTOR]

func _evaluate_all(user: BattleActor, enemies: Array[BattleActor], action: _BattleAction) -> Array:
	var ACTOR := BattleActor.new()
	ACTOR.name = "ALL"

	var maxVal := 0.0
	var maxTarget: BattleActor = enemies[0]

	for target: BattleActor in enemies + team:
		if target.is_defeated: continue

		maxVal += _evaluate_target(user, target, action, target in team)

	return [maxVal, ACTOR]

func _evaluate_random(user: BattleActor, enemies: Array[BattleActor], action: _BattleAction) -> Array:
	var ACTOR := BattleActor.new()
	ACTOR.name = "RANDOM"

	var maxVal := 0.0
	var maxTarget: BattleActor = enemies[0]

	for target: BattleActor in enemies + team:
		if target.is_defeated: continue

		maxVal += _evaluate_target(user, target, action, target in team)

	return [maxVal / len(enemies + team), ACTOR]


func _evaluate_setup_potential(user: BattleActor, target: BattleActor, action: _BattleAction) -> Array:
	_AttackEffect.current_buffer.action = action
	var setupPotential := 0.0
	var dmg := 0

	for effect: _BaseEffectSlot in action.effects:
		var slot: EffectSlot = effect.get_effect_slot(user, target, action, 1.0)
		# ConditionalEffect, where effect will fail.
		if not slot:
			continue
			
		var isFriendly: bool = action.target == _BattleAction.TargetType.SELF \
				or action.target == _BattleAction.TargetType.ALLY \
				or action.target == _BattleAction.TargetType.ALLIES \
				or slot.effect_target == _BaseEffectSlot.EffectTarget.USER \
				or slot.effect_target == _BaseEffectSlot.EffectTarget.USER_ONCE
		
		var data := ActorTurnData.new(user, action, [target], 1)
		dmg += int(slot.attack_effect.get_dmg_potential(data, target, isFriendly) * slot.chance)
		data.total_dmg = dmg

		var pot: float = slot.attack_effect.get_setup_potential(data, target, isFriendly)
		var weight := _weighted_setup_potential(user, target, slot, isFriendly)
		var val: float =  pot * weight * effect.chance
		Logger.append_battle_ai_log("AttackEffect(%s) SetupPotential(%s) = Base(%.2f) * Weight(%.2f) * Chance(%.2f)" 
				% [ slot.attack_effect.name, val, pot, weight, effect.chance ])
		
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
			Logger.append_battle_ai_log("BattleActor(%s) is low on health. Boosting Effect(%s) by %.2f" 
				% [user.name, effect.name, base])
			return base

	return 1.0
