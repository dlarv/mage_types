@tool
extends Condition
class_name TransmutationCondition
## Returns true if attack will cause a transmutation.

@export_enum("user", "target", "both", "either")
var apply_to := "target"

#override
func check(data: ActorTurnData, target: BattleActor) -> bool:
	var actionElement: ElementalType = data.action.element
	var targetTrans := false
	var userTrans := false

	if not apply_to == "user":
		var e1 := ElementManager.get_matchup(target.element2, actionElement)
		var e2 := ElementManager.get_matchup(target.element1, e1)
		targetTrans = not target.stasis and (e1 or e2)
	if not apply_to == "target":
		var e1 := ElementManager.get_matchup(data.user.element2, actionElement)
		var e2 := ElementManager.get_matchup(data.user.element1, e1)
		userTrans = not data.user.stasis and (e1 or e2)

	match apply_to:
		"user": return userTrans
		"both": return userTrans and targetTrans
		"either": return userTrans or targetTrans
		"target",_: return targetTrans

func _to_string() -> String:
	var output := "Attack must cause transmutation in "
	match apply_to:
		"user","target":
			output += apply_to.capitalize()
		"both":
			output += "User and Target"
		"either":
			output += "User or Target"
	return output
