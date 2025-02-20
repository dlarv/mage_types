extends Resource
class_name AffinityManager

enum BonusReason { TRANSMUTATION, CONSECUTIVE, STRUGGLE, BIAS, ATTACK_EFFECT }

const OFFENSIVE_INDEX: int = 0
const DEFENSIVE_INDEX: int = 1

@export_category("Bonus values")
@export var TRANSMUTATION_BONUS: int = 1
## BONUS * #turns
@export var CONSECUTIVE_BONUS: int = 1
@export var STRUGGLE_BONUS: int = 2
@export var BIAS_BONUS: int = 2

@export_category("Affinity Values")
@export var initial_offensive_affinity := 100:
	set(value):
		affinities[OFFENSIVE_INDEX] = value
@export var initial_defensive_affinity := 100:
	set(value):
		affinities[DEFENSIVE_INDEX] = value

var affinities := [0, 0]
var _element_1: ElementalType
var _element_2: ElementalType
var _element_1_turn_counter := 0
var _element_2_turn_counter := 0 

func _init():
	ElementManager.force_load()
	affinities = [
		initial_offensive_affinity,
		initial_defensive_affinity,
	]

func gain_affinity(element: ElementalType, reason: BonusReason) -> int:
	if element.is_blank(): return 0
	var bonus := 0
	match(reason):
		BonusReason.TRANSMUTATION:
			bonus = TRANSMUTATION_BONUS
		BonusReason.CONSECUTIVE:
			if element == _element_1:
				bonus = CONSECUTIVE_BONUS * _element_1_turn_counter
			elif element == _element_2:
				bonus = CONSECUTIVE_BONUS * _element_2_turn_counter
		BonusReason.STRUGGLE:
			bonus = STRUGGLE_BONUS
		BonusReason.BIAS:
			bonus = BIAS_BONUS
	affinities[_map_key(element)] += bonus
	return bonus

func add_affinity(element: ElementalType, amount: int) -> void:
	affinities[_map_key(element)] += amount

func lose_affinity(element: ElementalType, amount: int) -> float:
	if element.is_blank(): return 1
	var index := _map_key(element)

	var prev = affinities[index]
	var affinity = affinities[index] - amount
	affinities[index] = max(0, affinity)

	if affinity == -amount:
		affinities[index] = STRUGGLE_BONUS
		return 0
	if affinity < 0:
		var output = float(prev) / float(amount)
		return output
	return 1

func set_element(id: int, element: ElementalType) -> int:
	if id == 0:
		_element_1 = element
		_element_1_turn_counter = 0
	else:
		_element_2 = element
		_element_2_turn_counter = 0
	var bonus := TRANSMUTATION_BONUS
	affinities[_map_key(element)] += bonus
	return bonus

func get_affinity(element: ElementalType) -> int:
	return affinities[_map_key(element)]

func get_current_offensive_affinity() -> int:
	return affinities[OFFENSIVE_INDEX]

func get_current_defensive_affinity() -> int:
	return affinities[DEFENSIVE_INDEX]

func get_base_offensive_affinity() -> int:
	return initial_offensive_affinity

func get_base_defensive_affinity() -> int:
	return initial_defensive_affinity

func _map_key(e: ElementalType) -> int:
	match e:
		ElementManager.Blue,ElementManager.Cyan, ElementManager.Yellow,ElementManager.Magenta:
			return DEFENSIVE_INDEX
		ElementManager.Red,ElementManager.Purple,ElementManager.Orange,ElementManager.Green,_:
			return OFFENSIVE_INDEX
