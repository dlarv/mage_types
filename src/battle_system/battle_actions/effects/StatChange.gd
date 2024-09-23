@tool
extends StatusEffect 
class_name StatChange 

# How each stack increases.
const STACK_MODIFIER: float = 0.3
var stack: float = 1

# override
func combine(a):
	duration = a.duration
	stack += a.strength / abs(a.strength) #STACK_MODIFIER * (a.strength / abs(a.strength))

func get_mod():
	return stack * strength + 1

