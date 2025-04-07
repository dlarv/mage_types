@tool
extends StatusEffect 
class_name StatChange 

@export var stat: StatManager.Stat
@export var stack: float = 1

# override
func combine(a: StatusEffect):
	duration = a.duration
	stack += a.strength / abs(a.strength) #STACK_MODIFIER * (a.strength / abs(a.strength))
	strength += a.strength

func get_mod() -> float:
	return stack * strength

func get_setup_potential(user: BattleActor, target: BattleActor) -> float:
	return 1

# override
func _get_message() -> String:
	var output := ""
	var dir := "lowered" if strength < 0 else "boosted"

	match stat:
		StatManager.Stat.ATTACK:
			output = "{target}'s melee attack was %s!\n" % dir
			output += "{target}'s ranged attack was %s!" % dir
		StatManager.Stat.DEFENSE:
			output = "{target}'s melee defense was %s!\n" % dir
			output += "{target}'s ranged defense was %s!" % dir
		StatManager.Stat.MELEE:
			output = "{target}'s melee attack was %s!\n" % dir
			output += "{target}'s melee defense was %s!" % dir
		StatManager.Stat.RANGED:
			output = "{target}'s ranged attack was %s!\n" % dir
			output += "{target}'s ranged defense was %s!" % dir
		_:
			output = "{target}'s %s was %s!" % [ 
				StatManager.Stat.keys()[stat].to_lower().replace("_", " "), 
				dir]
	
	return output
