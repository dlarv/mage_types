@tool
extends ItemRequirement 
class_name StatRequirement 

@export var stat: StatManager.Stats 
@export var threshold: float 

# override
func check(actor: Variant) -> bool:
	if(actor is BaseCompanion):
		actor = actor.battle_actor
	if(actor is Player or actor is PhysicsPlayer):
		actor = actor.battle_actor
	return actor != null and actor.get_stat(stat) >= threshold

func get_requirement_message() -> String:
	return "%s stat must be %d or higher." % [StatManager.Stats.keys()[stat], threshold]
