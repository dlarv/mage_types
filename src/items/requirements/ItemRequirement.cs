using Godot;
using System;

[Tool]
[GlobalClass]
public abstract partial class ItemRequirement : Resource {
	[Export]
	public bool BattleRelevant { get; set; }

	public abstract bool Check(BaseCompanion companion);
	public abstract bool Check(Player player);
	public abstract bool Check(BattleActor actor);
}
