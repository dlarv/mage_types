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
