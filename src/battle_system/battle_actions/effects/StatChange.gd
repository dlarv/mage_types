@tool
extends StatusEffect 
class_name StatChange 

const MODIFIER := 0.3

@export var stat: StatManager.Stats:
	set(val):
		stat = val
		var dir := "Drop" if strength < 0 else "Boost"
		name = "%s %s" % [
				" ".join(Array(StatManager.Stats.keys()[stat].split("_")).map(func(x): return x.capitalize())),
				dir]

func _init():
	id = StatusEffectManager.StatusEffects.STAT_CHANGE


func get_strength() -> float:
	return strength * MODIFIER


func get_setup_potential(user: BattleActor, target: BattleActor) -> float:
	return 1


# override
func _get_message() -> String:
	var output := ""
	var dir := "lowered" if strength < 0 else "boosted"

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
func _set_status_effect(val: StatusEffectManager.StatusEffects) -> void:
	id = StatusEffectManager.StatusEffects.STAT_CHANGE
