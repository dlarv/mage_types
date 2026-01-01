@tool
extends Condition
class_name StatusEffectCondition

@export_enum("user", "target", "both", "either")
var apply_to := "target"

@export var effect: StatusEffect

#override
func check(data: ActorTurnData, target: BattleActor) -> bool:
	match apply_to:
		"user":
			return data.user.has_status_effect(effect)
		"target":
			return target.has_status_effect(effect)
		"both":
			return data.user.has_status_effect(effect) \
					and target.has_status_effect(effect)
		"either",_:
			return data.user.has_status_effect(effect) \
					or target.has_status_effect(effect)
