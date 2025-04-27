extends OpponentController
class_name GenericOpponentController

## How much does this opponent value damage over setup.
@export_range(0, 1) var aggression: float
## How much should randomness influence this opponent's decisions.
@export_range(0, 1) var intelligence: float
## How much should opponent value causing transmutations.
@export_range(0, 1) var transmutation_bias: float

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

	for action in user.attacks:
		for target in targets:
			Logger.append_battle_log("\nEvaluating BattleAction(%s) against Target(%s)" 
					% [ action.name, target.name ])

			# Count number of transmutations.
			var e1 := ElementManager.get_matchup(target.element1, action.element)
			var e2 := ElementManager.get_matchup(target.element2, action.element)
			var e3 := ElementManager.get_matchup(target.element1, target.element2)
			var currTransCount = len([e1, e2, e3].filter(func(item): return item != null))
			Logger.append_battle_log("This action will cause %d transmutations." % currTransCount)

			var potential := action.get_attack_potential(user, target)

			# Check damage.
			var currDmg: int = potential.get("dmg", 0)
			Logger.append_battle_log("This action will do ~%.2f base damage." % currDmg)

			# Check potential phobia damage.
			var phobiaDmg = int(target.has_phobia(e1))
			phobiaDmg += int(target.has_phobia(e2))
			phobiaDmg += int(target.has_phobia(e3))
			Logger.append_battle_log("This action will do ~%.2f phobia damage." % phobiaDmg)
			currDmg += phobiaDmg
			Logger.append_battle_log("This action will do ~%.2f total damage." % currDmg)

			# Check non-damage related attack potential.
			var currStatusPotential: float = potential.get("setup", 0)
			Logger.append_battle_log("This attack has %.2f status potential." % currStatusPotential)

			# Get random influence.
			var rand := randf_range(-2, 2 * intelligence)
			Logger.append_battle_log("Rand(%.2f) = [-2, 2 * Intelligence(%.2f)]" 
					% [rand, intelligence])

			# Normalize damage, otherwise this value will always beat out the others.
			var agg := currDmg * aggression_bias
			Logger.append_battle_log("Agg(%.2f) = Dmg(%.2f) * Aggression(%.2f)" 
					% [agg, currDmg, aggression_bias])
			var tCount = currTransCount * transmutation_bias
			Logger.append_battle_log("TransmutationCount(%.2f) = Count(%.2f) * T_Bias(%.2f)" 
					% [tCount, currTransCount, transmutation_bias])
			var sPot := currStatusPotential * setup_bias
			Logger.append_battle_log("StatusPotential(%.2f) = Potential(%.2f) * S_Bias(%.2f)" 
					% [sPot, currStatusPotential, setup_bias])

			var val: float = agg + tCount + sPot + rand
			Logger.append_battle_log("Value(%.2f) = Aggression(%.2f) + TransmutationCount(%.2f) + StatusPotential(%.2f) + Random(%.2f)" 
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
			Logger.append_battle_log("PrevAction(%s) vs CurrAction(%sf) ---> Action(%s)"
					% [prevTarget.name, target.name, maxTarget.name])

	Logger.append_battle_log("%s is using %s against %s.\n"
			% [user.name, maxAction.name, maxTarget.name])
	return ActorAction.new(user, maxAction, [ maxTarget ], TEAM_INDEX)
