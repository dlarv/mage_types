using Godot;
using System;

[Tool]
[GlobalClass]
public partial class StatRequirement : ItemRequirement {
	[Export]
	private Stats stat;
	[Export]
	private double threshold;

    public override bool Check(BaseCompanion companion) {
		BattleActor actor = companion.BattleActor;
		return actor != null && actor.GetStat(stat) >= threshold;
    }

    public override bool Check(Player player) {
		BattleActor actor = player.BattleActor;
		return actor != null && actor.GetStat(stat) >= threshold;
    }

    public override bool Check(BattleActor actor) {
		return actor.GetStat(stat) >= threshold;
    }
}
