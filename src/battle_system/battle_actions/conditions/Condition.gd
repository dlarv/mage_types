@tool
extends Resource
class_name Condition

func check(user: BattleActor, target: BattleActor, action: _BattleAction, effectiveness:=1.0) -> bool:
	return true

func _to_string() -> String:
	return "Conditional"
