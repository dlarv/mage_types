@tool
extends _BaseEffectSlot
class_name EffectSlot

@export var attack_effect: _AttackEffect:
	set(val):
		attack_effect = val
		if attack_effect is Damage and effect_target == EffectTarget.USER:
			resource_name = "Recoil %s" % val.resource_name
		else:
			resource_name = val.resource_name


# override
func apply_effect(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> String:
	var msg := ""
	var rand := randf()
	if rand <= chance:
		if chance != 1.0:
			Logger.append_battle_log("Action(%s) Succeeded. Chance(%f) >= Rand(%f)" 
					% [attack_effect.name, chance, rand])
		if effect_target == EffectTarget.TARGET or effect_target == EffectTarget.NOT_USER:
			return attack_effect.apply_effect(user, target, effectiveness)
		return attack_effect.apply_effect(user, user, effectiveness)

	Logger.append_battle_log("Action(%s) failed. Chance(%f) >= Rand(%f)" 
			% [attack_effect.name, chance, rand])

	return msg


# override
func get_effect_slot(user: BattleActor=null, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0) -> EffectSlot:
	return self

func get_attack_effect(user: BattleActor=null, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0) -> _AttackEffect: 
	return attack_effect

# override
func _set_effect_target(val: EffectTarget) -> void:
	super._set_effect_target(val)
	if attack_effect is Damage and effect_target == EffectTarget.USER:
		resource_name = "Recoil %s" % attack_effect.resource_name
	else:
		resource_name = attack_effect.resource_name
