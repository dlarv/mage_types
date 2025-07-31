@tool
extends StatManager
class_name PlayerStatManager

const TRANSMUTATION_XP_UNIT := 0.3
# Since side effects don't boost HP, this value will let HP keep pace.
const HP_XP_BOOST := 0.3
## Percentage of current base stat. Upon level up, the stat boost will not be able to exceed this amount.
const LEVEL_UP_BOOST_MAX := 0.1
## Linear control to adjust how many stat points a player receives upon level up.
const LEVEL_UP_SCALING_FACTOR := 1.0
## If battle is completed within this number of turns, then give bonus stat xp.
const BLITZ_BONUS_THRESHOLD := 5

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
				_melee_attack_xp += effect.strength
				_ranged_attack_xp += effect.strength
			Stats.DEFENSE:
				_melee_defense_xp += effect.strength
				_ranged_defense_xp += effect.strength
			Stats.SPEED:
				_speed_xp += effect.strength


func resolve_end_of_turn(unnormalizedValues: Array[float], turns:=1) -> void:
	# Values drawn from design doc Roadmap#The List#Battle (BATT)#End Battle#Option 2
	# This is a gross way of doing this, but these values would need to be hardcoded somewhere.

	var blitzBonus: int = max(1, BLITZ_BONUS_THRESHOLD - turns)

	# Blue
	_hp_xp += unnormalizedValues[0] * TRANSMUTATION_XP_UNIT * blitzBonus + HP_XP_BOOST
	_melee_defense_xp += unnormalizedValues[0] * TRANSMUTATION_XP_UNIT * blitzBonus

	# Purple
	_melee_attack_xp += unnormalizedValues[1] * TRANSMUTATION_XP_UNIT * blitzBonus
	_ranged_attack_xp += unnormalizedValues[1] * TRANSMUTATION_XP_UNIT * blitzBonus
	_ranged_defense_xp += unnormalizedValues[1] * TRANSMUTATION_XP_UNIT * blitzBonus

	# Magenta
	_hp_xp += unnormalizedValues[2] * TRANSMUTATION_XP_UNIT * blitzBonus + HP_XP_BOOST
	_melee_defense_xp += unnormalizedValues[2] * TRANSMUTATION_XP_UNIT * blitzBonus

	# Red
	_hp_xp += unnormalizedValues[3] * TRANSMUTATION_XP_UNIT * blitzBonus + HP_XP_BOOST
	_melee_attack_xp += unnormalizedValues[3] * TRANSMUTATION_XP_UNIT * blitzBonus

	# Orange
	_ranged_attack_xp += unnormalizedValues[4] * TRANSMUTATION_XP_UNIT * blitzBonus
	_speed_xp += unnormalizedValues[4] * TRANSMUTATION_XP_UNIT * blitzBonus
	
	# Yellow
	_ranged_defense_xp += unnormalizedValues[5] * TRANSMUTATION_XP_UNIT * blitzBonus
	_speed_xp += unnormalizedValues[5] * TRANSMUTATION_XP_UNIT * blitzBonus

	# Green
	_melee_attack_xp += unnormalizedValues[6] * TRANSMUTATION_XP_UNIT * blitzBonus
	_ranged_attack_xp += unnormalizedValues[6] * TRANSMUTATION_XP_UNIT * blitzBonus
	_speed_xp += unnormalizedValues[6] * TRANSMUTATION_XP_UNIT * blitzBonus

	# Cyan
	_melee_defense_xp += unnormalizedValues[7] * TRANSMUTATION_XP_UNIT * blitzBonus
	_ranged_defense_xp += unnormalizedValues[7] * TRANSMUTATION_XP_UNIT * blitzBonus


func boost_elemental_stats(elements: Array[ElementalType]) -> void:
	var values: Array[float] = []
	values.resize(8)
	values.fill(0)

	for element in elements:
		var index: int = ElementManager.get_index_from_name(element.name)
		values[index] += 1.0 / TRANSMUTATION_XP_UNIT
	
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


func level_up(levels:=1) -> Dictionary[Stats, float]:
	var output: Dictionary[Stats, float] = {}

	output[Stats.HP] = _calc_boost(Stats.HP, _hp_xp, levels)
	output[Stats.MELEE_ATTACK] = _calc_boost(Stats.MELEE_ATTACK, _melee_attack_xp, levels)
	output[Stats.MELEE_DEFENSE] = _calc_boost(Stats.MELEE_DEFENSE, _melee_defense_xp, levels)
	output[Stats.RANGED_ATTACK] = _calc_boost(Stats.RANGED_ATTACK, _ranged_attack_xp, levels)
	output[Stats.RANGED_DEFENSE] = _calc_boost(Stats.RANGED_DEFENSE, _ranged_defense_xp, levels)
	output[Stats.SPEED] = _calc_boost(Stats.SPEED, _speed_xp, levels)

	return output


func _calc_boost(stat: Stats, xp: float, levels: int) -> float:
	var base := get_base_stat(stat) 
	var amount := int(min(xp, base * LEVEL_UP_BOOST_MAX)) * levels * LEVEL_UP_SCALING_FACTOR

	set_base_stat(stat, base + amount)

	var decimal := xp - int(xp)
	# Only half of whole number rolls over.
	var whole := int(xp) / 2.0
	# The higher xp is, the lower this value will be.
	Logger.append_battle_log(
			"StatBoost(%s): Amount(%0.2f) = min[Xp(%0.2f) , 10%%of(%0.2f)] * Levels(%d) * %0.2f" 
			% [Stats.keys()[stat], amount, xp, base, levels, LEVEL_UP_SCALING_FACTOR]
		)
	Logger.append_battle_log("StatBoost(%s): Rollover(%0.2f) = Xp(%0.2f) / 2" 
			% [Stats.keys()[stat], whole + decimal, xp]
		)

	set_xp_stat(stat, max(0, whole + decimal))
	return amount
