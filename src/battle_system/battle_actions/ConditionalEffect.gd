extends BaseEffect
class_name ConditionalEffect

@export var condition: Condition
@export var success_effect: Effect = null
@export var failed_effect: Effect = null

var _last_activated_effect: Effect = null

# override
func apply_effect(user: BattleActor, target: BattleActor, action: BattleAction, effectiveness:=1.0) -> String:
	if condition.check(user, target, action, effectiveness):
		_last_activated_effect = success_effect
		return success_effect.apply_effect(user, target, action, effectiveness)
	elif failed_effect != null:
		_last_activated_effect = failed_effect
		var msg := "But it failed!\n"
		return msg + failed_effect.apply_effect(user, target, action, effectiveness)
	return ""

func get_attack_effect() -> AttackEffect:
	return _last_activated_effect.attack_effect

