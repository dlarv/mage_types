extends Node
class_name OpponentController 

const TEAM_INDEX = 1

var team := []

func setup(team: Array) -> void:
	self.team = team

func get_actions(otherTeam: Array) -> Array:
	var actions := []
	actions.resize(len(team))

	for i in range(len(team)):
		if(len(team[i].attacks) == 0):
			actions[i] = null;
		else:
			actions[i] = ActorAction.new(team[i], team[i].attacks[0],[ otherTeam[0] ], TEAM_INDEX);
	return actions;
