@tool
extends BattleAction 
class_name Attack 

@export var effects: Array[BaseEffect]
@export var cost: int 

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

			var msg3 = target.get_and_flush_msgs()
			if len(msg3) > 0:
				msg.append_array(msg3)

			if len(msg2) > 0:
				if effect.get_attack_effect() is Damage \
						and effect.effect_target == Effect.EffectTarget.USER:
					msg.append("This attack has recoil!")
				msg.append("%s" % msg2)

				if effect.get_attack_effect() is Damage and target.is_defeated:
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

# override
func get_attack_potential(user: BattleActor, target: BattleActor) -> Dictionary:
	var setupPotential := 0.0
	var dmg := 0

	for effect in effects:
		dmg += effect.attack_effect.get_dmg_potential(user, self, target)
		setupPotential += effect.attack_effect.get_setup_potential(user, target) * effect.chance
	return { 
		"setup": setupPotential,
		"dmg": dmg,
	}
