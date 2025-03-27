@tool
extends Resource
class_name StatManager

enum Stat { ATTACK, MELEE_ATTACK, RANGED_ATTACK, DEFENSE, MELEE_DEFENSE, RANGED_DEFENSE, SPEED, EVASION }

signal stat_changed(stat: StatusEffect, mod: float)
const BASE_MIN_MOD := 0.1
const BASE_MAX_MOD := 3.0

var MIN_MOD := 0.1
var MAX_MOD := 3.0

@export var _base_melee_attack: float = 100
@export var _base_ranged_attack: float = 100
@export var _base_melee_defense: float = 100
@export var _base_ranged_defense: float = 100
@export var _base_speed: float = 100
@export var _base_evasion: float = 100

var _attack_mod: float = 0
var _melee_attack_mod: float = 1
var _ranged_attack_mod: float = 1
var _defense_mod: float = 0
var _melee_defense_mod: float = 1
var _ranged_defense_mod: float = 1
var _speed_mod: float = 1
var _evasion_mod: float = 1

var melee_attack: float:
	get: return _get_value(_base_melee_attack, _melee_attack_mod, _attack_mod)
var ranged_attack: float:
	get: return  _get_value(_base_ranged_attack, _ranged_attack_mod, _attack_mod)
var melee_defense: float:
	get: return _get_value(_base_melee_defense, _melee_defense_mod, _defense_mod)
var ranged_defense: float:
	get: return _get_value(_base_ranged_defense, _ranged_defense_mod, _defense_mod)
var speed: float:
	get: return _get_value(_base_speed, _speed_mod)
var evasion: float:
	get: return _get_value(_base_evasion, _evasion_mod)

func _get_value(base: float, mod1: float, mod2:=0.0) -> float:
	var output = base * clampf(mod1 + mod2, MIN_MOD, MAX_MOD)
	# Output==0. its not a direct comparison b/c of float nonsense.
	if 1 / output == INF:
		output = 0.1
	return output

func get_stat(stat: Stat) -> float:
	match stat:
		Stat.MELEE_ATTACK: return melee_attack
		Stat.RANGED_ATTACK: return ranged_attack
		Stat.MELEE_DEFENSE: return melee_defense
		Stat.RANGED_DEFENSE: return ranged_defense
		Stat.SPEED: return speed
		Stat.EVASION: return evasion
		_: return -1

func set_base_stat(stat: Stat, val: float):
	match stat:
		Stat.MELEE_ATTACK: 
			_base_melee_attack = val
		Stat.RANGED_ATTACK: 
			_base_ranged_attack = val
		Stat.MELEE_DEFENSE: 
			_base_melee_defense = val
		Stat.RANGED_DEFENSE: 
			_base_ranged_defense = val
		Stat.SPEED: 
			_base_speed = val
		Stat.EVASION: 
			_base_evasion = val

func get_base_stat(stat: Stat) -> float:
	match stat:
		Stat.MELEE_ATTACK: return _base_melee_attack
		Stat.RANGED_ATTACK: return _base_ranged_attack
		Stat.MELEE_DEFENSE: return _base_melee_defense
		Stat.RANGED_DEFENSE: return _base_ranged_defense
		Stat.SPEED: return _base_speed
		Stat.EVASION: return _base_evasion
		_: return -1

func mod_base_stat(stat: Stat, amount: float, minAmount:=0.0) -> void:
	match stat:
		Stat.MELEE_ATTACK: 
			_base_melee_attack = max(_base_melee_attack + amount, minAmount)
		Stat.RANGED_ATTACK: 
			_base_ranged_attack = max(_base_ranged_attack + amount, minAmount)
		Stat.MELEE_DEFENSE: 
			_base_melee_defense = max(_base_melee_defense + amount, minAmount)
		Stat.RANGED_DEFENSE: 
			_base_ranged_defense = max(_base_ranged_defense + amount, minAmount)
		Stat.SPEED: 
			_base_speed = max(_base_speed + amount, minAmount)
		Stat.EVASION: 
			_base_evasion = max(_base_evasion + amount, minAmount)

func reset() -> void:
	_attack_mod = 0
	_defense_mod = 0
	_melee_attack_mod = 1
	_ranged_attack_mod = 1
	_melee_defense_mod = 1
	_ranged_defense_mod = 1
	_speed_mod = 1
	_evasion_mod = 1

func get_stat_mod(stat: Stat) -> float:
	match stat:
		Stat.ATTACK: return _attack_mod
		Stat.MELEE_ATTACK: return _melee_attack_mod + _attack_mod
		Stat.RANGED_ATTACK: return _ranged_attack_mod + _attack_mod
		Stat.DEFENSE: return _defense_mod
		Stat.MELEE_DEFENSE: return _melee_defense_mod + _defense_mod
		Stat.RANGED_DEFENSE: return _ranged_defense_mod + _defense_mod
		Stat.SPEED: return _speed_mod
		Stat.EVASION: return _evasion_mod
		_: return -1

func add(effect: StatChange, name: String) -> void:
	var mod = effect.get_mod()
	match effect.stat:
		Stat.ATTACK: _attack_mod += effect.get_mod()
		Stat.MELEE_ATTACK: _melee_attack_mod+= effect.get_mod()
		Stat.RANGED_ATTACK: _ranged_attack_mod+= effect.get_mod()
		Stat.DEFENSE: _defense_mod += effect.get_mod()
		Stat.MELEE_DEFENSE: _melee_defense_mod+= effect.get_mod()
		Stat.RANGED_DEFENSE: _ranged_defense_mod+= effect.get_mod()
		Stat.SPEED: _speed_mod += effect.get_mod()
		Stat.EVASION: _evasion_mod += effect.get_mod()

	var msg = "%s for %s. Base(%f) * Mod(%f) = %f%s"
	if effect.stat == StatManager.Stat.ATTACK:
		Logger.append_battle_log(msg % [effect.name, name, _base_melee_attack, _melee_attack_mod + _attack_mod, melee_attack, "(melee attack)"])
		Logger.append_battle_log(msg % [effect.name, name, _base_ranged_attack, _ranged_attack_mod + _attack_mod, ranged_attack, "(ranged attack)"])
		stat_changed.emit(effect.stat, get_stat_mod(StatManager.Stat.MELEE_ATTACK))
		stat_changed.emit(effect.stat, get_stat_mod(StatManager.Stat.RANGED_ATTACK))

	elif effect.stat == StatManager.Stat.DEFENSE:
		Logger.append_battle_log(
			msg % [effect.name, name, _base_melee_defense, _melee_defense_mod + _defense_mod, melee_defense, "(melee defense)"])
		Logger.append_battle_log(
			msg % [effect.name, name, _base_ranged_defense, _ranged_defense_mod + _defense_mod, ranged_defense, "(ranged defense)"])
		stat_changed.emit(effect.stat, get_stat_mod(StatManager.Stat.MELEE_DEFENSE))
		stat_changed.emit(effect.stat, get_stat_mod(StatManager.Stat.RANGED_DEFENSE))

	else:
		Logger.append_battle_log(
			msg % [effect.name, name, get_base_stat(effect.stat), get_stat_mod(effect.stat), get_stat(effect.stat), ""])
		stat_changed.emit(effect.stat, get_stat_mod(effect.stat))

func serialize() -> Dictionary: 
	return {
		"melee_attack": _base_melee_attack,
		"ranged_attack": _base_ranged_attack,
		"melee_defense": _base_melee_defense,
		"ranged_defense": _base_ranged_defense,
		"speed": _base_speed,
		"evasion": _base_evasion,
	}
func deserialize(data: Dictionary) -> void: 
	_base_melee_attack = data["melee_attack"]
	_base_ranged_attack = data["ranged_attack"]
	_base_melee_defense = data["melee_defense"]
	_base_ranged_defense = data["ranged_defense"]
	_base_speed = data["speed"]
	_base_evasion = data["evasion"]
