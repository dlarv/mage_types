using Godot;
using System;

[Tool]
[GlobalClass]
public partial class ElementRequirement : ItemRequirement {
	[Export]
	private ElementalType element;

    public override bool Check(BaseCompanion companion) {
		BattleActor actor = companion.BattleActor;
		return actor != null && (actor.Element1 == element || actor.Element2 == element);

    }

    public override bool Check(Player player) {
		BattleActor actor = player.BattleActor;
		return actor != null && (actor.Element1 == element || actor.Element2 == element);
    }

    public override bool Check(BattleActor actor) {
		return actor.Element1 == element || actor.Element2 == element;
    }
}
