@tool
extends _AttackEffect 
class_name Damage 

const ALIGNMENT_BONUS := 0.3

func _init() -> void:
	# Force call of _set_name()
	name = "Damage"


func get_dmg_potential(user: BattleActor, target: BattleActor, isFriendly: bool,  action: _BattleAction) -> int:
	if target.statuses.blocking: return 0
	return calculate_damage(user.get_attack_stat(action), target.get_defense_stat(action), 1.0, user)


# override
func apply_effect(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> String:
	var dmg := calculate_damage(
			user.get_attack_stat(current_buffer.action), 
			target.get_defense_stat(current_buffer.action), 
			effectiveness,
			user
		)
	
	return _apply_to(target, dmg, user)


## The most basic damage calculation. Only accounts for attack, defense, and power.
func calculate_damage(attack: float, defense: float, effectiveness: float, user: BattleActor) -> int:
	if not user.alignment.is_blank() and current_buffer.action.element == user.alignment:
		effectiveness += ALIGNMENT_BONUS

	var power: float = strength / 4.0# + (strength * float(user.level) / 10.0)
	var dmg := power * (attack/defense) * effectiveness
	var rand := randf_range(.8, 1)
	Logger.append_battle_log("Dmg(%f) = Pwr(%f) * [Att(%f)/Def(%f)] * Affinity(%f) * Rand(%f)" 
			% [dmg, power, attack, defense, effectiveness, rand])
	return int(dmg * rand)


func _apply_to(target: BattleActor, dmg: int, user: BattleActor=null) -> String:
	var actualDmg := target.apply_damage(dmg)
	_AttackEffect.current_buffer.damage = actualDmg
	_AttackEffect.current_buffer.total_damage += actualDmg

	if actualDmg == dmg:
		return "Dealt %d damage to %s." % [dmg, target.name]

	var msg := "Tried to deal %d damage to %s.\n" % [dmg, target.name]
	if actualDmg == 0:
		msg += "But %s blocked the attack!" % target.name
	else:
		msg += "But %s deflected some of the damage!\nDealt %d damage to %s." \
				% [target.name, actualDmg, target.name]
	
	return msg


func _set_name(_val: String) -> void:
	name = "Damage"
	resource_name = name
