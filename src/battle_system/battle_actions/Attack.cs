using Godot;
using System;

[GlobalClass]
public partial class Attack : BattleAction 
{
	[Export]
	public Effect[] effects = new Effect[0];

	public static Attack Create(string name, ElementalType element, int power, int range, string description="") {
		Attack output = new Attack();
		output.Name = name;
		output.Element = element;
		output.Range = (AttackRange)range;
		output.Details = description;
		return output;
	}

    public override string ApplyEffects(BattleActor user, BattleActor[] targets) {
        string msg = base.ApplyEffects(user, targets);
		int attackStat = user.GetAttackStat(this);

		for(int i = 0; i < targets.Length; i++) {
			var target = targets[i];

			foreach(Effect effect in effects) {
				double rand = GD.RandRange(0.0, 1.0);

				if(rand <= effect.Chance) {
					msg += $"\n{effect.AttackEffect.ApplyEffect(user, target, this)}";
					// Add status effect icon.
					if(effect.AttackEffect is Damage) {
						// Check if character was defeated.
						if(target.Defeated) {
							msg += $"........{target.ActorName} was defeated.";
							continue;
						}
					}
				}
			}
		}

		return msg;
    }
}
