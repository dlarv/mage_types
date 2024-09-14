using Godot;
using System;

[Tool]
[GlobalClass]
public partial class BattleItem : BattleAction {
	public bool IsConsumable { get; set; } = true;
	public int Quantity { get; set; }
	public ItemRequirement Requirement { get; set; } = null;
	[Export]
	public AttackEffect Effect { get; set; }

	public static BattleItem Create(string name, string details="") {
		BattleItem item = new();
		item.Name = name;
		item.Details = details;
		return item;
	}

    public override bool IsActionAvailable(BattleActor actor) {
		if(IsConsumable && Quantity == 0) return false;
		if(Requirement == null) return true;

		return Requirement.Check(actor);
    }
    public override void ApplyCost(BattleActor user) {
		if(IsConsumable) {
			Quantity -= 1;
		}
    }
}
