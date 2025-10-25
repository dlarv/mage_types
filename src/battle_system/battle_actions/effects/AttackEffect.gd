@tool
extends Resource 
class_name _AttackEffect 

const DataBuffer := Attack.DataBuffer
const Parser := preload("res://addons/attackeffectinspector/parser.gd")
const EXPRESSION_VARS := ActorTurnData.EXPRESSION_VARS

# This value is written by Attack before any effects are applied.
static var current_buffer: DataBuffer = DataBuffer.new()

@export var name: String: set = _set_name
## Effectiveness of this effect, usually as a percentage of health.
@export var _strength: String:
	set(val):
		_strength = val
		strength = Expression.new()
		var err := strength.parse(val, EXPRESSION_VARS)

		if err != OK:
			push_error(error_string(err))
var strength: Expression

@export_multiline var message: String = "": get = _get_message

var buffer_map: Dictionary[String, Expression]

# virtual
func apply_effect(data: ActorTurnData, target: BattleActor, effectiveness:=1.0) -> ActorTurnData:
	return data

# virtual
func get_dmg_potential(data: ActorTurnData, target: BattleActor, isFriendly: bool) -> int:
	return 0


# override
func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	return 0


func _get_message() -> String:
	return message


func _set_name(val: String) -> void:
	name = val
	resource_name = val


func get_strength(vars: Array=[]) -> float:
	return strength.execute(vars)
