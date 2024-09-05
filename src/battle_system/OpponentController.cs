using Godot;
using System;

public partial class OpponentController : Node
{
	public virtual ActorAction[] GetActions(BattleActor[] team, BattleActor[] otherTeam) {
		ActorAction[] actions = new ActorAction[team.Length];

		for(int i = 0; i < actions.Length; i++) {
			if(team[i].Attacks.Length == 0) 
				actions[i] = null;
			else
				actions[i] = new ActorAction(team[i], team[i].Attacks[0], new BattleActor[] { otherTeam[0] }, 1);
		}
		return actions;
	}
}
