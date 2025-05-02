@tool
extends Resource 
class_name BattleActor 

signal battle_setup_completed
@warning_ignore("unused_signal")
signal turn_ended()
signal was_just_defeated()
signal status_effect_added(effect)
signal status_effects_removed(effect)
signal damage_applied(current_hp)
signal element_changed(id, element)
signal spell_learned(spell, index)
signal equipment_equipped(equipment)
## Called when opponents choose their action during battle.
@warning_ignore("unused_signal")
signal action_selected(action: _BattleAction)

@export var name: String = "Guy" 
@export var level: int = 1
var xp: float = 0

@export_category("Stats")
var statuses := StatusEffectManager.new()
@export var stat_manager := StatManager.new()
@export var hp: int = 100:
	set(value):
		hp = value
		current_hp = value
var current_hp: int = 100
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

var _msgs := []
# Dict<StringName, Callable> 
var _func_overrides := {}


func setup() -> void:
	battle_setup_completed.emit()


func get_and_flush_msgs() -> Array:
	var output = _msgs
	_msgs = []

	if equipment != null:
		var equipmentMsgs := equipment.get_and_flush_msgs()
		if len(equipmentMsgs) > 0:
			output.append("%s's %s activated!" % [name, equipment.name])
			output.append_array(equipmentMsgs)
	
	return output

func set_element(id: int, element: ElementalType) -> void:
	if id == 0:
		element1 = element
	else:
		element2 = element

	element_changed.emit(id, element)
	if alignment_manager:
		alignment_manager.append_unnormalized(element, 1, AlignmentManager.Type.TRANSMUTATION)

	var mod
	var dmg = 0
	var effect = statuses.check_phobic(element)
	if effect != null:
		dmg = hp * effect.strength
		_msgs.append("%s was hurt by its phobia! (%d damage)" % [ name, dmg ])

	if dmg != 0:
		apply_damage(dmg, false)

func get_element(id: int) -> ElementalType:
	if id == 0:
		return element1
	return element2

func is_element(element: ElementalType) -> bool:
	return element1 == element or element2 == element

# Teaches actor spell contained within scroll.
# If the actor does not meet the requirements, return an array containing the unmet requirements.
func learn_spell(scroll: SpellScroll, index:=-1) -> Array:
	if scroll == null:
		var attack = attacks[index]
		if attack:
			Inventory.add_spell(attack)
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
		if attacks[index]:
			Inventory.add_spell(attacks[index])
		attacks[index] = scroll.spell
		spell_learned.emit(scroll.spell, index)
	else:
		print("Could not learn selected Spell(%s). BattleActor(%s) does not meet the following reqs: %s" 
				% [scroll.spell.name, name, str(output) ])
		if prevAttack:
			attacks[index] = prevAttack
	return output

func get_stat(stat: StatManager.Stats) -> float:
	return stat_manager.get_stat(stat)

func set_stat(stat: Variant, amount: float) -> void:
	if stat == "HP":
		hp = int(amount)
		current_hp = int(amount)
	elif stat == "CURRENT_HP":
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
func apply_damage(dmg: int, allowBlocking: bool=true) -> int:
	if _func_overrides.has(apply_damage.get_method()):
		return _func_overrides.get(apply_damage.get_method()).call(dmg, allowBlocking, self)

	var blocking = null
	if dmg > 0 and allowBlocking:
		blocking = statuses.blocking

	if blocking:
		dmg *= 1 - blocking.strength
		if statuses.remove_blocking():
			status_effects_removed.emit([blocking])

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


func add_status_effect(effect: StatusEffect) -> void:
	if _func_overrides.has(add_status_effect.get_method()):
		_func_overrides.get(add_status_effect.get_method()).call(effect)
	else:
		Logger.append_battle_log("%s was applied to %s." % [ effect.name, name ])
		if effect is StatChange:
			stat_manager.add(effect, name)
		else:
			statuses.add(effect)
			status_effect_added.emit(statuses.get_status(effect))

	if alignment_manager and effect.id == StatusEffectManager.StatusEffects.PHOBIC:
		alignment_manager.add(effect.element, -1)


func remove_status_effect(effect: StatusEffect) -> void:
	Logger.append_battle_log("%s's %s expired." % [ name, effect.name ])
	statuses.remove([effect])
	status_effects_removed.emit([ effect ])


func has_status_effect(effect: StatusEffect) -> bool:
	return statuses.has(effect)


func list_status_effects() -> Array:
	return statuses.list()


func resolve_end_of_turn(allies:=[], opponents:=[], useOverride:=true)-> void:
	if useOverride and _func_overrides.has(resolve_end_of_turn.get_method()):
		_func_overrides.get(resolve_end_of_turn.get_method()).call(allies, opponents)
		return 
	# Calc poison and healing.
	var mod = 0
	var poison = statuses.poison
	var healing = statuses.healing

	if poison > 0:
		mod += poison
		_msgs.append("%s was hurt by poison (%d dmg)!" % [ name, poison * hp])
	if healing > 0:
		mod -= healing
		_msgs.append("%s recovered %d health!" % [ name, hp * healing])
	apply_damage(hp * mod, false)

	var effects = statuses.calculate_expirations()
	if len(effects) > 0:
		_msgs.append("Status effects wore off! (%s)" % effects.map(func(x): return x.name))
	status_effects_removed.emit(effects)


func resolve_end_of_battle() -> String:
	stat_manager.reset()
	statuses.clear()
	if reset_hp_after_battle: 
		current_hp = hp
	
	# Update alignment.
	if alignment_manager and not alignment_manager.alignment_locked:
		Logger.append_battle_log("Normalizing and updating alignment for BattleActor(%s):" % name)
		var prevAlign := alignment_manager.current_alignment
		var alignmentLocked := alignment_manager.normalize_and_add()
		if alignmentLocked:
			set_element(0, alignment_manager.current_alignment)
			return "!!!!!!!!!!!!!!\n%s has become aligned to %s!" \
					% [name, alignment_manager.current_alignment.name]
		elif prevAlign != alignment_manager.current_alignment:
			set_element(0, alignment_manager.current_alignment)
			return "!!!\n%s's core changed to %s!" \
					% [name, alignment_manager.current_alignment.name]
	return ""

func has_phobia(element: ElementalType=null) -> bool:
	# If value is null, return true if they have any phobias.
	if not element: return len(statuses.phobias) > 0
	return statuses.check_phobic(element) != null

func add_func_override(old: Callable, new: Callable) -> void:
	_func_overrides[old.get_method()] = new

func remove_func_override(old: Callable) -> void:
	_func_overrides.erase(old.get_method())

func serialize() -> Dictionary:
	var attackData := []
	for attack in attacks:
		attackData.append(attack.resource_path)
	var equipmentData := ""
	if equipment:
		equipmentData = equipment.resource_path
	
	var alignmentData := ""
	if alignment_manager:
		alignment_manager.serialize()

	return {
		"name": name,
		# "statuses": statuses.serialize(),
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
	# if "statuses" in data:
	# 	# statuses.deserialize(data["statuses"])
	# 	statuses
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
		for d in data["attacks"]:
			attacks.append(ResourceLoader.load(d))
	if "equipment" in data:
		var d = data["equipment"]
		if not d.is_empty():
			equipment = ResourceLoader.load(d)
		else:
			equipment = null
	if "alignment" in data:
		if not alignment_manager:
			alignment_manager = AlignmentManager.new()
		alignment_manager.deserialize(data["alignment"])
