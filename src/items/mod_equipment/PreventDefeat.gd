extends ModEquipmentEffect
class_name PreventDefeat

var _actor: BattleActor
var _death_averted := false

#override
func equip(actor: BattleActor) -> void:
	_actor = actor
	actor.battle_setup_completed.connect(setup)
	actor.add_func_override(actor.apply_damage, apply_damage)

#override
func unequip(actor: BattleActor) -> void:
	actor.battle_setup_completed.disconnect(setup)
	actor.remove_func_override(actor.apply_damage)
	_actor = null

func setup() -> void:
	_death_averted = false

func apply_damage(dmg: int, allowBlocking: bool=true) -> int:
	var blocking = null
	if dmg > 0 and allowBlocking:
		blocking = _actor.statuses.blocking

	if blocking != null:
		dmg *= 1 - blocking.strength
		_actor.statuses.remove_blocking()
		_actor.status_effects_removed.emit([blocking])

	if dmg != 0:
		_actor.current_hp -= dmg
		if _actor.current_hp <= 0 and not _actor.aleady_defeated:
			if not _death_averted:
				self.activated.emit("They survived the attack!")
				_actor.current_hp = 1
				_death_averted = true
			else:
				_actor.aleady_defeated = true
				_actor.was_just_defeated.emit()
		_actor.damage_applied.emit(_actor.current_hp)
	return dmg

