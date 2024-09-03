using Godot;
using System;

[GlobalClass]
public abstract partial class StatusEffect : Resource 
{
	[Export]
	public PackedScene Icon { get; set; } 
	[Export]
	public string Name { get; set; } 
	/// The text displayed when hovering over its icon on the BattleActorDisplay panel.
	[Export]
	public string ToolTip { get; set; }
	/// The text displayed inside the MessageBox, etc.
	[Export(PropertyHint.MultilineText)]
	public string Description { get; set; }

	public abstract string Apply(BattleActor actor);
}
