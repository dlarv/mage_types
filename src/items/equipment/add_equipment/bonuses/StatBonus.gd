@tool
extends EquipmentBonus
class_name StatBonus

@export var stat: StatChange

func apply_to(actor: BattleActor) -> ActorTurnData:
	return stat.apply_effect(ActorTurnData.empty(actor), actor)
