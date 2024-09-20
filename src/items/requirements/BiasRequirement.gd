@tool
extends ItemRequirement 
class_name BiasRequirement 

@export
var element: ElementalType ;

# override
func Check(actor):
	if(actor is BaseCompanion):
		actor = actor.BattleActor
	if(actor is Player):
		actor = actor.BattleActor
	return actor != null && actor.ElementalBias == element;
