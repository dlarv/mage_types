@tool
extends Equipment 
class_name AddEquipment 

@export var effects: Array[AddEquipmentEffect]:
	set(value):
		effects = value
		for effect in effects:
			if not effect.activated.is_connected(_on_activated):
				effect.activated.connect(_on_activated)

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
