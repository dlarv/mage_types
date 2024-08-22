using Godot;
using System;
using System.Linq;

public partial class Battle : Node
{
	[Signal]
	public delegate void TransmutationOccuredEventHandler(int actorIndex, Element a, Element b);
	[Signal]
	public delegate void HpChangedEventHandler(int actorIndex, int amount, bool isDead);
	[Signal]
	public delegate void StatusEffectInflictedEventHandler(int actorIndex, StatusEffect effect);

	private BattleActor[] opponents;
	private BattleActor[] allies;
	private BattleActor[] actors;

	public void StartBattle(BattleActor[] allies, BattleActor[] opponents) 
	{
		this.allies = allies;
		this.opponents = opponents;
		actors = allies.Concat(opponents).ToArray();
	}

	public void UseItem() 
	{
	}

}
