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
			if effects[i].attack_effect is ElementalEffect \
					and effects[i].attack_effect.element.is_blank():
				effects[i].attack_effect = effects[i].attack_effect.duplicate()
				effects[i].attack_effect.element = element
				effects[i].attack_effect._element = _element

# override
func apply_effects(user: BattleActor, targets: Array) -> String:
	var msg := [super.apply_effects(user, targets)]
	var affinity := 1.0

	if cost > 0:
		affinity = apply_cost(user)

	for i in range(len(targets)):
		var target = targets[i]
		if affinity == 0:
			msg.append("%s's affinity for %s is empty! This attack had no effect!" 
					% [user.name, element.get_bb_code_name()])
			msg.append("%s received %d affinity from their struggle!" 
					% [user.name, user.get_affinity_for(element)])
			return "\n".join(msg)

		var rand = randf()
		if rand > affinity:
			msg.append("%s's affinity for %s is low! The power of this attack was weakened!" 
					% [user.name, element.get_bb_code_name()])
			Logger.append_log(Logger.LogType.BATTLE, 
					"Low %s affinity weakened the attack. Affinity(%f) < Rand(%f)" 
						% [element.name, affinity, rand])

		var missedMsg := ""
		var didDmg := false
		for effect in effects:
			if rand > affinity and not effect.attack_effect is Damage: 
				Logger.append_log(Logger.LogType.BATTLE, "Effect(%s) missed due to low affinity." 
						% effect.attack_effect.name)
				missedMsg = "The attack missed due to low affinity!"
				continue

			didDmg = true
			var msg2 = effect.apply_effect(user, target, self, affinity)
			if len(msg2) > 0:
				if effect.attack_effect is Damage \
						and effect.effect_target == Effect.EffectTarget.USER:
					msg.append("This attack has recoil!")
				msg.append("%s" % msg2)

				if effect.attack_effect is Damage and target.is_defeated:
					msg.append("........%s was defeated." % target.name)
					continue

		if not didDmg and len(missedMsg) > 0:
			msg.append(missedMsg)

	return "\n".join(msg)

# override
func is_action_available(actor: BattleActor) -> bool:
	return true
	# return actor.current_mana >= cost

# override
func apply_cost(user: BattleActor) -> float:
	return user.lose_affinity(element, cost)
