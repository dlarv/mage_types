extends Equipment
class_name ModEquipment


#override
func equip(battleActor: BattleActor) -> void:
	super.equip(battleActor)

	for effect in effects:
		effect.equip(battleActor)

#override
func unequip(battleActor: BattleActor) -> void:
	super.unequip(battleActor)

	for effect in effects:
		effect.unequip(battleActor)
