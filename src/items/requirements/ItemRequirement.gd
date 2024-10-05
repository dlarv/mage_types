@tool
extends Resource 
class_name ItemRequirement 

@export var battle_relevant: bool 

# abstract
func check(companion: Variant) -> bool: return true

# abstract
func get_requirement_message() -> String: return ""
