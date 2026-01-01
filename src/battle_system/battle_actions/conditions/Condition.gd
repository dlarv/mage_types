@tool
extends Resource
class_name Condition

func check(data: ActorTurnData, target: BattleActor) -> bool: return true

func _to_string() -> String:
	return "Conditional"
