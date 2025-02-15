extends Resource
class_name ModEquipmentEffect

signal activated(msg: String)

#virtual
func equip(actor: BattleActor) -> void: pass

#virtual
func unequip(actor: BattleActor) -> void: pass
