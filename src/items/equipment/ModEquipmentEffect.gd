@tool
extends _EquipmentEffect
class_name ModEquipmentEffect

enum Type { PREVENT_DEFEAT, TRAINING_WHEELS, HAMMER, NONE }

@export var type := Type.NONE: set = _set_type
var method_name: StringName
var default_method: Callable


func setup() -> void:
	match type:
		Type.PREVENT_DEFEAT:

			var _death_averted: Dictionary[BattleActor, bool] = get_meta("prevent_defeat", {})
			for actor: BattleActor in Battle.query_battlefield_state(null, Battle.BattlefieldStateParams.COMBATANTS):
				if _death_averted.has(actor):
					_death_averted[actor] = false


#virtual
func equip(actor: BattleActor) -> void: 
	if not actor.battle_setup_completed.is_connected(setup):
		actor.battle_setup_completed.connect(setup)
	match type:
		Type.PREVENT_DEFEAT:
			actor.add_func_override(method_name, _prevent_defeat.bind(actor))
			get_meta("prevent_defeat", {})[actor] = false
			print("DEBUG: " + str(get_meta("prevent_defeat")))
		Type.TRAINING_WHEELS:
			actor.add_func_override(method_name, _training_wheels.bind(actor))
		Type.HAMMER:
			actor.add_func_override(method_name, _hammer_init.bind(actor))

	Logger.append_battle_log("%s equipment altered %s.%s(...)" % [str(type), actor.name, method_name])


#virtual
func unequip(actor: BattleActor) -> void: 
	actor.battle_setup_completed.disconnect(setup)
	actor.remove_func_override(method_name)

	match type:
		Type.PREVENT_DEFEAT:
			var meta: Dictionary[BattleActor, bool] = get_meta("prevent_defeat", {})
			meta.erase(actor)
			set_meta("prevent_defeat", meta)
		Type.TRAINING_WHEELS:
			actor.remove_func_override(method_name)


func _prevent_defeat(dmg: int, allowBlocking: bool=true, actor: BattleActor=null) -> int:
	var _death_averted: Dictionary[BattleActor, bool] = get_meta("prevent_defeat")
	var blocking: StatusEffect = null
	if dmg > 0 and allowBlocking:
		blocking = actor.statuses.blocking

	if blocking != null:
		dmg = int(float(dmg) * (1 - blocking.strength))
		actor.statuses.remove_blocking()
		actor.status_effects_removed.emit([blocking] as Array[StatusEffect])

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


func _training_wheels(effect: StatusEffect, actor: BattleActor) -> bool:
	if effect is StatChange and effect.is_side_effect: 
		return false

	Logger.append_battle_log("%s was applied to %s." % [ effect.name, actor.name ])
	if effect is StatChange:
		actor.stat_manager.add(effect, actor.name)
	else:
		actor.statuses.add(effect)
		actor.status_effect_added.emit(actor.statuses.get_status(effect))

	if actor.alignment_manager and effect.id == BattleActor.StatusEffectManager.StatusEffects.PHOBIC:
		actor.alignment_manager.add(effect.element, -1)

	return true


func _hammer_init(actor: BattleActor) -> void:
	var slot := EffectSlot.new()
	slot.chance = 0.3
	slot.attack_effect = StatusEffect.new()
	slot.attack_effect.id = StatusEffect.Effects.FLINCH
	slot.effect_target = EffectSlot.EffectTarget.TARGET

	for attack in actor.attacks:
		if attack.attack_range != Attack.AttackRange.MELEE: continue

		attack.resource_local_to_scene = true
		attack.effects.append(slot)
		Logger.append_battle_log("Added flinch to %s" % attack.name)

	actor.battle_resolution_completed.connect(func() -> void:
		for attack in actor.attacks:
			attack.effects.remove_at(len(attack.effects) - 1)
			Logger.append_battle_log("Remove flinch from %s" % attack.name)
	)
	actor.battle_setup_completed.emit()


func _set_type(val: Type) -> void:
	var actor := BattleActor.new()
	type = val
	match type:
		Type.PREVENT_DEFEAT:
			method_name = actor.apply_damage.get_method()
			set_meta("prevent_defeat", {} as Dictionary[BattleActor, bool])
		Type.TRAINING_WHEELS:
			method_name = actor.add_status_effect.get_method()
		Type.HAMMER:
			method_name = actor.setup.get_method()
