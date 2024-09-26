@tool
extends AttackEffect 
class_name StatusHeal 

@export
var effect: StatusEffect 

# override
func apply_effect(user, target=null, action=null, duplicated_effect=null):
	target.remove_status_effect(effect)
	return "%s was healed from %s." % [ target.name, effect.name ]
