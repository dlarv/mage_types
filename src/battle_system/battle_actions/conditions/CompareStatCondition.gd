@tool
extends Condition
class_name CompareStatCondition

@export_enum("target", "user") 
var actor_1 := "target"
@export var stat_1: StatManager.Stats

@export_enum("==", "!=", "<", "<=", ">", ">=")
var operator := "=="

@export_enum("target", "user") 
var actor_2 := "target"
@export var stat_2: StatManager.Stats

#override
func check(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> bool:
	var actor1 := user if actor_1 == "user" else target
	var actor2 := user if actor_1 == "user" else target
	return _compare(actor1.get_stat(stat_1), actor2.get_stat(stat_2))

func _compare(stat1: float, stat2: float) -> bool:
	match operator:
		"<": 
			return stat1 < stat2
		"<=": 
			return stat1 <= stat2
		">": 
			return stat1 > stat2
		">=": 
			return stat1 >= stat2
		"!=":
			return stat1 != stat2
		"==",_:
			return stat1 == stat2

