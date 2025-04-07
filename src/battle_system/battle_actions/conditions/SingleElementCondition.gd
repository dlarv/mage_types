extends Condition
class_name SingleElementCondition

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blue":
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 
@export_enum("user", "target", "both", "either")
var apply_to := "target"


#override
func check(user: BattleActor, target: BattleActor, action: _BattleAction, effectiveness:=1.0) -> bool:
	match apply_to:
		"user":
			return user.is_element(element)
		"target":
			return target.is_element(element)
		"either":
			return target.is_element(element) or user.is_element(element)
		_:
			return target.is_element(element) and user.is_element(element)


