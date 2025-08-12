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

## No Match/Affinity/Match/Double Match[br]
## No Match: %power when user.element1 NOR user.element2 == action.element[br]
## Affinity: %power when either user.element1 OR user.element2 == action.element.affinity[br]
## Match: %power when either user.element1 OR user.element2 == action.element[br]
## Double Match: %power when user.element1 AND user.element2 == action.element[br]
## If value == -1, then value will be hidden in the UI.
@export var scaling_factor := Vector4i(100, 100, 100, -1)

# override
func apply_effects(user: BattleActor, targets: Array[BattleActor]) -> Dictionary:
	var buffer := DataBuffer.new(self)
	_AttackEffect.current_buffer = buffer

	var msg: Array[String] = super.apply_effects(user, targets).msg

	# Calculate alignments, if necessary.
	if user.alignment_manager:
		user.alignment_manager.append_unnormalized(element, AttackType.CHANNELING)

	for actor: BattleActor in targets:
		if actor.alignment_manager:
			actor.alignment_manager.append_unnormalized(element, AttackType.ATTACK)

	# Calculate accuracy.
	var rand := randf()
	if rand > accuracy:
		Logger.append_battle_log("Rand(%.2f) > Accuracy(%.2f)." % [ rand, accuracy ])
		msg.append("But it missed!")
		return { "msg": "\n".join(msg), "missed": true }

	var affinity: float = scaling_factor.x
	if scaling_factor.w > -1 and user.element1 == element and user.element2 == element:
		Logger.append_battle_log("User(%s) elements both match Attack.Element(%s)" 
			% [user.name, element])
		affinity = scaling_factor.w
	elif user.element1 == element or user.element2 == element:
		Logger.append_battle_log("User(%s) typing matches Attack.Element(%s)" 
			% [user.name, element])
		affinity = scaling_factor.z
	elif user.element1.in_same_affinity_group(element) or user.element2.in_same_affinity_group(element):
		Logger.append_battle_log("User(%s)'s typing has affinity for Attack.Element(%s)"
				% [user.name, element])
		affinity = scaling_factor.y
	affinity /= 100
	Logger.append_battle_log("Affinity(%.2f)" % affinity)
	
	var delayedEffects: Array[_BaseEffectSlot] = []
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
			var msg2 := effect.apply_effect(user, target, affinity)

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
		var msg2 := effect.apply_effect(user, user, affinity)

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


