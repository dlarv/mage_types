@tool
extends EquipmentTrigger
class_name DefeatTrigger

#override
func equip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	if not actor.was_just_defeated.is_connected(_simple_activate):
		actor.was_just_defeated.connect(_simple_activate)

#override
func unequip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	if actor.was_just_defeated.is_connected(_simple_activate):
		actor.was_just_defeated.disconnect(_simple_activate)

