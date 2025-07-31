@tool
extends StatManager
class_name PlayerStatManager

const TRANSMUTATION_XP_UNIT := 0.3
# Since side effects don't boost HP, this value will let HP keep pace.
const HP_XP_BOOST := 0.3

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


func resolve_end_of_turn(unnormalizedValues: Array[float]) -> void:
	# Values drawn from design doc Roadmap#The List#Battle (BATT)#End Battle#Option 2
	# This is a gross way of doing this, but these values would need to be hardcoded somewhere.

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
	var amount := int(xp) * levels
	set_base_stat(stat, get_base_stat(stat) + amount)
	set_xp_stat(stat, max(0, xp - int(xp)))

	return amount


