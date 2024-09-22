@tool
extends Resource 
class_name BattleActor 

enum Stats { HP, MELEE_ATTACK, RANGED_ATTACK, MELEE_DEFENSE, RANGED_DEFENSE, SPEED, EVASION, MANA, }

const MAX_STAT: int = 1000;

signal was_just_defeated();
signal status_effect_added(effect);
signal status_effects_removed(effect);
signal damage_applied(hp);
signal element_changed(id, element);

@export
var name : String = "Guy"; 

@export_category("Stats")
var statuses = StatusEffectManager.new();
@export
var hp: int: 
	get: return hp 
	set(value):
		hp = value;
		current_hp = value;

var current_hp: int = 100
@export
var melee_attack: int: 
	get: return melee_attack * statuses.melee_attack_mod
	set(value): melee_attack = value; 

@export
var ranged_attack : int: 
	get: return ranged_attack * statuses.ranged_attack_mod
	set(value): ranged_attack = value
@export
var melee_defense : int = 100: 
	get: return melee_defense * statuses.melee_defense_mod
	set(value): melee_defense = value; 
@export
var ranged_defense: int = 100:
	get: return ranged_defense* statuses.ranged_defense_mod
	set(value): ranged_defense = value; 
@export
var speed : int: 
	get: return speed * statuses.speed_mod
	set(value): speed = value; 
@export
var evasion : int:
	get: return evasion * statuses.evasion_mod
	set(value): evasion = value; 
@export
var mana : int = 100

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
var elemental_bias : ElementalType = ElementManager.Blank;
@export
# Attack[]
var attacks: Array[Attack] = []
@export
var sprite_path: PackedScene;
var sprite : Sprite = null;

var is_dissonant: 
	get: statuses.is_dissonant()
var is_flinching: 
	get: statuses.is_flinching()
var in_stasis: 
	get: statuses.in_stasis()
var is_defeated: bool: 
	get: return current_hp <= 0
var prevElement1 : ElementalType = ElementManager.Blank;
var elementCounter1 : int = 0;
var prevElement2 : ElementalType = ElementManager.Blank;
var elementCounter2 : int = 0;

var aleadyDefeated : bool = false;

func set_element(id: int, element: ElementalType) -> String:
	var msg = "";
	if id == 0:
		element1 = element;
	else:
		element2 = element;
	
	sprite.set_element(id, element);
	element_changed.emit(id, element)

	var mod;
	var dmg;
	var effect = statuses.is_phobic(element)
	if effect != null:
		dmg = hp * effect.strength
		current_hp -= dmg
		msg += "%s was hurt by its phobia! (%d damage)" % [ name, dmg ]

	effect = statuses.is_philic(element)
	if effect != null:
		dmg = hp * effect.strength
		current_hp += dmg
		msg += "%s was healed by its philia! (%d hp)" % [ name, dmg ]
	return msg;

func use_gradient_sprite()-> void:
	sprite = Sprite.new();
	sprite.set_gradient_sprite(element1, element2);

static func get_max_stat()-> int:
	return 100000

# public Dictionary<string, int> GetStats() {
# 	return new Dictionary<string, int>() {
# 		{ "hp", hp },
# 		{ "attack", melee_attack },
# 		{ "defense", melee_defense },
# 		{ "speed", melee_defense },
# 	};
# }
func get_stat_from_string(name: String) -> int:
	match name.to_lower().strip_edges():
		"hp","health","max_health","max health": return hp;
		"attack","melee_attack","melee attack": return melee_attack;
		"defense","melee_defense","melee defense": return melee_defense;
		"ranged_attack","ranged attack": return ranged_attack;
		"ranged_defense","ranged defense": return ranged_defense;
		"speed": return speed;
		"evasion": return evasion;
		"mana": return mana;
		_: return -1;

func get_stat(stat) -> int:
	if stat is String:
		return get_stat_from_string(stat)

	match stat:
		Stats.MELEE_ATTACK:
			return melee_attack;
		Stats.MELEE_DEFENSE:
			return melee_defense;
		Stats.RANGED_ATTACK:
			return ranged_attack;
		Stats.RANGED_DEFENSE:
			return ranged_defense;
		Stats.SPEED:
			return speed;
		Stats.EVASION:
			return evasion;
		Stats.MANA:
			return mana;
		_:
			return -1;

func set_stat_from_string(name: String, value: int) -> void:
	# name = Regex.Replace(name, "[-_ ]", "").ToLower().Trim();
	match name:
		"hp","health","maxhealth","maxhp":
			hp = value;
			current_hp = value;
			
		"attack","meleeattack","mattack":
			melee_attack = value;
			
		"defense","meleedefense","mdefense":
			melee_defense = value;
			
		"rangedattack","rattack":
			ranged_attack = value;
			
		"rangeddefense","rdefense": 
			ranged_defense = value;
			
		"speed":
			speed = value;
			
		"evasion":
			evasion = value;
			
		"mana":
			mana = value;
			
func set_stat(stat, value: int) -> void:
	if(stat is String):
		set_stat_from_string(stat, value)
		return

	match stat:
		Stats.MELEE_ATTACK:
			melee_attack = value;
			
		Stats.MELEE_DEFENSE:
			melee_defense = value;
			
		Stats.RANGED_ATTACK:
			ranged_attack = value;
			
		Stats.RANGED_DEFENSE:
			ranged_defense = value;
			
		Stats.SPEED:
			speed = value;
			
		Stats.EVASION:
			evasion = value;
			
		Stats.MANA:
			mana = value;
			
func get_attack_stat(action: BattleAction) -> int:
	if action.attack_range == BattleAction.AttackRange.MELEE:
		return melee_attack;
	return ranged_attack;

func get_defense_stat(action: BattleAction) -> int:
	if action.attack_range == BattleAction.AttackRange.MELEE:
		return melee_defense;
	return ranged_defense;

# Returns actual amount of damage applied, after accounting for status conditions.
func apply_damage(dmg: int, allowBlocking: bool=true) -> int:
	if not (statuses.is_blocking() and allowBlocking):
		current_hp -= dmg;
		damage_applied.emit(current_hp)
		if current_hp <= 0 and not aleadyDefeated:
			aleadyDefeated = true;
			was_just_defeated.emit()
		return dmg;
	return 0;

func add_status_effect(effect: StatusEffect) -> void:
	statuses.add_status(effect);
	status_effect_added.emit(statuses.get_status(effect))

func remove_status_effect(effect: StatusEffect) -> void:
	statuses.remove(effect);
	status_effects_removed.emit([ effect ])

func has_status_effect(effect: StatusEffect) -> bool:
	return statuses.get_status(effect) != null;

func update_elemental_state()-> void:
	if(prevElement1 == element1): elementCounter1 += 1;
	else: elementCounter1 = 0;

	if(prevElement2 == element2): elementCounter2 += 1;
	else: elementCounter2 = 0;

	prevElement1 = element1;
	prevElement2 = element2;

func try_revert_to_bias()-> bool:
	return false;

func list_status_effects():
	return statuses.list();

func resolve_end_of_turn()-> String:
	# Calc poison and healing.
	var msg = "";
	var mod = 0;
	var poison = statuses.poison;
	var healing = statuses.healing;

	if poison > 0:
		mod += poison;
		msg += "%s was hurt by poison (%d dmg)!\n" % [ name, poison * hp]
	if healing > 0:
		mod -= healing;
		msg += "%s recovered %d health!" % [ name, hp * healing]
	current_hp -= hp * mod;
	damage_applied.emit(current_hp)

	var effects = statuses.calculate_expirations();
	status_effects_removed.emit(effects)
	return msg;
