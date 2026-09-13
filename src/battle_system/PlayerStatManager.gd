@tool
extends StatManager
class_name PlayerStatManager

const TRANSMUTATION_XP_UNIT := 0.3
# Since side effects don't boost HP, this value will let HP keep pace.
const HP_XP_BOOST := 0.3
# This value x6 is the approx maximum number of stat points a character can receive upon level up.
const MAX_STAT_POINTS := 3

@export_category("Experience")
@export var next_level_xp := 100
@export var total_xp := 0

var _hp_xp := 0.0
var _melee_attack_xp := 0.0
var _ranged_attack_xp := 0.0
var _melee_defense_xp := 0.0
var _ranged_defense_xp := 0.0
var _speed_xp := 0.0

#override
func add(effect: StatChange, name: String) -> void:
	super.add(effect, name)

	if effect.is_side_effect:
		match effect.stat:
			Stats.ATTACK:
				_melee_attack_xp += effect.get_strength()
				_ranged_attack_xp += effect.get_strength()
			Stats.DEFENSE:
				_melee_defense_xp += effect.get_strength()
				_ranged_defense_xp += effect.get_strength()
			Stats.SPEED:
				_speed_xp += effect.get_strength()


## Values drawn from design doc Roadmap#The List#Battle (BATT)#End Battle#Option 2
## This is a gross way of doing this, but these values would need to be hardcoded somewhere.
func resolve_end_of_turn(unnormalizedValues: Array[float], turns:=1) -> void:
	if len(unnormalizedValues) < 8: return

	# Blue
	_hp_xp += unnormalizedValues[0] * TRANSMUTATION_XP_UNIT + HP_XP_BOOST
	_melee_defense_xp += unnormalizedValues[0] * TRANSMUTATION_XP_UNIT

	# Purple
	_melee_attack_xp += unnormalizedValues[1] * TRANSMUTATION_XP_UNIT
	_ranged_attack_xp += unnormalizedValues[1] * TRANSMUTATION_XP_UNIT
	_ranged_defense_xp += unnormalizedValues[1] * TRANSMUTATION_XP_UNIT

	# Magenta
	_hp_xp += unnormalizedValues[2] * TRANSMUTATION_XP_UNIT + HP_XP_BOOST
	_melee_defense_xp += unnormalizedValues[2] * TRANSMUTATION_XP_UNIT

	# Red
	_hp_xp += unnormalizedValues[3] * TRANSMUTATION_XP_UNIT + HP_XP_BOOST
	_melee_attack_xp += unnormalizedValues[3] * TRANSMUTATION_XP_UNIT

	# Orange
	_ranged_attack_xp += unnormalizedValues[4] * TRANSMUTATION_XP_UNIT
	_speed_xp += unnormalizedValues[4] * TRANSMUTATION_XP_UNIT
	
	# Yellow
	_ranged_defense_xp += unnormalizedValues[5] * TRANSMUTATION_XP_UNIT
	_speed_xp += unnormalizedValues[5] * TRANSMUTATION_XP_UNIT

	# Green
	_melee_attack_xp += unnormalizedValues[6] * TRANSMUTATION_XP_UNIT
	_ranged_attack_xp += unnormalizedValues[6] * TRANSMUTATION_XP_UNIT
	_speed_xp += unnormalizedValues[6] * TRANSMUTATION_XP_UNIT

	# Cyan
	_melee_defense_xp += unnormalizedValues[7] * TRANSMUTATION_XP_UNIT
	_ranged_defense_xp += unnormalizedValues[7] * TRANSMUTATION_XP_UNIT


func boost_elemental_stats(elements: Array[ElementalType]) -> void:
	var values: Array[float] = []
	values.resize(8)
	values.fill(0)

	for element in elements:
		values[int(element.id)] += 1.0 / TRANSMUTATION_XP_UNIT
	
	resolve_end_of_turn(values)


func set_xp_stat(stat: Stats, val: float) -> void:
	match stat:
		Stats.MELEE_ATTACK: 
			_melee_attack_xp = val
		Stats.RANGED_ATTACK: 
			_ranged_attack_xp = val
		Stats.MELEE_DEFENSE: 
			_melee_defense_xp = val
		Stats.RANGED_DEFENSE: 
			_ranged_defense_xp = val
		Stats.SPEED: 
			_speed_xp = val
		Stats.HP:
			_hp_xp = val


## forceReset: Used when xp values are 0, like when leveling up using debug menu.
func level_up(levels:=1, forceReset:=false) -> Dictionary[Stats, float]:
	var output: Dictionary[Stats, float] = {}
	if forceReset:
		for stat in 11:
			set_xp_stat(stat as Stats, 1.0)
	var average := (_hp_xp+_speed_xp+_melee_attack_xp+_melee_defense_xp+_ranged_attack_xp+_ranged_defense_xp) \
			/ 6.0

	output[Stats.HP] = _calc_boost(Stats.HP, _hp_xp, levels, average)
	output[Stats.MELEE_ATTACK] = _calc_boost(Stats.MELEE_ATTACK, _melee_attack_xp, levels, average)
	output[Stats.MELEE_DEFENSE] = _calc_boost(Stats.MELEE_DEFENSE, _melee_defense_xp, levels, average)
	output[Stats.RANGED_ATTACK] = _calc_boost(Stats.RANGED_ATTACK, _ranged_attack_xp, levels, average)
	output[Stats.RANGED_DEFENSE] = _calc_boost(Stats.RANGED_DEFENSE, _ranged_defense_xp, levels, average)
	output[Stats.SPEED] = _calc_boost(Stats.SPEED, _speed_xp, levels, average)

	return output


func _calc_boost(stat: Stats, xp: float, levels: int, average: float) -> float:
	var actualXp := (xp / average) * MAX_STAT_POINTS

	var base := get_base_stat(stat) 
	var amount := int(round(actualXp)) * levels

	set_base_stat(stat, base + amount)

	var decimal: float = max(0, actualXp - float(int(actualXp)))
	MyLogger.append_battle_log(
			"StatBoost(%s): Amount(%d) = Xp(%.2f) * Scaling(%d) / Average(%.2f) * Levels(%d)" 
			% [Stats.keys()[stat], amount, xp, MAX_STAT_POINTS, average, levels]
		)
	MyLogger.append_battle_log("StatBoost(%s): Rollover(%0.2f) = Xp(%.2f) - IntXp(%d)" 
			% [Stats.keys()[stat], decimal, actualXp, int(actualXp)]
		)

	set_xp_stat(stat, decimal)
	return amount


func add_xp(xp: float) -> int:
	var levels := 0
	total_xp = int(total_xp + xp)

	while total_xp >= next_level_xp:
		total_xp -= next_level_xp
		levels += 1
		next_level_xp = 50 * (levels + 1)
	
	return levels


func serialize() -> Dictionary: 
	var output := super.serialize()
	output["hp_xp"] = _hp_xp
	output["melee_attack_xp"] = _melee_attack_xp
	output["melee_defense_xp"] = _melee_defense_xp
	output["ranged_attack_xp"] = _ranged_attack_xp
	output["ranged_defense_xp"] = _ranged_defense_xp
	output["speed_xp"] = _speed_xp
	output["total_xp"] = total_xp
	output["xp_threshold"] = next_level_xp
	return output


func deserialize(data: Dictionary) -> void: 
	super.deserialize(data)
	_hp_xp = data["hp_xp"]
	_melee_attack_xp = data["melee_attack_xp"]
	_melee_defense_xp = data["melee_defense_xp"]
	_ranged_attack_xp = data["ranged_attack_xp"]
	_ranged_defense_xp = data["ranged_defense_xp"]
	_speed_xp = data["speed_xp"]
	total_xp  = data["total_xp"]
	next_level_xp  = data["xp_threshold"]


static func get_next_xp_threshold(level: int) -> int:
	return 50 * level
