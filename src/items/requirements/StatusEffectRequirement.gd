@tool
extends ItemRequirement 
class_name StatusEffectRequirement 

@export var effect: StatusEffect

# override
func check(actor: Variant) -> bool:
	actor = _get_battle_actor(actor)
	return actor != null and actor.has_status_effect(effect)

func get_requirement_message() -> String:
	return "Must have the %s status effect." % effect.name
