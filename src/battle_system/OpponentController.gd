extends Node
class_name OpponentController 


func GetActions(team, otherTeam):
	var actions = []
	actions.resize(len(team))

	for i in range(len(team)):
		if(len(team[i].Attacks) == 0):
			actions[i] = null;
		else:
			actions[i] = ActorAction.new(team[i], team[i].Attacks[0],[ otherTeam[0] ], 1);
	return actions;
