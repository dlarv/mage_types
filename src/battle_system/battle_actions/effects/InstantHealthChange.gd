@tool
extends AttackEffect 
class_name InstantHealthChange 

# override
func apply_effect(user, target=null, action=null, duplicated_effect=null):
	var health = target.hp * strength
	target.apply_damage(-health, false)
	var verb =  "lost"  if strength < 0  else  "recovered"
	return "%s %s %d hp!" % [ user.name, verb, health ]
