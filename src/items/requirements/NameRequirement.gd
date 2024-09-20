@tool
extends ItemRequirement 
class_name NameRequirement 

@export
var requiredName: String ;

# override
func Check(actor):
	if(actor is BaseCompanion):
		actor = actor.BattleActor
	if(actor is Player):
		actor = actor.BattleActor
	return actor != null and actor.ActorName == requiredName
