@tool
extends Resource 
class_name ItemRequirement 

@export var battle_relevant: bool 

# abstract
func check(companion: Variant) -> bool: return true

# abstract
func get_requirement_message() -> String: return ""

## obj: Player | BaseCompanion | BattleActor
func _get_battle_actor(obj: Variant) -> BattleActor:
	if obj is BattleActor: 
		return obj
	elif obj.is_in_group("player"): 
		return obj.battle_actor
	return null
