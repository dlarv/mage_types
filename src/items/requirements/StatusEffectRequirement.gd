@tool
extends ItemRequirement 
class_name StatusEffectRequirement 

@export var effect: StatusEffect

# override
func check(actor: Variant) -> bool:
	if(actor is BaseCompanion):
		actor = actor.battle_actor
	if(actor is Player or actor is PhysicsPlayer):
		actor = actor.battle_actor
	return actor != null and actor.has_status_effect(effect)

func get_requirement_message() -> String:
	return "Must have the %s status effect." % effect.get_full_name()
