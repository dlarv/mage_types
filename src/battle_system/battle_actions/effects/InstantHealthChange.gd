@tool
extends _AttackEffect 
class_name InstantHealthChange 

@export var allow_overflow := false
@export var strength_is_percent_hp := true
@export var use_effectiveness := true

# override
func apply_effect(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> String:
	var health: float = strength
	if strength_is_percent_hp:
		health *= target.hp
	if use_effectiveness:
		health *= effectiveness

	var verb: String

	if strength < 0:
		target.apply_damage(int(health), allow_overflow)
		verb = "lost"
	else:
		verb = "gained"
		target.heal(int(health), allow_overflow)

	return "%s %s %d hp!" % [ target.name, verb, health ]

func get_dmg_potential(user: BattleActor, target: BattleActor, isFriendly: bool, action: _BattleAction) -> int:
	if isFriendly: return 0
	return -int(target.hp * strength) 

# override
## Return what % of hp will be healed.
func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	var mod := 1 if isFriendly else -1
	if allow_overflow: 
		return mod * strength
	return mod * float(min(target.hp * strength, target.hp - target.current_hp)) / float(target.hp)

func _set_name(val: String) -> void:
	name = "InstantHealthChange"
