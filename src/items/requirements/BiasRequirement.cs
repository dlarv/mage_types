using Godot;
using System;

[Tool]
[GlobalClass]
public partial class BiasRequirement : ItemRequirement {
	[Export]
	private ElementalType element;

    public override bool Check(BaseCompanion companion) {
		BattleActor actor = companion.BattleActor;
		return actor != null && actor.ElementalBias == element;
    }

    public override bool Check(Player player) {
		BattleActor actor = player.BattleActor;
		return actor != null && actor.ElementalBias == element;
    }

    public override bool Check(BattleActor actor) {
		return actor != null && actor.ElementalBias == element;
    }
}
