@tool
extends ModEquipmentEffect
class_name PreventDefeat

var _death_averted := {}


#override
func equip(actor: BattleActor) -> void:
	if not actor.battle_setup_completed.is_connected(setup):
		actor.battle_setup_completed.connect(setup)
	Logger.append_battle_log("PreventDefeat equipment altered %s.apply_damage(...)" % actor.name)
	_death_averted[actor] = false
	actor.add_func_override(actor.apply_damage, apply_damage)

#override
func unequip(actor: BattleActor) -> void:
	actor.battle_setup_completed.disconnect(setup)
	actor.remove_func_override(actor.apply_damage.bind(actor))

func setup() -> void:
	for key in _death_averted.keys():
		_death_averted[key] = false

func apply_damage(dmg: int, allowBlocking: bool=true, actor: BattleActor=null) -> int:
	var blocking = null
	if dmg > 0 and allowBlocking:
		blocking = actor.statuses.blocking

	if blocking != null:
		dmg *= 1 - blocking.strength
		actor.statuses.remove_blocking()
		actor.status_effects_removed.emit([blocking])

	if dmg != 0:
		actor.current_hp -= dmg
		if actor.current_hp <= 0 and not actor.aleady_defeated:
			if not _death_averted.get(actor, false):
				self.activated.emit(actor, "They survived the attack!")
				actor.current_hp = 1
				_death_averted[actor] = true
			else:
				actor.aleady_defeated = true
				actor.was_just_defeated.emit()
		actor.damage_applied.emit(actor.current_hp)
	return dmg
