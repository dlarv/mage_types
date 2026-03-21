@tool
extends Resource 
class_name BattleActor 

signal battle_setup_completed
signal battle_resolution_completed
@warning_ignore("unused_signal")
signal turn_ended()
signal was_just_defeated()
signal status_effect_added(effect: StatusEffect)
signal status_effects_removed(effects: Array[StatusEffect])
signal damage_applied(current_hp: float)
signal element_changed(id: int, element: ElementalType)
signal leveled_up()
signal spell_learned(spell: _BattleAction, index: int)
signal equipment_equipped(equipment: Equipment)
@warning_ignore("unused_signal")
## Called by the equipment directly
signal equipment_activated(equipment: Equipment)
signal status_activated(effect: StatusEffect, data: Variant)
## Called when opponents choose their action during battle.
@warning_ignore("unused_signal")
signal action_selected(action: _BattleAction)
@warning_ignore("unused_signal")
signal action_used(action: _BattleAction)

const StatusEffectManager := preload("res://src/battle_system/StatusEffectManager.gd")

@export var name := "Guy" 
## Positive for allies/pcs, negative for enemies, 0 for randomly generated.
@export var id := 0
@export var level := 1

@export_category("Stats")
var statuses := StatusEffectManager.new()
@export var stat_manager := StatManager.new()
var current_hp: int:
	set(value):
		stat_manager.current_hp = value
	get:
		return int(stat_manager.current_hp)
var hp: int = 200:
	set(value):
		stat_manager.hp = value
		current_hp = value
	get:
		return int(stat_manager.hp)
@export var reset_hp_after_battle := true

var speed: float:
	get: return stat_manager.speed
var evasion: float:
	get: return stat_manager.evasion

@export_category("General")
@export var _element1 := ElementalType.ElementId.BLANK:
	set(value):
		_element1 = value
		element1 = ElementManager.elements[int(value)]
var element1: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element1 = value 
		element_changed.emit(0, element1)

@export var _element2 := ElementalType.ElementId.BLANK:
	set(value):
		_element2 = value
		element2 = ElementManager.elements[int(value)]
var element2: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element2 = value 
		element_changed.emit(1, element2)
@export var alignment_manager: AlignmentManager = null
@export var _alignment := ElementalType.ElementId.BLANK:
	set(value):
		if alignment_manager:
			_alignment = alignment_manager.current_alignment.id
			return
		_alignment = value
		alignment = ElementManager.elements[int(value)]
var alignment: ElementalType = ElementManager.Blank:
	get:
		if alignment_manager: return alignment_manager.current_alignment
		return alignment
@export var attacks: Array[_BattleAction] = []
@export var equipment: Equipment = null:
	set(value):
		if not Engine.is_editor_hint() and equipment != null:
			equipment.unequip(self)
		equipment = value
		if not Engine.is_editor_hint() and value != null:
			equipment.equip(self)
		equipment_equipped.emit(value)

@export var sprite_path: PackedScene

var flinching: StatusEffect:
	get: return statuses.check_flinching()
var stasis: StatusEffect:
	get: return statuses.check_stasis()
var is_defeated: bool:
	get: return current_hp <= 0

var aleady_defeated: bool = false

var _msgs: Array[String] = []
var _func_overrides: Dictionary[StringName, Callable] = {}
var _override_output: Variant = null


func setup() -> void:
	if _try_call_override(setup.get_method(), []): 
		return
	battle_setup_completed.emit()


## Returns amount of damage dealt, if actor has phobia
func set_element(id: int, element: ElementalType) -> float:
	if id == 0:
		element1 = element
	else:
		element2 = element

	if alignment_manager:
		alignment_manager.append_unnormalized(element, AlignmentManager.Type.TRANSMUTATION)

	var effect := statuses.check_phobic(element)
	var output := 0
	if effect != null:
		var dmg := hp * effect.get_strength()
		MyLogger.append_battle_log("%s was hurt by its phobia! (%d damage)" % [ name, dmg ])

		output = apply_damage(int(dmg), false)
		status_activated.emit(effect, dmg)
	return output


func get_element(id: int) -> ElementalType:
	if id == 0:
		return element1
	return element2


func is_element(element: ElementalType) -> bool:
	return element1 == element or element2 == element


func get_stat(stat: StatManager.Stats) -> float:
	match stat:
		StatManager.Stats.HP:
			return hp
		StatManager.Stats.CURRENT_HP:
			return current_hp
	return stat_manager.get_stat(stat)


func set_stat(stat: Variant, amount: float) -> void:
	if (stat is int and stat == StatManager.Stats.HP) or (stat is String and stat.to_upper() == "HP"):
		hp = int(amount)
		current_hp = int(amount)
	elif (stat is int and stat == StatManager.Stats.CURRENT_HP) or (stat is String and stat.to_upper() == "CURRENT_HP"):
		current_hp = int(amount)
	else:
		if stat is String:
			stat = StatManager.Stats[stat]
		stat_manager.set_base_stat(stat, amount)

			
func get_attack_stat(action: _BattleAction) -> float:
	if _try_call_override(get_attack_stat.get_method(), [action]):
		return _override_output
	elif action.attack_range == _BattleAction.AttackRange.MELEE:
		return stat_manager.melee_attack
	return stat_manager.ranged_attack


func get_defense_stat(action: _BattleAction) -> float:
	if _try_call_override(get_defense_stat.get_method(), [action]):
		return _override_output
	elif action.attack_range == _BattleAction.AttackRange.MELEE:
		return stat_manager.melee_defense
	return stat_manager.ranged_defense


## Returns actual amount of damage applied, after accounting for status conditions.
func apply_damage(dmg: int, allowBlocking:=true, data: ActorTurnData=null) -> int:
	if _func_overrides.has(apply_damage.get_method()):
		return _func_overrides.get(apply_damage.get_method()).call(dmg, allowBlocking, data)

	if _try_call_override(_calc_blocking.get_method(), [dmg, allowBlocking, data]):
		dmg = _override_output
	else:
		dmg = _calc_blocking(dmg, allowBlocking, data)

	if not _try_call_override(_apply_dmg.get_method(), [dmg]):
		_apply_dmg(dmg)

	return dmg


func _calc_blocking(dmg: int, allowBlocking: bool, data: ActorTurnData) -> int: 
	var blocking: StatusEffect = null
	if dmg > 0 and allowBlocking:
		blocking = statuses.blocking

	if blocking:
		dmg = int(float(dmg) * (1.0 - blocking.get_strength()))

		statuses.remove_blocking()
		if data != null:
			data.add_activated_effect(self, blocking.id)
	return dmg


func _apply_dmg(dmg: int) -> void:
	if dmg != 0:
		current_hp -= dmg
		damage_applied.emit(current_hp)
		if current_hp <= 0 and not aleady_defeated:
			aleady_defeated = true
			was_just_defeated.emit()


func heal(dmg: int, allowOverflow: bool=false) -> int:
	if _try_call_override(heal.get_method(), [dmg, allowOverflow]):
		return _override_output

	current_hp += dmg
	if not allowOverflow:
		current_hp = min(current_hp, hp)

	damage_applied.emit(current_hp)

	return dmg


func add_status_effect(effect: StatusEffect) -> bool:
	if _try_call_override(add_status_effect.get_method(), [effect]):
		return _override_output
	else:
		MyLogger.append_battle_log("%s was applied to %s." % [ effect.name, name ])
		if effect is StatChange:
			stat_manager.add(effect, name)
		else:
			statuses.add(effect)
			status_effect_added.emit(statuses.get_status(effect))

	if alignment_manager and effect.id == StatusEffectManager.StatusEffects.PHOBIC:
		alignment_manager.add(effect.element, -1)

	return true


func remove_status_effect(effect: StatusEffect) -> void:
	MyLogger.append_battle_log("Actor(%s)'s StatusEffect(%s) was removed." % [ name, effect.name ])
	statuses.remove([effect])
	status_effects_removed.emit([ effect ])


func has_status_effect(effect: StatusEffect) -> bool:
	return statuses.has(effect)


func list_status_effects() -> Array[StatusEffect]:
	return statuses.list()


func resolve_end_of_turn(allies:=[], opponents:=[], data: ActorTurnData=null, useOverride:=true)-> void:
	if useOverride and _try_call_override(resolve_end_of_turn.get_method(), [allies, opponents]):
		return

	# Calc poison and healing.
	var poison := statuses.poison
	var healing := statuses.healing

	if poison > 0:
		data.activated_status_effects.append(StatusEffectManager.StatusEffects.POISON)
		_msgs.append("%s was hurt by poison (%d dmg)!" % [ name, poison * hp])

		# If apply_damage is after status_activated, then hp bar will not be able to react properly
		var dmg := int(hp * poison)
		apply_damage(dmg, false)
		status_activated.emit(statuses.statuses[StatusEffect.Effects.POISON], dmg)

	if healing > 0:
		data.activated_status_effects.append(StatusEffectManager.StatusEffects.HEALING)
		_msgs.append("%s recovered %d health!" % [ name, hp * healing])

		# If apply_damage is after status_activated, then hp bar will not be able to react properly
		var dmg := int(hp * -healing)
		apply_damage(dmg, false)
		status_activated.emit(statuses.statuses[StatusEffect.Effects.HEALING], dmg)

	var effects := statuses.calculate_expirations()
	for effect in effects:
		data.expired_status_effects.append(effect)
		_msgs.append("Status effects wore off! (%s)" % StatusEffectManager.StatusEffects.keys()[effect.id])

	status_effects_removed.emit(effects)


func resolve_end_of_battle(turnCounter: int) -> void:
	stat_manager.reset_all()
	statuses.clear()
	if reset_hp_after_battle: 
		current_hp = hp
	
	# Update alignment.
	var unnormalizedValues: Array[float] = []
	if alignment_manager and not alignment_manager.alignment_locked:
		MyLogger.append_battle_log("Normalizing and updating alignment for BattleActor(%s):" % name)
		unnormalizedValues = alignment_manager.normalize_and_add()

	if stat_manager is PlayerStatManager:
		stat_manager.boost_elemental_stats([element1, element2] as Array[ElementalType])
		stat_manager.resolve_end_of_turn(unnormalizedValues, turnCounter)

	is_defeated = false
	aleady_defeated = false

	battle_resolution_completed.emit()


func has_phobia(element: ElementalType=null) -> bool:
	# If value is null, return true if they have any phobias.
	if not element: return len(statuses.phobias) > 0
	return statuses.check_phobic(element) != null


func update_alignment() ->  Dictionary:
	if not alignment_manager: return {}
	var output := {}
	var maxElements := alignment_manager.update_current_alignment()
	var newCore: ElementalType
	if element1 in maxElements:
		newCore = element1
	else:
		newCore = maxElements.pick_random()

	if alignment_manager.alignment_locked:
		output["aligned"] = true
		output["element"] = newCore
		set_element(0, newCore)
	elif element1 != newCore:
		output["aligned"] = false
		output["element"] = newCore
		set_element(0, newCore)
	else:
		output["element"] = null

	return output


func serialize() -> Dictionary:
	var attackData := []
	for attack in attacks:
		attackData.append(attack.resource_path)
	var equipmentData := ""
	if equipment:
		equipmentData = equipment.resource_path
	
	var alignmentData := {}
	if alignment_manager:
		alignmentData = alignment_manager.serialize()

	return {
		"name": name,
		"level": level,
		"stats": stat_manager.serialize(),
		"hp": hp,
		"current_hp": current_hp,
		"element1": element1.name,
		"element2": element2.name,
		"alignment": alignmentData,
		"attacks": attackData,
		"equipment": equipmentData,
	}


func deserialize(data: Dictionary) -> void:
	if "name" in data:
		name = data["name"]
	if "level" in data:
		level = data["level"]
	if "stats" in data:
		stat_manager.deserialize(data["stats"])
	if "hp" in data:
		hp = data["hp"]
	if "current_hp" in data:
		current_hp = data["current_hp"]
	if "element1" in data:
		_element1 = data["element1"]
	if "element2" in data:
		_element2 = data["element2"]
	if "attacks" in data:
		attacks = []
		for d: String in data["attacks"]:
			attacks.append(ResourceLoader.load(d))
	if "equipment" in data:
		var d: String = data["equipment"]
		if not d.is_empty():
			equipment = ResourceLoader.load(d)
		else:
			equipment = null
	if "alignment" in data:
		if not alignment_manager:
			alignment_manager = AlignmentManager.new()
		alignment_manager.deserialize(data["alignment"])
	

## Func Override methods
func add_func_override(key: StringName, call: Callable) -> void:
	var i := call.get_argument_count()
	_func_overrides[key] = call


func remove_func_override(key: StringName) -> void:
	_func_overrides.erase(key)


func _try_call_override(n: StringName, args: Array[Variant]) -> bool:
	if not _func_overrides.has(n): return false
	_override_output = _func_overrides.get(n).callv(args)
	return true
