extends Node 
class_name StatusEffectManager 

# The Name field of all status effects should match one of these.
const ATTACK_KEY: String = "Attack"
const DEFENSE_KEY: String = "Defense"
const MELEE_ATTACK_KEY: String = "Melee Attack"
const RANGED_ATTACK_KEY: String = "Ranged Attack"
const MELEE_DEFENSE_KEY: String = "Melee Defense"
const RANGED_DEFENSE_KEY: String = "Ranged Defense"
const SPEED_KEY: String = "Speed"
const EVASION_KEY: String = "Evasion"
const STASIS_KEY: String = "Stasis"
const BLOCKING_KEY: String = "Blocking"
const POISON_KEY: String = "Poison"
const HEALING_KEY: String = "Healing"
const DISSONANT_KEY: String = "Dissonant"
const FLINCHING_KEY: String = "Flinching"
const PHOBIC_KEY: String = "Phobic"
const PHILIC_KEY: String = "Philic"

var melee_attack_mod : float:  
	get:
		var total = 1
		var effect = statuses.get(MELEE_ATTACK_KEY)
		if effect != null:
			total += effect.get_mod()
		effect = statuses.get(ATTACK_KEY)
		if effect != null:
			total += effect.get_mod()
		return total

var melee_defense_mod : float: 
	get:
		var total = 1
		var effect = statuses.get(MELEE_DEFENSE_KEY)
		if effect != null:
			total += effect.get_mod()
		
		effect = statuses.get(DEFENSE_KEY)
		if effect != null:
			total += effect.get_mod()
		return total

var ranged_attack_mod : float:
	get:
		var total = 1
		var effect = statuses.get(RANGED_ATTACK_KEY)
		if effect != null:
			total += effect.get_mod()
		effect = statuses.get(ATTACK_KEY)
		if effect != null:
			total += effect.get_mod()
		return total

var ranged_defense_mod : float:
	get:
		var total = 1
		var effect = statuses.get(RANGED_DEFENSE_KEY)
		if effect != null:
			total += effect.get_mod()
		effect = statuses.get(DEFENSE_KEY)
		if effect != null:
			total += effect.get_mod()
		return total

var speed_mod : float:
	get:
		var effect = statuses.get(MELEE_ATTACK_KEY)
		if effect != null:
			return effect.get_mod()
		return 1

var evasion_mod : float:
	get:
		var effect = statuses.get(MELEE_ATTACK_KEY)
		if effect != null:
			return effect.get_mod()
		return 1

var poison : float:
	get:
		var effect = statuses.get(POISON_KEY)
		if effect != null:
			if randf_range(0.0, 1.0) <= effect.chance:
				return effect.strength
		return 0

var healing : float:
	get:
		var effect = statuses.get(HEALING_KEY)
		if effect != null:
			if randf_range(0.0, 1.0) <= effect.chance:
				return effect.strength
		return 0

var blocking : StatusEffect = null
var stasis : StatusEffect = null
# StatusEffect[]
var effectsToRemove = []

# Dict<string, StatusEffect>
var statuses = {}

func add_status(status):
	# if status is ElementalEffect:
	# 	status = status.duplicate()
	# 	status.element = ElementManager.get_element_from_name(status.name)
	match status.name:
		BLOCKING_KEY:
			blocking = status
		STASIS_KEY:
			stasis = status
		_:
			if statuses.has(status.name):
				statuses[status.name].combine(status)
			else:
				statuses[status.name] = status

func get_status(status):
	match status.name:
		BLOCKING_KEY:
			return blocking
		STASIS_KEY:
			return stasis
		_:
			return statuses.get(status.name)

func remove(effects):
	for effect in effects:
		statuses.remove(effect.name)


func calculate_expirations():
	for effect in statuses.values():
		effect.duration -= 1
		if effect.is_expired():
			effectsToRemove.append(effect)

	for effect in effectsToRemove:
		statuses.erase(effect.name)
	
	var output = effectsToRemove
	effectsToRemove = []
	return output

func is_flinching():
	return statuses.has(FLINCHING_KEY)

func is_dissonant():
	return statuses.has(DISSONANT_KEY)

func is_blocking():
	if blocking != null:
		effectsToRemove.add(blocking)
		blocking = null
		return true
	return false

func in_stasis():
	if stasis != null:
		effectsToRemove.add(stasis)
		stasis = null
		return true
	
	return false

func is_phobic(element):
	return statuses.get(PHOBIC_KEY)

func is_philic(element):
	return statuses.get(PHILIC_KEY)

func list():
	var output = []
	if blocking != null:
		output.append(blocking)
	
	if stasis != null:
		output.append(stasis)
	for effect in statuses.values():
		output.append(effect)
	return output
