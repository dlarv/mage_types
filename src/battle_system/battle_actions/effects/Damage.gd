@tool
extends _AttackEffect 
class_name Damage 

func get_dmg_potential(user: BattleActor, action: _BattleAction, target: BattleActor) -> int:
	return calculate_damage(user.get_attack_stat(action), target.get_defense_stat(action), action, 1.0)

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0, element:ElementalType=ElementManager.Blank) -> String:
	var dmg = calculate_damage(user.get_attack_stat(action), target.get_defense_stat(action), action, effectiveness)
	return "%s" % [ _apply_to(target, dmg, user) ]

## The most basic damage calculation. Only accounts for attack, defense, and power.
func calculate_damage(attack: float, defense: float, action: _BattleAction, effectiveness: float) -> int:
	var dmg := strength * (attack/defense) * effectiveness
	var rand := randf_range(.8, 1)
	Logger.append_battle_log("Dmg(%f) = Pwr(%f) * [Att(%f)/Def(%f)] * Affinity(%f) * Rand(%f)" 
			% [dmg, strength, attack, defense, effectiveness, rand])
	return int(dmg * rand)

func _apply_to(target: BattleActor, dmg: int, user: BattleActor=null) -> String:
	var actualDmg = target.apply_damage(dmg)
	if actualDmg == dmg:
		return "Dealt %d damage to %s." % [dmg, target.name]

	var msg := "Tried to deal %d damage to %s.\n" % [dmg, target.name]
	if actualDmg == 0:
		msg += "But %s blocked the attack!" % target.name
	else:
		msg += "But %s deflected some of the damage!\nDealt %d damage to %s." % [target.name, actualDmg, target.name]

	return msg

# func check_resistance(e1: ElementalType, e2: ElementalType) -> float:
# 	return ElementManager.get_resistance(e1, e2)	
