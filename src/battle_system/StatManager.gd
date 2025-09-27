@tool
extends Resource
class_name StatManager

enum Stats { ATTACK, MELEE_ATTACK, RANGED_ATTACK, DEFENSE, MELEE_DEFENSE, RANGED_DEFENSE, MELEE, RANGED, SPEED, EVASION, HP, CURRENT_HP  }

signal stat_changed(stat: StatusEffect, mod: float)
const BASE_MIN_MOD := 0.1
const BASE_MAX_MOD := 3.0

var MIN_MOD := 0.1
var MAX_MOD := 3.0

@export_category("Base Stats")
@export var _base_melee_attack: float = 10.0
@export var _base_ranged_attack: float = 10.0
@export var _base_melee_defense: float = 10.0
@export var _base_ranged_defense: float = 10.0
@export var _base_speed: float = 10.0
@export var _base_evasion: float = 100
@export var hp := 50.0:
	set(value):
		hp = value
		current_hp = value
var current_hp: float

var _melee_attack_mod: float = 1
var _ranged_attack_mod: float = 1
var _melee_defense_mod: float = 1
var _ranged_defense_mod: float = 1
var _speed_mod: float = 1
var _evasion_mod: float = 1

var melee_attack: float:
	get: return _get_value(_base_melee_attack, _melee_attack_mod)
var ranged_attack: float:
	get: return  _get_value(_base_ranged_attack, _ranged_attack_mod)
var melee_defense: float:
	get: return _get_value(_base_melee_defense, _melee_defense_mod)
var ranged_defense: float:
	get: return _get_value(_base_ranged_defense, _ranged_defense_mod)
var speed: float:
	get: return _get_value(_base_speed, _speed_mod)
var evasion: float:
	get: return _get_value(_base_evasion, _evasion_mod)

func _get_value(base: float, mod1: float) -> float:
	var output := base * clampf(mod1, MIN_MOD, MAX_MOD)
	# Output==0. its not a direct comparison b/c of float nonsense.
	if 1 / output == INF:
		output = 0.1
	return output

func get_stat(stat: Stats) -> float:
	match stat:
		Stats.MELEE_ATTACK: return melee_attack
		Stats.RANGED_ATTACK: return ranged_attack
		Stats.MELEE_DEFENSE: return melee_defense
		Stats.RANGED_DEFENSE: return ranged_defense
		Stats.SPEED: return speed
		Stats.EVASION: return evasion
		Stats.HP: return hp
		_: return -1

func set_base_stat(stat: Stats, val: float) -> void:
	match stat:
		Stats.MELEE_ATTACK: 
			_base_melee_attack = val
		Stats.RANGED_ATTACK: 
			_base_ranged_attack = val
		Stats.MELEE_DEFENSE: 
			_base_melee_defense = val
		Stats.RANGED_DEFENSE: 
			_base_ranged_defense = val
		Stats.SPEED: 
			_base_speed = val
		Stats.EVASION: 
			_base_evasion = val
		Stats.HP: 
			hp = val

func get_base_stat(stat: Stats) -> float:
	match stat:
		Stats.MELEE_ATTACK: return _base_melee_attack
		Stats.RANGED_ATTACK: return _base_ranged_attack
		Stats.MELEE_DEFENSE: return _base_melee_defense
		Stats.RANGED_DEFENSE: return _base_ranged_defense
		Stats.SPEED: return _base_speed
		Stats.EVASION: return _base_evasion
		Stats.HP: return hp 
		_: return -1

func raise_base_stat(stat: Stats, val: float) -> void:
	match stat:
		Stats.MELEE_ATTACK: 
			_base_melee_attack += val
		Stats.RANGED_ATTACK: 
			_base_ranged_attack += val
		Stats.MELEE_DEFENSE: 
			_base_melee_defense += val
		Stats.RANGED_DEFENSE: 
			_base_ranged_defense += val
		Stats.SPEED: 
			_base_speed += val
		Stats.EVASION: 
			_base_evasion += val
		Stats.HP: 
			hp += val

func mod_base_stat(stat: Stats, amount: float, minAmount:=0.0) -> void:
	match stat:
		Stats.MELEE_ATTACK: 
			_base_melee_attack = max(_base_melee_attack + amount, minAmount)
		Stats.RANGED_ATTACK: 
			_base_ranged_attack = max(_base_ranged_attack + amount, minAmount)
		Stats.MELEE_DEFENSE: 
			_base_melee_defense = max(_base_melee_defense + amount, minAmount)
		Stats.RANGED_DEFENSE: 
			_base_ranged_defense = max(_base_ranged_defense + amount, minAmount)
		Stats.SPEED: 
			_base_speed = max(_base_speed + amount, minAmount)
		Stats.EVASION: 
			_base_evasion = max(_base_evasion + amount, minAmount)

func reset_all() -> void:
	_melee_attack_mod = 1
	_ranged_attack_mod = 1
	_melee_defense_mod = 1
	_ranged_defense_mod = 1
	_speed_mod = 1
	_evasion_mod = 1

func reset(stat: Stats) -> void:
	match stat:
		Stats.MELEE_ATTACK:
			_melee_attack_mod = 1
		Stats.RANGED_ATTACK:
			_ranged_attack_mod = 1
		Stats.MELEE_DEFENSE:
			_melee_defense_mod = 1
		Stats.RANGED_DEFENSE:
			_ranged_defense_mod = 1
		Stats.SPEED:
			_speed_mod = 1
		Stats.EVASION:
			_evasion_mod = 1

func get_stat_mod(stat: Stats) -> float:
	match stat:
		Stats.ATTACK: return (_melee_attack_mod + _ranged_attack_mod) / 2.0
		Stats.DEFENSE: return (_melee_defense_mod + _ranged_defense_mod) / 2.0
		Stats.MELEE:  return (_melee_defense_mod + _melee_attack_mod) / 2.0
		Stats.RANGED:  return (_ranged_defense_mod + _ranged_attack_mod) / 2.0
		Stats.MELEE_ATTACK: return _melee_attack_mod
		Stats.RANGED_ATTACK: return _ranged_attack_mod
		Stats.MELEE_DEFENSE: return _melee_defense_mod
		Stats.RANGED_DEFENSE: return _ranged_defense_mod
		Stats.SPEED: return _speed_mod
		Stats.EVASION: return _evasion_mod
		_: return -1

func add(effect: StatChange, name: String) -> void:
	var mod: float = effect.get_strength()
	if effect.clear_first:
		reset(effect.stat)

	match effect.stat:
		Stats.MELEE_ATTACK: 
			_melee_attack_mod += mod
		Stats.RANGED_ATTACK: 
			_ranged_attack_mod += mod
		Stats.MELEE_DEFENSE: 
			_melee_defense_mod += mod
		Stats.RANGED_DEFENSE: 
			_ranged_defense_mod += mod
		Stats.SPEED: 
			_speed_mod += mod
		Stats.EVASION: 
			_evasion_mod += mod
		Stats.ATTACK: 
			_melee_attack_mod += mod
			_ranged_attack_mod += mod
		Stats.DEFENSE: 
			_melee_defense_mod += mod
			_ranged_defense_mod += mod
		Stats.MELEE: 
			_melee_attack_mod += mod
			_melee_defense_mod += mod
		Stats.RANGED: 
			_ranged_attack_mod += mod
			_ranged_defense_mod += mod

	var msg := "%s for %s. Base(%f) * Mod(%f) = %f%s"
	match effect.stat:
		StatManager.Stats.ATTACK:
			Logger.append_battle_log(msg % [
					effect.name, 
					name, 
					_base_melee_attack, 
					_melee_attack_mod, 
					melee_attack, 
					"(melee attack)"])
			Logger.append_battle_log(msg % [
						effect.name, 
						name, 
						_base_ranged_attack, 
						_ranged_attack_mod,
						ranged_attack,
						"(ranged attack)"])
			stat_changed.emit(StatManager.Stats.MELEE_ATTACK, get_stat_mod(StatManager.Stats.MELEE_ATTACK))
			stat_changed.emit(StatManager.Stats.RANGED_ATTACK, get_stat_mod(StatManager.Stats.RANGED_ATTACK))

		StatManager.Stats.DEFENSE:
			Logger.append_battle_log( msg % [
					effect.name,
					name,
					_base_melee_defense,
					_melee_defense_mod,
					melee_defense,
					"(melee defense)"])
			Logger.append_battle_log( msg % [
					effect.name,
					name,
					_base_ranged_defense,
					_ranged_defense_mod,
					ranged_defense,
					"(ranged defense)"])
			stat_changed.emit(StatManager.Stats.MELEE_DEFENSE, get_stat_mod(StatManager.Stats.MELEE_DEFENSE))
			stat_changed.emit(StatManager.Stats.RANGED_DEFENSE, get_stat_mod(StatManager.Stats.RANGED_DEFENSE))

		StatManager.Stats.MELEE:
			Logger.append_battle_log( msg % [
					effect.name,
					name,
					_base_melee_attack,
					_melee_attack_mod,
					melee_attack,
					"(melee attack)"])
			Logger.append_battle_log( msg % [
					effect.name,
					name,
					_base_melee_defense,
					_melee_defense_mod,
					melee_defense,
					"(melee defense)"])
			stat_changed.emit(StatManager.Stats.MELEE_ATTACK, get_stat_mod(StatManager.Stats.MELEE_ATTACK))
			stat_changed.emit(StatManager.Stats.MELEE_DEFENSE, get_stat_mod(StatManager.Stats.MELEE_DEFENSE))
		StatManager.Stats.RANGED:
			Logger.append_battle_log( msg % [
					effect.name,
					name,
					_base_ranged_attack,
					_ranged_attack_mod,
					ranged_attack,
					"(ranged attack)"])
			Logger.append_battle_log( msg % [
					effect.name,
					name,
					_base_ranged_defense,
					_ranged_defense_mod,
					ranged_defense,
					"(ranged defense)"])
			stat_changed.emit(StatManager.Stats.RANGED_ATTACK, get_stat_mod(StatManager.Stats.RANGED_ATTACK))
			stat_changed.emit(StatManager.Stats.RANGED_DEFENSE, get_stat_mod(StatManager.Stats.RANGED_DEFENSE))
		_:
			Logger.append_battle_log(msg % [
					effect.name,
					name,
					get_base_stat(effect.stat),
					get_stat_mod(effect.stat),
					get_stat(effect.stat),
					""])
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
