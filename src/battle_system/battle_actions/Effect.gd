@tool
extends Resource 
class_name Effect 

enum EffectTarget { USER, TARGET }

@export var attack_effect: AttackEffect 
@export_range(0, 1) var chance: float = 1
@export var effect_target: EffectTarget = EffectTarget.TARGET
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

func apply_effect(user: BattleActor, target: BattleActor, action: BattleAction, effectiveness:=1.0) -> String:
	var rand = randf()
	if rand <= chance:
		if effect_target == EffectTarget.TARGET:
			return attack_effect.apply_effect(user, target, action, effectiveness, element)
		return attack_effect.apply_effect(user, user, action, effectiveness, element)
	
	else:
		Logger.append_log(Logger.LogType.BATTLE, "Action(%s) failed. Chance(%f) >= Rand(%f)" % [attack_effect.name, chance, rand])

	return "" 
