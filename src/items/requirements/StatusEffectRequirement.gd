@tool
extends ItemRequirement 
class_name StatusEffectRequirement 

@export
var effect: StatusEffect

# override
func check(actor):
	if(actor is BaseCompanion):
		actor = actor.battle_actor
	if(actor is Player):
		actor = actor.battle_actor
	return actor != null and actor.has_status_effect(effect)

func get_requirement_message():
	return "Must have the %s status effect." % effect.get_full_name()
