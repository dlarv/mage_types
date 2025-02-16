extends EquipmentBonus
class_name ChanceWrapper

@export var bonus: EquipmentBonus
@export var chance: float


func apply_to(actor: BattleActor) -> String: 
	var rand := randf()
	if rand <= chance:
		return bonus.apply_to(actor)
	return ""
