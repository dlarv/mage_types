extends Resource
class_name _BaseEffectSlot

enum EffectTarget { USER, TARGET, NOT_USER, USER_ONCE }

@export var effect_target: EffectTarget = EffectTarget.TARGET: set = _set_effect_target
@export_range(0, 1) var chance: float = 1

#virtual
func apply_effect(user: BattleActor, target: BattleActor, action: _BattleAction, effectiveness:=1.0) -> String:
	return ""

func get_attack_effect() -> _AttackEffect:
	return null

func _set_effect_target(val: EffectTarget) -> void:
	effect_target = val
