@tool
extends Resource 
class_name _AttackEffect 

const DataBuffer := Attack.DataBuffer

@export var name: String: set = _set_name
## Effectiveness of this effect, usually as a percentage of health.
@export var strength: float
@export_multiline var message: String = "": get = _get_message

var read_from_buffer: bool

# virtual
func apply_effect(user: BattleActor, target: BattleActor, buffer: DataBuffer=null, effectiveness:=1.0) -> String:
	return message.replace("{user}", user.name).replace("{target}", target.name)

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
