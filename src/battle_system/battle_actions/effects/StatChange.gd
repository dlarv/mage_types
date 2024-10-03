@tool
extends StatusEffect 
class_name StatChange 

var stack: float = 1

# override
func combine(a):
	duration = a.duration
	stack += a.strength / abs(a.strength) #STACK_MODIFIER * (a.strength / abs(a.strength))
	strength += a.strength

func get_mod():
	return stack * strength + 1

func get_full_name():
	var output = name
	if strength < 0:
		output += " Drop"
	else:
		output += " Boost"
	return output
