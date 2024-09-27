@tool
extends AttackEffect 
class_name StatusEffect 

@export
var duration : int 
@export
var icon : PackedScene 
## The text displayed inside the MessageBox, etc.
@export_multiline
var description : String 

# override
func apply_effect(user, target=null, action=null, duplicated_effect=null):
	# if target == null or action == null: return name
	if target == null:
		target = user
	if duplicated_effect != null:
		target.add_status_effect(duplicated_effect)
	else:
		target.add_status_effect(duplicate())
	return super.apply_effect(user, target, action)


func is_expired():
	return duration == 0

# virtual
func combine(a):
	duration += a.duration

# virtual
func instantiate_icon():
	if(icon == null): return null
	return icon.instantiate()
