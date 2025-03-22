@tool
extends ModEquipmentEffect
class_name StatBoostBoundsMod

@export var new_min := -1.0
@export var new_max := -1.0
var _prev_max: float
var _prev_min: float

#override
func equip(actor: BattleActor) -> void:
	if new_max != -1:
		_prev_max = actor.stat_manager.MAX_MOD
		actor.stat_manager.MAX_MOD = new_max
	if new_min != -1:
		_prev_min = actor.stat_manager.MIN_MOD
		actor.stat_manager.MIN_MOD = new_min

#override
func unequip(actor: BattleActor) -> void:
	if new_max != -1:
		actor.stat_manager.MAX_MOD = _prev_max
	if new_min != -1:
		actor.stat_manager.MIN_MOD = _prev_min
