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
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element1: String = "blue":
	set(value):
		_element1 = value
		element1 = ElementManager.get_element_from_name(value)
var element1 : ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element1 = value 
		element_changed.emit(0, element1)

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element2: String = "blank":
	set(value):
		_element2 = value
		element2 = ElementManager.get_element_from_name(value)
var element2: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element2 = value 
		element_changed.emit(1, element2)
@export var alignment_manager: AlignmentManager = null
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _alignment: String = "blank":
	set(value):
		if alignment_manager:
			_alignment = alignment_manager.current_alignment.name.to_lower()
			return
		_alignment = value
		alignment = ElementManager.get_element_from_name(value)
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

func setup() -> void:
	if _func_overrides.has(setup.get_method()):
		_func_overrides.get(setup.get_method()).call()
		return
	battle_setup_completed.emit()


## Returns amount of damage dealt, if actor has phobia
func set_element(id: int, element: ElementalType) -> float:
	if id == 0:
		element1 = element
	else:
		element2 = element

	element_changed.emit(id, element)
	if alignment_manager:
		alignment_manager.append_unnormalized(element, AlignmentManager.Type.TRANSMUTATION)

	var effect := statuses.check_phobic(element)
	var output := 0
	if effect != null:
		var dmg := hp * effect.get_strength()
		Logger.append_battle_log("%s was hurt by its phobia! (%d damage)" % [ name, dmg ])

		output = apply_damage(int(dmg), false)
		status_activated.emit(effect, dmg)
	return output


func get_element(id: int) -> ElementalType:
	if id == 0:
		return element1
	return element2


func is_element(element: ElementalType) -> bool:
	return element1 == element or element2 == element


## Teaches actor spell contained within scroll.
## If spell already exists at index, places old spell into inventory.
## If the actor does not meet the requirements, return an array containing the unmet requirements.
func replace_attack(scroll: SpellScroll, index:=-1) -> Array[ItemRequirement]:
	if scroll == null:
		# Prevent player from removing their last attack.
		if attacks.count(null) == len(attacks) - 1: return []

		var attack := attacks[index]
		if attack:
			Inventory.find_and_add_spell(attack)
		attacks.remove_at(index)
		attacks.append(null)

		for i in range(index, len(attacks)): spell_learned.emit(attacks[i], i)
		return []

	if index == -1:
		index = attacks.find(null)
		if index == -1:
			index = len(attacks)
	if index >= len(attacks):
		attacks.resize(index + 1)
	
	# E.g. player can only know 1 offensive strike attack at a time.
	# If player is trying to replace a strike move with another strike, 
	# the check_requirements call will fail.
	var prevAttack: Attack = null
	if attacks[index]:
		prevAttack = attacks[index]
		attacks[index] = null
		
	var output := scroll.check_requirements(self)
	if len(output) == 0:
		if prevAttack:
			Inventory.find_and_add_spell(prevAttack)
		attacks[index] = scroll.spell
		spell_learned.emit(scroll.spell, index)
	else:
		push_warning("Could not learn selected Spell(%s). BattleActor(%s) does not meet the following reqs: %s" 
				% [scroll.spell.name, name, str(output) ])
		if prevAttack:
			attacks[index] = prevAttack
	return output


func replace_equipment(item: Equipment) -> void:
	if equipment != null:
		Inventory.add(equipment)
	equipment = item


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
	if action.attack_range == _BattleAction.AttackRange.MELEE:
		return stat_manager.melee_attack
	return stat_manager.ranged_attack


func get_defense_stat(action: _BattleAction) -> float:
	if action.attack_range == _BattleAction.AttackRange.MELEE:
		return stat_manager.melee_defense
	return stat_manager.ranged_defense


## Returns actual amount of damage applied, after accounting for status conditions.
func apply_damage(dmg: int, allowBlocking:=true, data: ActorTurnData=null) -> int:
	if _func_overrides.has(apply_damage.get_method()):
		return _func_overrides.get(apply_damage.get_method()).call(dmg, allowBlocking, data)

	var blocking: StatusEffect = null
	if dmg > 0 and allowBlocking:
		blocking = statuses.blocking

	if blocking:
		dmg = int(float(dmg) * (1.0 - blocking.get_strength()))

		statuses.remove_blocking()
		if data != null:
			data.add_activated_effect(self, blocking.id)

	if dmg != 0:
		current_hp -= dmg
		damage_applied.emit(current_hp)
		if current_hp <= 0 and not aleady_defeated:
			aleady_defeated = true
			was_just_defeated.emit()
	return dmg


func heal(dmg: int, allowOverflow: bool=false) -> int:
	current_hp += dmg
	if not allowOverflow:
		current_hp = min(current_hp, hp)

	damage_applied.emit(current_hp)

	return dmg


func add_status_effect(effect: StatusEffect) -> bool:
	if _func_overrides.has(add_status_effect.get_method()):
		return _func_overrides.get(add_status_effect.get_method()).call(effect)
	else:
		Logger.append_battle_log("%s was applied to %s." % [ effect.name, name ])
		if effect is StatChange:
			stat_manager.add(effect, name)
		else:
			statuses.add(effect)
			status_effect_added.emit(statuses.get_status(effect))

	if alignment_manager and effect.id == StatusEffectManager.StatusEffects.PHOBIC:
		alignment_manager.add(effect.element, -1)

	return true


func remove_status_effect(effect: StatusEffect) -> void:
	Logger.append_battle_log("Actor(%s)'s StatusEffect(%s) was removed." % [ name, effect.name ])
	statuses.remove([effect])
	status_effects_removed.emit([ effect ])


func has_status_effect(effect: StatusEffect) -> bool:
	return statuses.has(effect)


func list_status_effects() -> Array[StatusEffect]:
	return statuses.list()


func resolve_end_of_turn(allies:=[], opponents:=[], data: ActorTurnData=null, useOverride:=true)-> void:
	if useOverride and _func_overrides.has(resolve_end_of_turn.get_method()):
		_func_overrides.get(resolve_end_of_turn.get_method()).call(allies, opponents)
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
	var unnormalizedValues := []
	if alignment_manager and not alignment_manager.alignment_locked:
		Logger.append_battle_log("Normalizing and updating alignment for BattleActor(%s):" % name)
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


func add_func_override(key: StringName, new: Callable) -> void:
	_func_overrides[key] = new


func remove_func_override(key: StringName) -> void:
	_func_overrides.erase(key)


func add_xp(xp: float) -> int:
	if not stat_manager is PlayerStatManager: return 0
	return stat_manager.add_xp(xp)


func level_up(levels:=1, forceReset:=false) -> Dictionary[StatManager.Stats, float]:
	level += levels
	Logger.append_battle_log("BattleActor(%s) is now level(%d)!" % [name, level])

	var output: Dictionary[StatManager.Stats, float] = stat_manager.level_up(levels, forceReset)

	leveled_up.emit()
	return output


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
