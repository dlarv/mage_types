@tool
extends _AttackEffect 
class_name StatusEffect 

@export var id: StatusEffectManager.StatusEffects: set = _set_status_effect
@export var duration: int 
@export var icon: PackedScene 
## The text displayed inside the MessageBox, etc.
@export_multiline var description: String 

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0) -> String:
	# if target == null or action == null: return name
	if target == null:
		target = user

	var dupe := duplicate()
	target.add_status_effect(dupe)
	return super.apply_effect(user, target, action)


func is_expired() -> bool:
	return duration == 0


# virtual
func combine(a: StatusEffect) -> void:
	duration += a.duration


# virtual
func instantiate_icon() -> Node:
	if icon == null : return null
	return icon.instantiate()


func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	var positiveEffect: int
	var doesNotHave := 0 if target.has_status_effect(self) else 1
	var bias: int
	match id:
		StatusEffectManager.StatusEffects.STASIS:
			positiveEffect = 1 if isFriendly else -1
			bias = 2 if target.has_phobia() else 0

		StatusEffectManager.StatusEffects.BLOCK: 
			positiveEffect = 1 if isFriendly else -1
			if float(target.current_hp) / float(target.hp) <= 0.5: bias = 2
			else: bias = 1
			# Don't worry about stacking.
			doesNotHave = 1

		StatusEffectManager.StatusEffects.POISON: 
			positiveEffect = -1 if isFriendly else 1
			if float(target.current_hp) / float(target.hp) > 0.5: bias = 2
			else: bias = 1

		StatusEffectManager.StatusEffects.HEALING: 
			positiveEffect = 1 if isFriendly else -1
			if float(target.current_hp) / float(target.hp) <= 0.5: bias = 2
			else: bias = 1

		StatusEffectManager.StatusEffects.FLINCH: 
			positiveEffect = -1 if isFriendly else 1

	return float(bias * positiveEffect * doesNotHave) / 2.0


func _get_message() -> String:
	if name.contains("Phobic"):
		return "{target} is feeling adverse to [el]{element}[/el]!"
	return message


func _set_status_effect(val: StatusEffectManager.StatusEffects) -> void:
	id = val
