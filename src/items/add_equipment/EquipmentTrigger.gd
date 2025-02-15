extends Resource
class_name EquipmentTrigger

@warning_ignore("unused_signal")
signal activated(msg: String)

# virtual
func equip(actor: BattleActor, bonus: EquipmentBonus) -> void: pass

# virtual
func unequip(actor: BattleActor, bonus: EquipmentBonus) -> void: pass

func _simple_activate(a: Variant=null) -> void:
	activated.emit("")
