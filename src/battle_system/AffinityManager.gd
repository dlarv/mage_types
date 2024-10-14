extends Resource
class_name AffinityManager

enum BonusReason { TRANSMUTATION, CONSECUTIVE, STRUGGLE, BIAS }

@export_category("Bonus values")
@export var TRANSMUTATION_BONUS: int = 1
## BONUS * #turns
@export var CONSECUTIVE_BONUS: int = 1
@export var STRUGGLE_BONUS: int = 2
@export var BIAS_BONUS: int = 2

@export_category("Affinity Values")
@export var initial_blue_affinity := 100
@export var initial_purple_affinity := 100
@export var initial_magenta_affinity := 100
@export var initial_red_affinity := 100
@export var initial_orange_affinity := 100
@export var initial_yellow_affinity := 100
@export var initial_green_affinity := 100
@export var initial_cyan_affinity := 100

@export_category("Bias Values")
@export var blue_threshold := 50
@export var purple_threshold := 50
@export var magenta_threshold := 50
@export var red_threshold := 50
@export var orange_threshold := 50
@export var yellow_threshold := 50
@export var green_threshold := 50
@export var cyan_threshold := 50

var affinities := {}
var _element_1: ElementalType
var _element_2: ElementalType
var _element_1_turn_counter := 0
var _element_2_turn_counter := 0 

func _init():
	ElementManager.force_load()
	affinities = {
		ElementManager.Blue: initial_blue_affinity,
		ElementManager.Purple: initial_purple_affinity,
		ElementManager.Magenta: initial_magenta_affinity,
		ElementManager.Red: initial_red_affinity,
		ElementManager.Orange: initial_orange_affinity,
		ElementManager.Yellow: initial_yellow_affinity,
		ElementManager.Green: initial_green_affinity,
		ElementManager.Cyan: initial_cyan_affinity,
	}

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
	affinities[element] += bonus
	return bonus

func lose_affinity(element: ElementalType, amount: int) -> float:
	var affinity = affinities[element] - amount
	affinities[element] = max(0, affinity)

	if affinities[element] == 1:
		affinities[element] = STRUGGLE_BONUS
		return 0
	if affinity < 0:
		return float(amount) / float(affinities[element])
	return 1

func set_element(id: int, element: ElementalType) -> int:
	if id == 0:
		_element_1 = element
		_element_1_turn_counter = 0
	else:
		_element_2 = element
		_element_2_turn_counter = 0
	var bonus := TRANSMUTATION_BONUS
	affinities[element] += bonus
	return bonus
