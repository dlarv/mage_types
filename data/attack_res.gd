extends Resource
class_name Attack

@export var attack_name: String
@export var power: int
@export_enum("Melee", "Ranged")
var range: int

@export_enum("Red", "Green", "Blue", "Yellow", "Magenta", "Cyan", "Orange", "Purple", "Pink")
var _element: String:
	set(val):
		element =  MatchupManager.get_element_by_name(val)
var element: ElementalType

const DEFAULT_MELEE_ANIMATION = preload("res://data/attack_animations/basic_melee_animation.tscn")

func create(attack_name: String, element: ElementalType, power: int, range: int):
	self.attack_name = attack_name
	self.power = power
	self.range = range
	self.element = element

func get_tinted_animation():
	var output = DEFAULT_MELEE_ANIMATION.instantiate()
	output.modulate = element.color
	return output
