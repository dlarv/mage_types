extends AttackEffect
class_name GenerateAffinity


func apply_effect(user: BattleActor, target: BattleActor=null, action: BattleAction=null, effectiveness:=1.0) -> String:
	var element := user.element1
	var amount := int(strength * effectiveness)
	user.add_affinity(element, amount) 

	return "%s gained %d %s affinity!" % [user.name, amount, element.name]

