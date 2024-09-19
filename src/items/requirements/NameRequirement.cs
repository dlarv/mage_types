using Godot;
using System;

[Tool]
[GlobalClass]
public partial class NameRequirement : ItemRequirement {
	[Export]
	private string requiredName;

    public override bool Check(BaseCompanion companion) {
		return companion.Name == requiredName;
    }

    public override bool Check(Player player) {
		return player.Name == requiredName;
    }

    public override bool Check(BattleActor actor) {
		return actor.ActorName == requiredName;
    }
}
