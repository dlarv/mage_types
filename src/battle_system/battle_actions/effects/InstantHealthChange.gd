@tool
extends _AttackEffect 
class_name InstantHealthChange 

@export var allow_overflow := false
@export var strength_is_percent_hp := true
@export var use_effectiveness := true

# override
func apply_effect(data: ActorTurnData, target: BattleActor, effectiveness:=1.0) -> ActorTurnData:
	var strength := get_strength(data.get_vars()) 

	var health := strength
	if strength_is_percent_hp:
		health *= target.hp
	if use_effectiveness:
		health *= effectiveness

	var actual: int
	if strength < 0:
		actual = target.apply_damage(int(health), allow_overflow)
		if target == data.user:
			data.recoil_dmg += actual
	else:
		actual = -target.heal(int(health), allow_overflow)
	data.total_dmg += actual
	data.last_dmg = actual

	return data

func get_dmg_potential(data: ActorTurnData, target: BattleActor, isFriendly: bool) -> int:
	if isFriendly: return 0
	return -int(target.hp * get_strength()) 

# override
## Return what % of hp will be healed.
func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	var mod := 1 if isFriendly else -1
	if allow_overflow: 
		return mod * get_strength()
	return mod * float(min(target.hp * get_strength(), target.hp - target.current_hp)) / float(target.hp)

func _set_name(val: String) -> void:
	name = "InstantHealthChange"
