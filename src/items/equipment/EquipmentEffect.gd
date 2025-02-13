extends Resource
class_name EquipmentEffect

signal activated(msg: String)

@export var trigger: EquipmentTrigger
@export var bonus: EquipmentBonus

func equip(actor: BattleActor) -> void:
	trigger.equip(actor, bonus)

	if not trigger.activated.is_connected(_on_trigger):
		trigger.activated.connect(_on_trigger)
		

func unequip(actor: BattleActor) -> void:
	trigger.unequip(actor, bonus)


func _on_trigger(msg: String) -> void:
	activated.emit(msg)
