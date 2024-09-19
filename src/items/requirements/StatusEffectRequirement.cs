using Godot;
using System;

[Tool]
[GlobalClass]
public partial class StatusEffectRequirement : ItemRequirement {
	[Export]
	private StatusEffect effect;

    public override bool Check(BaseCompanion companion) {
		BattleActor actor = companion.BattleActor;
		return actor != null && actor.HasStatusEffect(effect);
    }

    public override bool Check(Player player) {
		BattleActor actor = player.BattleActor;
		return actor != null && actor.HasStatusEffect(effect);
    }

    public override bool Check(BattleActor actor) {
		return actor != null && actor.HasStatusEffect(effect);
    }
}
