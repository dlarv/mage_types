@tool
extends ItemRequirement 
class_name NameRequirement 

@export
var required_name: String ;

# override
func check(actor):
	if(actor is BaseCompanion):
		actor = actor.battle_actor
	if(actor is Player):
		actor = actor.battle_actor
	return actor != null and actor.name == required_name
