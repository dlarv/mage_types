@tool
extends ItemRequirement 
class_name NameRequirement 

@export var required_name: String

# override
func check(actor: Variant) -> bool:
	if(actor is BaseCompanion):
		actor = actor.battle_actor
	if(actor is Player or actor is PhysicsPlayer):
		actor = actor.battle_actor
	return actor != null and actor.name == required_name

func get_requirement_message() -> String:
	return "Can only be learned by %s." % required_name
