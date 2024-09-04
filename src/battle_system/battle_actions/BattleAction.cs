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

	public virtual GodotObject PlayAnimation(Vector2 start, Vector2 end) 
	{
		GodotObject obj = animation.Instantiate();
		obj.Call("_play", start, end, Element);
		return obj;
	}

	// Main logic for action.
	// Returns message stating what happened to actor. This is displayed for player.
	public virtual string ApplyEffects(BattleActor actor, BattleActor other=null) 
	{
		return "";
	}
}
