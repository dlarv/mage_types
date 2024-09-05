using Godot;
using System;

/// Datatype for actions selected by BattleActors.
/// These are basically like an instance of a BattleAction.
public partial class ActorAction : Node, IComparable<ActorAction> 
{
	public BattleActor actor;
	public int priority;
	public BattleAction action;
	public BattleActor[] targets;
	public int teamIndex;

	public ActorAction(BattleActor actor, BattleAction action, BattleActor[] targets, int teamIndex) {
		this.actor = actor;
		this.action = action;
		this.priority = action.Priority;
		this.targets = targets;
		this.teamIndex = teamIndex;
	}

	public int CompareTo(ActorAction other)
	{
		// Compare priority.
		if(this.priority.CompareTo(other.priority) != 0)
			return this.priority.CompareTo(other.priority);
		// If both actions have the same priority, compare speeds.
		if(this.actor.Speed.CompareTo(other.actor.Speed) != 0)
			return this.actor.Speed.CompareTo(other.actor.Speed);

		// If both actors have the same speed stat, randomize.
		var speed1 = this.actor.Speed + GD.RandRange(-5, 5);
		var speed2 = other.actor.Speed + GD.RandRange(-5, 5);
		return speed1.CompareTo(speed2);
	}
}
