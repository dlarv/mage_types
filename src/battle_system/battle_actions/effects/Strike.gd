extends Damage
class_name Strike

enum StrikeType { STAB, TARGETED }

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType
@export var type: StrikeType
@export var positive_factor: float
@export var negative_factor: float


func apply_effect(user: BattleActor, target: BattleActor=null, action: BattleAction=null, effectiveness:=1.0, e:ElementalType=ElementManager.Blank):
	var dmg = calculate_damage(user.get_attack_stat(action), target.get_defense_stat(action), action, effectiveness)
	var factor: float
	var msg = ""
	var actor: BattleActor
	match type:
		StrikeType.TARGETED: actor = target
		StrikeType.STAB,_: actor = user 
	

	if actor.get_element(0) == element or actor.get_element(1) == element:
		factor = positive_factor
		msg = "It was super effective!\n"
	else:
		factor = negative_factor
		msg = "It wasn't very effective...\n"

	dmg *= factor
	return  msg + _apply_to(target, dmg)
