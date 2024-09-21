@tool
extends Resource 
class_name AttackEffect 

@export
var Name : String 
## Chance this effect will trigger each turn.
@export_range(0, 1)
var Chance : float = 1
## Effectiveness of this effect, usually as a percentage of health.
@export
var Strength :float  
@export_multiline
var Message : String = ""

# virtual
func ApplyEffect(user, target=null, action=null):
	if target != null:
		return Message.replace("{user}", user.ActorName).replace("{target}", target.ActorName)
	else:
		return ""
