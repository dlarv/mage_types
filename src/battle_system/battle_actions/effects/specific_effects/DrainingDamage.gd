@tool
extends Damage
class_name DrainingDamage

@export var heal_percent := 0.5
@export var allow_overflow := false

func _apply_to(target: BattleActor, dmg: int, user: BattleActor=null) -> String:
	var actualDmg := target.apply_damage(dmg)
	var msg := "Tried to deal %d damage to %s.\n" % [ dmg, target.name ]

	if actualDmg == dmg:
		msg = "Dealt %d damage to %s." % [ dmg, target.name ]

	elif actualDmg == 0:
		msg += "But %s blocked the attack!" % target.name
		return msg
	else:
		msg += "But %s deflected some of the damage!\nDealt %d damage to %s." % [ target.name, actualDmg, target.name ]
	
	actualDmg = int(float(actualDmg) * heal_percent)
	if actualDmg > 0:
		user.heal(actualDmg, allow_overflow)
		msg += "\n%s drained %d hp from the target!" % [ user.name, actualDmg ]
	return msg


func _set_name(_val: String) -> void:
	name = "Draining Damage"
	resource_name = name


func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	var amount := dmg * heal_percent / float(user.hp)
	if isFriendly: 
		return -amount
	elif allow_overflow: 
		return amount
	else: 
		return min(amount, target.hp - target.current_hp)
