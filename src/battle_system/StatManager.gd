@tool
extends Resource
class_name StatManager

enum Stat { ATTACK, MELEE_ATTACK, RANGED_ATTACK, DEFENSE, MELEE_DEFENSE, RANGED_DEFENSE, SPEED, EVASION }

signal stat_changed(stat, mod)

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
	get: return _base_melee_attack * (_melee_attack_mod + _attack_mod)
var ranged_attack: float:
	get: return  _base_ranged_attack * (_ranged_attack_mod + _attack_mod)
var melee_defense: float:
	get: return _base_melee_defense * (_melee_defense_mod + _defense_mod)
var ranged_defense: float:
	get: return _base_ranged_defense * (_ranged_defense_mod + _defense_mod)
var speed: float:
	get: return _base_speed * _speed_mod
var evasion: float:
	get: return _base_evasion * _evasion_mod

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

func add(effect: StatChange, name: String):
	var mod = effect.get_mod()
	match effect.stat:
		Stat.ATTACK: _attack_mod += effect.get_mod()
		Stat.MELEE_ATTACK: _melee_attack_mod += effect.get_mod()
		Stat.RANGED_ATTACK: _ranged_attack_mod += effect.get_mod()
		Stat.DEFENSE: _defense_mod += effect.get_mod()
		Stat.MELEE_DEFENSE: _melee_defense_mod += effect.get_mod()
		Stat.RANGED_DEFENSE: _ranged_defense_mod += effect.get_mod()
		Stat.SPEED: _speed_mod += effect.get_mod()
		Stat.EVASION: _evasion_mod += effect.get_mod()

	var msg = "%s for %s. Base(%f) * Mod(%f) = %f%s"
	if effect.stat == StatManager.Stat.ATTACK:
		Logger.append_log(Logger.LogType.BATTLE, 
			msg % [effect.name, name, _base_melee_attack, _melee_attack_mod, melee_attack, "(melee attack)"])
		Logger.append_log(Logger.LogType.BATTLE, 
			msg % [effect.name, name, _base_ranged_attack, _ranged_attack_mod, ranged_attack, "(ranged attack)"])
		stat_changed.emit(effect.stat, get_stat_mod(StatManager.Stat.MELEE_ATTACK))
		stat_changed.emit(effect.stat, get_stat_mod(StatManager.Stat.RANGED_ATTACK))

	elif effect.stat == StatManager.Stat.DEFENSE:
		Logger.append_log(Logger.LogType.BATTLE, 
			msg % [effect.name, name, _base_melee_defense, _melee_defense_mod, melee_defense, "(melee defense)"])
		Logger.append_log(Logger.LogType.BATTLE, 
			msg % [effect.name, name, _base_ranged_defense, _ranged_defense_mod, ranged_defense, "(ranged defense)"])
		stat_changed.emit(effect.stat, get_stat_mod(StatManager.Stat.MELEE_DEFENSE))
		stat_changed.emit(effect.stat, get_stat_mod(StatManager.Stat.RANGED_DEFENSE))

	else:
		Logger.append_log(Logger.LogType.BATTLE, 
			msg % [effect.name, name, get_base_stat(effect.stat), get_stat_mod(effect.stat), get_stat(effect.stat), ""])
		stat_changed.emit(effect.stat, get_stat_mod(effect.stat))
