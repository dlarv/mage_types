@tool
extends StatusEffect 
class_name StatChange 

# How each stack increases.
const STACK_MODIFIER: float = 0.3
var Stack: float = STACK_MODIFIER

# override
func Combine(a):
	Duration = a.Duration
	Stack += STACK_MODIFIER * (a.Strength / abs(a.Strength))

func GetMod():
	return Stack * Strength + 1
