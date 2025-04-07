extends Condition
class_name AffinityCondition

@export_enum("defensive", "offensive") 
var affinity_category := "defensive"
@export_enum("user", "target", "both")
var apply_to := "user"

#override
func check(user: BattleActor, target: BattleActor, action: _BattleAction, effectiveness:=1.0) -> bool:
	match apply_to:
		"user": return _check_actor(user)
		"target": return _check_actor(target)
		_: return _check_actor(user) and _check_actor(target)

func _check_actor(user: BattleActor) -> bool:
	return user.element1.is_defensive_type == (affinity_category == "defensive") \
				or user.element2.is_defensive_type == (affinity_category == "defensive")

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
