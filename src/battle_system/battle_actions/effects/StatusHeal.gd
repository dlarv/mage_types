@tool
extends _AttackEffect 
class_name StatusHeal 

@export var effect: StatusEffect 

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0):
	target.remove_status_effect(effect)
	return "%s was healed from %s." % [ target.name, effect.name ]

func get_setup_potential(user: BattleActor, target: BattleActor) -> float:
	return int(target.has_status_effect(effect))
