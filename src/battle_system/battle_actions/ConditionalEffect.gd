extends _BaseEffectSlot
class_name ConditionalEffect

@export var condition: Condition
@export var success_effect: EffectSlot = null
@export var failed_effect: EffectSlot = null
## When to print "But it failed." to console.
## SILENT: Never
## FAILURE: If condition.check returns false.
## TOTAL_FAILURE: If condition.check returns false and failed_effect.apply_effect returns an empty string.
@export_enum("SILENT", "FAILURE", "TOTAL_FAILURE")
var print_failed_status := "FAILURE"

var _last_activated_effect: _BaseEffectSlot = null

# override
func apply_effect(user: BattleActor, target: BattleActor, action: _BattleAction, effectiveness:=1.0) -> String:
	if condition.check(user, target, action, effectiveness):
		_last_activated_effect = success_effect
		return success_effect.apply_effect(user, target, action, effectiveness)
	elif failed_effect != null:
		_last_activated_effect = failed_effect

		var msg := []

		msg.append(failed_effect.apply_effect(user, target, action, effectiveness))

		if print_failed_status == "FAILURE":
			msg.insert(0, "But it failed!\n")
		elif print_failed_status == "TOTAL_FAILURE" and (len(msg) == 0 or msg[0].is_empty()):
			msg.insert(0, "But it failed!\n")

		return "\n".join(msg)
	elif print_failed_status != "SILENT":
		return "But it failed!\n"
	return ""

## Used to check the type of the last _AttackEffect.
## e.g. if it was Damage, StatusEffect, etc.
func get_attack_effect() -> _AttackEffect:
	return _last_activated_effect.attack_effect
