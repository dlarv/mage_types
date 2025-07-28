extends Resource
class_name _BaseEffectSlot

const DataBuffer := Attack.DataBuffer
const Parser := preload("res://addons/attackeffectinspector/parser.gd")

enum EffectTarget { USER, TARGET, NOT_USER, USER_ONCE }

@export var effect_target: EffectTarget = EffectTarget.TARGET: set = _set_effect_target

@export var _chance: String:
	set(val):
		_chance = val
		if val.is_valid_float():
			chance = min(float(val), 1)
		else:
			chance = 0
	get:
		if _chance.is_empty():
			return str(chance)
		return _chance
var chance: float = 1:
	get:
		if chance != INF:
			return chance 
		if not get_chance:
			get_chance = Parser.parse(_chance)
		return get_chance.call()

## Callable | null
var get_chance: Variant

#virtual
func apply_effect(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> String:
	return ""

## If object is of type EffectSlot, returns itself.
## Otherwise, if object is of type ConditionalEffectSlot, return whichever Slot will activate.
func get_effect_slot(user: BattleActor=null, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0) -> EffectSlot:
	return null

func get_attack_effect(user: BattleActor=null, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0) -> _AttackEffect: return null

func _set_effect_target(val: EffectTarget) -> void:
	effect_target = val
