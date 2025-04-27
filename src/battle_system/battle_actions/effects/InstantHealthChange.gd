@tool
extends _AttackEffect 
class_name InstantHealthChange 

@export var allow_overflow := false

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0):
	var health := int(target.hp * strength * effectiveness) 
	var verb: String

	if strength < 0:
		target.apply_damage(health, allow_overflow)
		verb = "lost"
	else:
		target.heal(health, allow_overflow)

	return "%s %s %d hp!" % [ target.name, verb, health ]

func get_dmg_potential(user: BattleActor, target: BattleActor, isFriendly: bool, action: _BattleAction) -> int:
	if isFriendly: return 0
	return -int(target.hp * strength) 

# override
## Return what % of hp will be healed.
func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool) -> float:
	var mod := 1 if isFriendly else -1
	if allow_overflow: 
		return mod * strength
	return mod * float(min(target.hp * strength, target.hp - target.current_hp)) / float(target.hp)
