@tool
extends Resource 
class_name _AttackEffect 

const DataBuffer := Attack.DataBuffer
# This value is written by Attack before any effects are applied.
static var current_buffer: DataBuffer

@export var name: String: set = _set_name
## Effectiveness of this effect, usually as a percentage of health.
@export var _strength: String:
	set(val):
		_strength = val
		if val.is_valid_float():
			strength = float(val)
	get:
		if _strength.is_empty():
			return str(strength)
		return _strength
var strength: float:
	get:
		if read_from_buffer and buffer_map.has("strength"):
			return buffer_map["strength"].call(current_buffer)
		return strength


@export_multiline var message: String = "": get = _get_message

var read_from_buffer: bool
var buffer_map: Dictionary[String, Callable]

# virtual
func apply_effect(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> String:
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
