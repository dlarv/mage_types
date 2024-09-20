@tool
extends AttackEffect 
class_name InstantHealthChange 

# override
func ApplyEffect(user, target=null, action=null):
	var health = target.Hp * Strength
	target.ApplyDamage(-health, false)
	var verb =  "lost"  if Strength < 0  else  "recovered"
	return "%s %s %d hp!" % [ user.ActorName, verb, health ]
