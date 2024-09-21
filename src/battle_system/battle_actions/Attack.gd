@tool
extends BattleAction 
class_name Attack 

@export
# Effect[]
var Effects: Array[Effect] = []
@export
var Cost : int 

# public static Attack Create(string name, ElementalType element, int power, int range, string description="") {
# 	Attack output = new Attack()
# 	output.Name = name
# 	output.Element = element
# 	output.Range = (AttackRange)range
# 	output.Details = description
# 	return output
# }

# override
func ApplyEffects(user, targets):
	var msg = super.ApplyEffects(user, targets)
	for i in range(len(targets)):
		var target = targets[i]

		for effect in Effects:
			var rand = randf_range(0.0, 1.0)

			if rand <= effect.Chance:
				msg += "\n%s" % [ effect.attack_effect.ApplyEffect(user, target, self) ]
				# Add status effect icon.
				if effect.attack_effect is Damage:
					# Check if character was defeated.
					if target.Defeated:
						msg += "........%s was defeated." % target.ActorName
						continue
	return msg

# override
func IsActionAvailable(actor):
	return actor.Mana >= Cost

# override
func ApplyCost(user):
	user.Mana -= Cost
