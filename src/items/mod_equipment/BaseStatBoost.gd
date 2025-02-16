extends ModEquipmentEffect
class_name BaseStatBoost

@export var stat: StatManager.Stat
@export var amount: float


#override
func equip(actor: BattleActor) -> void:
	actor.stat_manager.mod_base_stat(stat, amount)

#override
func unequip(actor: BattleActor) -> void:
	actor.stat_manager.mod_base_stat(stat, -amount)
