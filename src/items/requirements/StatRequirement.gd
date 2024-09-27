@tool
extends ItemRequirement 
class_name StatRequirement 

@export
var stat: BattleActor.Stats 
@export
var threshold: float 

# override
func check(actor):
	if(actor is BaseCompanion):
		actor = actor.battle_actor
	if(actor is Player):
		actor = actor.battle_actor
	return actor != null and actor.get_stat(stat) >= threshold

func get_requirement_message():
	return "%s stat must be %d or higher." % [BattleActor.Stats.keys()[stat], threshold]
