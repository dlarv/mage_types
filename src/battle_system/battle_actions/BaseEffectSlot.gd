extends Resource
class_name BaseEffectSlot

enum EffectTarget { USER, TARGET }

@export var effect_target: EffectTarget = EffectTarget.TARGET
@export_range(0, 1) var chance: float = 1
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 

#virtual
func apply_effect(user: BattleActor, target: BattleActor, action: BattleAction, effectiveness:=1.0) -> String:
	return ""

func get_attack_effect() -> AttackEffect:
	return null
