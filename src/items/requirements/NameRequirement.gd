@tool
extends ItemRequirement 
class_name NameRequirement 

@export var required_name: String

# override
func check(actor: Variant) -> bool:
	actor = _get_battle_actor(actor)
	return actor != null and actor.name == required_name

func get_requirement_message() -> String:
	return "Can only be learned by %s." % required_name
