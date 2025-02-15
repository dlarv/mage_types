extends EquipmentBonus
class_name StatusEffectBonus

@export var status_effect: StatusEffect

func apply_to(actor: BattleActor) -> String: 
	return status_effect.apply_effect(actor, actor)
