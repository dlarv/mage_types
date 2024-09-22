@tool
extends ItemRequirement 
class_name BiasRequirement 

@export
var element: ElementalType ;

# override
func check(actor):
	if(actor is BaseCompanion):
		actor = actor.battle_actor
	if(actor is Player):
		actor = actor.battle_actor
	return actor != null && actor.elemental_bias == element;
