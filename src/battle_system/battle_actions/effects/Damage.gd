@tool
extends AttackEffect 
class_name Damage 

# override
func ApplyEffect(user, target=null, action=null):
	var dmg = CalculateDamage(user.GetAttackStat(action), target.GetDefenseStat(action), action)
	dmg = target.ApplyDamage(dmg)

	return "Dealt %d damage to %s." % [dmg, target.ActorName]

## The most basic damage calculation. Only accounts for attack, defense, and power.
func CalculateDamage(attack, defense, action):
	var dmg = Strength * (attack/defense)
	var rand = randf_range(80.0, 100.0)/100.0
	return (dmg * rand)
