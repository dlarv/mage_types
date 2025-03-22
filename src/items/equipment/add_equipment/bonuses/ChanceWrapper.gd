@tool
extends EquipmentBonus
class_name ChanceWrapper

@export var bonus: EquipmentBonus
@export var chance: float


func apply_to(actor: BattleActor) -> String: 
	var rand := randf()
	Logger.append_log(Logger.LogType.BATTLE, 
			"Rand(%.2f) <= Chance(%s) == %s" 
			% [rand, chance, str(rand <= chance)])
	if rand <= chance:
		return bonus.apply_to(actor)
	return ""
