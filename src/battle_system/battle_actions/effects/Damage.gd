@tool
extends _AttackEffect 
class_name Damage 

func _init():
	# Force call of _set_name()
	name = "Damage"


func get_dmg_potential(user: BattleActor, target: BattleActor, isFriendly: bool,  action: _BattleAction) -> int:
	if target.statuses.blocking: return 0
	return calculate_damage(user.get_attack_stat(action), target.get_defense_stat(action), user.level, 1.0)


# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0) -> String:
	var dmg = calculate_damage(user.get_attack_stat(action), target.get_defense_stat(action), user.level, effectiveness)
	return "%s" % [ _apply_to(target, dmg, user) ]


## The most basic damage calculation. Only accounts for attack, defense, and power.
func calculate_damage(attack: float, defense: float, level: int, effectiveness: float) -> int:
	var dmg := strength * (attack/defense) * effectiveness * level
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


func _set_name(_val: String) -> void:
	name = "Damage"
	resource_name = name
