@tool
extends _AttackEffect 
class_name Damage 

const ALIGNMENT_BONUS := 0.3

@export var allow_blocking := true

func _init() -> void:
	# Force call of _set_name()
	name = "Damage"


func get_dmg_potential(data: ActorTurnData, target: BattleActor, isFriendly: bool) -> int:
	if target.statuses.blocking: return 0
	return calculate_damage(
		data.user.get_attack_stat(data.action), 
		target.get_defense_stat(data.action), 
		1.0, 
		data
	)


# override
func apply_effect(data: ActorTurnData, target: BattleActor, effectiveness:=1.0) -> ActorTurnData:
	var user := data.user
	var dmg := calculate_damage(
			user.get_attack_stat(data.action), 
			target.get_defense_stat(data.action), 
			effectiveness,
			data
		)
	
	_apply_to(data, target, dmg)
	return data


## The most basic damage calculation. Only accounts for attack, defense, and power.
func calculate_damage(attack: float, defense: float, effectiveness: float, data: ActorTurnData) -> int:
	var user := data.user
	if not user.alignment.is_blank() and data.action.element == user.alignment:
		effectiveness += ALIGNMENT_BONUS

	var power: float = get_strength(data.get_vars())# / 4.0# + (strength * float(user.level) / 10.0)
	var dmg := power * (attack/defense) * effectiveness
	var rand := randf_range(.8, 1)
	MyLogger.append_battle_log("Dmg(%f) = Pwr(%f) * [lb]Att(%f)/Def(%f)[rb] * Affinity(%f) * Rand(%f)" 
			% [dmg, power, attack, defense, effectiveness, rand])
	return int(dmg * rand)


func _apply_to(data: ActorTurnData, target: BattleActor, dmg: int) -> void:
	var actualDmg := target.apply_damage(dmg, allow_blocking, data)
	
	if target.is_defeated:
		data.set_defeated(target)
	
	if actualDmg == dmg:
		MyLogger.append_battle_log("Dealt %d damage to %s." % [dmg, target.name])
		data.add_damage(target, actualDmg)
		return

	var msg := "Tried to deal %d damage to %s." % [dmg, target.name]
	if actualDmg == 0:
		msg += "But %s blocked the attack!" % target.name
	else:
		msg += " But %s deflected some of the damage! Dealt %d damage to %s." \
				% [target.name, actualDmg, target.name]
		data.add_damage(target, actualDmg)
	
	MyLogger.append_battle_log(msg)


func _set_name(_val: String) -> void:
	name = "Damage"
	resource_name = name
