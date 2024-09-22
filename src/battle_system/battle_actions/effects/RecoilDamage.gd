@tool
extends Damage 
class_name RecoilDamage 

# override
func apply_effect(user, target=null, action=null, duplicated_effect=null):
	var dmg = calculate_damage(user.get_attack_stat(action), user.get_defense_stat(action), action)
	dmg = user.apply_damage(dmg)
	return "%s was hurt by recoil (%d damage)." % [ target.name, dmg ]
