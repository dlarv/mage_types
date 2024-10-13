extends Node 
class_name StatusEffectManager 

# The Name field of all status effects should match one of these.
const STASIS_KEY: String = "Stasis"
const BLOCKING_KEY: String = "Blocking"
const POISON_KEY: String = "Poison"
const HEALING_KEY: String = "Healing"
const DISSONANT_KEY: String = "Dissonant"
const FLINCHING_KEY: String = "Flinching"
const PHOBIC_KEY: String = "Phobic"
const PHILIC_KEY: String = "Philic"

var poison: float:
	get:
		var effect = statuses.get(POISON_KEY)
		if effect != null:
			if randf_range(0.0, 1.0) <= effect.chance:
				return effect.strength
		return 0

var healing: float:
	get:
		var effect = statuses.get(HEALING_KEY)
		if effect != null:
			if randf_range(0.0, 1.0) <= effect.chance:
				return effect.strength
		return 0

var blocking: StatusEffect = null

# StatusEffect[]
var _effects_to_remove = []

# Dict<string, StatusEffect>
var statuses = {}

func add_status(status: StatusEffect) -> void:
	match status.name:
		BLOCKING_KEY:
			if blocking != null:
				blocking.combine(status)
			else:
				blocking = status
		_:
			if statuses.has(status.name):
				statuses[status.name].combine(status)
			else:
				statuses[status.name] = status

func get_status(status: StatusEffect) -> StatusEffect:
	match status.name:
		BLOCKING_KEY:
			return blocking
		_:
			return statuses.get(status.name)

func remove(effects: Array) -> void: 
	for effect in effects: statuses.erase(effect.name)


func calculate_expirations() -> Array:
	for effect in statuses.values():
		effect.duration -= 1
		if effect.is_expired():
			_effects_to_remove.append(effect)

	for effect in _effects_to_remove:
		statuses.erase(effect.name)
	
	var output = _effects_to_remove
	_effects_to_remove = []
	return output

func check_flinching() -> StatusEffect:
	return statuses.get(FLINCHING_KEY)

func check_dissonant() -> StatusEffect:
	return statuses.get(DISSONANT_KEY)

func check_blocking() -> bool:
	if blocking != null:
		_effects_to_remove.add(blocking)
		blocking = null
		return true
	return false

func check_stasis() -> StatusEffect:
	return statuses.get(STASIS_KEY)

func check_phobic(element) -> ElementalEffect:
	var effect = statuses.get(PHOBIC_KEY)
	if effect != null and effect.element == element:
		return effect
	return null

func check_philic(element) -> ElementalEffect:
	var effect = statuses.get(PHILIC_KEY)
	if effect != null and effect.element == element:
		return effect
	return null

func list() -> Array:
	var output = []
	if blocking != null:
		output.append(blocking)
	
	for effect in statuses.values():
		output.append(effect)
	return output
