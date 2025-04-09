@tool
extends _BattleAction 
class_name Attack 

@export var effects: Array[_BaseEffectSlot]
@export_range(0, 1) var accuracy := 1.0

## This is a helper property which should be set manually.
@export var power := -1:
	get:
		if power >= 0: return power
		if attack_range == AttackRange.STATUS: return 0

		var total := 0
		var count := 0
		for slot in effects:
			if slot is EffectSlot and slot.attack_effect is Damage:
				total += slot.attack_effect.strength
				count += 1
			elif slot is ConditionalEffect:
				if slot.success_effect and slot.success_effect.attack_effect is Damage:
					total += slot.success_effect.attack_effect.strength
					count += 1

				if slot.failed_effect and slot.failed_effect.attack_effect is Damage:
					total += slot.failed_effect.attack_effect.strength
					count += 1
		return int(float(total) / float(count))


# override
func apply_effects(user: BattleActor, targets: Array) -> Dictionary:
	var msg := [super.apply_effects(user, targets).msg]

	# Calculate accuracy.
	var rand := randf()
	if rand > accuracy:
		Logger.append_battle_log("Rand(%.2f) > Accuracy(%.2f)." % [ rand, accuracy ])
		msg.append("But it missed!")
		return { "msg": "\n".join(msg), "missed": true }

	var affinity := 0.8 
	if not user.element1.is_blank() and user.element1.is_defensive_type == element.is_defensive_type:
		Logger.append_battle_log("User(%s)'s primary Element(%s) has affinity for Attack.Element(%s)"
				% [user.name, user.element1.name, element.name])
		affinity += 0.2
	if not user.element2.is_blank() and user.element2.is_defensive_type == element.is_defensive_type: 
		Logger.append_battle_log("User(%s) secondary Element(%s) has affinity for Attack.Element(%s)"
				% [user.name, user.element2.name, element.name])
		affinity += 0.2

	Logger.append_battle_log("Affinity(%.2f)" % affinity)
	
	for i in range(len(targets)):
		var target = targets[i]
		var didDmg := false

		for effect in effects:
			didDmg = true
			var msg2 = effect.apply_effect(user, target, self, affinity)

			# Get equipment effect logs, etc.
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

	return { "msg": "\n".join(msg) }

# override
func is_action_available(actor: BattleActor) -> bool:
	return true

# override
func get_attack_potential(user: BattleActor, target: BattleActor) -> Dictionary:
	var setupPotential := 0.0
	var dmg := 0

	for effect in effects:
		dmg += effect.get_attack_effect().get_dmg_potential(user, self, target)
		setupPotential += effect.get_attack_effect().get_setup_potential(user, target) * effect.chance
	return { 
		"setup": setupPotential,
		"dmg": dmg,
	}
