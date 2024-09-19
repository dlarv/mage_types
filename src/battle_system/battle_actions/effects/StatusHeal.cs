using Godot;
using System;

[Tool]
[GlobalClass]
public partial class StatusHeal : AttackEffect {
	[Export]
	public StatusEffect Effect;

    public override string ApplyEffect(BattleActor user, BattleActor target, BattleAction action) {
		target.RemoveStatusEffect(Effect);
		return $"{target.ActorName} was healed from {Effect.Name}.";
	}
}
