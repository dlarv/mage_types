using Godot;
using System;

public partial class OpponentController : Node
{
	public BattleAction[] GetActions(BattleActor[] otherTeam) {
		return new BattleAction[0];
	}
}
