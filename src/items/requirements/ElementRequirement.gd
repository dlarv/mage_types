@tool
extends ItemRequirement 
class_name ElementRequirement 

@export var element: ElementalType 

# override
func check(actor: Variant) -> bool:
	if(actor is BaseCompanion):
		actor = actor.battle_actor
	if(actor is Player or actor is PhysicsPlayer):
		actor = actor.battle_actor
	return actor != null and (actor.element1 == element or actor.element2 == element)

func get_requirement_message() -> String:
	return "Either primary or secondary element must be %s." % element.name
