extends BaseEffectSlot
class_name ConditionalEffect

@export var condition: Condition
@export var success_effect: BaseEffectSlot = null
@export var failed_effect: BaseEffectSlot = null
## If true, if this effect fails, "But it failed" will be printed to player's console.
## Otherwise, this will only be printed if failed effect is null or returns no output.
@export var print_failed_status := false

var _last_activated_effect: BaseEffectSlot = null

# override
func apply_effect(user: BattleActor, target: BattleActor, action: BattleAction, effectiveness:=1.0) -> String:
	if condition.check(user, target, action, effectiveness):
		_last_activated_effect = success_effect
		return success_effect.apply_effect(user, target, action, effectiveness)
	elif failed_effect != null:
		_last_activated_effect = failed_effect
		var msg := ""
		if print_failed_status:
			msg = "But it failed!\n"
		msg += failed_effect.apply_effect(user, target, action, effectiveness)
		if len(msg) == 0:
			msg = "But it failed!\n"
		return msg
	else:
		return "But it failed!\n"

func get_attack_effect() -> AttackEffect:
	return _last_activated_effect.attack_effect

