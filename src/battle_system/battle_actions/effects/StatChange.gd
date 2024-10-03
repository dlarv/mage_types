@tool
extends StatusEffect 
class_name StatChange 

@export
var stat: StatManager.Stat
@export
var stack: float = 1

# override
func combine(a):
	duration = a.duration
	stack += a.strength / abs(a.strength) #STACK_MODIFIER * (a.strength / abs(a.strength))
	strength += a.strength

func get_mod():
	return stack * strength

