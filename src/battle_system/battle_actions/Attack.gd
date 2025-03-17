@tool
extends _BattleAction 
class_name Attack 

@export var effects: Array[_BaseEffectSlot]

# override
func apply_effects(user: BattleActor, targets: Array) -> String:
	var msg := [super.apply_effects(user, targets)]

	var affinity := 0.5 
	if not user.element1.is_blank() and user.element1.is_defensive_type == element.is_defensive_type:
		Logger.append_log(Logger.LogType.BATTLE, "User(%s)'s primary Element(%s) has affinity for Attack.Element(%s)"
				% [user.name, user.element1.name, element.name])
		affinity *= 2.0
	if not user.element2.is_blank() and user.element2.is_defensive_type == element.is_defensive_type: 
		Logger.append_log(Logger.LogType.BATTLE, "User(%s) secondary Element(%s) has affinity for Attack.Element(%s)"
				% [user.name, user.element2.name, element.name])
		affinity *= 2.0

	Logger.append_log(Logger.LogType.BATTLE, "Affinity(%.2f)" % affinity)
	

	for i in range(len(targets)):
		var target = targets[i]
		var missedMsg := ""
		var didDmg := false

		for effect in effects:
			didDmg = true
			var msg2 = effect.apply_effect(user, target, self, affinity)

			var msg3 = target.get_and_flush_msgs()
			if len(msg3) > 0:
				msg.append_array(msg3)

			if len(msg2) > 0:
				if effect.get_attack_effect() is Damage \
						and effect.effect_target == EffectSlot.EffectTarget.USER:
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
