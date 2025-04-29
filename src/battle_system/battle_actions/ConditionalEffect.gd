extends _BaseEffectSlot
class_name ConditionalEffect

@export var condition: Condition
@export var success_effect: EffectSlot = null
@export var failed_effect: EffectSlot = null
## When to print FAILURE_MSG to console.
## SILENT: Never
## FAILURE: If condition.check returns false.
## TOTAL_FAILURE: If condition.check returns false and failed_effect.apply_effect returns an empty string.
@export_enum("SILENT", "FAILURE", "TOTAL_FAILURE")
var print_failed_status := "FAILURE"
## Contents of FAILURE_MSG
## FAILED: But it failed!
## MISSED: But it missed!
## INEFFECTIVE: It wasn't very effective...
@export_enum("FAILED", "MISSED", "INEFFECTIVE")
var failure_msg := "FAILED"

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
			msg.insert(0, _get_failure_msg())
		elif print_failed_status == "TOTAL_FAILURE" and (len(msg) == 0 or msg[0].is_empty()):
			msg.insert(0, _get_failure_msg())

		return "\n".join(msg)
	elif print_failed_status != "SILENT":
		return _get_failure_msg()
	return ""

## Used to check the type of the last _AttackEffect.
## e.g. if it was Damage, StatusEffect, etc.
func get_effect_slot(user: BattleActor=null, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0) -> EffectSlot:
	if user == null:
		return success_effect
	elif condition.check(user, target, action, effectiveness):
		return success_effect
	elif failed_effect:
		return failed_effect
	else:
		return null


func get_attack_effect() -> _AttackEffect:
	return success_effect.attack_effect

func _get_failure_msg() -> String:
	match failure_msg:
		"FAILED":
			return "But it failed!\n"
		"MISSED":
			return "But it missed!\n"
		_:
			return "It wasn't very effective...\n"
