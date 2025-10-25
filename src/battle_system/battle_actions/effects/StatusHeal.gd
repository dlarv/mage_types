@tool
extends _AttackEffect 
class_name StatusHeal 

@export var effect: StatusEffect:
	set(val):
		effect = val
		_set_name("")

# override
func apply_effect(data: ActorTurnData, target: BattleActor, effectiveness:=1.0) -> ActorTurnData:
	target.remove_status_effect(effect)
	return data


func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	return float(target.has_status_effect(effect))


# override
func _set_name(val: String) -> void:
	name = "%s Heal" % [ effect.name if effect else "Status" ]
	resource_name = name
