@tool
extends Condition
class_name AffinityCondition
## 

@export_enum("defensive", "offensive") 
var affinity_category := "defensive"
@export_enum("user", "target", "both")
var apply_to := "user"
@export_enum("primary", "secondary", "both", "either",  "xor")
var slot := "secondary"

#override
func check(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> bool:
	match apply_to:
		"user": return _check_actor(user)
		"target": return _check_actor(target)
		_: return _check_actor(user) and _check_actor(target)


func _check_actor(user: BattleActor) -> bool:
	var affinityCat := affinity_category == "defensive"
	var a1 := user.element1.is_defensive_type == affinityCat
	var a2 := user.element2.is_defensive_type == affinityCat
	match slot:
		"primary": return a1
		"secondary": return a2
		"both": return a1 and a2
		"xor": return (a1 or a2) and not (a1 and a2)
		"either",_: return a1 or a2



func _to_string() -> String:
	var output := ""
	if apply_to == "user":
		output = "User "
	elif apply_to != "both":
		output = "Target "
	if apply_to == "both":
		output += "& Target "

	output += "must be %s types." % affinity_category
	return output
