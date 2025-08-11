@tool
extends _EquipmentEffect
class_name AddEquipmentEffect

@export var trigger: EquipmentTrigger:
	set(val):
		trigger = val
		if trigger and not trigger.triggered.is_connected(_on_trigger):
			trigger.triggered.connect(_on_trigger)
@export var bonus: EquipmentBonus


# override
func equip(actor: BattleActor) -> void:
	trigger.equip(actor, bonus)


# override
func unequip(actor: BattleActor) -> void:
	trigger.unequip(actor, bonus)


func _on_trigger(actor: BattleActor, msg: String) -> void:
	if len(msg) > 0:
		msg += "\n"
	Logger.append_battle_log(
			"BattleActor(%s) equipment activated. Trigger(%s)." 
			% [actor.name, trigger.get_class()])
	msg += bonus.apply_to(actor)
	Logger.append_battle_log("Final Msg(%s)." % msg) 
	activated.emit(actor, msg)
