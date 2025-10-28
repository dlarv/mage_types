@tool
extends _AttackEffect 
class_name StatusEffect 

const StatusEffectManager := preload("res://src/battle_system/StatusEffectManager.gd")
const Effects := StatusEffectManager.StatusEffects

@export var id: Effects: set = _set_status_effect
@export var _duration: String:
	set(val):
		_duration = val
		initial_duration = Expression.new()
		if val.is_valid_float():
			initial_duration.parse(val)
		else:
			var err := initial_duration.parse(val, EXPRESSION_VARS)

			if err != OK:
				push_error(error_string(err))
var initial_duration: Expression
var duration: int 
@export var icon: PackedScene 
## The text displayed inside the MessageBox, etc.
@export_multiline var description: String 

# override
func apply_effect(data: ActorTurnData, target: BattleActor, effectiveness:=1.0) -> ActorTurnData:
	var user := data.user
	if target == null:
		target = user

	var dupe := duplicate()
	dupe.duration = get_duration(data.get_vars())
	if not target.add_status_effect(dupe): return data
	if id != Effects.STAT_CHANGE:
		data.new_status_effects.append([target, dupe])
	return super.apply_effect(data, target)


func is_expired() -> bool:
	return duration == 0


# virtual
func combine(a: StatusEffect) -> void:
	duration += a.duration


# virtual
func instantiate_icon() -> Node:
	if icon == null : return null
	return icon.instantiate()


func get_setup_potential(data: ActorTurnData, target: BattleActor, isFriendly: bool) -> float:
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


func get_duration(vars: Array=[]) -> int:
	return int(initial_duration.execute(vars))
