extends Resource
class_name EquipmentEffect

signal activated(msg: String)

@export var trigger: EquipmentTrigger
@export var bonus: EquipmentBonus

var _actor: BattleActor

func equip(actor: BattleActor) -> void:
	trigger.equip(actor, bonus)
	_actor = actor

	if not trigger.activated.is_connected(_on_trigger):
		trigger.activated.connect(_on_trigger)
		

func unequip(actor: BattleActor) -> void:
	_actor = null 
	trigger.unequip(actor, bonus)


func _on_trigger(msg: String) -> void:
	msg += "\n" + bonus.apply_to(_actor)
	activated.emit(msg)
