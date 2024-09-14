using Godot;
using System;

[Tool]
[GlobalClass]
public partial class BattleItem : BattleAction {
	public bool IsConsumable { get; set; } = true;
	public int Quantity { get; set; }
	public ItemRequirement Requirement { get; set; } = null;
	[Export]
	public Effect[] Effects { get; set; } = new Effect[0];

	public static BattleItem Create(string name, string details="") {
		BattleItem item = new();
		item.Name = name;
		item.Details = details;
		return item;
	}
    public override string ApplyEffects(BattleActor user, BattleActor[] targets) {
        string msg = base.ApplyEffects(user, targets);

		for(int i = 0; i < targets.Length; i++) {
			var target = targets[i];

			foreach(Effect effect in Effects) {
				double rand = GD.RandRange(0.0, 1.0);

				if(rand <= effect.Chance) {
					msg += $"\n{effect.AttackEffect.ApplyEffect(user, target, this)}";
					// Add status effect icon.
					if(effect.AttackEffect is Damage) {
						// Check if character was defeated.
						if(target.Defeated) {
							msg += $"........{target.ActorName} was defeated.";
							continue;
						}
					}
				}
			}
		}

		return msg;
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
