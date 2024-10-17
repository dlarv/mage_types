@tool
extends Resource 
class_name BattleActor 

enum Stats { MELEE_ATTACK, RANGED_ATTACK, MELEE_DEFENSE, RANGED_DEFENSE, SPEED, EVASION, HP, MANA, STAMINA }

signal was_just_defeated()
signal status_effect_added(effect)
signal status_effects_removed(effect)
signal damage_applied(hp)
signal element_changed(id, element)

@export
var name : String = "Guy" 
var level: int = 1
var xp: float = 0

@export_category("Stats")
var statuses = StatusEffectManager.new()
@export var stat_manager = StatManager.new()
@export
var hp: int = 100:
	get: return hp 
	set(value):
		hp = value
		current_hp = value
var current_hp: int = 100
@export var affinity_manager = AffinityManager.new()


var speed: float:
	get: return stat_manager.speed
var evasion: float:
	get: return stat_manager.evasion

@export_category("General")
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element1: String = "blue":
	get:
		return _element1
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
	get:
		return _element2
	set(value):
		_element2 = value
		element2 = ElementManager.get_element_from_name(value)
var element2: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element2 = value 
@export
var elemental_bias : ElementalType = ElementManager.Blank
@export
# Attack[]
var attacks: Array[BattleAction] = []
@export
var sprite_path: PackedScene
var sprite : Sprite = null

var dissonant: StatusEffect: 
	get: return statuses.check_dissonant()
var flinching: StatusEffect: 
	get: return statuses.check_flinching()
var stasis: StatusEffect: 
	get: return statuses.check_stasis()
var is_defeated: bool: 
	get: return current_hp <= 0

var aleady_defeated: bool = false

func set_element(id: int, element: ElementalType) -> Array:
	var msg := []
	if id == 0:
		element1 = element
	else:
		element2 = element
	
	if not element.is_blank():
		var affinity = affinity_manager.set_element(id, element)
		msg.append("%s gained %d %s affinity!" % [name, affinity, element.get_bb_code_name()])
	sprite.set_element(id, element)
	element_changed.emit(id, element)

	var mod
	var dmg = 0
	var effect = statuses.check_phobic(element)
	if effect != null:
		dmg = hp * effect.strength
		current_hp -= dmg
		msg.append("%s was hurt by its phobia! (%d damage)" % [ name, dmg ])

	effect = statuses.check_philic(element)
	if effect != null:
		dmg = hp * effect.strength
		current_hp += dmg
		msg.append("%s was healed by its philia! (%d hp)" % [ name, dmg ])
	if dmg != 0:
		apply_damage(dmg)

	return msg

func get_element(id: int) -> ElementalType:
	if id == 0:
		return element1
	return element2

# Teaches actor spell contained within scroll.
# If the actor does not meet the requirements, return an array containing the unmet requirements.
func learn_spell(index: int, scroll: SpellScroll) -> Array:
	if index >= len(attacks):
		attacks.resize(index + 1)
	
	var output := scroll.check_requirements(self)
	if len(output) == 0:
		attacks[index] = scroll.spell
	return output

func use_gradient_sprite()-> void:
	sprite = Sprite.new()
	sprite.set_gradient_sprite(element1, element2)

func get_stat(stat: StatManager.Stat) -> float:
	return stat_manager.get_stat(stat)

func set_stat(stat: StatManager.Stat, amount: float) -> void:
	stat_manager.set_stat(stat, amount)
			
func get_attack_stat(action: BattleAction) -> int:
	if action.attack_range == BattleAction.AttackRange.MELEE:
		return stat_manager.melee_attack
	return stat_manager.ranged_attack

func get_defense_stat(action: BattleAction) -> int:
	if action.attack_range == BattleAction.AttackRange.MELEE:
		return stat_manager.melee_defense
	return stat_manager.ranged_defense

# Returns actual amount of damage applied, after accounting for status conditions.
func apply_damage(dmg: int, allowBlocking: bool=true) -> int:
	if not (statuses.check_blocking() and allowBlocking):
		current_hp -= dmg
		damage_applied.emit(current_hp)
		if current_hp <= 0 and not aleady_defeated:
			aleady_defeated = true
			was_just_defeated.emit()
		return dmg
	return 0

func add_status_effect(effect: StatusEffect) -> void:
	Logger.append_log(Logger.LogType.BATTLE, "%s was applied to %s." % [ effect.name, name ])
	if effect is StatChange:
		stat_manager.add(effect, name)
	else:
		statuses.add_status(effect)
		status_effect_added.emit(statuses.get_status(effect))

func remove_status_effect(effect: StatusEffect) -> void:
	Logger.append_log(Logger.LogType.BATTLE, "%s's %s expired." % [ effect.name, name ])
	statuses.remove([effect])
	status_effects_removed.emit([ effect ])

func has_status_effect(effect: StatusEffect) -> bool:
	return statuses.get_status(effect) != null


## Subtracts amount from the element's total affinity.
## If amount > affinity, return affinity / amount.
## If amount == 0, character had no affinity to begin with
func lose_affinity(element: ElementalType, amount: int) -> float:
	return affinity_manager.lose_affinity(element, amount)

func get_affinity_for(element: ElementalType) -> float:
	return affinity_manager.affinities[element]

func try_revert_to_bias()-> bool:
	return false

func list_status_effects() -> Array:
	return statuses.list()

func resolve_end_of_turn()-> Array:
	# Calc poison and healing.
	var msg = []
	var mod = 0
	var poison = statuses.poison
	var healing = statuses.healing

	if poison > 0:
		mod += poison
		msg.append("%s was hurt by poison (%d dmg)!" % [ name, poison * hp])
	if healing > 0:
		mod -= healing
		msg.append("%s recovered %d health!" % [ name, hp * healing])
	current_hp -= hp * mod
	damage_applied.emit(current_hp)

	# Calculate consecutive turn affinity, if any.
	var bonus := affinity_manager.gain_affinity(element1, AffinityManager.BonusReason.CONSECUTIVE)
	if bonus > 0:
		msg.append("%s has spent %d consecutive turns as %s. Gained %d affinity!" % [name, bonus / affinity_manager.CONSECUTIVE_BONUS, element1.get_bb_code_name(), bonus])

	bonus = affinity_manager.gain_affinity(element2, AffinityManager.BonusReason.CONSECUTIVE)
	if bonus > 0:
		msg.append("%s has spent %d consecutive turns as %s. Gained %d affinity!" % [name, bonus / affinity_manager.CONSECUTIVE_BONUS, element2.get_bb_code_name(), bonus])

	var effects = statuses.calculate_expirations()
	status_effects_removed.emit(effects)
	return msg
