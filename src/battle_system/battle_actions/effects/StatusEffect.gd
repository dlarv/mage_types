@tool
extends AttackEffect 
class_name StatusEffect 

@export
var Duration : int 
@export
var Icon : PackedScene 
## The text displayed inside the MessageBox, etc.
@export_multiline
var Description : String 

# override
func ApplyEffect(user, target=null, action=null):
	if target == null or action == null: return Name

	target.AddStatusEffect(duplicate())
	return super.ApplyEffect(user, target, action)


func IsExpired():
	return Duration == 0

# virtual
func Combine(a):
	Duration += a.Duration

# virtual
func InstantiateIcon():
	if(Icon == null): return null
	return Icon.instantiate()
