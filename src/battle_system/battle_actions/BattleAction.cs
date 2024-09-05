using Godot;
using System;

[GlobalClass]
public partial class BattleAction : Resource
{
	public static BattleAction Flee { get; private set; } = new();
	public enum TargetType { Self, Ally, Allies, Enemy, Enemies }

	[Export]
	public string Name { get; set; }
	[Export]
	protected PackedScene animation;
	[Export]
	public ElementalType Element = ElementManager.Blank;
	[Export]
	public int Priority { get; set; }
	[Export]
	public TargetType Target = TargetType.Enemy;
	[Export(PropertyHint.MultilineText)]
	public string Details { get; set; }

	public virtual Node PlayAnimation(Vector2 start, Vector2 end) 
	{
		Node obj = animation.Instantiate();
		obj.Call("_play", start, end, Element);
		return obj;
	}

	// Main logic for action.
	// Returns message stating what happened to actor. This is displayed for player.
	public virtual string ApplyEffects(BattleActor user, BattleActor[] targets=null) {
		return $"{user.ActorName} used {Name} on {(targets.Length == 1 ? targets[0].ActorName : "opposing team")}";
	}

	/// The most basic damage calculation. Only accounts for attack, defense, and power.
	public static int CalculateDamage(int attack, int defense, Attack action) {
		return action.Power * (attack/defense) * (GD.RandRange(80, 100)/100);
	}
}
