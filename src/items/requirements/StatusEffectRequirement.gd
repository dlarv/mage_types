@tool
extends ItemRequirement 
class_name StatusEffectRequirement 

@export
var effect: StatusEffect

# override
func Check(actor):
	if(actor is BaseCompanion):
		actor = actor.BattleActor
	if(actor is Player):
		actor = actor.BattleActor
	return actor != null and actor.HasStatusEffect(effect)
