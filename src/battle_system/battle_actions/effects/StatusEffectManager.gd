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

var MeleeAttackMod : float:  
	get:
		var total = 1
		var effect
		if statuses.TryGetValue(MELEE_ATTACK_KEY, effect):
			total += effect.GetMod()
		if statuses.TryGetValue(ATTACK_KEY, effect):
			total += effect.GetMod()
		return total

var MeleeDefenseMod : float: 
	get:
		var total = 1
		var effect
		if statuses.TryGetValue(MELEE_DEFENSE_KEY, effect):
			total += effect.GetMod()
		
		if statuses.TryGetValue(DEFENSE_KEY, effect):
			total += effect.GetMod()
		
		return total

var RangedAttackMod : float:
	get:
		var total = 1
		var effect
		if statuses.TryGetValue(RANGED_ATTACK_KEY, effect):
			total += effect.GetMod()
		if statuses.TryGetValue(ATTACK_KEY, effect):
			total += effect.GetMod()
		return total
var RangedDefenseMod : float:
	get:
		var total = 1
		var effect
		if statuses.TryGetValue(RANGED_DEFENSE_KEY, effect):
			total += effect.GetMod()
		
		if statuses.TryGetValue(DEFENSE_KEY, effect):
			total += effect.GetMod()
		
		return total

var SpeedMod : float:
	get:
		var effect
		if statuses.TryGetValue(MELEE_ATTACK_KEY, effect):
			return effect.GetMod()
		
		return 1
var EvasionMod : float:
	get:
		var effect
		if statuses.TryGetValue(MELEE_ATTACK_KEY, effect):
			return effect.GetMod()
		
		return 1

var Poison : float:
	get:
		var poison
		if statuses.TryGetValue(POISON_KEY, poison):
			if randf_range(0.0, 1.0) <= poison.Chance:
				return poison.Strength
		return 0

var Healing : float:
	get:
		var healing
		if statuses.TryGetValue(HEALING_KEY, healing):
			if randf_range(0.0, 1.0) <= healing.Chance:
				return healing.Strength
		return 0

var blocking : StatusEffect = null
var stasis : StatusEffect = null
# StatusEffect[]
var effectsToRemove = []

# Dict<string, StatusEffect>
var statuses = {}

func Add(status):
	match status.Name:
		BLOCKING_KEY:
			blocking = status
		STASIS_KEY:
			stasis = status
		_:
			if statuses.contains_key(status.Name):
				statuses[status.Name].Combine(status)
			else:
				statuses.add(status.Name, status)

func Get(status):
	match status.Name:
		BLOCKING_KEY:
			return blocking
		STASIS_KEY:
			return stasis
		_:
			return statuses.get_value_or_default(status.Name, null)

func Remove(effects):
	for effect in effects:
		statuses.remove(effect.Name)


func CalculateExpirations():
	for effect in statuses.Values:
		effect.Duration -= 1
		if effect.IsExpired():
			effectsToRemove.add(effect)

	for effect in effectsToRemove:
		statuses.remove(effect.Name)
	
	var output = effectsToRemove
	effectsToRemove = []
	return output

func IsFlinching():
	return statuses.contains_key(FLINCHING_KEY)

func IsDissonant():
	return statuses.contains_key(DISSONANT_KEY)

func IsBlocking():
	if blocking != null:
		effectsToRemove.add(blocking)
		blocking = null
		return true
	return false

func InStasis():
	if stasis != null:
		effectsToRemove.add(stasis)
		stasis = null
		return true
	
	return false

func IsPhobic(element, mod):
	var effect
	if statuses.TryGetValue(PHOBIC_KEY, effect):
		mod = effect
		return effect.Element.Name == element.Name
	
	mod = null
	return false

func IsPhilic(element, mod):
	var effect
	if statuses.TryGetValue(PHILIC_KEY, effect):
		mod = effect
		return effect.Element.Name == element.Name
	mod = null
	return false

func List():
	var output = []
	if blocking != null:
		output.add(blocking)
	
	if stasis != null:
		output.add(stasis)
	for effect in statuses.Values:
		output.add(effect)
	return output
