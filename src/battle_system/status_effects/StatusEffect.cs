using Godot;
using System;

[GlobalClass]
public partial class StatusEffect : Resource {
	[Export]
	public string Name { get; set; } 
	[Export]
	public int Duration { get; set; }
	/// Chance this effect will trigger each turn.
	[Export(PropertyHint.Range, "0, 1")]
	public double Chance { get; set; }
	/// Effectiveness of this effect, usually as a percentage of health.
	[Export(PropertyHint.Range, "-1, 1")]
	public double Strength { get; set; }

	[Export]
	public PackedScene Icon { get; set; } 
	/// The text displayed when hovering over its icon on the BattleActorDisplay panel.
	[Export]
	public string ToolTip { get; set; }
	/// The text displayed inside the MessageBox, etc.
	[Export(PropertyHint.MultilineText)]
	public string Description { get; set; }
	[Export(PropertyHint.MultilineText)]
	public string Message { get; set; }

	public string ApplyEffect(BattleActor actor) {
		actor.AddStatusEffect((StatusEffect)Duplicate());
		return Message.Replace("{ActorName}", actor.ActorName); 
	}
	public bool IsExpired() {
		return Duration == 0;
	}

    public static StatusEffect operator + (StatusEffect a, StatusEffect b) {
		StatusEffect output = (StatusEffect)b.Duplicate();
		output.Duration = a.Duration + b.Duration;
		return output;
	}
}
