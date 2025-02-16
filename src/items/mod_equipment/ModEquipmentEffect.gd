extends Resource
class_name ModEquipmentEffect

@warning_ignore("unused_signal")
signal activated(msg: String)

#virtual
func equip(actor: BattleActor) -> void: pass

#virtual
func unequip(actor: BattleActor) -> void: pass
