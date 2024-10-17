extends OpponentController
## Cycles through each of its actors movesets.
## Targets are randomly selected.

var indices := []

func setup(team: Array) -> void:
	super.setup(team)
	
	for i in team:
		indices.append(-1)

func get_actions(otherTeam: Array) -> Array:
	var actions := []
	var i = -1
	for actor in team:
		i += 1

		indices[i] += 1
		indices[i] %= len(actor.attacks)
		var index = indices[i]

		var attack = actor.attacks[index]
		if attack is BattleTalk:
			actions.append(ActorAction.new(actor, attack, [ ], TEAM_INDEX))
			if not attack.repeat:
				attack.already_said = true
				actor.attacks.remove_at(index)
			else:
				indices[i] += 1
				indices[i] %= len(actor.attacks)
				index += 1
			attack = actor.attacks[index]

		actions.append(ActorAction.new(actor, attack, [ otherTeam.pick_random() ], TEAM_INDEX))
	
	return actions

		

