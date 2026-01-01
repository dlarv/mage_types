@tool
extends ItemRequirement 
class_name BiasRequirement 

@export var _element := ElementalType.ElementId.BLANK:
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.elements[int(value)]
var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 

# override
func check(actor: Variant) -> bool:
	actor = _get_battle_actor(actor)
	# If the bias is Blank, this acts like a wildcard.
	if element.is_blank():
		return actor != null and not actor.elemental_bias.is_blank()
	return actor != null and actor.elemental_bias == element

func get_requirement_message() -> String:
	if element == ElementManager.Blank:
		return "Must have an Elemental alignment."
	return "Must be %s-aligned." % element
