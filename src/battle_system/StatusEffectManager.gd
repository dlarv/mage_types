extends Node 
class_name StatusEffectManager 

# The Name field of all status effects should match one of these.
const STASIS_KEY: String = "Stasis"
const BLOCKING_KEY: String = "Blocking"
const POISON_KEY: String = "Poison"
const PHOBIC_KEY: String = "Phobic"
const HEALING_KEY: String = "Healing"

const PHILIC_KEY: String = "Philic"
const DISSONANT_KEY: String = "Dissonant"
const FLINCHING_KEY: String = "Flinching"

var poison: float:
	get:
		var effect = statuses.get(POISON_KEY)
		if effect != null:
			if randf() <= effect.chance:
				return effect.strength
		return 0

var healing: float:
	get:
		var effect = statuses.get(HEALING_KEY)
		if effect != null:
			if randf() <= effect.chance:
				return effect.strength
		return 0

var blocking: StatusEffect = null

var phobias := {}

# StatusEffect[]
var _effects_to_remove := []

# Dict<string, StatusEffect>
var statuses := {}

func add_status(status: StatusEffect) -> void:
	match status.name:
		BLOCKING_KEY:
			if blocking != null:
				blocking.combine(status)
			else:
				blocking = status
		PHOBIC_KEY:
			var key := "%s_%s" % [status.element, status.name]
			if statuses.has(key):
				statuses[key].combine(status)
			else:
				statuses[key] = status
		_:
			if statuses.has(status.name):
				statuses[status.name].combine(status)
			else:
				statuses[status.name] = status

func get_status(status: StatusEffect) -> StatusEffect:
	match status.name:
		BLOCKING_KEY:
			return blocking
		PHOBIC_KEY:
			var key := "%s_%s" % [status.element, status.name]
			return statuses.get(key)
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

func remove_blocking() -> bool:
	if blocking != null:
		blocking.duration -= 1
		if blocking.is_expired():
			blocking = null
			return true
	return false

func check_stasis() -> StatusEffect:
	return statuses.get(STASIS_KEY)

func check_phobic(element) -> ElementalEffect:
	var key := "%s_%s" % [element, PHOBIC_KEY]
	var effect = statuses.get(key)
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

# func serialize() -> Dictionary: 
# 	return {
# 		"statuses": statuses,
# 		"phobias": phobias,
# 	}
# func deserialize(data: Dictionary) -> void: 
# 	if "statuses" in data:
# 		statuses = data["statuses"]
# 	if "phobias" in data:
# 		phobias = data["phobias"]
