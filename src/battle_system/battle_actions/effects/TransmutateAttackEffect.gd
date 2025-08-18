@tool
extends _AttackEffect 
class_name TransmutateAttackEffect 

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

@export_range(0, 1) var element_id: int 

#override
func apply_effect(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> String:
	if target.get_element(element_id) == element:
		return "But %s is already %s!" % [ user.name, element ]
	elif target.stasis:
		return "%s is in stasis! Transmutations were blocked!" % target.name
	target.set_element(element_id, element)
	return "\n".join(target.get_and_flush_msgs())


func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	return float(target.stasis != null)


func get_dmg_potential(user: BattleActor, target: BattleActor, isFriendly: bool,  action: _BattleAction) -> int:
	var phobia: PhobiaEffect = target.statuses.check_phobic(element)
	if not phobia: return 0
	return phobia.get_dmg_potential(user, target, isFriendly, action)
