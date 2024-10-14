@tool
extends AttackEffect 
class_name StatusHeal 

@export var effect: StatusEffect 

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: BattleAction=null, effectiveness:=1.0):
	target.remove_status_effect(effect)
	return "%s was healed from %s." % [ target.name, effect.name ]
