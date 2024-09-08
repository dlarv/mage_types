using Godot;
using System;

[GlobalClass]
public partial class StatusEffect : AttackEffect {
	[Export]
	public int Duration { get; set; }
	[Export]
	public PackedScene Icon { get; set; } 
	/// The text displayed inside the MessageBox, etc.
	[Export(PropertyHint.MultilineText)]
	public string Description { get; set; }
	[Export(PropertyHint.MultilineText)]
	public string Message { get; set; }

	public override string ApplyEffect(BattleActor user, BattleActor target, BattleAction action) {
		target.AddStatusEffect((StatusEffect)Duplicate());
		return Message.Replace("{ActorName}", target.ActorName); 
	}
	public bool IsExpired() {
		return Duration == 0;
	}
	public virtual void Combine(StatusEffect a) {
		Duration += a.Duration;
	}
}
