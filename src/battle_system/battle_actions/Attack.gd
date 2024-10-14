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
	var msg := [super.apply_effects(user, targets)]
	var affinity := apply_cost(user)

	for i in range(len(targets)):
		var target = targets[i]
		var rand = randf_range(0, 1)
		if rand > affinity:
			msg.append("%s's affinity for %s is low! The effectiveness of this attack was weakened!" % [user.name, element.get_bb_code_name()])
			Logger.append_log(Logger.LogType.BATTLE, "Low %s affinity weakened the attack. Affinity(%f) < Rand(%f)" % [element.name, affinity, rand])

		for effect in effects:
			if rand > affinity and not effect.attack_effect is Damage: 
				Logger.append_log(Logger.LogType.BATTLE, "Effect(%s) missed due to low affinity." % effect.attack_effect.name)
				continue

			var msg2 = effect.apply_effect(user, target, self, affinity)
			if len(msg2) > 0:
				msg.append("%s" % msg2)

				if effect.attack_effect is Damage and target.is_defeated:
					msg.append("........%s was defeated." % target.name)
					continue
	return "\n".join(msg)

# override
func is_action_available(actor: BattleActor) -> bool:
	return actor.current_mana >= cost

# override
func apply_cost(user: BattleActor) -> float:
	return user.lose_affinity(element, cost)
