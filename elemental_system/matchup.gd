extends Node
class_name Matchup

var element: ElementalType
var effect: ElementalEffect.Effect
var modifier: int
	
func _init( \
		element: ElementalType, \
		effect: ElementalEffect.Effect=ElementalEffect.Effect.NONE, \
		modifier: int=0):
	self.element = element
	self.effect = effect
	self.modifier = modifier

func is_empty() -> bool:
	return element == null
