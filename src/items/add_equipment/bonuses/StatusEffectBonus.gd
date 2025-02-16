extends EquipmentBonus
class_name StatusEffectBonus

@export var status_effect: StatusEffect

func apply_to(actor: BattleActor) -> String: 
	Logger.append_log(Logger.LogType.BATTLE, 
			"Bonus = StatusEffect(%s) applied." % status_effect.name)
	return status_effect.apply_effect(actor, actor)
