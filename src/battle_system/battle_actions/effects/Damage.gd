@tool
extends AttackEffect 
class_name Damage 

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: BattleAction=null):
	var dmg = calculate_damage(user.get_attack_stat(action), target.get_defense_stat(action), action)
	dmg = target.apply_damage(dmg)

	return "Dealt %d damage to %s." % [dmg, target.name]

## The most basic damage calculation. Only accounts for attack, defense, and power.
func calculate_damage(attack: float, defense: float, action: BattleAction):
	var dmg = strength * (attack/defense)
	var rand = randf_range(80.0, 100.0)/100.0
	return (dmg * rand)
