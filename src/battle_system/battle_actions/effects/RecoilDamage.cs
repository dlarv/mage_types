using Godot;
using System;

[Tool]
[GlobalClass]
public partial class RecoilDamage : Damage {
    public override string ApplyEffect(BattleActor user, BattleActor target, BattleAction action) {
		int dmg = CalculateDamage(user.GetAttackStat(action), user.GetDefenseStat(action), (Attack)action);
		dmg = user.ApplyDamage(dmg);

		return $"{target.ActorName} was hurt by recoil ({dmg} damage).";
    }
}
