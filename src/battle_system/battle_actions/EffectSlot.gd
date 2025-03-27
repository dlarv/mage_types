@tool
extends _BaseEffectSlot
class_name EffectSlot

@export var attack_effect: _AttackEffect 

# override
func apply_effect(user: BattleActor, target: BattleActor, action: _BattleAction, effectiveness:=1.0) -> String:
	var rand = randf()
	if rand <= chance:
		if chance != 1.0:
			Logger.append_battle_log("Action(%s) Succeeded. Chance(%f) >= Rand(%f)" 
					% [attack_effect.name, chance, rand])
		if effect_target == EffectTarget.TARGET:
			return attack_effect.apply_effect(user, target, action, effectiveness, element)
		return attack_effect.apply_effect(user, user, action, effectiveness, element)
	
	else:
		Logger.append_battle_log("Action(%s) failed. Chance(%f) >= Rand(%f)" 
				% [attack_effect.name, chance, rand])

	return "" 

func get_attack_effect() -> _AttackEffect:
	return attack_effect 
