@tool
extends Resource 
class_name AttackEffect 

@export var name: String 
## Chance this effect will trigger each turn.
@export_range(0, 1) var chance: float = 1
## Effectiveness of this effect, usually as a percentage of health.
@export var strength: float  
@export_multiline var message: String = ""

# virtual
func apply_effect(user: BattleActor, target: BattleActor=null, action: BattleAction=null, effectiveness:=1.0, element:ElementalType=ElementManager.Blank):
	if target != null:
		return message.replace("{user}", user.name).replace("{target}", target.name)
	return ""

# virtual
func get_dmg_potential(user: BattleActor, action: BattleAction, target: BattleActor) -> int:
	return 0

func get_full_name() -> String:
	return name
