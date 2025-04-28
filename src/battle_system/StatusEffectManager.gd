extends Node 
class_name StatusEffectManager 

enum StatusEffects { STASIS, BLOCKING, POISON, PHOBIC, HEALING, FLINCHING, STAT_CHANGE }

var poison: float:
	get:
		var effect = statuses.get(StatusEffects.POISON)
		if effect != null:
			return effect.strength
		return 0

var healing: float:
	get:
		var effect = statuses.get(StatusEffects.HEALING)
		if effect != null:
			return effect.strength
		return 0

var blocking: StatusEffect = null

# Dict<ElementalType, StatusEffect>
var phobias := {}

# StatusEffect[]
var _effects_to_remove := []
# Dict<string, StatusEffect>
var statuses := {}


func add_status(status: StatusEffect) -> void:
	match status.id:
		StatusEffects.BLOCKING:
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
		StatusEffects.BLOCKING:
			return blocking
		StatusEffects.PHOBIC:
			var key: ElementalType = status.element
			return phobias.get(key)
		_:
			return statuses.get(status.id)


func remove(effects: Array) -> void: 
	for effect in effects: 
		if effect.id == StatusEffects.PHOBIC:
			phobias.erase(effect.element)
		else:
			statuses.erase(effect.id)


func calculate_expirations() -> Array:
	for effect in statuses.values():
		effect.duration -= 1
		if effect.is_expired():
			_effects_to_remove.append(effect)

	for phobia in phobias.values():
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
	
	var output = _effects_to_remove
	_effects_to_remove = []
	return output


func check_flinching() -> StatusEffect:
	return statuses.get(StatusEffects.FLINCHING)


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
	var effect = phobias.get(element)
	if effect != null:
		return effect
	return null


func list() -> Array:
	var output = []
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
