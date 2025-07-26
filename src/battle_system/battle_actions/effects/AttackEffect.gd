@tool
extends Resource 
class_name _AttackEffect 

@export var name: String: set = _set_name
## Effectiveness of this effect, usually as a percentage of health.
@export var strength: float
@export_multiline var message: String = "": get = _get_message

# virtual
func apply_effect(user: BattleActor, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0) -> String:
	if target != null:
		return message.replace("{user}", user.name).replace("{target}", target.name)
	return ""

# virtual
func get_dmg_potential(user: BattleActor, target: BattleActor, isFriendly: bool, action: _BattleAction) -> int:
	return 0


# override
func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	return 0


func _get_message() -> String:
	return message


func _set_name(val: String) -> void:
	name = val
	resource_name = val

