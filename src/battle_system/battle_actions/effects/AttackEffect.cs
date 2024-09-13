using Godot;
using System;

[GlobalClass]
public partial class AttackEffect : Resource {
	[Export]
	public string Name { get; set; } 
	/// Chance this effect will trigger each turn.
	[Export(PropertyHint.Range, "0, 1")]
	public double Chance { get; set; } = 1;
	/// Effectiveness of this effect, usually as a percentage of health.
	[Export]
	public double Strength { get; set; }
	[Export(PropertyHint.MultilineText)]
	public string Message { get; set; }

	public virtual string ApplyEffect(BattleActor user, BattleActor target, BattleAction action) {
		return Message.Replace("{user}", user.ActorName).Replace("{target}", target.ActorName);
	}
}
