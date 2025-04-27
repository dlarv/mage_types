@tool
extends ItemRequirement 
class_name BiasRequirement 

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 

# override
func check(actor: Variant) -> bool:
	if(actor is BaseCompanion):
		actor = actor.battle_actor
	if(actor is Player or actor is PhysicsPlayer):
		actor = actor.battle_actor
	# If the bias is Blank, this acts like a wildcard.
	if element.is_blank():
		return actor != null and not actor.elemental_bias.is_blank()
	return actor != null and actor.elemental_bias == element

func get_requirement_message() -> String:
	if element == ElementManager.Blank:
		return "Must have an Elemental alignment."
	return "Must be %s-aligned." % element
