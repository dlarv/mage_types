using Godot;
using System;

[GlobalClass]
public partial class BattleAction : Resource
{
	public static BattleAction Flee { get; private set; } = new();

	public enum TargetType { Self, Ally, Allies, Enemy, Enemies }
	public enum AttackRange { Melee, Ranged }

	[Export]
	public string Name { get; set; }
	[Export]
	protected PackedScene animation;
	[Export]
	public ElementalType Element = ElementManager.Blank;
	[Export]
	public int Priority { get; set; }
	[Export]
	public AttackRange Range;
	[Export]
	public TargetType Target = TargetType.Enemy;
	[Export(PropertyHint.MultilineText)]
	public string Details { get; set; }

	public virtual Node PlayAnimation(Vector2 start, Vector2 end) {
		Node obj = animation.Instantiate();
		obj.Call("_play", start, end, Element);
		return obj;
	}

	// Main logic for action.
	// Returns message stating what happened to the targets. This is displayed for player.
	public virtual string ApplyEffects(BattleActor user, BattleActor[] targets, TeamDisplay display) {
		string end = "";
		if(targets.Length == 1) {
			if(user == targets[0]) {
				end = "itself";
			} else {
				end = $"{targets[0].ActorName}";
			}
		} else {
			end = "the opposing team";
		}

		return $"{user.ActorName} used {Name} on {end}.";
	}

	/// The most basic damage calculation. Only accounts for attack, defense, and power.
	public static int CalculateDamage(int attack, int defense, Attack action) {
		return (int)((double)action.Power * ((double)attack/(double)defense) * (GD.RandRange(80.0, 100.0)/100.0));
	}
}
