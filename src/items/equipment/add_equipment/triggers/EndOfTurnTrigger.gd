@tool
extends EquipmentTrigger
class_name EndOfTurnTrigger

func equip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	if not actor.turn_ended.is_connected(_simple_activate):
		actor.turn_ended.connect(_simple_activate)

#override
func unequip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	if actor.turn_ended.is_connected(_simple_activate):
		actor.turn_ended.disconnect(_simple_activate)
