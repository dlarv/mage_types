extends Resource
class_name _EquipmentEffect

@warning_ignore("unused_signal")
signal activated(actor: BattleActor, msg: String)

#virtual
func equip(actor: BattleActor) -> void: pass
#virtual
func unequip(actor: BattleActor) -> void: pass
