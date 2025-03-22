@tool
extends EquipmentBonus
class_name StatBonus

@export var stat: StatChange

func apply_to(actor: BattleActor) -> String: 
	return stat.apply_effect(actor, actor)
