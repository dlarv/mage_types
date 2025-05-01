@tool
extends EquipmentTrigger
class_name EndOfTurnTrigger

func equip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	if not actor.turn_ended.is_connected(_simple_trigger):
		actor.turn_ended.connect(_simple_trigger.bind(actor))

#override
func unequip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	if actor.turn_ended.is_connected(_simple_trigger):
		actor.turn_ended.disconnect(_simple_trigger)
