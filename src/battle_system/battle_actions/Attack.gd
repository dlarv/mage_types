@tool
extends _BattleAction 
class_name Attack 

const AttackType := AlignmentManager.Type

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
func apply_effects(user: BattleActor, targets: Array[BattleActor]) -> Dictionary:
	var msg: Array[String] = super.apply_effects(user, targets).msg
	if user.alignment_manager:
		user.alignment_manager.append_unnormalized(element, 1, AttackType.ATTACK)

	# Calculate accuracy.
	var rand := randf()
	if rand > accuracy:
		Logger.append_battle_log("Rand(%.2f) > Accuracy(%.2f)." % [ rand, accuracy ])
		msg.append("But it missed!")
		return { "msg": "\n".join(msg), "missed": true }

	var affinity := 0.8 
	if not user.element1.is_blank() and user.element1.is_defensive_type == element.is_defensive_type:
		Logger.append_battle_log("User(%s)'s primary Element(%s) has affinity for Attack.Element(%s)"
				% [user.name, user.element1, element])
		affinity += 0.2
	if not user.element2.is_blank() and user.element2.is_defensive_type == element.is_defensive_type: 
		Logger.append_battle_log("User(%s) secondary Element(%s) has affinity for Attack.Element(%s)"
				% [user.name, user.element2, element])
		affinity += 0.2

	Logger.append_battle_log("Affinity(%.2f)" % affinity)
	
	var delayedEffects: Array[_BaseEffectSlot]= []
	for i in len(targets):
		var target := targets[i]
		var didDmg := false

		for effect in effects:
			if effect.effect_target == _BaseEffectSlot.EffectTarget.NOT_USER and target == user: 
				continue
			elif effect.effect_target == _BaseEffectSlot.EffectTarget.USER_ONCE:
				if not effect in delayedEffects:
					delayedEffects.append(effect)
				continue

			didDmg = true
			var msg2 := effect.apply_effect(user, target, self, affinity)

			# Get equipment effect logs, etc.
			var msg3 := target.get_and_flush_msgs()
			if len(msg3) > 0:
				msg.append_array(msg3)

			if len(msg2) > 0:
				if effect.get_attack_effect(user, target, self) is Damage \
						and effect.effect_target == EffectSlot.EffectTarget.USER:
					msg.append("This attack has recoil!")
				msg.append("%s" % msg2)

				if effect.get_attack_effect() is Damage and target.is_defeated:
					msg.append("........%s was defeated." % target.name)
					continue
		
	for effect: _BaseEffectSlot in delayedEffects:
		var didDmg := true
		var msg2 := effect.apply_effect(user, user, self, affinity)

		# Get equipment effect logs, etc.
		var msg3 := user.get_and_flush_msgs()
		if len(msg3) > 0:
			msg.append_array(msg3)

		if len(msg2) > 0:
			if effect.get_attack_effect() is Damage:
				msg.append("This attack has recoil!")

				if user.is_defeated:
					msg.append("........%s was defeated." % effect.target.name)
					continue
		msg.append("%s" % msg2)


	return { "msg": msg }


# override
func is_action_available(actor: BattleActor) -> bool:
	return true
