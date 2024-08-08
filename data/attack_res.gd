extends Resource
class_name Attack

enum AttackRange { MELEE, RANGED, SELF }

@export var attack_name: String
@export var power: int
@export var range: AttackRange

@export_enum("Red", "Green", "Blue", "Yellow", "Magenta", "Cyan", "Orange", "Purple", "Pink")
var _element: String:
	set(val):
		element =  MatchupManager.get_element_by_name(val)
var element: ElementalType

const DEFAULT_MELEE_ANIMATION = preload("res://data/attack_animations/basic_melee_animation.tscn")
const DEFAULT_RANGED_ANIMATION = preload("res://data/attack_animations/basic_ranged_animation.tscn")


func create(attack_name: String, element: ElementalType, power: int, range: AttackRange):
	self.attack_name = attack_name
	self.power = power
	self.range = range
	self.element = element

func get_tinted_animation():
	var output
	match range:
		Attack.AttackRange.MELEE:
			output = DEFAULT_MELEE_ANIMATION.instantiate()
		Attack.AttackRange.RANGED:
			output = DEFAULT_RANGED_ANIMATION.instantiate()
	output.modulate = element.color
	return output
