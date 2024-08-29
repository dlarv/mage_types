using Godot;
using System;

[GlobalClass]
public partial class BattleAction : Resource
{
	public enum TargetType { Self, Ally, Allies, Enemy, Enemies }

	[Export]
	public string Name { get; set; }
	[Export]
	protected PackedScene animation;
	[Export]
	public Element Element;
	[Export]
	public TargetType Target;


	public virtual GodotObject PlayAnimation(Vector2 start, Vector2 end) 
	{
		GodotObject obj = animation.Instantiate();
		obj.Call("_play", start, end, Element);
		return obj;
	}

	// Main logic for action.
	// Returns message stating what happened to actor. This is displayed for player.
	public virtual string ApplyEffects(BattleActor actor) 
	{
		return "";
	}
}
