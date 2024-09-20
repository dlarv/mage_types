@tool
extends AttackEffect 
class_name StatusHeal 

@export
var effect: StatusEffect 

# override
func ApplyEffect(user, target=null, action=null):
	target.RemoveStatusEffect(Effect)
	return "%s was healed from %s." % [ target.ActorName, effect.Name ]
