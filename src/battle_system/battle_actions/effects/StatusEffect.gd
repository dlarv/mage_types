@tool
extends _AttackEffect 
class_name StatusEffect 

@export var id: StatusEffectManager.StatusEffects: set = _set_status_effect
@export var duration: int 
@export var icon: PackedScene 
## The text displayed inside the MessageBox, etc.
@export_multiline var description: String 

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0):
	# if target == null or action == null: return name
	if target == null:
		target = user

	var dupe = duplicate()
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


func get_setup_potential(user: BattleActor, target: BattleActor) -> float:
	return 1


func _get_message() -> String:
	if name.contains("Phobic"):
		return "{target} is feeling adverse to [color={element}]{element}[/color]!"
	return message


func _set_status_effect(val: StatusEffectManager.StatusEffects) -> void:
	id = val
