using Godot;
using System;

[Tool]
[GlobalClass]
public partial class Damage : AttackEffect {
	
    public override string ApplyEffect(BattleActor user, BattleActor target, BattleAction action) {
		int dmg = CalculateDamage(user.GetAttackStat(action), target.GetDefenseStat(action), (Attack)action);
		dmg = target.ApplyDamage(dmg);

		return $"Dealt {dmg} damage to {target.ActorName}.";
    }

	/// The most basic damage calculation. Only accounts for attack, defense, and power.
	public int CalculateDamage(int attack, int defense, Attack action) {
		double dmg = (double)Strength * ((double)attack/(double)defense);
		double rand = GD.RandRange(80.0, 100.0)/100.0;
		return (int)(dmg * rand);
	}


}
