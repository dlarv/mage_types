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
	match status.name:
		BLOCKING_KEY:
			if blocking != null:
				blocking.combine(status)
			else:
				blocking = status
		STASIS_KEY:
			if stasis != null:
				stasis.combine(status)
			else:
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
		statuses.erase(effect.name)


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

func check_flinching():
	return statuses.get(FLINCHING_KEY)

func check_dissonant():
	return statuses.get(DISSONANT_KEY)

func check_blocking():
	if blocking != null:
		effectsToRemove.add(blocking)
		blocking = null
		return true
	return false

func check_stasis():
	if stasis != null:
		var output = stasis
		effectsToRemove.add(stasis)
		stasis = null
		return stasis
	
	return null

func check_phobic(element):
	var effect = statuses.get(PHOBIC_KEY)
	if effect != null and effect.element == element:
		return effect
	return null

func check_philic(element):
	var effect = statuses.get(PHILIC_KEY)
	if effect != null and effect.element == element:
		return effect
	return null

func list():
	var output = []
	if blocking != null:
		output.append(blocking)
	
	if stasis != null:
		output.append(stasis)
	for effect in statuses.values():
		output.append(effect)
	return output
