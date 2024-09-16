using Godot;
using System;

[Tool]
[GlobalClass]
public partial class InstantHealthChange : AttackEffect {
	public override string ApplyEffect(BattleActor user, BattleActor target, BattleAction action) {
		int health = (int)((double)target.Hp * Strength);
		target.ApplyDamage(health, false);
		string verb = Strength < 0 ? "lost" : "recovered";
		return $"{user.ActorName} {verb} {health} hp!";
	}
}
