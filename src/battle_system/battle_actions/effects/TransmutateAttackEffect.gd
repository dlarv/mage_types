@tool
extends _AttackEffect 
class_name TransmutateAttackEffect 

@export var _element := ElementalType.ElementId.BLANK:
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.elements[int(value)]
var element: ElementalType:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 

@export_range(0, 1) var element_id: int 

#override
func apply_effect(data: ActorTurnData, target: BattleActor, effectiveness:=1.0) -> ActorTurnData:
	var user := data.user
	if target.get_element(element_id) == element:
		Logger.append_battle_log("But %s is already %s!" % [ user.name, element ])
	elif target.stasis:
		Logger.append_battle_log("%s is in stasis! Transmutations were blocked!" % target.name)
	else:
		var dmg := target.set_element(element_id, element)
		data.element = element
		data.total_dmg += int(dmg)
		data.phobia_dmg += int(dmg)
		Logger.append_battle_log("%s is in stasis! Transmutations were blocked!" % target.name)
	return data


func get_setup_potential(data: ActorTurnData, target: BattleActor, isFriendly: bool) -> float:
	return float(target.stasis != null)


func get_dmg_potential(data: ActorTurnData, target: BattleActor, isFriendly: bool) -> int:
	var phobia: PhobiaEffect = target.statuses.check_phobic(element)
	if not phobia: return 0
	return phobia.get_dmg_potential(data, target, isFriendly)
