@tool
extends BattleActor
class_name PlayerBattleActor


## Teaches actor spell contained within scroll.
## If spell already exists at index, places old spell into inventory.
## If the actor does not meet the requirements, return an array containing the unmet requirements.
func replace_attack(scroll: SpellScroll, index:=-1) -> Array[ItemRequirement]:
	if scroll == null:
		# Prevent player from removing their last attack.
		if attacks.count(null) == len(attacks) - 1: return []

		var attack := attacks[index]
		if attack:
			Inventory.find_and_add_spell(attack)
		attacks.remove_at(index)
		attacks.append(null)

		for i in range(index, len(attacks)): spell_learned.emit(attacks[i], i)
		return []

	if index == -1:
		index = attacks.find(null)
		if index == -1:
			index = len(attacks)
	if index >= len(attacks):
		attacks.resize(index + 1)
	
	# E.g. player can only know 1 offensive strike attack at a time.
	# If player is trying to replace a strike move with another strike, 
	# the check_requirements call will fail.
	var prevAttack: Attack = null
	if attacks[index]:
		prevAttack = attacks[index]
		attacks[index] = null
		
	var output := scroll.check_requirements(self)
	if len(output) == 0:
		if prevAttack:
			Inventory.find_and_add_spell(prevAttack)
		attacks[index] = scroll.spell
		spell_learned.emit(scroll.spell, index)
	else:
		push_warning("Could not learn selected Spell(%s). BattleActor(%s) does not meet the following reqs: %s" 
				% [scroll.spell.name, name, str(output) ])
		if prevAttack:
			attacks[index] = prevAttack
	return output


func replace_equipment(item: Equipment) -> void:
	if equipment != null:
		Inventory.add(equipment)
	equipment = item


func add_xp(xp: float) -> int:
	if not stat_manager is PlayerStatManager: return 0
	elif _try_call_override(add_xp.get_method(), [xp]): return _override_output
	return stat_manager.add_xp(xp)


func level_up(levels:=1, forceReset:=false) -> Dictionary[StatManager.Stats, float]:
	level += levels
	Logger.append_battle_log("BattleActor(%s) is now level(%d)!" % [name, level])

	var output: Dictionary[StatManager.Stats, float] = stat_manager.level_up(levels, forceReset)

	leveled_up.emit()
	return output


func update_alignment() ->  Dictionary:
	if not alignment_manager: return {}
	var output := {}
	var maxElements := alignment_manager.update_current_alignment()
	var newCore: ElementalType
	if element1 in maxElements:
		newCore = element1
	else:
		newCore = maxElements.pick_random()

	if alignment_manager.alignment_locked:
		output["aligned"] = true
		output["element"] = newCore
		set_element(0, newCore)
	elif element1 != newCore:
		output["aligned"] = false
		output["element"] = newCore
		set_element(0, newCore)
	else:
		output["element"] = null

	return output


