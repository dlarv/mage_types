using Godot;
using System;

[Tool]
[GlobalClass]
public partial class StatusEffect : AttackEffect {
	[Export]
	public int Duration { get; set; }
	[Export]
	public PackedScene Icon { get; set; } 
	/// The text displayed inside the MessageBox, etc.
	[Export(PropertyHint.MultilineText)]
	public string Description { get; set; }

	public override string ApplyEffect(BattleActor user, BattleActor target, BattleAction action) {
		target.AddStatusEffect((StatusEffect)Duplicate());
		return base.ApplyEffect(user, target, action);
	}
    public override string ApplyEffect(BattleActor actor) {
		actor.AddStatusEffect((StatusEffect)Duplicate());
		return Name;
    }
	
	public bool IsExpired() {
		return Duration == 0;
	}
	public virtual void Combine(StatusEffect a) {
		Duration += a.Duration;
	}
	public virtual Node InstantiateIcon() {
		if(Icon == null) return null;
		return Icon.Instantiate();
	}
}
