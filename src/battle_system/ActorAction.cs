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

	public ActorAction(BattleActor actor, BattleAction action, BattleActor[] targets) {
		this.actor = actor;
		this.action = action;
		this.priority = action.Priority;
		this.targets = targets;
	}

	public int CompareTo(ActorAction other)
	{
		return this.priority.CompareTo(other.priority);
	}
}
