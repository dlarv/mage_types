@tool
extends EquipmentBonus
class_name InstantHealthBonus

@export var bonus: InstantHealthChange

func apply_to(actor: BattleActor) -> String: 
	return bonus.apply_effect(actor, actor)
