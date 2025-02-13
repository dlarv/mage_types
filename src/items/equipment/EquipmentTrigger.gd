extends Resource
class_name EquipmentTrigger

signal activated(msg: String)

# virtual
func equip(actor: BattleActor, bonus: EquipmentBonus) -> void: pass

# virtual
func unequip(actor: BattleActor, bonus: EquipmentBonus) -> void: pass
