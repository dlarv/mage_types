@tool
extends EquipmentEffect
class_name AddEquipmentEffect

@export var trigger: EquipmentTrigger
@export var bonus: EquipmentBonus

var _actor: BattleActor

# override
func equip(actor: BattleActor) -> void:
	trigger.equip(actor, bonus)
	_actor = actor

	if not trigger.activated.is_connected(_on_trigger):
		trigger.activated.connect(_on_trigger)
		

# override
func unequip(actor: BattleActor) -> void:
	_actor = null 
	trigger.unequip(actor, bonus)


func _on_trigger(msg: String) -> void:
	if len(msg) > 0:
		msg += "\n"
	Logger.append_log(Logger.LogType.BATTLE, 
			"BattleActor(%s) equipment activated. Trigger(%s)." 
			% [_actor.name, trigger.get_class()])
	msg += bonus.apply_to(_actor)
	Logger.append_log(Logger.LogType.BATTLE, "Final Msg(%s)." % msg) 
	activated.emit(msg)
