@tool
extends AttackEffect 
class_name StatusEffect 

@export var duration: int 
@export var icon: PackedScene 
## The text displayed inside the MessageBox, etc.
@export_multiline var description: String 

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: BattleAction=null):
	# if target == null or action == null: return name
	if target == null:
		target = user
	target.add_status_effect(duplicate())
	return super.apply_effect(user, target, action)


func is_expired() -> bool:
	return duration == 0

# virtual
func combine(a: StatusEffect) -> void:
	duration += a.duration

# virtual
func instantiate_icon() -> Node:
	if(icon == null): return null
	return icon.instantiate()
