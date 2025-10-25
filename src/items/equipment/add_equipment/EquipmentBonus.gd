@tool
extends Resource
class_name EquipmentBonus


# virtual
func apply_to(actor: BattleActor) -> ActorTurnData: return ActorTurnData.empty(actor)
