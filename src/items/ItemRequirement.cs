using Godot;
using System;

[GlobalClass]
public partial class ItemRequirement : Resource {
	[Export]
	public bool BattleRelevant { get; set; }

	public virtual bool Check(BaseCompanion companion) {
		return true;
	}
	public virtual bool Check(Player player) {
		return true;
	}
	public virtual bool Check(BattleActor actor) {
		return true;
	}
}
