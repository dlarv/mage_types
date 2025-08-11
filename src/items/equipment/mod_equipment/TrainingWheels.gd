@tool
extends _ModEquipmentEffect
class_name TrainingWheels

const StatusEffectManager := preload("res://src/battle_system/StatusEffectManager.gd")

#override
func equip(actor: BattleActor) -> void:
	if not actor.battle_setup_completed.is_connected(setup):
		actor.battle_setup_completed.connect(setup)
	Logger.append_battle_log("TrainingWheels equipment altered %s.add_status_effect(...)" % actor.name)
	actor.add_func_override(actor.add_status_effect, add_status_effect.bind(actor))

#override
func unequip(actor: BattleActor) -> void:
	actor.battle_setup_completed.disconnect(setup)
	actor.remove_func_override(actor.apply_damage.bind(actor))


func setup() -> void:
	for actor: BattleActor in Battle.query_battlefield_state(null, Battle.BattlefieldStateParams.COMBATANTS):
		# if _death_averted.has(actor):
		# 	_death_averted[actor] = false
		pass


func add_status_effect(effect: StatusEffect, actor: BattleActor) -> bool:
	if effect is StatChange and effect.is_side_effect: 
		return false

	Logger.append_battle_log("%s was applied to %s." % [ effect.name, actor.name ])
	if effect is StatChange:
		actor.stat_manager.add(effect, actor.name)
	else:
		actor.statuses.add(effect)
		actor.status_effect_added.emit(actor.statuses.get_status(effect))

	if actor.alignment_manager and effect.id == StatusEffectManager.StatusEffects.PHOBIC:
		actor.alignment_manager.add(effect.element, -1)

	return true
