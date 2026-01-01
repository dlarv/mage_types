@tool
extends Condition
class_name SingleElementCondition

@export var _element := ElementalType.ElementId.BLANK:
	set(value):
		_element = value
		element = ElementManager.elements[int(value)]
var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 
@export_enum("user", "target", "both", "either")
var apply_to := "target"


#override
func check(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> bool:
	match apply_to:
		"user":
			return user.is_element(element)
		"target":
			return target.is_element(element)
		"either":
			return target.is_element(element) or user.is_element(element)
		_:
			return target.is_element(element) and user.is_element(element)


func _to_string() -> String:
	var output := ""
	if apply_to == "user":
		output = "User "
	elif apply_to != "both":
		output = "Target "
	if apply_to == "both":
		output += "& Target "
	
	output += "must be [color=%s]%s[/color]" % [ element, element ]

	return output
