@tool
extends Resource 
class_name ItemRequirement 

@export
var BattleRelevant : bool 

# abstract
func Check(companion) -> bool: return true
