extends Node
class_name OpponentController 


func GetActions(team, otherTeam):
	var actions = []

	for i in range(len(actions)):
		if(len(team[i].Attacks) == 0):
			actions[i] = null;
		else:
			actions[i] = ActorAction.new(team[i], team[i].Attacks[0],[ otherTeam[0] ], 1);
	return actions;
