@tool
extends AttackEffect 
class_name Damage 

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: BattleAction=null, effectiveness:=1.0):
	var dmg = calculate_damage(user.get_attack_stat(action), target.get_defense_stat(action), action, effectiveness)
	dmg = target.apply_damage(dmg)

	return "Dealt %d damage to %s." % [dmg, target.name]

## The most basic damage calculation. Only accounts for attack, defense, and power.
func calculate_damage(attack: float, defense: float, action: BattleAction, effectiveness: float) -> int:
	var dmg := strength * (attack/defense) * effectiveness
	var rand := randf_range(.8, 1)
	Logger.append_log(Logger.LogType.BATTLE, "Dmg(%f) = Pwr(%f) * [Att(%f)/Def(%f)] * Affinity(%f) * Rand(%f)" 
			% [dmg, strength, attack, defense, effectiveness, rand])
	return int(dmg * rand)
