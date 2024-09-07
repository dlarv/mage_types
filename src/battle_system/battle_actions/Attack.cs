using Godot;
using System;

[GlobalClass]
public partial class Attack : BattleAction 
{
	[Export]
	public int Power;

	public static Attack Create(string name, ElementalType element, int power, int range, string description="") {
		Attack output = new Attack();
		output.Name = name;
		output.Element = element;
		output.Power = power;
		output.Range = (AttackRange)range;
		output.Details = description;
		return output;
	}

    public override string ApplyEffects(BattleActor user, BattleActor[] targets) {
        string msg = base.ApplyEffects(user, targets);
		int attackStat = user.GetAttackStat(this);

		for(int i = 0; i < targets.Length; i++) {
			var target = targets[i];
			int dmg = CalculateDamage(attackStat, target.GetDefenseStat(this), this);
			target.CurrentHp -= dmg;
			GD.Print($"Damage done = {dmg}");
		}

		return msg;
    }
}
