@tool
extends BattleAction 
class_name Attack 

@export
# Effect[]
var effects: Array[Effect]: 
	set(value):
		effects = value
		if not Engine.is_editor_hint():
			for effect in value:
				if effect.attack_effect is ElementalEffect:
					_needs_elemental_effect_override = true
@export var cost: int 

var _needs_elemental_effect_override = false

func elemental_effect_override(element: ElementalType) -> void:
	if not Engine.is_editor_hint():
		for i in range(len(effects)):
			if effects[i].attack_effect is ElementalEffect:
				effects[i].attack_effect = effects[i].attack_effect.duplicate()
				effects[i].attack_effect.element = element
				effects[i].attack_effect._element = _element


# override
func apply_effects(user: BattleActor, targets: Array) -> String:
	var msg := super.apply_effects(user, targets)
	for i in range(len(targets)):
		var target = targets[i]

		for effect in effects:
			var msg2 =effect.apply_effect(user, target, self)
			if len(msg2) > 0:
				msg += "\n%s" % msg2
				if effect.attack_effect is Damage:
					# Check if character was defeated.
					if target.is_defeated:
						msg += "........%s was defeated." % target.name
						continue
	return msg

# override
func is_action_available(actor: BattleActor) -> bool:
	return actor.current_mana >= cost

# override
func apply_cost(user: BattleActor) -> void:
	user.lose_affinity(element, cost)
