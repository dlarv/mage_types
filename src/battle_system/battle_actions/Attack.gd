@tool
extends BattleAction 
class_name Attack 

@export
# Effect[]
var effects: Array[Effect] = []
@export
var cost : int 

# override
func apply_effects(user, targets):
	var msg = super.apply_effects(user, targets)
	for i in range(len(targets)):
		var target = targets[i]

		for effect in effects:
			var rand = randf_range(0.0, 1.0)

			if rand <= effect.chance:
				msg += "\n%s" % [ effect.attack_effect.apply_effect(user, target, self) ]
				# Add status effect icon.
				if effect.attack_effect is Damage:
					# Check if character was defeated.
					if target.is_defeated:
						msg += "........%s was defeated." % target.name
						continue
	return msg

# override
func is_action_available(actor):
	return actor.mana >= cost

# override
func apply_cost(user):
	user.mana -= cost
