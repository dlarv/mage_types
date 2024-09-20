@tool
extends ItemRequirement 
class_name StatRequirement 

@export
var stat: BattleActor.Stats 
@export
var threshold: float 

# override
func Check(actor):
	if(actor is BaseCompanion):
		actor = actor.BattleActor
	if(actor is Player):
		actor = actor.BattleActor
	return actor != null and actor.GetStat(stat) >= threshold
