@tool
extends Equipment 
class_name AddEquipment 

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
