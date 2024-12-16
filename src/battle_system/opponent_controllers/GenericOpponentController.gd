extends OpponentController

@export_range(0, 1) var aggression: float
@export_range(0, 1) var intelligence: float
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
		actions.append(_get_action(user, otherTeam))
	return actions;

func _get_action(user: BattleActor, targets: Array) -> ActorAction:
	var maxVal := 0.0
	var maxTarget: BattleActor
	var maxAction: BattleAction

	for action in user.attacks:
		for target in targets:
			# Count number of transmutations.
			var e1 := ElementManager.get_matchup(target.element1, action.element)
			var e2 := ElementManager.get_matchup(target.element2, action.element)
			var e3 := ElementManager.get_matchup(target.element1, target.element2)
			var currTransCount = len([e1, e2, e3].filter(func(item): return item != null))

			var potential := action.get_attack_potential(user, target)
			var currDmg: int = potential.get("dmg", 0)
			var currStatusPotential: float = potential.get("status", 0.0)

			# Check potential phobia damage.
			currDmg += int(target.has_phobia(e1))
			currDmg += int(target.has_phobia(e2))
			currDmg += int(target.has_phobia(e3))

			# Calculate value.
			var val: float = currDmg * aggression_bias \
					+ currTransCount * transmutation_bias \
					+ currStatusPotential * setup_bias \
					+ randf_range(-2, 2 * intelligence)

			# Update maximum value.
			if val > maxVal:
				maxVal = val
				maxTarget = target
				maxAction = action

	return ActorAction.new(user, maxAction, [ maxTarget ], TEAM_INDEX)

