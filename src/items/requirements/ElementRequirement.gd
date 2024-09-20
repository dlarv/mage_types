@tool
extends ItemRequirement 
class_name ElementRequirement 

@export
var element: ElementalType ;

# override
func Check(actor):
	if(actor is BaseCompanion):
		actor = actor.BattleActor
	if(actor is Player):
		actor = actor.BattleActor
	return actor != null and (actor.Element1 == element or actor.Element2 == element);
