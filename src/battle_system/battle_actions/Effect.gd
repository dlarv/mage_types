@tool
extends Resource 
class_name Effect 

enum EffectTarget { USER, TARGET }

@export
var attack_effect: AttackEffect 
@export_range(0, 1)
var chance: float = 1
@export
var effect_target: EffectTarget = EffectTarget.TARGET

func apply_effect(user: BattleActor, target: BattleActor, action: BattleAction) -> String:
	var rand = randf_range(0.0, 1.0)

	if rand <= chance:
		if effect_target == EffectTarget.TARGET:
			return attack_effect.apply_effect(user, target, action)
		return attack_effect.apply_effect(user, user, action)

	return ""
