@tool
extends EquipmentBonus
class_name ChanceWrapper

@export var bonus: EquipmentBonus
@export var chance: float


func apply_to(actor: BattleActor) -> ActorTurnData: 
	var rand := randf()
	var output := ActorTurnData.empty(actor)
	Logger.append_battle_log("Rand(%.2f) <= Chance(%s) == %s" 
			% [rand, chance, str(rand <= chance)])
	if rand <= chance:
		return bonus.apply_to(actor)
	else:
		output.missed = true
	return output
