@tool
extends Resource 
class_name ItemRequirement 

@export
var battle_relevant : bool 

# abstract
func check(companion) -> bool: 
	return true

func get_requirement_message():
	return ""
