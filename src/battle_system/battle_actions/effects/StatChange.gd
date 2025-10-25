@tool
extends StatusEffect 
class_name StatChange 

const MODIFIER := 0.3


## ADD: +=
## MUL *=
## RESET: Set value to 1.0, then ADD
## ZERO: Set value to 0.0, then ADD
enum Operator { ADD, RESET, ZERO, MUL }

@export var stat: StatManager.Stats:
	set(val):
		stat = val
		# var dir := "Drop" if get_strength() < 0 else "Boost"
		# name = "%s %s" % [
		# 	" ".join(Array(StatManager.Stats.keys()[stat].split("_"))
		# 			.map(func(x: String) -> String: 
		# 				return x.capitalize())
		# 		),
		# 	dir
		# ]

## If true, set target's stat to 1 before apply buff/debuff.
@export var op := Operator.ADD

## DO NOT CHANGE IN INSPECTOR!
## ElementManager handles this value, it is only exposed for duplication purposes!
@export var is_side_effect := false

func _init() -> void:
	id = Effects.STAT_CHANGE


func get_strength(vars: Array[Variant]=[]) -> float:
	return super.get_strength(vars) * MODIFIER


func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	# Output should scale inversely with current stat buffs.
	if isFriendly:
		return _get_setup_potential_ally(target)
	return _get_setup_potential_enemy(target)


func _get_setup_potential_ally(target: BattleActor) -> float:
	var mod := target.stat_manager.get_stat_mod(stat) 
	var maxMod := target.stat_manager.MAX_MOD 
	var minMod := target.stat_manager.MIN_MOD 

	if get_strength() > 0:
		if mod <= 0: 
			return 1.0
		return (maxMod - mod) / maxMod
	# If current stat_mod is really low, further debuffing is neglible.
	# Likewise if stat_mod is really high.
	if mod <= minMod * 0.66 or mod >= maxMod * 0.66: 
		return 0.0
	return -1.0


func _get_setup_potential_enemy(target: BattleActor) -> float:
	var mod := target.stat_manager.get_stat_mod(stat) 
	var maxMod := target.stat_manager.MAX_MOD 
	var minMod := target.stat_manager.MIN_MOD 

	if get_strength() < 0:
		if mod >= 0:
			return 1.0
		return (minMod - mod) / minMod

	if mod <= minMod * 0.66 or mod >= maxMod * 0.66:
		return 0.0
	return -1.0


# override
func _get_message() -> String:
	var output := ""
	var dir := "lowered" if get_strength() < 0 else "boosted"

	match stat:
		StatManager.Stats.ATTACK:
			output = "{target}'s melee attack was %s!\n" % dir
			output += "{target}'s ranged attack was %s!" % dir
		StatManager.Stats.DEFENSE:
			output = "{target}'s melee defense was %s!\n" % dir
			output += "{target}'s ranged defense was %s!" % dir
		StatManager.Stats.MELEE:
			output = "{target}'s melee attack was %s!\n" % dir
			output += "{target}'s melee defense was %s!" % dir
		StatManager.Stats.RANGED:
			output = "{target}'s ranged attack was %s!\n" % dir
			output += "{target}'s ranged defense was %s!" % dir
		_:
			output = "{target}'s %s was %s!" % [ 
				StatManager.Stats.keys()[stat].to_lower().replace("_", " "), 
				dir]
	
	return output


# override
func _set_status_effect(val: Effects) -> void:
	id = Effects.STAT_CHANGE
