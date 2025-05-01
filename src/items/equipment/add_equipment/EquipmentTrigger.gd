@tool
extends Resource
class_name EquipmentTrigger

@warning_ignore("unused_signal")
signal triggered(actor: BattleActor, msg: String)

# virtual
func equip(actor: BattleActor, bonus: EquipmentBonus) -> void: pass

# virtual
func unequip(actor: BattleActor, bonus: EquipmentBonus) -> void: pass

func _simple_trigger(actor: BattleActor=null) -> void:
	triggered.emit(actor, "")
