@tool
extends _BattleAction 
class_name Attack 

const AttackType := AlignmentManager.Type
const POOR_AFFINITY_THRESHOLD := 0.5
const WEAK_AFFINITY_THRESHOLD := 0.8
const GOOD_AFFINITY_THRESHOLD := 1.0
const GREAT_AFFINITY_THRESHOLD := 1.2

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
func apply_effects(data: ActorTurnData) -> ActorTurnData:
	# var buffer := DataBuffer.new(self)
	# _AttackEffect.current_buffer = buffer
	var user := data.user
	var targets := data.targets

	super.apply_effects(data)

	# Calculate alignments, if necessary.
	if user.alignment_manager:
		user.alignment_manager.append_unnormalized(element, AttackType.CHANNELING)

	for actor: BattleActor in targets:
		if actor.alignment_manager:
			actor.alignment_manager.append_unnormalized(element, AttackType.ATTACK)

	# Calculate accuracy.
	var rand := randf()
	if rand > accuracy:
		data.missed = true
		Logger.append_battle_log("Rand(%.2f) > Accuracy(%.2f)." % [ rand, accuracy ])
		return data

	var affinity := calculate_affinity(user)
	data.effectiveness = affinity
	Logger.append_battle_log("Affinity(%.2f)" % affinity)
	
	var delayedEffects: Array[_BaseEffectSlot] = []
	for i in len(targets):
		var target := targets[i]
		data.add_actor(target)

		for slot in effects:
			if slot.effect_target == _BaseEffectSlot.EffectTarget.NOT_USER and target == user: 
				continue
			elif slot.effect_target == _BaseEffectSlot.EffectTarget.USER_ONCE:
				if not slot in delayedEffects:
					delayedEffects.append(slot)
				continue

			slot.apply_effect(data, target, affinity)

		
	for effect: _BaseEffectSlot in delayedEffects:
		effect.apply_effect(data, user, affinity)

	return data


func calculate_affinity(user: BattleActor) -> float:
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
	return affinity


# override
func is_action_available(actor: BattleActor) -> bool:
	return true
