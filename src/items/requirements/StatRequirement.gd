@tool
extends ItemRequirement 
class_name StatRequirement 

@export var stat: StatManager.Stats 
@export var threshold: float 

# override
func check(actor: Variant) -> bool:
	actor = _get_battle_actor(actor)
	return actor != null and actor.get_stat(stat) >= threshold

func get_requirement_message() -> String:
	return "%s stat must be %d or higher." % [StatManager.Stats.keys()[stat], threshold]
