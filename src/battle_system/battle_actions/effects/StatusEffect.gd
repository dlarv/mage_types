@tool
extends _AttackEffect 
class_name StatusEffect 

const StatusEffectManager := preload("res://src/battle_system/StatusEffectManager.gd")
const Effects := StatusEffectManager.StatusEffects

@export var id: Effects: set = _set_status_effect
@export var _duration: String:
	set(val):
		_duration = val
		if val.is_valid_float():
			duration = int(val)
		else:
			duration = int(-INF)
	get:
		if _duration.is_empty():
			return str(duration)
		return _duration
var duration: int:
	get:
		if duration != int(-INF):
			return duration
		if not buffer_map.has("duration"):
			buffer_map["duration"] = Parser.parse(_strength)
		return buffer_map["duration"].call()
@export var icon: PackedScene 
## The text displayed inside the MessageBox, etc.
@export_multiline var description: String 

# override
func apply_effect(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> String:
	# if target == null or action == null: return name
	if target == null:
		target = user

	var dupe := duplicate()
	target.add_status_effect(dupe)
	return super.apply_effect(user, target)


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
		Effects.STASIS:
			positiveEffect = 1 if isFriendly else -1
			bias = 2 if target.has_phobia() else 0

		Effects.BLOCK: 
			positiveEffect = 1 if isFriendly else -1
			if float(target.current_hp) / float(target.hp) <= 0.5: bias = 2
			else: bias = 1
			# Don't worry about stacking.
			doesNotHave = 1

		Effects.POISON: 
			positiveEffect = -1 if isFriendly else 1
			if float(target.current_hp) / float(target.hp) > 0.5: bias = 2
			else: bias = 1

		Effects.HEALING: 
			positiveEffect = 1 if isFriendly else -1
			if float(target.current_hp) / float(target.hp) <= 0.5: bias = 2
			else: bias = 1

		Effects.FLINCH: 
			positiveEffect = -1 if isFriendly else 1

	return float(bias * positiveEffect * doesNotHave) / 2.0


func _get_message() -> String:
	if name.contains("Phobic"):
		return "{target} is feeling adverse to [el]{element}[/el]!"
	return message


func _set_status_effect(val: Effects) -> void:
	id = val
