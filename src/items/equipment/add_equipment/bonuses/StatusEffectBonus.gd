@tool
extends EquipmentBonus
class_name StatusEffectBonus

@export var status_effect: StatusEffect

func apply_to(actor: BattleActor) -> ActorTurnData: 
	Logger.append_battle_log("Bonus = StatusEffect(%s) applied." % status_effect.name)
	return status_effect.apply_effect(ActorTurnData.empty(actor), actor)
