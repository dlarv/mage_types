extends Node 
class_name StatusEffectManager 

enum StatusEffects { STASIS, BLOCK, POISON, PHOBIC, HEALING, FLINCH, STAT_CHANGE }

var poison: float:
	get:
		var effect: StatusEffect = statuses.get(StatusEffects.POISON)
		if effect != null:
			return effect.strength
		return 0

var healing: float:
	get:
		var effect: StatusEffect = statuses.get(StatusEffects.HEALING)
		if effect != null:
			return effect.strength
		return 0

var blocking: StatusEffect = null

# Dict<ElementalType, StatusEffect>
var phobias := {}

# StatusEffect[]
var _effects_to_remove: Array[StatusEffect] = []
# Dict<string, StatusEffect>
var statuses := {}


func add(status: StatusEffect) -> void:
	match status.id:
		StatusEffects.BLOCK:
			if blocking != null:
				blocking.combine(status)
			else:
				blocking = status
		StatusEffects.PHOBIC:
			var key: ElementalType = status.element
			if phobias.has(key):
				phobias[key].combine(status)
			else:
				phobias[key] = status
		_:
			if statuses.has(status.id):
				statuses[status.id].combine(status)
			else:
				statuses[status.id] = status


func get_status(status: StatusEffect) -> StatusEffect:
	match status.id:
		StatusEffects.BLOCK:
			return blocking
		StatusEffects.PHOBIC:
			var key: ElementalType = status.element
			return phobias.get(key)
		_:
			return statuses.get(status.id)


func remove(effects: Array[StatusEffect]) -> void: 
	for effect in effects: 
		if effect.id == StatusEffects.PHOBIC:
			if effect.element.is_blank():
				phobias = {}
			else:
				phobias.erase(effect.element)
		elif effect.id == StatusEffects.BLOCK:
			blocking = null
		else:
			statuses.erase(effect.id)


func has(effect: StatusEffect) -> bool:
	if not effect: 
		return len(statuses) > 0 or blocking or len(phobias) > 0
	elif effect.id == StatusEffects.PHOBIC and effect.element.is_blank():
		return len(phobias) > 0
	elif effect.id == StatusEffects.BLOCK:
		return blocking != null
	else:
		return statuses.has(effect.id)


func calculate_expirations() -> Array[StatusEffect]:
	for effect: StatusEffect in statuses.values():
		effect.duration -= 1
		if effect.is_expired():
			_effects_to_remove.append(effect)

	for phobia: PhobiaEffect in phobias.values():
		phobia.duration -= 1
		if phobia.is_expired():
			_effects_to_remove.append(phobia)

	if blocking:
		blocking.duration -= 1
		if blocking.is_expired():
			_effects_to_remove.append(blocking)
			blocking = null

	for effect in _effects_to_remove:
		if effect is PhobiaEffect:
			phobias.erase(effect.element)
		else:
			statuses.erase(effect.id)
	
	var output := _effects_to_remove
	_effects_to_remove = []
	return output


func check_flinching() -> StatusEffect:
	return statuses.get(StatusEffects.FLINCH)


func remove_blocking() -> bool:
	if blocking != null:
		blocking.duration -= 1
		if blocking.is_expired():
			blocking = null
			return true
	return false


func check_stasis() -> StatusEffect:
	return statuses.get(StatusEffects.STASIS)


func check_phobic(element:ElementalType) -> PhobiaEffect:
	var effect: StatusEffect = phobias.get(element)
	if effect != null:
		return effect
	return null


func list() -> Array[StatusEffect]:
	var output: Array[StatusEffect] = []
	if blocking != null:
		output.append(blocking)
	
	output.append_array(statuses.values())
	output.append_array(phobias.values())
	return output


func clear() -> void:
	blocking = null
	phobias = {}
	_effects_to_remove = []
	statuses = {}


static func get_generic_status_effect(status: StatusEffects) -> StatusEffect:
	match status:
		StatusEffects.STASIS:
			return load("res://data/battle_system/status_effects/stasis_effect.tres")
		StatusEffects.BLOCK:
			return load("res://data/battle_system/status_effects/blocking_effect.tres")
		StatusEffects.POISON:
			return load("res://data/battle_system/status_effects/poison_effect.tres")
		StatusEffects.HEALING:
			return load("res://data/battle_system/status_effects/healing_effect.tres")
		StatusEffects.FLINCH:
			return load("res://data/battle_system/status_effects/flinching_effect.tres")
		# StatusEffects.PHOBIC:
		# 	return load("res://data/battle_system/status_effects/blocking_effect.tres")
		# StatusEffects.STAT_CHANGE:
		# 	return load("res://data/battle_system/status_effects/blocking_effect.tres")
	return null
