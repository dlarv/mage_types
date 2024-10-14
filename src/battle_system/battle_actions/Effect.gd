@tool
extends Resource 
class_name Effect 

enum EffectTarget { USER, TARGET }

@export var attack_effect: AttackEffect 
@export_range(0, 1) var chance: float = 1
@export var effect_target: EffectTarget = EffectTarget.TARGET

func apply_effect(user: BattleActor, target: BattleActor, action: BattleAction, effectiveness:=1.0) -> String:
	var rand = randf_range(0.0, 1.0)
	if rand <= chance:
		if effect_target == EffectTarget.TARGET:
			return attack_effect.apply_effect(user, target, action, effectiveness)
		return attack_effect.apply_effect(user, user, action, effectiveness)
	
	else:
		Logger.append_log(Logger.LogType.BATTLE, "Action(%s) failed. Chance(%f) >= Rand(%f)" % [attack_effect.name, chance, rand])

	return "" 
