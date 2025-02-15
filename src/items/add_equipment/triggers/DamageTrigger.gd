@tool
extends EquipmentTrigger
class_name DamageTrigger

#override
func equip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	if not actor.damage_applied.is_connected(_simple_activate):
		actor.damage_applied.connect(_simple_activate)

#override
func unequip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	if actor.damage_applied.is_connected(_simple_activate):
		actor.damage_applied.disconnect(_simple_activate)

