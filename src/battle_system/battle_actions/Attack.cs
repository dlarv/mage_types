using Godot;
using System;

[GlobalClass]
public partial class Attack : BattleAction 
{
	[Export]
	public int Power;
	[Export]
	public AttackEffect[] effects = new AttackEffect[0];

	public static Attack Create(string name, ElementalType element, int power, int range, string description="") {
		Attack output = new Attack();
		output.Name = name;
		output.Element = element;
		output.Power = power;
		output.Range = (AttackRange)range;
		output.Details = description;
		return output;
	}

    public override string ApplyEffects(BattleActor user, BattleActor[] targets, TeamDisplay display) {
        string msg = base.ApplyEffects(user, targets, display);
		int attackStat = user.GetAttackStat(this);

		for(int i = 0; i < targets.Length; i++) {
			var target = targets[i];

			// Apply damage.
			int dmg = CalculateDamage(attackStat, target.GetDefenseStat(this), this);
			dmg = target.ApplyDamage(dmg);
			msg += $"\nDealt {dmg} damage to {target.ActorName}.";

			// Check if character was defeated.
			if(target.Defeated) {
				msg += $"........{target.ActorName} was defeated.";
				display.GetDisplay(target).SetHealth(target.CurrentHp);
				continue;
			}

			foreach(AttackEffect effect in effects) {
				var rand = GD.RandRange(0, 1);
				if(rand <= effect.Chance) {
					msg += $"\n{effect.Effect.ApplyEffect(target)}";
					// Add status effect icon.
					display.GetDisplay(target).AddStatusCondition(effect.Effect);
				}
			}

			// Update hp bar.
			display.GetDisplay(target).SetHealth(target.CurrentHp);
		}

		return msg;
    }
}
